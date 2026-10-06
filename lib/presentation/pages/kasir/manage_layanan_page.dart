import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/section_card.dart';
import '../../../domain/entities/layanan.dart';
import '../../providers/layanan_provider.dart';
import 'layanan_form_page.dart';

/// FR-9: kasir/admin mengelola (tambah/ubah/hapus) data layanan & harga.
class ManageLayananPage extends ConsumerWidget {
  const ManageLayananPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(layananManagementProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Layanan')),
      body: state.isLoading && state.items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.error != null && state.items.isEmpty
              ? AppErrorView(
                  message: 'Gagal memuat data layanan',
                  onRetry: () => ref.read(layananManagementProvider.notifier).load(),
                )
              : state.items.isEmpty
                  ? const EmptyStateWidget(icon: Icons.local_laundry_service_outlined, title: 'Belum ada layanan')
                  : RefreshIndicator(
                      onRefresh: () => ref.read(layananManagementProvider.notifier).load(),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(AppSizes.md),
                        itemCount: state.items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
                        itemBuilder: (context, i) => _LayananTile(layanan: state.items[i]),
                      ),
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LayananFormPage())),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah'),
      ),
    );
  }
}

class _LayananTile extends ConsumerWidget {
  final Layanan layanan;
  const _LayananTile({required this.layanan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SectionCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: layanan.isActive ? AppColors.primaryLight : AppColors.divider,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Icon(Icons.local_laundry_service_rounded,
                color: layanan.isActive ? AppColors.primary : AppColors.textSecondary),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(layanan.namaLayanan, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text('${AppFormatters.currency(layanan.hargaPerUnit)} / ${layanan.satuan}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                if (!layanan.isActive)
                  const Text('Nonaktif', style: TextStyle(color: AppColors.danger, fontSize: 11.5)),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'edit') {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => LayananFormPage(layanan: layanan)));
              } else if (value == 'delete') {
                final confirmed = await showConfirmDialog(
                  context,
                  title: 'Hapus Layanan',
                  message: 'Yakin ingin menghapus "${layanan.namaLayanan}"?',
                  destructive: true,
                );
                if (!confirmed) return;
                final success = await ref.read(layananManagementProvider.notifier).delete(layanan.id!);
                if (!context.mounted) return;
                if (success) {
                  AppSnackbar.success(context, 'Layanan dihapus');
                } else {
                  AppSnackbar.error(context, 'Gagal menghapus layanan');
                }
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Hapus')),
            ],
          ),
        ],
      ),
    );
  }
}
