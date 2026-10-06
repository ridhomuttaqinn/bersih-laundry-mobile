import '../../core/utils/formatters.dart';
import '../../domain/entities/pelanggan.dart';

/// Model data yang tahu cara serialisasi ke/dari baris tabel `pelanggan`.
class PelangganModel extends Pelanggan {
  final String passwordHash;

  const PelangganModel({
    super.id,
    required super.nama,
    required super.alamat,
    required super.noTelepon,
    required super.email,
    required super.createdAt,
    required this.passwordHash,
  });

  factory PelangganModel.fromMap(Map<String, Object?> map) {
    return PelangganModel(
      id: map['id_pelanggan'] as int?,
      nama: map['nama'] as String,
      alamat: map['alamat'] as String,
      noTelepon: map['no_telepon'] as String,
      email: map['email'] as String,
      passwordHash: map['password'] as String,
      createdAt: AppFormatters.fromDbString(map['created_at'] as String),
    );
  }

  factory PelangganModel.fromEntity(Pelanggan entity, {required String passwordHash}) {
    return PelangganModel(
      id: entity.id,
      nama: entity.nama,
      alamat: entity.alamat,
      noTelepon: entity.noTelepon,
      email: entity.email,
      createdAt: entity.createdAt,
      passwordHash: passwordHash,
    );
  }

  Map<String, Object?> toMap({bool includeId = false}) {
    final map = <String, Object?>{
      'nama': nama,
      'alamat': alamat,
      'no_telepon': noTelepon,
      'email': email,
      'password': passwordHash,
      'created_at': AppFormatters.toDbString(createdAt),
    };
    if (includeId && id != null) map['id_pelanggan'] = id;
    return map;
  }
}
