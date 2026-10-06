import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/detail_pesanan.dart';
import '../../domain/entities/pesanan.dart';
import 'core_providers.dart';

/// FR-8: riwayat transaksi milik satu pelanggan.
final orderHistoryProvider = FutureProvider.autoDispose
    .family<List<Pesanan>, int>((ref, idPelanggan) async {
  final usecase = ref.watch(getOrderHistoryUseCaseProvider);
  final result = await usecase(idPelanggan);
  return result.when(success: (data) => data, failure: (f) => throw f);
});

/// Kasir: daftar seluruh pesanan masuk, dapat difilter berdasarkan status.
final incomingOrdersProvider = FutureProvider.autoDispose
    .family<List<Pesanan>, String?>((ref, statusFilter) async {
  final usecase = ref.watch(getIncomingOrdersUseCaseProvider);
  final result = await usecase(statusFilter: statusFilter);
  return result.when(success: (data) => data, failure: (f) => throw f);
});

/// Detail satu pesanan (dipakai di halaman detail & proses pesanan).
final orderDetailProvider =
    FutureProvider.autoDispose.family<Pesanan, int>((ref, id) async {
  final usecase = ref.watch(getOrderDetailUseCaseProvider);
  final result = await usecase(id);
  return result.when(success: (data) => data, failure: (f) => throw f);
});

/// Notifier ringan untuk aksi mutasi pesanan (buat, proses, tolak, update status)
class OrderActionState {
  final bool isLoading;
  final Failure? error;
  const OrderActionState({this.isLoading = false, this.error});
}

class OrderActionNotifier extends StateNotifier<OrderActionState> {
  final Ref ref;
  OrderActionNotifier(this.ref) : super(const OrderActionState());

  Future<Pesanan?> createOrder({
    required int idPelanggan,
    required String alamatJemput,
    required String jadwalJemput,
    required List<DetailPesanan> items,
    String? metodeBayarPilihan,
    bool isEstimasiBerat = false,
  }) async {
    state = const OrderActionState(isLoading: true);
    final usecase = ref.read(createOrderUseCaseProvider);
    final result = await usecase(
      idPelanggan: idPelanggan,
      alamatJemput: alamatJemput,
      jadwalJemput: jadwalJemput,
      items: items,
      metodeBayarPilihan: metodeBayarPilihan,
      isEstimasiBerat: isEstimasiBerat,
    );
    return result.when(
      success: (p) {
        state = const OrderActionState();
        return p;
      },
      failure: (f) {
        state = OrderActionState(error: f);
        return null;
      },
    );
  }

  Future<bool> processOrder(int idPesanan, int idKasir) async {
    state = const OrderActionState(isLoading: true);
    final usecase = ref.read(processOrderUseCaseProvider);
    final result = await usecase(idPesanan: idPesanan, idKasir: idKasir);
    state = result.when(
      success: (_) => const OrderActionState(),
      failure: (f) => OrderActionState(error: f),
    );
    return result.isSuccess;
  }

  Future<bool> rejectOrder(int idPesanan, int idKasir, String alasan) async {
    state = const OrderActionState(isLoading: true);
    final usecase = ref.read(rejectOrderUseCaseProvider);
    final result =
        await usecase(idPesanan: idPesanan, idKasir: idKasir, alasan: alasan);
    state = result.when(
      success: (_) => const OrderActionState(),
      failure: (f) => OrderActionState(error: f),
    );
    return result.isSuccess;
  }

  Future<bool> updateStatus(int idPesanan, String statusBaru) async {
    state = const OrderActionState(isLoading: true);
    final usecase = ref.read(updateOrderStatusUseCaseProvider);
    final result = await usecase(idPesanan: idPesanan, statusBaru: statusBaru);
    state = result.when(
      success: (_) => const OrderActionState(),
      failure: (f) => OrderActionState(error: f),
    );
    return result.isSuccess;
  }

  Future<bool> confirmActualWeight(
      int idPesanan, Map<int, double> beratAktualPerDetail) async {
    state = const OrderActionState(isLoading: true);
    final usecase = ref.read(confirmActualWeightUseCaseProvider);
    final result = await usecase(
        idPesanan: idPesanan, beratAktualPerDetail: beratAktualPerDetail);
    state = result.when(
      success: (_) => const OrderActionState(),
      failure: (f) => OrderActionState(error: f),
    );
    return result.isSuccess;
  }

  void clearError() => state = const OrderActionState();
}

final orderActionProvider =
    StateNotifierProvider.autoDispose<OrderActionNotifier, OrderActionState>(
  (ref) => OrderActionNotifier(ref),
);
