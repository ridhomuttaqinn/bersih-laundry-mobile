import '../../../core/widgets/pickup_navigation_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/section_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/pesanan.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pesanan_provider.dart';
import 'payment_page.dart';

/// Activity diagram: kasir menerima & memeriksa pesanan → valid? → proses/tolak
/// → memperbarui status → (lanjut ke pembayaran & cetak nota).
class OrderProcessPage extends ConsumerWidget {
  final int orderId;
  const OrderProcessPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      appBar: AppBar(title: Text('Kelola Pesanan #$orderId')),
      body: orderAsync.when(
        data: (order) => _ProcessBody(order: order),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorView(
          message: 'Gagal memuat pesanan',
          onRetry: () => ref.invalidate(orderDetailProvider(orderId)),
        ),
      ),
    );
  }
}

class _ProcessBody extends ConsumerWidget {
  final Pesanan order;
  const _ProcessBody({required this.order});

  Future<void> _reject(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final alasan = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tolak Pesanan'),
        content: AppTextField(
          controller: controller,
          label: 'Alasan penolakan',
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Tolak', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (alasan == null || alasan.isEmpty || !context.mounted) return;

    final session = ref.read(authProvider).session!;
    final success = await ref.read(orderActionProvider.notifier).rejectOrder(order.id!, session.id, alasan);

    if (!context.mounted) return;
    if (success) {
      AppSnackbar.success(context, 'Pesanan ditolak');
      ref.invalidate(orderDetailProvider(order.id!));
      ref.invalidate(incomingOrdersProvider(null));
    } else {
      AppSnackbar.error(context, ref.read(orderActionProvider).error?.message ?? 'Gagal menolak pesanan');
    }
  }

  Future<void> _process(BuildContext context, WidgetRef ref) async {
    final session = ref.read(authProvider).session!;
    final success = await ref.read(orderActionProvider.notifier).processOrder(order.id!, session.id);

    if (!context.mounted) return;
    if (success) {
      AppSnackbar.success(context, 'Pesanan mulai diproses');
      ref.invalidate(orderDetailProvider(order.id!));
      ref.invalidate(incomingOrdersProvider(null));
    } else {
      AppSnackbar.error(context, ref.read(orderActionProvider).error?.message ?? 'Gagal memproses pesanan');
    }
  }

  Future<void> _updateStatus(BuildContext context, WidgetRef ref, String status) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Perbarui Status',
      message: 'Ubah status pesanan menjadi "${OrderStatus.label(status)}"?',
    );
    if (!confirmed) return;

    final success = await ref.read(orderActionProvider.notifier).updateStatus(order.id!, status);
    if (!context.mounted) return;

    if (success) {
      AppSnackbar.success(context, 'Status diperbarui');
      ref.invalidate(orderDetailProvider(order.id!));
      ref.invalidate(incomingOrdersProvider(null));
    } else {
      AppSnackbar.error(context, ref.read(orderActionProvider).error?.message ?? 'Gagal memperbarui status');
    }
  }

  Future<void> _confirmWeight(BuildContext context, WidgetRef ref) async {
    final controllers = <int, TextEditingController>{
      for (final item in order.items) item.id!: TextEditingController(text: item.beratQty.toString()),
    };
    final formKey = GlobalKey<FormState>();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLg)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSizes.lg,
            right: AppSizes.lg,
            top: AppSizes.lg,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.lg,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Konfirmasi Berat Aktual', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                const Text(
                  'Masukkan hasil timbangan aktual untuk tiap item. Total pesanan akan '
                  'dihitung ulang otomatis.',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSizes.md),
                for (final item in order.items) ...[
                  AppTextField(
                    controller: controllers[item.id!]!,
                    label: '${item.layanan.namaLayanan} (${item.layanan.satuan})',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => Validators.positiveNumber(v, field: 'Berat aktual'),
                  ),
                  const SizedBox(height: AppSizes.sm),
                ],
                const SizedBox(height: AppSizes.sm),
                AppPrimaryButton(
                  label: 'Simpan & Hitung Ulang Total',
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.pop(context, true);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    final beratAktual = controllers.map(
      (idDetail, c) => MapEntry(idDetail, double.parse(c.text.replaceAll(',', '.'))),
    );

    final success = await ref.read(orderActionProvider.notifier).confirmActualWeight(order.id!, beratAktual);
    if (!context.mounted) return;

    if (success) {
      AppSnackbar.success(context, 'Berat aktual dikonfirmasi & total diperbarui');
      ref.invalidate(orderDetailProvider(order.id!));
      ref.invalidate(incomingOrdersProvider(null));
    } else {
      AppSnackbar.error(context, ref.read(orderActionProvider).error?.message ?? 'Gagal mengonfirmasi berat');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionState = ref.watch(orderActionProvider);

    return ListView(
      padding: const EdgeInsets.all(AppSizes.md),
      children: [
        SectionCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.namaPelanggan ?? '-', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  Text(AppFormatters.dateTime(order.tanggalMasuk),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                ],
              ),
              StatusBadge(status: order.statusPesanan, fontSize: 13),
            ],
          ),
        ),
        // Revisi poin #4: kartu peringatan ini hanya muncul untuk pesanan
        // yang beratnya masih estimasi pelanggan (`berat_dikonfirmasi = 0`)
        // dan belum ditolak — mendorong kasir mengonfirmasi sebelum lanjut.
        if (!order.beratDikonfirmasi && order.statusPesanan != OrderStatus.ditolak) ...[
          const SizedBox(height: AppSizes.md),
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: AppColors.warning.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.scale_outlined, color: AppColors.warning),
                const SizedBox(width: AppSizes.sm),
                const Expanded(
                  child: Text(
                    'Berat masih estimasi pelanggan. Timbang ulang & konfirmasi agar total akurat.',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: () => _confirmWeight(context, ref),
                  child: const Text('Konfirmasi'),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSizes.md),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _row(Icons.location_on_outlined, 'Alamat', order.alamatJemput),
              PickupNavigationButton(address: order.alamatJemput),
              const Divider(height: 20),
              _row(Icons.event_outlined, 'Jadwal', order.jadwalJemput),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.md),
        Text('Rincian Layanan', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSizes.sm),
        SectionCard(
          child: Column(
            children: [
              for (final item in order.items)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(child: Text('${item.layanan.namaLayanan} × ${item.beratQty} ${item.layanan.satuan}')),
                      Text(AppFormatters.currency(item.subtotal)),
                    ],
                  ),
                ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontWeight: FontWeight.w700)),
                  Text(AppFormatters.currency(order.totalBayar),
                      style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.lg),
        _ActionSection(order: order, isLoading: actionState.isLoading, onReject: () => _reject(context, ref),
            onProcess: () => _process(context, ref),
            onUpdateStatus: (s) => _updateStatus(context, ref, s)),
      ],
    );
  }

  Widget _row(IconData icon, String label, String value) {
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
              Text(value),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionSection extends StatelessWidget {
  final Pesanan order;
  final bool isLoading;
  final VoidCallback onReject;
  final VoidCallback onProcess;
  final void Function(String) onUpdateStatus;

  const _ActionSection({
    required this.order,
    required this.isLoading,
    required this.onReject,
    required this.onProcess,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    switch (order.statusPesanan) {
      case OrderStatus.diterima:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : onReject,
                icon: const Icon(Icons.close_rounded, color: AppColors.danger),
                label: const Text('Tolak', style: TextStyle(color: AppColors.danger)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.danger)),
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: AppPrimaryButton(label: 'Proses Pesanan', isLoading: isLoading, onPressed: onProcess),
            ),
          ],
        );
      case OrderStatus.diproses:
        return AppPrimaryButton(
          label: 'Tandai Selesai',
          isLoading: isLoading,
          onPressed: () => onUpdateStatus(OrderStatus.selesai),
          backgroundColor: AppColors.success,
        );
      case OrderStatus.selesai:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppPrimaryButton(
              label: 'Tandai Sudah Diambil',
              isLoading: isLoading,
              onPressed: () => onUpdateStatus(OrderStatus.diambil),
            ),
            const SizedBox(height: AppSizes.sm),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => PaymentPage(order: order))),
              icon: const Icon(Icons.payments_outlined),
              label: const Text('Catat Pembayaran'),
            ),
          ],
        );
      case OrderStatus.diambil:
        return OutlinedButton.icon(
          onPressed: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => PaymentPage(order: order))),
          icon: const Icon(Icons.receipt_long_outlined),
          label: const Text('Lihat / Catat Pembayaran'),
        );
      case OrderStatus.ditolak:
        return SectionCard(
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.danger),
              const SizedBox(width: AppSizes.sm),
              Expanded(child: Text('Alasan penolakan: ${order.catatanPenolakan ?? '-'}')),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
