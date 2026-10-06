import 'package:equatable/equatable.dart';

/// Entity murni untuk pembayaran (tabel `pembayaran` pada ERD proposal).
class Pembayaran extends Equatable {
  final int? id;
  final int idPesanan;
  final DateTime tanggalBayar;
  final String metodeBayar; // 'tunai' | 'transfer' | 'e-wallet'
  final double jumlahBayar;

  const Pembayaran({
    this.id,
    required this.idPesanan,
    required this.tanggalBayar,
    required this.metodeBayar,
    required this.jumlahBayar,
  });

  @override
  List<Object?> get props => [id, idPesanan, tanggalBayar, metodeBayar, jumlahBayar];
}
