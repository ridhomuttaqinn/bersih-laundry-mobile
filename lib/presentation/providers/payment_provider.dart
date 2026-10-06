import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/pembayaran.dart';
import 'core_providers.dart';

final paymentByOrderProvider = FutureProvider.autoDispose.family<Pembayaran?, int>((ref, idPesanan) async {
  final usecase = ref.watch(getPaymentByOrderUseCaseProvider);
  final result = await usecase(idPesanan);
  return result.when(success: (data) => data, failure: (f) => throw f);
});

class PaymentActionState {
  final bool isLoading;
  final Failure? error;
  const PaymentActionState({this.isLoading = false, this.error});
}

class PaymentActionNotifier extends StateNotifier<PaymentActionState> {
  final Ref ref;
  PaymentActionNotifier(this.ref) : super(const PaymentActionState());

  Future<Pembayaran?> recordPayment({
    required int idPesanan,
    required String metodeBayar,
    required double jumlahBayar,
  }) async {
    state = const PaymentActionState(isLoading: true);
    final usecase = ref.read(recordPaymentUseCaseProvider);
    final result = await usecase(idPesanan: idPesanan, metodeBayar: metodeBayar, jumlahBayar: jumlahBayar);
    return result.when(
      success: (p) {
        state = const PaymentActionState();
        return p;
      },
      failure: (f) {
        state = PaymentActionState(error: f);
        return null;
      },
    );
  }
}

final paymentActionProvider = StateNotifierProvider.autoDispose<PaymentActionNotifier, PaymentActionState>(
  (ref) => PaymentActionNotifier(ref),
);
