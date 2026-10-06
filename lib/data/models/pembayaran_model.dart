import '../../core/utils/formatters.dart';
import '../../domain/entities/pembayaran.dart';

class PembayaranModel extends Pembayaran {
  const PembayaranModel({
    super.id,
    required super.idPesanan,
    required super.tanggalBayar,
    required super.metodeBayar,
    required super.jumlahBayar,
  });

  factory PembayaranModel.fromMap(Map<String, Object?> map) {
    return PembayaranModel(
      id: map['id_pembayaran'] as int?,
      idPesanan: map['id_pesanan'] as int,
      tanggalBayar: AppFormatters.fromDbString(map['tanggal_bayar'] as String),
      metodeBayar: map['metode_bayar'] as String,
      jumlahBayar: (map['jumlah_bayar'] as num).toDouble(),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id_pesanan': idPesanan,
      'tanggal_bayar': AppFormatters.toDbString(tanggalBayar),
      'metode_bayar': metodeBayar,
      'jumlah_bayar': jumlahBayar,
    };
  }
}
