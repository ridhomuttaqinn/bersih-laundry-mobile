import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/section_card.dart';
import '../../../domain/entities/app_user.dart';
import '../../providers/user_provider.dart';
import 'user_form_page.dart';

/// Use case "Mengelola Data Akun" oleh Pemilik: menambah/menonaktifkan akun kasir.
class ManageUserPage extends ConsumerWidget {
  const ManageUserPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userManagementProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Data Akun')),
      body: state.isLoading && state.items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.error != null && state.items.isEmpty
              ? AppErrorView(
                  message: 'Gagal memuat data akun',
                  onRetry: () => ref.read(userManagementProvider.notifier).load(),
                )
              : state.items.isEmpty
                  ? const EmptyStateWidget(icon: Icons.admin_panel_settings_outlined, title: 'Belum ada akun')
                  : RefreshIndicator(
                      onRefresh: () => ref.read(userManagementProvider.notifier).load(),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(AppSizes.md),
                        itemCount: state.items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
                        itemBuilder: (context, i) => _UserTile(user: state.items[i]),
                      ),
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UserFormPage())),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Tambah Akun'),
      ),
    );
  }
}

class _UserTile extends ConsumerWidget {
  final AppUser user;
  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPemilik = user.role == AppRole.pemilik;

    return SectionCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isPemilik ? AppColors.primaryLight : AppColors.divider,
            child: Icon(
              isPemilik ? Icons.storefront_rounded : Icons.support_agent_rounded,
              color: isPemilik ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.nama, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text('@${user.username} • ${isPemilik ? 'Pemilik' : 'Kasir'}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                if (!user.isActive)
                  const Text('Nonaktif', style: TextStyle(color: AppColors.danger, fontSize: 11.5)),
              ],
            ),
          ),
          Switch(
            value: user.isActive,
            activeTrackColor: AppColors.success,
            onChanged: (value) async {
              final success = await ref.read(userManagementProvider.notifier).toggleActive(user.id!, value);
              if (!context.mounted) return;
              if (!success) AppSnackbar.error(context, 'Gagal memperbarui status akun');
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
            onPressed: () async {
              final confirmed = await showConfirmDialog(
                context,
                title: 'Hapus Akun',
                message: 'Yakin ingin menghapus akun "${user.nama}"?',
                destructive: true,
              );
              if (!confirmed) return;
              final success = await ref.read(userManagementProvider.notifier).delete(user.id!);
              if (!context.mounted) return;
              if (success) {
                AppSnackbar.success(context, 'Akun dihapus');
              } else {
                AppSnackbar.error(context, 'Gagal menghapus akun');
              }
            },
          ),
        ],
      ),
    );
  }
}
