import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/section_card.dart';
import '../../../domain/entities/pelanggan.dart';
import '../../providers/pelanggan_provider.dart';

/// FR-9: kasir/admin mengelola data pelanggan.
class ManagePelangganPage extends ConsumerStatefulWidget {
  const ManagePelangganPage({super.key});

  @override
  ConsumerState<ManagePelangganPage> createState() => _ManagePelangganPageState();
}

class _ManagePelangganPageState extends ConsumerState<ManagePelangganPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pelangganManagementProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Data Pelanggan')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Cari nama atau email pelanggan...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onSubmitted: (v) => ref.read(pelangganManagementProvider.notifier).load(search: v),
            ),
          ),
          Expanded(
            child: state.isLoading && state.items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.error != null && state.items.isEmpty
                    ? AppErrorView(
                        message: 'Gagal memuat data pelanggan',
                        onRetry: () => ref.read(pelangganManagementProvider.notifier).load(),
                      )
                    : state.items.isEmpty
                        ? const EmptyStateWidget(icon: Icons.people_outline_rounded, title: 'Belum ada pelanggan')
                        : RefreshIndicator(
                            onRefresh: () => ref.read(pelangganManagementProvider.notifier).load(),
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                              itemCount: state.items.length,
                              separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
                              itemBuilder: (context, i) => _PelangganTile(pelanggan: state.items[i]),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _PelangganTile extends ConsumerWidget {
  final Pelanggan pelanggan;
  const _PelangganTile({required this.pelanggan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SectionCard(
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.primaryLight,
            child: Icon(Icons.person_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pelanggan.nama, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(pelanggan.email, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                Text(pelanggan.noTelepon, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
            onPressed: () async {
              final confirmed = await showConfirmDialog(
                context,
                title: 'Hapus Pelanggan',
                message: 'Yakin ingin menghapus data "${pelanggan.nama}"? Seluruh riwayat pesanannya juga akan terhapus.',
                destructive: true,
              );
              if (!confirmed) return;
              final success = await ref.read(pelangganManagementProvider.notifier).delete(pelanggan.id!);
              if (!context.mounted) return;
              if (success) {
                AppSnackbar.success(context, 'Data pelanggan dihapus');
              } else {
                AppSnackbar.error(context, 'Gagal menghapus data pelanggan');
              }
            },
          ),
        ],
      ),
    );
  }
}
