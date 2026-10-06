import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../../core/errors/exceptions.dart';
import '../models/layanan_model.dart';

class LayananLocalDatasource {
  Future<Database> get _db async => DatabaseHelper.instance.database;

  Future<List<LayananModel>> getAll({bool onlyActive = false}) async {
    final db = await _db;
    final rows = await db.query(
      'layanan',
      where: onlyActive ? 'is_active = 1' : null,
      orderBy: 'nama_layanan ASC',
    );
    return rows.map(LayananModel.fromMap).toList();
  }

  Future<LayananModel> getById(int id) async {
    final db = await _db;
    final rows = await db.query('layanan', where: 'id_layanan = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) throw const NotFoundException('Layanan tidak ditemukan');
    return LayananModel.fromMap(rows.first);
  }

  Future<LayananModel> create(LayananModel model) async {
    final db = await _db;
    final id = await db.insert('layanan', model.toMap());
    return LayananModel(
      id: id,
      namaLayanan: model.namaLayanan,
      hargaPerUnit: model.hargaPerUnit,
      satuan: model.satuan,
      isActive: model.isActive,
    );
  }

  Future<LayananModel> update(LayananModel model) async {
    final db = await _db;
    final count = await db.update(
      'layanan',
      model.toMap(),
      where: 'id_layanan = ?',
      whereArgs: [model.id],
    );
    if (count == 0) throw const NotFoundException('Layanan tidak ditemukan');
    return model;
  }

  Future<void> delete(int id) async {
    final db = await _db;
    final count = await db.delete('layanan', where: 'id_layanan = ?', whereArgs: [id]);
    if (count == 0) throw const NotFoundException('Layanan tidak ditemukan');
  }
}
