import '../../core/utils/formatters.dart';
import '../../domain/entities/detail_pesanan.dart';
import '../../domain/entities/pesanan.dart';

class PesananModel extends Pesanan {
  const PesananModel({
    super.id,
    required super.idPelanggan,
    super.namaPelanggan,
    super.idUser,
    super.namaKasir,
    required super.tanggalMasuk,
    super.tanggalSelesai,
    required super.alamatJemput,
    required super.jadwalJemput,
    required super.statusPesanan,
    super.catatanPenolakan,
    required super.totalBayar,
    super.metodeBayarPilihan,
    super.beratDikonfirmasi,
    super.items,
  });

  /// [map] adalah hasil JOIN antara `pesanan`, `pelanggan`, dan `user` (kasir).
  factory PesananModel.fromJoinedMap(Map<String, Object?> map, {List<DetailPesanan> items = const []}) {
    return PesananModel(
      id: map['id_pesanan'] as int?,
      idPelanggan: map['id_pelanggan'] as int,
      namaPelanggan: map['nama_pelanggan'] as String?,
      idUser: map['id_user'] as int?,
      namaKasir: map['nama_kasir'] as String?,
      tanggalMasuk: AppFormatters.fromDbString(map['tanggal_masuk'] as String),
      tanggalSelesai: map['tanggal_selesai'] != null
          ? AppFormatters.fromDbString(map['tanggal_selesai'] as String)
          : null,
      alamatJemput: map['alamat_jemput'] as String,
      jadwalJemput: map['jadwal_jemput'] as String,
      statusPesanan: map['status_pesanan'] as String,
      catatanPenolakan: map['catatan_penolakan'] as String?,
      totalBayar: (map['total_bayar'] as num).toDouble(),
      metodeBayarPilihan: map['metode_bayar_pilihan'] as String?,
      beratDikonfirmasi: (map['berat_dikonfirmasi'] as int? ?? 1) == 1,
      items: items,
    );
  }

  Map<String, Object?> toInsertMap() {
    return {
      'id_pelanggan': idPelanggan,
      'id_user': idUser,
      'tanggal_masuk': AppFormatters.toDbString(tanggalMasuk),
      'tanggal_selesai': tanggalSelesai != null ? AppFormatters.toDbString(tanggalSelesai!) : null,
      'alamat_jemput': alamatJemput,
      'jadwal_jemput': jadwalJemput,
      'status_pesanan': statusPesanan,
      'catatan_penolakan': catatanPenolakan,
      'total_bayar': totalBayar,
      'metode_bayar_pilihan': metodeBayarPilihan,
      'berat_dikonfirmasi': beratDikonfirmasi ? 1 : 0,
    };
  }
}
