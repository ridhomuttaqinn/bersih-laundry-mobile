import '../../domain/entities/layanan.dart';

class LayananModel extends Layanan {
  const LayananModel({
    super.id,
    required super.namaLayanan,
    required super.hargaPerUnit,
    required super.satuan,
    super.isActive = true,
  });

  String get nama => namaLayanan;
  double get harga => hargaPerUnit;
  bool get isAktif => isActive;

  // Dari SQLite / Laravel API
  factory LayananModel.fromMap(Map<String, dynamic> map) {
    // ID
    final rawId = map['id'] ?? map['id_layanan'];

    int? parsedId;
    if (rawId is num) {
      parsedId = rawId.toInt();
    } else if (rawId != null) {
      parsedId = int.tryParse(rawId.toString());
    }

    // Nama layanan
    final nama = map['nama_layanan'] ?? map['namaLayanan'] ?? map['nama'] ?? '';

    // Harga
    // Laravel API mengirim "harga"
    // SQLite bisa menggunakan "harga_per_unit"
    final rawHarga =
        map['harga'] ?? map['harga_per_unit'] ?? map['hargaPerUnit'];

    double parsedHarga = 0.0;

    if (rawHarga is num) {
      parsedHarga = rawHarga.toDouble();
    } else if (rawHarga != null) {
      parsedHarga = double.tryParse(rawHarga.toString()) ?? 0.0;
    }

    // Status aktif
    final rawActive = map['is_active'] ?? map['is_aktif'] ?? map['isActive'];

    bool parsedActive = true;

    if (rawActive != null) {
      if (rawActive is bool) {
        parsedActive = rawActive;
      } else if (rawActive is num) {
        parsedActive = rawActive != 0;
      } else {
        parsedActive = rawActive.toString() == '1' ||
            rawActive.toString().toLowerCase() == 'true';
      }
    }

    return LayananModel(
      id: parsedId,
      namaLayanan: nama.toString(),
      hargaPerUnit: parsedHarga,
      satuan: (map['satuan'] ?? '').toString(),
      isActive: parsedActive,
    );
  }

  factory LayananModel.fromJson(Map<String, dynamic> json) {
    return LayananModel.fromMap(json);
  }

  // Untuk SQLite
  Map<String, dynamic> toMap() {
    return {
      'id_layanan': id,
      'nama_layanan': namaLayanan,
      'harga_per_unit': hargaPerUnit,
      'satuan': satuan,
      'is_active': isActive ? 1 : 0,
    };
  }

  // Untuk Laravel API
  Map<String, dynamic> toJson() {
    return {
      'nama_layanan': namaLayanan,
      'harga_per_unit': hargaPerUnit,
      'satuan': satuan,
      'is_active': isActive,
    };
  }

  factory LayananModel.fromEntity(Layanan entity) {
    return LayananModel(
      id: entity.id,
      namaLayanan: entity.namaLayanan,
      hargaPerUnit: entity.hargaPerUnit,
      satuan: entity.satuan,
      isActive: entity.isActive,
    );
  }
}
