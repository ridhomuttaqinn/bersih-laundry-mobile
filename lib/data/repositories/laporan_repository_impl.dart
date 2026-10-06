import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/ringkasan_pendapatan.dart';
import '../../domain/repositories/laporan_repository.dart';
import '../datasources/laporan_remote_datasource.dart';

class LaporanRepositoryImpl implements LaporanRepository {
  final LaporanRemoteDatasource datasource;
  const LaporanRepositoryImpl(this.datasource);

  @override
  Future<Result<List<RingkasanPendapatan>>> getRingkasanPendapatan({
    required PeriodeLaporan periode,
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) async {
    try {
      final result = await datasource.getRingkasan(
        periode: periode,
        rangeStart: rangeStart,
        rangeEnd: rangeEnd,
      );
      return Result.success(result);
    } catch (e) {
      return Result.failure(
          DatabaseFailure('Gagal memuat laporan pendapatan: $e'));
    }
  }

  @override
  Future<Result<double>> getTotalPendapatan(
      {required DateTime rangeStart, required DateTime rangeEnd}) async {
    try {
      return Result.success(await datasource.getTotalPendapatan(
          rangeStart: rangeStart, rangeEnd: rangeEnd));
    } catch (e) {
      return Result.failure(
          DatabaseFailure('Gagal menghitung total pendapatan: $e'));
    }
  }

  @override
  Future<Result<int>> getJumlahPesanan(
      {required DateTime rangeStart, required DateTime rangeEnd}) async {
    try {
      return Result.success(await datasource.getJumlahPesanan(
          rangeStart: rangeStart, rangeEnd: rangeEnd));
    } catch (e) {
      return Result.failure(
          DatabaseFailure('Gagal menghitung jumlah pesanan: $e'));
    }
  }
}
