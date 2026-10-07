import 'package:latlong2/latlong.dart';
import '../shared/pickup_map_page.dart';
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
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/layanan.dart';
import '../../providers/auth_provider.dart';
import '../../providers/layanan_provider.dart';
import '../../providers/order_cart_provider.dart';
import '../../providers/pesanan_provider.dart';
import 'order_detail_page.dart';

/// Kisaran berat siap pakai untuk mode estimasi (revisi poin #4). Nilai
/// [representasi] dipakai sebagai `beratQty` sementara sampai dikonfirmasi
/// ulang oleh kasir/kurir saat penjemputan (lihat `berat_dikonfirmasi` pada
/// entity Pesanan & `ConfirmActualWeightUseCase`).
class _RentangBerat {
  final String label;
  final double representasi;
  const _RentangBerat(this.label, this.representasi);
}

const List<_RentangBerat> _kisaranBerat = [
  _RentangBerat('1 - 3 kg', 2),
  _RentangBerat('3 - 5 kg', 4),
  _RentangBerat('5 - 7 kg', 6),
  _RentangBerat('> 7 kg', 8),
];

/// FR-3: pelanggan membuat pesanan baru dengan memilih satu/lebih layanan,
/// mengisi berat/jumlah, alamat, dan jadwal penjemputan.
/// FR-6: total dihitung otomatis melalui [OrderCartState.total].
class CreateOrderPage extends ConsumerStatefulWidget {
  const CreateOrderPage({super.key});

  @override
  ConsumerState<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends ConsumerState<CreateOrderPage> {
  LatLng? _pickupPoint;
  final _alamatController = TextEditingController();
  final _jadwalController = TextEditingController();

  @override
  void dispose() {
    _alamatController.dispose();
    _jadwalController.dispose();
    super.dispose();
  }

  Future<void> _pickJadwal() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 2)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date == null || !mounted) return;

    final time =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null || !mounted) return;

    final combined =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    _jadwalController.text = AppFormatters.dateTime(combined);
    ref.read(orderCartProvider.notifier).setJadwal(combined.toIso8601String());
  }

  Future<void> _addItemDialog(Layanan layanan) async {
    final isKg = layanan.satuan.toLowerCase() == 'kg';
    final cart = ref.read(orderCartProvider);
    // Mode kisaran hanya relevan untuk layanan bersatuan kg saat pelanggan
    // memilih "Timbang saat penjemputan" — layanan satuan (mis. pasang
    // sepatu) selalu pakai input jumlah pasti karena tidak butuh timbangan.
    final pakaiKisaran = isKg && cart.isEstimasiBerat;

    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    double? beratTerpilih;
    bool inputManual = false;

    final result = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLg)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                    Text(layanan.namaLayanan,
                        style: Theme.of(context).textTheme.titleLarge),
                    Text(
                      '${AppFormatters.currency(layanan.hargaPerUnit)} / ${layanan.satuan}',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSizes.md),
                    if (pakaiKisaran && !inputManual) ...[
                      const Text(
                        'Belum tahu berat pastinya? Pilih kisaran berikut — berat aktual akan '
                        'dikonfirmasi ulang oleh kurir saat penjemputan.',
                        style: TextStyle(
                            fontSize: 12.5, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _kisaranBerat
                            .map((r) => ChoiceChip(
                                  label: Text(r.label),
                                  selected: beratTerpilih == r.representasi,
                                  onSelected: (_) => setModalState(
                                      () => beratTerpilih = r.representasi),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      TextButton.icon(
                        onPressed: () =>
                            setModalState(() => inputManual = true),
                        icon: const Icon(Icons.scale_outlined, size: 18),
                        label: const Text('Saya sudah tahu berat pastinya'),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      AppPrimaryButton(
                        label: 'Tambahkan',
                        onPressed: beratTerpilih == null
                            ? null
                            : () => Navigator.pop(context, beratTerpilih),
                      ),
                    ] else ...[
                      AppTextField(
                        controller: controller,
                        label: 'Berat / Jumlah (${layanan.satuan})',
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (v) =>
                            Validators.positiveNumber(v, field: 'Berat/jumlah'),
                      ),
                      const SizedBox(height: AppSizes.md),
                      AppPrimaryButton(
                        label: 'Tambahkan',
                        onPressed: () {
                          if (!formKey.currentState!.validate()) return;
                          final qty = double.parse(
                              controller.text.replaceAll(',', '.'));
                          Navigator.pop(context, qty);
                        },
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      ref.read(orderCartProvider.notifier).addItem(layanan, result);
    }
  }

  Future<void> _pickMetodeBayar() async {
    final cart = ref.read(orderCartProvider);
    final selected = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLg)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Pilih Metode Pembayaran',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSizes.xs),
                const Text(
                  'Preferensi ini masih bisa dikonfirmasi/diubah oleh kasir saat pembayaran.',
                  style:
                      TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSizes.sm),
                ...PaymentMethod.all.map((m) => RadioListTile<String>(
                      value: m,
                      groupValue: cart.metodeBayarPilihan,
                      onChanged: (v) => Navigator.pop(context, v),
                      title: Text(PaymentMethod.label(m)),
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.primary,
                    )),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) {
      ref.read(orderCartProvider.notifier).setMetodeBayar(selected);
    }
  }

  Future<void> _submitOrder() async {
    final cart = ref.read(orderCartProvider);
    final session = ref.read(authProvider).session;

    if (cart.items.isEmpty) {
      AppSnackbar.error(context, 'Pilih minimal satu jenis layanan');
      return;
    }
    if (_alamatController.text.trim().isEmpty) {
      AppSnackbar.error(context, 'Alamat penjemputan wajib diisi');
      return;
    }
    if (_jadwalController.text.trim().isEmpty) {
      AppSnackbar.error(context, 'Jadwal penjemputan wajib diisi');
      return;
    }

    ref
        .read(orderCartProvider.notifier)
        .setAlamat(_alamatController.text.trim());

    final order = await ref.read(orderActionProvider.notifier).createOrder(
          idPelanggan: session!.id,
          alamatJemput: _pickupPoint == null
              ? _alamatController.text.trim()
              : '${_alamatController.text.trim()}\nTitik jemput: https://www.google.com/maps/search/?api=1&query=${_pickupPoint!.latitude.toStringAsFixed(6)},${_pickupPoint!.longitude.toStringAsFixed(6)}',
          jadwalJemput: cart.jadwalJemput,
          items: cart.items,
          metodeBayarPilihan: cart.metodeBayarPilihan,
          isEstimasiBerat: cart.isEstimasiBerat,
        );

    if (!mounted) return;

    if (order != null) {
      ref.read(orderCartProvider.notifier).reset();
      AppSnackbar.success(context, 'Pesanan berhasil dibuat!');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => OrderDetailPage(orderId: order.id!)),
      );
    } else {
      final error = ref.read(orderActionProvider).error;
      AppSnackbar.error(context, error?.message ?? 'Gagal membuat pesanan');
    }
  }

  @override
  Widget build(BuildContext context) {
    final layananAsync = ref.watch(activeLayananProvider);
    final cart = ref.watch(orderCartProvider);
    final actionState = ref.watch(orderActionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Buat Pesanan')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSizes.md),
              children: [
                // Revisi poin #4: toggle "timbang saat penjemputan" ditaruh
                // paling atas karena memengaruhi cara input berat pada
                // langkah "Pilih Layanan" di bawahnya.
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: CheckboxListTile(
                    value: cart.isEstimasiBerat,
                    onChanged: (v) => ref
                        .read(orderCartProvider.notifier)
                        .setEstimasiBerat(v ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primary,
                    title: const Text(
                      'Timbang saat penjemputan',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13.5),
                    ),
                    subtitle: const Text(
                      'Tidak punya timbangan? Pilih kisaran berat — kurir akan menimbang ulang '
                      'dan total disesuaikan otomatis.',
                      style: TextStyle(fontSize: 11.5),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                Text('1. Pilih Layanan',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSizes.sm),
                layananAsync.when(
                  data: (list) => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: list.map((layanan) {
                      final inCart =
                          cart.items.any((i) => i.layanan.id == layanan.id);
                      return ActionChip(
                        avatar: Icon(
                          inCart
                              ? Icons.check_circle
                              : Icons.add_circle_outline,
                          size: 18,
                          color: inCart ? AppColors.success : AppColors.primary,
                        ),
                        label: Text(layanan.namaLayanan),
                        onPressed: () => _addItemDialog(layanan),
                      );
                    }).toList(),
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => AppErrorView(
                    message: 'Gagal memuat layanan',
                    onRetry: () => ref.invalidate(activeLayananProvider),
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                Text('2. Rincian Pesanan',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSizes.sm),
                if (cart.items.isEmpty)
                  const EmptyStateWidget(
                    icon: Icons.shopping_basket_outlined,
                    title: 'Belum ada layanan dipilih',
                    subtitle:
                        'Ketuk salah satu layanan di atas untuk menambahkan',
                  )
                else
                  ...cart.items.map((item) => Card(
                        child: ListTile(
                          title: Text(item.layanan.namaLayanan),
                          subtitle: Text(
                              '${item.beratQty} ${item.layanan.satuan} × '
                              '${AppFormatters.currency(item.layanan.hargaPerUnit)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(AppFormatters.currency(item.subtotal),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                              IconButton(
                                icon: const Icon(Icons.close_rounded,
                                    size: 18, color: AppColors.danger),
                                onPressed: () => ref
                                    .read(orderCartProvider.notifier)
                                    .removeItem(item.layanan.id),
                              ),
                            ],
                          ),
                        ),
                      )),
                const SizedBox(height: AppSizes.lg),
                Text('3. Alamat & Jadwal Penjemputan',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSizes.sm),
                AppTextField(
                  controller: _alamatController,
                  label: 'Alamat Penjemputan',
                  maxLines: 2,
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.map_outlined),
                  label: Text(_pickupPoint == null ? 'Pilih titik di peta' : 'Ubah titik penjemputan'),
                  onPressed: () async {
                    final point = await Navigator.push<LatLng>(context,
                      MaterialPageRoute(builder: (_) => PickupMapPage(initialPoint: _pickupPoint)));
                    if (point != null && mounted) setState(() => _pickupPoint = point);
                  },
                ),
                if (_pickupPoint != null) Row(children: [
                  Expanded(child: Text('Titik tersimpan: ${_pickupPoint!.latitude.toStringAsFixed(5)}, ${_pickupPoint!.longitude.toStringAsFixed(5)}')),
                  IconButton(tooltip: 'Hapus titik', icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _pickupPoint = null)),
                ]),
                const SizedBox(height: AppSizes.md),
                // Revisi bug: seluruh area field kini bisa diketuk (readOnly +
                // onTap), bukan cuma ikon kecil di kanan seperti sebelumnya.
                AppTextField(
                  controller: _jadwalController,
                  label: 'Jadwal Penjemputan',
                  readOnly: true,
                  onTap: _pickJadwal,
                  prefixIcon: const Icon(Icons.event_outlined),
                  suffixIcon: const Icon(Icons.edit_calendar_outlined),
                ),
                const SizedBox(height: AppSizes.lg),
                Text('4. Metode Pembayaran (opsional)',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSizes.sm),
                InkWell(
                  onTap: _pickMetodeBayar,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  child: Container(
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.divider),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.payments_outlined,
                            color: AppColors.textSecondary),
                        const SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: Text(
                            cart.metodeBayarPilihan != null
                                ? PaymentMethod.label(cart.metodeBayarPilihan!)
                                : 'Belum dipilih — kasir akan konfirmasi',
                            style: TextStyle(
                              color: cart.metodeBayarPilihan != null
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                              fontWeight: cart.metodeBayarPilihan != null
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _TotalBar(
            total: cart.total,
            isEstimasi: cart.isEstimasiBerat,
            isLoading: actionState.isLoading,
            onSubmit: cart.items.isEmpty ? null : _submitOrder,
          ),
        ],
      ),
    );
  }
}

class _TotalBar extends StatelessWidget {
  final double total;
  final bool isEstimasi;
  final bool isLoading;
  final VoidCallback? onSubmit;

  const _TotalBar({
    required this.total,
    required this.isEstimasi,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isEstimasi ? 'Estimasi Total' : 'Total',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                  Text(
                    AppFormatters.currency(total),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              flex: 2,
              child: AppPrimaryButton(
                  label: 'Pesan Sekarang',
                  isLoading: isLoading,
                  onPressed: onSubmit),
            ),
          ],
        ),
      ),
    );
  }
}
