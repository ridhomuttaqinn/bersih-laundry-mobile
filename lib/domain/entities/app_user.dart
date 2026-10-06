import 'package:equatable/equatable.dart';

/// Entity murni untuk aktor "Kasir/Admin" dan "Pemilik" (tabel `user` pada ERD proposal).
class AppUser extends Equatable {
  final int? id;
  final String nama;
  final String username;
  final String role; // 'kasir' | 'pemilik' — lihat AppRole
  final bool isActive;
  final DateTime createdAt;

  const AppUser({
    this.id,
    required this.nama,
    required this.username,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  AppUser copyWith({
    int? id,
    String? nama,
    String? username,
    String? role,
    bool? isActive,
  }) {
    return AppUser(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      username: username ?? this.username,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, nama, username, role, isActive, createdAt];
}
