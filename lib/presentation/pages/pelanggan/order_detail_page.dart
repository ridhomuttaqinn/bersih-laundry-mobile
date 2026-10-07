import '../../../core/widgets/pickup_navigation_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/pdf_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/section_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../domain/entities/pesanan.dart';
import '../../providers/payment_provider.dart';
import '../../providers/pesanan_provider.dart';

/// FR-4 & FR-7: pelanggan melihat status pesanan secara rinci beserta nota
/// pembayaran (jika sudah dibayar).
class OrderDetailPage extends ConsumerWidget {
  final int orderId;
  const OrderDetailPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      appBar: AppBar(title: Text('Pesanan #$orderId')),
      body: orderAsync.when(
        data: (order) => _OrderDetailBody(order: order),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorView(
          message: 'Gagal memuat detail pesanan',
          onRetry: () => ref.invalidate(orderDetailProvider(orderId)),
        ),
      ),
    );
  }
}

class _OrderDetailBody extends ConsumerWidget {
  final Pesanan order;
  const _OrderDetailBody({required this.order});

  static const _timelineSteps = [
    OrderStatus.diterima,
    OrderStatus.diproses,
    OrderStatus.selesai,
    OrderStatus.diambil,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentAsync = ref.watch(paymentByOrderProvider(order.id!));
    final isRejected = order.statusPesanan == OrderStatus.ditolak;

    return ListView(
      padding: const EdgeInsets.all(AppSizes.md),
      children: [
        SectionCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppFormatters.dateTime(order.tanggalMasuk), style: const TextStyle(color: AppColors.textSecondary)),
              StatusBadge(status: order.statusPesanan, fontSize: 13),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.md),
        if (isRejected)
          SectionCard(
            child: Row(
              children: [
                const Icon(Icons.cancel_rounded, color: AppColors.danger),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    'Pesanan ditolak. Alasan: ${order.catatanPenolakan ?? '-'}',
                    style: const TextStyle(color: AppColors.danger),
                  ),
                ),
              ],
            ),
          )
        else
          _StatusTimeline(currentStatus: order.statusPesanan, steps: _timelineSteps),
        const SizedBox(height: AppSizes.lg),
        Text('Informasi Penjemputan', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSizes.sm),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoRow(icon: Icons.location_on_outlined, label: 'Alamat', value: order.alamatJemput),
              PickupNavigationButton(address: order.alamatJemput),
              const Divider(height: 20),
              _InfoRow(icon: Icons.event_outlined, label: 'Jadwal', value: order.jadwalJemput),
              if (order.namaKasir != null) ...[
                const Divider(height: 20),
                _InfoRow(icon: Icons.badge_outlined, label: 'Ditangani oleh', value: order.namaKasir!),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSizes.lg),
        Text('Rincian Layanan', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSizes.sm),
        SectionCard(
          child: Column(
            children: [
              for (final item in order.items) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text('${item.layanan.namaLayanan}  ×  ${item.beratQty} ${item.layanan.satuan}'),
                    ),
                    Text(AppFormatters.currency(item.subtotal), style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                if (item != order.items.last) const Divider(height: 20),
              ],
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontWeight: FontWeight.w700)),
                  Text(
                    AppFormatters.currency(order.totalBayar),
                    style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.lg),
        paymentAsync.when(
          data: (payment) {
            if (payment == null) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Pembayaran', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSizes.sm),
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(
                        icon: Icons.payments_outlined,
                        label: 'Metode',
                        value: PaymentMethod.label(payment.metodeBayar),
                      ),
                      const Divider(height: 20),
                      _InfoRow(
                        icon: Icons.check_circle_outline,
                        label: 'Dibayar pada',
                        value: AppFormatters.dateTime(payment.tanggalBayar),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                OutlinedButton.icon(
                  onPressed: () async {
                    final bytes = await PdfService.generateNota(pesanan: order, pembayaran: payment);
                    await PdfService.printOrShare(bytes, fileName: 'nota_pesanan_${order.id}.pdf');
                  },
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('Lihat / Bagikan Nota'),
                ),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final String currentStatus;
  final List<String> steps;
  const _StatusTimeline({required this.currentStatus, required this.steps});

  @override
  Widget build(BuildContext context) {
    final currentIndex = steps.indexOf(currentStatus);
    return SectionCard(
      child: Column(
        children: List.generate(steps.length, (i) {
          final done = i <= currentIndex;
          final isLast = i == steps.length - 1;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Icon(
                    done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    color: done ? AppColors.success : AppColors.divider,
                    size: 22,
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 32,
                      color: done && i < currentIndex ? AppColors.success : AppColors.divider,
                    ),
                ],
              ),
              const SizedBox(width: AppSizes.sm),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  OrderStatus.label(steps[i]),
                  style: TextStyle(
                    fontWeight: done ? FontWeight.w700 : FontWeight.w400,
                    color: done ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Text(value, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}
