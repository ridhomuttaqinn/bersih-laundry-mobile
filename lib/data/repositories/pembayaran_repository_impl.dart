import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/pembayaran.dart';
import '../../domain/repositories/pembayaran_repository.dart';
import '../datasources/pembayaran_remote_datasource.dart';

class PembayaranRepositoryImpl implements PembayaranRepository {
  final PembayaranRemoteDatasource datasource;
  const PembayaranRepositoryImpl(this.datasource);

  @override
  Future<Result<Pembayaran>> recordPayment({
    required int idPesanan,
    required String metodeBayar,
    required double jumlahBayar,
  }) async {
    try {
      final result = await datasource.recordPayment(
        idPesanan: idPesanan,
        metodeBayar: metodeBayar,
        jumlahBayar: jumlahBayar,
      );
      return Result.success(result);
    } on DuplicateException catch (e) {
      return Result.failure(ValidationFailure(e.message));
    } catch (e) {
      return Result.failure(DatabaseFailure('Gagal mencatat pembayaran: $e'));
    }
  }

  @override
  Future<Result<Pembayaran?>> getPaymentByPesanan(int idPesanan) async {
    try {
      return Result.success(await datasource.getByPesanan(idPesanan));
    } catch (e) {
      return Result.failure(
          DatabaseFailure('Gagal memuat data pembayaran: $e'));
    }
  }
}
