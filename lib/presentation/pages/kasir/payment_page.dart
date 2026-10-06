import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/pdf_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/section_card.dart';
import '../../../domain/entities/pembayaran.dart';
import '../../../domain/entities/pesanan.dart';
import '../../providers/payment_provider.dart';

/// FR-7: kasir mencatat pembayaran serta mencetak/menampilkan nota transaksi.
class PaymentPage extends ConsumerStatefulWidget {
  final Pesanan order;
  const PaymentPage({super.key, required this.order});

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  // Revisi poin #6: pre-select metode sesuai preferensi pelanggan saat
  // memesan, tapi kasir tetap bisa mengoreksinya di sini — kasir adalah
  // sumber kebenaran akhir untuk metode pembayaran yang benar-benar terjadi.
  late String _selectedMethod =
      widget.order.metodeBayarPilihan ?? PaymentMethod.tunai;

  Future<void> _submitPayment() async {
    final result = await ref.read(paymentActionProvider.notifier).recordPayment(
          idPesanan: widget.order.id!,
          metodeBayar: _selectedMethod,
          jumlahBayar: widget.order.totalBayar,
        );

    if (!mounted) return;

    if (result != null) {
      AppSnackbar.success(context, 'Pembayaran berhasil dicatat');
      ref.invalidate(paymentByOrderProvider(widget.order.id!));
    } else {
      final error = ref.read(paymentActionProvider).error;
      AppSnackbar.error(context, error?.message ?? 'Gagal mencatat pembayaran');
    }
  }

  Future<void> _printNota(Pembayaran payment) async {
    final bytes = await PdfService.generateNota(
        pesanan: widget.order, pembayaran: payment);
    await PdfService.printOrShare(bytes,
        fileName: 'nota_pesanan_${widget.order.id}.pdf');
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final paymentAsync = ref.watch(paymentByOrderProvider(order.id!));
    final actionState = ref.watch(paymentActionProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Pembayaran #${order.id}')),
      body: paymentAsync.when(
        data: (payment) {
          if (payment != null) {
            // Sudah dibayar sebelumnya — tampilkan ringkasan & opsi cetak nota.
            return ListView(
              padding: const EdgeInsets.all(AppSizes.md),
              children: [
                SectionCard(
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.success, size: 48),
                      const SizedBox(height: AppSizes.sm),
                      const Text('Pembayaran Telah Diterima',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(AppFormatters.currency(payment.jumlahBayar),
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary)),
                      const SizedBox(height: 4),
                      Text('via ${PaymentMethod.label(payment.metodeBayar)}',
                          style:
                              const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                AppPrimaryButton(
                  label: 'Cetak / Bagikan Nota',
                  icon: Icons.print_rounded,
                  onPressed: () => _printNota(payment),
                ),
              ],
            );
          }

          // Belum dibayar — tampilkan form pencatatan pembayaran.
          return ListView(
            padding: const EdgeInsets.all(AppSizes.md),
            children: [
              SectionCard(
                child: Column(
                  children: [
                    const Text('Total Tagihan',
                        style: TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(AppFormatters.currency(order.totalBayar),
                        style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary)),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              Text('Metode Pembayaran',
                  style: Theme.of(context).textTheme.titleMedium),
              if (order.metodeBayarPilihan != null) ...[
                const SizedBox(height: 2),
                Text(
                  'Preferensi pelanggan: ${PaymentMethod.label(order.metodeBayarPilihan!)} — bisa dikoreksi di bawah',
                  style: const TextStyle(
                      fontSize: 11.5, color: AppColors.textSecondary),
                ),
              ],
              const SizedBox(height: AppSizes.sm),
              ...PaymentMethod.all.map((method) => RadioListTile<String>(
                    value: method,
                    groupValue: _selectedMethod,
                    onChanged: (v) => setState(() => _selectedMethod = v!),
                    title: Text(PaymentMethod.label(method)),
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                  )),
              const SizedBox(height: AppSizes.lg),
              AppPrimaryButton(
                label: 'Konfirmasi Pembayaran',
                isLoading: actionState.isLoading,
                onPressed: _submitPayment,
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('Gagal memuat data pembayaran: $e')),
      ),
    );
  }
}
