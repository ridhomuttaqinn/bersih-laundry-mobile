import 'package:equatable/equatable.dart';

/// Entity murni untuk notifikasi status pesanan (tabel tambahan `notifikasi`,
/// mendukung FR-5 pada proposal).
class Notifikasi extends Equatable {
  final int? id;
  final int idPelanggan;
  final int idPesanan;
  final String pesan;
  final bool dibaca;
  final DateTime createdAt;

  const Notifikasi({
    this.id,
    required this.idPelanggan,
    required this.idPesanan,
    required this.pesan,
    required this.dibaca,
    required this.createdAt,
  });

  Notifikasi copyWith({bool? dibaca}) {
    return Notifikasi(
      id: id,
      idPelanggan: idPelanggan,
      idPesanan: idPesanan,
      pesan: pesan,
      dibaca: dibaca ?? this.dibaca,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, idPelanggan, idPesanan, pesan, dibaca, createdAt];
}
