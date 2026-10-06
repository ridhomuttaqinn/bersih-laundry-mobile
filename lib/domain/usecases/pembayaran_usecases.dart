import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../entities/pembayaran.dart';
import '../repositories/pembayaran_repository.dart';

/// FR-7: mencatat pembayaran serta menjadi dasar pencetakan nota transaksi.
class RecordPaymentUseCase {
  final PembayaranRepository repository;
  const RecordPaymentUseCase(this.repository);

  Future<Result<Pembayaran>> call({
    required int idPesanan,
    required String metodeBayar,
    required double jumlahBayar,
  }) {
    if (jumlahBayar <= 0) {
      return Future.value(
        const Result.failure(ValidationFailure('Jumlah pembayaran harus lebih dari 0')),
      );
    }
    return repository.recordPayment(
      idPesanan: idPesanan,
      metodeBayar: metodeBayar,
      jumlahBayar: jumlahBayar,
    );
  }
}

class GetPaymentByOrderUseCase {
  final PembayaranRepository repository;
  const GetPaymentByOrderUseCase(this.repository);

  Future<Result<Pembayaran?>> call(int idPesanan) => repository.getPaymentByPesanan(idPesanan);
}
