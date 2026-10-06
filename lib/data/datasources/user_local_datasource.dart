import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/password_hasher.dart';
import '../models/app_user_model.dart';

class UserLocalDatasource {
  Future<Database> get _db async => DatabaseHelper.instance.database;

  Future<List<AppUserModel>> getAll() async {
    final db = await _db;
    final rows = await db.query('user', orderBy: 'nama ASC');
    return rows.map(AppUserModel.fromMap).toList();
  }

  Future<AppUserModel> create({
    required String nama,
    required String username,
    required String password,
    required String role,
  }) async {
    final db = await _db;
    final existing = await db.query('user', where: 'username = ?', whereArgs: [username], limit: 1);
    if (existing.isNotEmpty) {
      throw const DuplicateException('Username sudah digunakan, silakan pilih username lain');
    }

    final now = DateTime.now();
    final passwordHash = PasswordHasher.hash(password);
    final id = await db.insert('user', {
      'nama': nama,
      'username': username,
      'password': passwordHash,
      'role': role,
      'is_active': 1,
      'created_at': AppFormatters.toDbString(now),
    });

    return AppUserModel(
      id: id,
      nama: nama,
      username: username,
      role: role,
      isActive: true,
      createdAt: now,
      passwordHash: passwordHash,
    );
  }

  Future<AppUserModel> toggleActive(int id, bool isActive) async {
    final db = await _db;
    final count = await db.update(
      'user',
      {'is_active': isActive ? 1 : 0},
      where: 'id_user = ?',
      whereArgs: [id],
    );
    if (count == 0) throw const NotFoundException('Pengguna tidak ditemukan');

    final rows = await db.query('user', where: 'id_user = ?', whereArgs: [id], limit: 1);
    return AppUserModel.fromMap(rows.first);
  }

  Future<void> delete(int id) async {
    final db = await _db;
    final count = await db.delete('user', where: 'id_user = ?', whereArgs: [id]);
    if (count == 0) throw const NotFoundException('Pengguna tidak ditemukan');
  }
}
