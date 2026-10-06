import '../../core/utils/result.dart';
import '../entities/ringkasan_pendapatan.dart';

/// FR-10: laporan rekap pendapatan harian/mingguan/bulanan untuk pemilik.
abstract class LaporanRepository {
  Future<Result<List<RingkasanPendapatan>>> getRingkasanPendapatan({
    required PeriodeLaporan periode,
    required DateTime rangeStart,
    required DateTime rangeEnd,
  });

  Future<Result<double>> getTotalPendapatan({
    required DateTime rangeStart,
    required DateTime rangeEnd,
  });

  Future<Result<int>> getJumlahPesanan({
    required DateTime rangeStart,
    required DateTime rangeEnd,
  });
}
