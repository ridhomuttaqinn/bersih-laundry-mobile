import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ringkasan_pendapatan.dart';
import '../../domain/usecases/laporan_usecases.dart';
import 'core_providers.dart';

final dashboardSummaryProvider = FutureProvider.autoDispose<DashboardSummary>((ref) async {
  final usecase = ref.watch(getDashboardSummaryUseCaseProvider);
  final result = await usecase();
  return result.when(success: (data) => data, failure: (f) => throw f);
});

/// PENTING: harus immutable & punya `==`/`hashCode` yang benar (via Equatable).
/// `ringkasanPendapatanProvider` di bawah adalah provider `.family`, yang
/// membandingkan argumennya dengan `==` untuk menentukan apakah instance
/// provider yang sudah ada bisa dipakai ulang. Tanpa Equatable, dua objek
/// ReportQuery dengan isi identik akan dianggap "berbeda" (default identity
/// equality), menyebabkan provider baru selalu dibuat ulang dari nol setiap
/// widget rebuild — inilah akar bug "loading terus" pada halaman Laporan.
class ReportQuery extends Equatable {
  final PeriodeLaporan periode;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  const ReportQuery({required this.periode, required this.rangeStart, required this.rangeEnd});

  @override
  List<Object?> get props => [periode, rangeStart, rangeEnd];
}

final ringkasanPendapatanProvider =
    FutureProvider.autoDispose.family<List<RingkasanPendapatan>, ReportQuery>((ref, query) async {
  final usecase = ref.watch(getRingkasanPendapatanUseCaseProvider);
  final result = await usecase(
    periode: query.periode,
    rangeStart: query.rangeStart,
    rangeEnd: query.rangeEnd,
  );
  return result.when(success: (data) => data, failure: (f) => throw f);
});
