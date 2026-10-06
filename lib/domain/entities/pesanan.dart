import 'package:equatable/equatable.dart';
import 'detail_pesanan.dart';

/// Entity murni untuk transaksi pesanan (tabel `pesanan` pada ERD proposal),
/// dilengkapi daftar [items] (detail_pesanan) dan info ringkas pelanggan/kasir
/// untuk kebutuhan tampilan.
class Pesanan extends Equatable {
  final int? id;
  final int idPelanggan;
  final String? namaPelanggan;
  final int? idUser;
  final String? namaKasir;
  final DateTime tanggalMasuk;
  final DateTime? tanggalSelesai;
  final String alamatJemput;
  final String jadwalJemput;
  final String statusPesanan;
  final String? catatanPenolakan;
  final double totalBayar;
  final List<DetailPesanan> items;

  /// Preferensi metode pembayaran yang dipilih pelanggan saat memesan
  /// (revisi poin #6) — opsional, murni sebagai referensi awal bagi kasir.
  /// Pembayaran final yang sesungguhnya tetap dicatat lewat entity [Pembayaran].
  final String? metodeBayarPilihan;

  /// `false` berarti berat/jumlah pada [items] masih estimasi pelanggan dan
  /// menunggu konfirmasi berat aktual dari kasir/kurir (revisi poin #4).
  final bool beratDikonfirmasi;

  const Pesanan({
    this.id,
    required this.idPelanggan,
    this.namaPelanggan,
    this.idUser,
    this.namaKasir,
    required this.tanggalMasuk,
    this.tanggalSelesai,
    required this.alamatJemput,
    required this.jadwalJemput,
    required this.statusPesanan,
    this.catatanPenolakan,
    required this.totalBayar,
    this.items = const [],
    this.metodeBayarPilihan,
    this.beratDikonfirmasi = true,
  });

  Pesanan copyWith({
    int? id,
    int? idUser,
    String? namaKasir,
    DateTime? tanggalSelesai,
    String? statusPesanan,
    String? catatanPenolakan,
    double? totalBayar,
    List<DetailPesanan>? items,
    String? metodeBayarPilihan,
    bool? beratDikonfirmasi,
  }) {
    return Pesanan(
      id: id ?? this.id,
      idPelanggan: idPelanggan,
      namaPelanggan: namaPelanggan,
      idUser: idUser ?? this.idUser,
      namaKasir: namaKasir ?? this.namaKasir,
      tanggalMasuk: tanggalMasuk,
      tanggalSelesai: tanggalSelesai ?? this.tanggalSelesai,
      alamatJemput: alamatJemput,
      jadwalJemput: jadwalJemput,
      statusPesanan: statusPesanan ?? this.statusPesanan,
      catatanPenolakan: catatanPenolakan ?? this.catatanPenolakan,
      totalBayar: totalBayar ?? this.totalBayar,
      items: items ?? this.items,
      metodeBayarPilihan: metodeBayarPilihan ?? this.metodeBayarPilihan,
      beratDikonfirmasi: beratDikonfirmasi ?? this.beratDikonfirmasi,
    );
  }

  @override
  List<Object?> get props => [
        id,
        idPelanggan,
        idUser,
        tanggalMasuk,
        tanggalSelesai,
        alamatJemput,
        jadwalJemput,
        statusPesanan,
        catatanPenolakan,
        totalBayar,
        items,
        metodeBayarPilihan,
        beratDikonfirmasi,
      ];
}
