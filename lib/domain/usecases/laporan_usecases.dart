import '../../core/utils/result.dart';
import '../entities/ringkasan_pendapatan.dart';
import '../repositories/laporan_repository.dart';

/// FR-10: laporan rekap pendapatan harian/mingguan/bulanan untuk pemilik usaha.
class GetRingkasanPendapatanUseCase {
  final LaporanRepository repository;
  const GetRingkasanPendapatanUseCase(this.repository);

  Future<Result<List<RingkasanPendapatan>>> call({
    required PeriodeLaporan periode,
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) {
    return repository.getRingkasanPendapatan(
      periode: periode,
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
    );
  }
}

class GetDashboardSummaryUseCase {
  final LaporanRepository repository;
  const GetDashboardSummaryUseCase(this.repository);

  Future<Result<DashboardSummary>> call() async {
    final now = DateTime.now();
    final startToday = DateTime(now.year, now.month, now.day);
    final endToday = startToday.add(const Duration(days: 1));

    final startMonth = DateTime(now.year, now.month, 1);
    final endMonth = DateTime(now.year, now.month + 1, 1);

    final todayIncomeResult = await repository.getTotalPendapatan(rangeStart: startToday, rangeEnd: endToday);
    final todayOrdersResult = await repository.getJumlahPesanan(rangeStart: startToday, rangeEnd: endToday);
    final monthIncomeResult = await repository.getTotalPendapatan(rangeStart: startMonth, rangeEnd: endMonth);
    final monthOrdersResult = await repository.getJumlahPesanan(rangeStart: startMonth, rangeEnd: endMonth);

    if (todayIncomeResult.isFailure) return Result.failure(todayIncomeResult.failureOrNull!);
    if (todayOrdersResult.isFailure) return Result.failure(todayOrdersResult.failureOrNull!);
    if (monthIncomeResult.isFailure) return Result.failure(monthIncomeResult.failureOrNull!);
    if (monthOrdersResult.isFailure) return Result.failure(monthOrdersResult.failureOrNull!);

    return Result.success(DashboardSummary(
      pendapatanHariIni: todayIncomeResult.dataOrNull!,
      jumlahPesananHariIni: todayOrdersResult.dataOrNull!,
      pendapatanBulanIni: monthIncomeResult.dataOrNull!,
      jumlahPesananBulanIni: monthOrdersResult.dataOrNull!,
    ));
  }
}

class DashboardSummary {
  final double pendapatanHariIni;
  final int jumlahPesananHariIni;
  final double pendapatanBulanIni;
  final int jumlahPesananBulanIni;

  const DashboardSummary({
    required this.pendapatanHariIni,
    required this.jumlahPesananHariIni,
    required this.pendapatanBulanIni,
    required this.jumlahPesananBulanIni,
  });
}
