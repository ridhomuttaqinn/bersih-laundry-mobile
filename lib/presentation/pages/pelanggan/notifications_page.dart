import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notifikasi_provider.dart';

/// FR-5: pelanggan melihat riwayat notifikasi perubahan status pesanan.
class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authProvider).session;
    final notifAsync = ref.watch(notifikasiListProvider(session!.id));

    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(notifikasiListProvider(session.id)),
        child: notifAsync.when(
          data: (list) {
            if (list.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  EmptyStateWidget(
                    icon: Icons.notifications_none_rounded,
                    title: 'Belum ada notifikasi',
                    subtitle: 'Pembaruan status pesanan Anda akan muncul di sini',
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSizes.md),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
              itemBuilder: (context, index) {
                final notif = list[index];
                return Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: notif.dibaca ? AppColors.surface : AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.local_laundry_service_rounded,
                        color: notif.dibaca ? AppColors.textSecondary : AppColors.primary,
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notif.pesan, style: const TextStyle(fontSize: 14)),
                            const SizedBox(height: 4),
                            Text(
                              AppFormatters.relativeFromNow(notif.createdAt),
                              style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => AppErrorView(
            message: 'Gagal memuat notifikasi',
            onRetry: () => ref.invalidate(notifikasiListProvider(session.id)),
          ),
        ),
      ),
    );
  }
}
