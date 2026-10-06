import 'package:equatable/equatable.dart';

/// Entity murni untuk aktor "Pelanggan" (lihat tabel `pelanggan` pada ERD proposal).
class Pelanggan extends Equatable {
  final int? id;
  final String nama;
  final String alamat;
  final String noTelepon;
  final String email;
  final DateTime createdAt;

  const Pelanggan({
    this.id,
    required this.nama,
    required this.alamat,
    required this.noTelepon,
    required this.email,
    required this.createdAt,
  });

  Pelanggan copyWith({
    int? id,
    String? nama,
    String? alamat,
    String? noTelepon,
    String? email,
  }) {
    return Pelanggan(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      alamat: alamat ?? this.alamat,
      noTelepon: noTelepon ?? this.noTelepon,
      email: email ?? this.email,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, nama, alamat, noTelepon, email, createdAt];
}
