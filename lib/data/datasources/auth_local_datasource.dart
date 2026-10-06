import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/password_hasher.dart';
import '../models/pelanggan_model.dart';
import '../models/app_user_model.dart';

class AuthLocalDatasource {
  Future<Database> get _db async => DatabaseHelper.instance.database;

  Future<PelangganModel?> findPelangganByEmail(String email) async {
    final db = await _db;
    final rows = await db.query('pelanggan', where: 'email = ?', whereArgs: [email], limit: 1);
    if (rows.isEmpty) return null;
    return PelangganModel.fromMap(rows.first);
  }

  Future<AppUserModel?> findUserByUsername(String username) async {
    final db = await _db;
    final rows = await db.query('user', where: 'username = ?', whereArgs: [username], limit: 1);
    if (rows.isEmpty) return null;
    return AppUserModel.fromMap(rows.first);
  }

  Future<PelangganModel> getPelangganById(int id) async {
    final db = await _db;
    final rows = await db.query('pelanggan', where: 'id_pelanggan = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) throw const NotFoundException('Pelanggan tidak ditemukan');
    return PelangganModel.fromMap(rows.first);
  }

  Future<AppUserModel> getUserById(int id) async {
    final db = await _db;
    final rows = await db.query('user', where: 'id_user = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) throw const NotFoundException('Pengguna tidak ditemukan');
    return AppUserModel.fromMap(rows.first);
  }

  Future<PelangganModel> registerPelanggan({
    required String nama,
    required String alamat,
    required String noTelepon,
    required String email,
    required String password,
  }) async {
    final db = await _db;
    final existing = await db.query('pelanggan', where: 'email = ?', whereArgs: [email], limit: 1);
    if (existing.isNotEmpty) {
      throw const DuplicateException('Email sudah terdaftar, silakan gunakan email lain');
    }

    final now = DateTime.now();
    final model = PelangganModel(
      nama: nama,
      alamat: alamat,
      noTelepon: noTelepon,
      email: email,
      createdAt: now,
      passwordHash: PasswordHasher.hash(password),
    );

    final id = await db.insert('pelanggan', model.toMap());
    return PelangganModel(
      id: id,
      nama: nama,
      alamat: alamat,
      noTelepon: noTelepon,
      email: email,
      createdAt: now,
      passwordHash: model.passwordHash,
    );
  }
}
