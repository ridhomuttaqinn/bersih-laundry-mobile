import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/section_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../domain/entities/pesanan.dart';
import '../../providers/auth_provider.dart';
import '../../providers/layanan_provider.dart';
import '../../providers/pesanan_provider.dart';
import 'create_order_page.dart';
import 'order_detail_page.dart';

/// Status yang masih dianggap "sedang berjalan" dari sudut pandang pelanggan —
/// dipakai untuk menentukan apakah banner beranda menampilkan tracker pesanan
/// aktif, atau konten promo (lihat poin #3 revisi UX: pemisahan fungsi
/// Banner vs Floating Action Button).
const List<String> _activeStatuses = [
  OrderStatus.diterima,
  OrderStatus.diproses,
  OrderStatus.selesai,
];

/// FR-2: menampilkan daftar layanan & harga sebagai landing pelanggan.
class PelangganHomePage extends ConsumerWidget {
  const PelangganHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authProvider).session;
    final layananAsync = ref.watch(activeLayananProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Halo, ${session?.nama.split(' ').first ?? ''} 👋'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(activeLayananProvider);
          if (session != null) ref.invalidate(orderHistoryProvider(session.id));
        },
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.md),
          children: [
            _HomeBanner(pelangganId: session?.id),
            const SizedBox(height: AppSizes.lg),
            Text('Layanan Kami', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSizes.sm),
            layananAsync.when(
              data: (list) => Column(
                children: list
                    .map((layanan) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSizes.sm),
                          child: SectionCard(
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                                  ),
                                  child: const Icon(Icons.local_laundry_service_rounded, color: AppColors.primary),
                                ),
                                const SizedBox(width: AppSizes.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(layanan.namaLayanan,
                                          style: const TextStyle(fontWeight: FontWeight.w700)),
                                      Text(
                                        '${AppFormatters.currency(layanan.hargaPerUnit)} / ${layanan.satuan}',
                                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              ),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSizes.xl),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => AppErrorView(
                message: 'Gagal memuat layanan',
                onRetry: () => ref.invalidate(activeLayananProvider),
              ),
            ),
          ],
        ),
      ),
      // FAB SELALU menuju alur Pemesanan Cepat, terlepas dari apa yang
      // ditampilkan banner di atas — lihat _HomeBanner untuk pemisahan fungsi.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateOrder(context),
        icon: const Icon(Icons.add_shopping_cart_rounded),
        label: const Text('Pesan Laundry'),
      ),
    );
  }
}

void _openCreateOrder(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateOrderPage()));
}

/// Banner beranda dengan dua mode:
/// - Ada pesanan aktif → tampilkan tracker status pesanan tersebut (bukan
///   duplikat aksi "buat pesanan" seperti FAB).
/// - Tidak ada pesanan aktif → tampilkan promo/ilustrasi laundry.
class _HomeBanner extends ConsumerWidget {
  final int? pelangganId;
  const _HomeBanner({required this.pelangganId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (pelangganId == null) return const _PromoBannerContent();

    final ordersAsync = ref.watch(orderHistoryProvider(pelangganId!));

    return ordersAsync.when(
      data: (orders) {
        Pesanan? active;
        for (final o in orders) {
          if (_activeStatuses.contains(o.statusPesanan)) {
            active = o;
            break;
          }
        }
        if (active == null) return const _PromoBannerContent();
        return _ActiveOrderBanner(order: active);
      },
      // Saat masih memuat/gagal, tampilkan promo sebagai fallback aman —
      // banner tidak boleh kosong/blank hanya karena query riwayat lambat.
      loading: () => const _PromoBannerContent(),
      error: (_, __) => const _PromoBannerContent(),
    );
  }
}

class _ActiveOrderBanner extends StatelessWidget {
  final Pesanan order;
  const _ActiveOrderBanner({required this.order});

  String get _message {
    switch (order.statusPesanan) {
      case OrderStatus.diterima:
        return 'Pesanan Anda telah diterima dan menunggu diproses kasir.';
      case OrderStatus.diproses:
        return 'Cucian Anda sedang dikerjakan.';
      case OrderStatus.selesai:
        return 'Cucian selesai! Siap untuk diambil.';
      default:
        return 'Pesanan sedang berjalan.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => OrderDetailPage(orderId: order.id!))),
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.secondary, Color(0xFF00897B)]),
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Flexible(
                        child: Text('Pesanan Berlangsung',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(status: order.statusPesanan, fontSize: 10.5),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(_message,
                      style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Lihat Detail',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12.5)),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                    ],
                  ),
                ],
              ),
            ),
            const _LaundryIllustrationBadge(icon: Icons.local_shipping_rounded, size: 64),
          ],
        ),
      ),
    );
  }
}

class _PromoBannerContent extends StatelessWidget {
  const _PromoBannerContent();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openCreateOrder(context),
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        child: const Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Laundry beres tanpa ribet',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                  SizedBox(height: 6),
                  Text('Pesan sekarang, kami jemput ke lokasi Anda',
                      style: TextStyle(color: Colors.white70, fontSize: 12.5)),
                ],
              ),
            ),
            _LaundryIllustrationBadge(icon: Icons.local_laundry_service_rounded, size: 72),
          ],
        ),
      ),
    );
  }
}

/// "Ilustrasi" ringan berbasis komposisi ikon berlapis (tanpa aset/paket
/// tambahan) — lingkaran gradasi tembus pandang sebagai latar + ikon utama
/// besar + aksen ikon kecil, agar banner tidak terasa flat/polos.
class _LaundryIllustrationBadge extends StatelessWidget {
  final IconData icon;
  final double size;
  const _LaundryIllustrationBadge({required this.icon, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: size * 0.72,
            height: size * 0.72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.22),
              shape: BoxShape.circle,
            ),
          ),
          Icon(icon, color: Colors.white, size: size * 0.42),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(Icons.check_rounded, color: AppColors.success, size: size * 0.16),
            ),
          ),
        ],
      ),
    );
  }
}
