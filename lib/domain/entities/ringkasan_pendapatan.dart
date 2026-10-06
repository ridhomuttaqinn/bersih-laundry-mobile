import 'package:equatable/equatable.dart';

/// Value object hasil agregasi laporan pendapatan (FR-10 pada proposal).
/// [label] merepresentasikan sumbu-x pada grafik (tanggal/minggu/bulan).
class RingkasanPendapatan extends Equatable {
  final String label;
  final DateTime periodeAwal;
  final double totalPendapatan;
  final int jumlahPesanan;

  const RingkasanPendapatan({
    required this.label,
    required this.periodeAwal,
    required this.totalPendapatan,
    required this.jumlahPesanan,
  });

  @override
  List<Object?> get props => [label, periodeAwal, totalPendapatan, jumlahPesanan];
}

enum PeriodeLaporan { harian, mingguan, bulanan }
