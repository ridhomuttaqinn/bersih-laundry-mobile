import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/section_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../domain/entities/pesanan.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pesanan_provider.dart';
import 'order_detail_page.dart';

/// FR-4 & FR-8: melihat status pesanan real-time dan riwayat transaksi.
class OrderHistoryPage extends ConsumerWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authProvider).session;
    final ordersAsync = ref.watch(orderHistoryProvider(session!.id));

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pesanan')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(orderHistoryProvider(session.id)),
        child: ordersAsync.when(
          data: (orders) {
            if (orders.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  EmptyStateWidget(
                    icon: Icons.receipt_long_outlined,
                    title: 'Belum ada pesanan',
                    subtitle: 'Riwayat transaksi laundry Anda akan tampil di sini',
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSizes.md),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
              itemBuilder: (context, index) => _OrderTile(order: orders[index]),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => AppErrorView(
            message: 'Gagal memuat riwayat pesanan',
            onRetry: () => ref.invalidate(orderHistoryProvider(session.id)),
          ),
        ),
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final Pesanan order;
  const _OrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => OrderDetailPage(orderId: order.id!))),
      child: SectionCard(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pesanan #${order.id}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    AppFormatters.dateTime(order.tanggalMasuk),
                    style: const TextStyle(fontSize: 12.5, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppFormatters.currency(order.totalBayar),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            StatusBadge(status: order.statusPesanan),
          ],
        ),
      ),
    );
  }
}
