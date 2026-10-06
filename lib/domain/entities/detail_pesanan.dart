import 'package:equatable/equatable.dart';
import 'layanan.dart';

/// Entity murni untuk satu baris rincian pesanan (tabel `detail_pesanan`).
/// [layanan] disertakan (denormalized-view) agar UI mudah menampilkan nama & harga
/// tanpa query tambahan — objek ini tidak disimpan langsung ke DB, hanya
/// digunakan pada lapisan domain/presentasi.
class DetailPesanan extends Equatable {
  final int? id;
  final int? idPesanan;
  final Layanan layanan;
  final double beratQty;
  final double subtotal;

  const DetailPesanan({
    this.id,
    this.idPesanan,
    required this.layanan,
    required this.beratQty,
    required this.subtotal,
  });

  factory DetailPesanan.fromLayanan(Layanan layanan, double beratQty) {
    return DetailPesanan(
      layanan: layanan,
      beratQty: beratQty,
      subtotal: layanan.hargaPerUnit * beratQty,
    );
  }

  @override
  List<Object?> get props => [id, idPesanan, layanan, beratQty, subtotal];
}
