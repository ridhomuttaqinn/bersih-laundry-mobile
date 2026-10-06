import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/detail_pesanan.dart';
import '../../domain/entities/layanan.dart';

/// State keranjang pesanan sementara sebelum dikirim (FR-3).
/// Total dihitung otomatis (FR-6) melalui getter [total].
///
/// [isEstimasiBerat] (revisi poin #4): saat true, pelanggan memilih untuk
/// tidak menimbang sendiri — berat item kg diisi dari kisaran perkiraan dan
/// akan dikonfirmasi ulang oleh kasir/kurir saat penjemputan.
///
/// [metodeBayarPilihan] (revisi poin #6): preferensi metode pembayaran
/// pelanggan, bersifat opsional dan tetap bisa dikoreksi kasir saat
/// pembayaran benar-benar dicatat.
class OrderCartState {
  final List<DetailPesanan> items;
  final String alamatJemput;
  final String jadwalJemput;
  final bool isEstimasiBerat;
  final String? metodeBayarPilihan;

  const OrderCartState({
    this.items = const [],
    this.alamatJemput = '',
    this.jadwalJemput = '',
    this.isEstimasiBerat = false,
    this.metodeBayarPilihan,
  });

  double get total => items.fold(0, (sum, item) => sum + item.subtotal);

  OrderCartState copyWith({
    List<DetailPesanan>? items,
    String? alamatJemput,
    String? jadwalJemput,
    bool? isEstimasiBerat,
    String? metodeBayarPilihan,
    bool clearMetodeBayar = false,
  }) {
    return OrderCartState(
      items: items ?? this.items,
      alamatJemput: alamatJemput ?? this.alamatJemput,
      jadwalJemput: jadwalJemput ?? this.jadwalJemput,
      isEstimasiBerat: isEstimasiBerat ?? this.isEstimasiBerat,
      metodeBayarPilihan: clearMetodeBayar ? null : (metodeBayarPilihan ?? this.metodeBayarPilihan),
    );
  }
}

class OrderCartNotifier extends StateNotifier<OrderCartState> {
  OrderCartNotifier() : super(const OrderCartState());

  void addItem(Layanan layanan, double beratQty) {
    final existingIndex = state.items.indexWhere((i) => i.layanan.id == layanan.id);
    final newItem = DetailPesanan.fromLayanan(layanan, beratQty);

    if (existingIndex >= 0) {
      final updated = [...state.items];
      updated[existingIndex] = newItem;
      state = state.copyWith(items: updated);
    } else {
      state = state.copyWith(items: [...state.items, newItem]);
    }
  }

  void removeItem(int? layananId) {
    state = state.copyWith(items: state.items.where((i) => i.layanan.id != layananId).toList());
  }

  void setAlamat(String alamat) => state = state.copyWith(alamatJemput: alamat);

  void setJadwal(String jadwal) => state = state.copyWith(jadwalJemput: jadwal);

  /// Revisi poin #4: toggle "timbang saat penjemputan". Item kg yang sudah
  /// ada di keranjang TIDAK dihapus otomatis — pelanggan tetap bisa menambah
  /// item baru dengan mode kisaran begitu toggle ini aktif.
  void setEstimasiBerat(bool value) => state = state.copyWith(isEstimasiBerat: value);

  /// Revisi poin #6: preferensi metode pembayaran (opsional, tidak wajib diisi).
  void setMetodeBayar(String? metode) =>
      state = state.copyWith(metodeBayarPilihan: metode, clearMetodeBayar: metode == null);

  void reset() => state = const OrderCartState();
}

final orderCartProvider = StateNotifierProvider.autoDispose<OrderCartNotifier, OrderCartState>(
  (ref) => OrderCartNotifier(),
);
