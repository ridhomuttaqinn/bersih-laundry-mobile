import '../../core/utils/formatters.dart';
import '../../domain/entities/app_user.dart';

class AppUserModel extends AppUser {
  final String passwordHash;

  const AppUserModel({
    super.id,
    required super.nama,
    required super.username,
    required super.role,
    required super.isActive,
    required super.createdAt,
    required this.passwordHash,
  });

  factory AppUserModel.fromMap(Map<String, Object?> map) {
    return AppUserModel(
      id: map['id_user'] as int?,
      nama: map['nama'] as String,
      username: map['username'] as String,
      role: map['role'] as String,
      isActive: (map['is_active'] as int) == 1,
      passwordHash: map['password'] as String,
      createdAt: AppFormatters.fromDbString(map['created_at'] as String),
    );
  }

  Map<String, Object?> toMap({bool includeId = false}) {
    final map = <String, Object?>{
      'nama': nama,
      'username': username,
      'password': passwordHash,
      'role': role,
      'is_active': isActive ? 1 : 0,
      'created_at': AppFormatters.toDbString(createdAt),
    };
    if (includeId && id != null) map['id_user'] = id;
    return map;
  }
}
