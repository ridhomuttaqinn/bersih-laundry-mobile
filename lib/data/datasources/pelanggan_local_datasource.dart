import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../../core/errors/exceptions.dart';
import '../models/pelanggan_model.dart';

class PelangganLocalDatasource {
  Future<Database> get _db async => DatabaseHelper.instance.database;

  Future<List<PelangganModel>> getAll({String? search}) async {
    final db = await _db;
    final hasSearch = search != null && search.trim().isNotEmpty;
    final rows = await db.query(
      'pelanggan',
      where: hasSearch ? '(nama LIKE ? OR email LIKE ? OR no_telepon LIKE ?)' : null,
      whereArgs: hasSearch ? List.filled(3, '%${search.trim()}%') : null,
      orderBy: 'nama ASC',
    );
    return rows.map(PelangganModel.fromMap).toList();
  }

  Future<void> delete(int id) async {
    final db = await _db;
    final count = await db.delete('pelanggan', where: 'id_pelanggan = ?', whereArgs: [id]);
    if (count == 0) throw const NotFoundException('Pelanggan tidak ditemukan');
  }

  Future<PelangganModel> update(PelangganModel model) async {
    final db = await _db;
    final count = await db.update(
      'pelanggan',
      {
        'nama': model.nama,
        'alamat': model.alamat,
        'no_telepon': model.noTelepon,
        'email': model.email,
      },
      where: 'id_pelanggan = ?',
      whereArgs: [model.id],
    );
    if (count == 0) throw const NotFoundException('Pelanggan tidak ditemukan');
    return model;
  }
}
