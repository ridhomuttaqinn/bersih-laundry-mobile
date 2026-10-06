import '../../domain/entities/detail_pesanan.dart';
import 'layanan_model.dart';

class DetailPesananModel extends DetailPesanan {
  const DetailPesananModel({
    super.id,
    super.idPesanan,
    required super.layanan,
    required super.beratQty,
    required super.subtotal,
  });

  /// [map] adalah hasil JOIN antara `detail_pesanan` dan `layanan`.
  factory DetailPesananModel.fromJoinedMap(Map<String, Object?> map) {
    return DetailPesananModel(
      id: map['id_detail'] as int?,
      idPesanan: map['id_pesanan'] as int?,
      beratQty: (map['berat_qty'] as num).toDouble(),
      subtotal: (map['subtotal'] as num).toDouble(),
      layanan: LayananModel(
        id: map['id_layanan'] as int?,
        namaLayanan: map['nama_layanan'] as String,
        hargaPerUnit: (map['harga_per_unit'] as num).toDouble(),
        satuan: map['satuan'] as String,
      ),
    );
  }

  Map<String, Object?> toMap({required int idPesanan}) {
    return {
      'id_pesanan': idPesanan,
      'id_layanan': layanan.id,
      'berat_qty': beratQty,
      'subtotal': subtotal,
    };
  }
}
