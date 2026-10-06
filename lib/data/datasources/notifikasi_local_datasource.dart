import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/notifikasi.dart';

class NotifikasiLocalDatasource {
  Future<Database> get _db async => DatabaseHelper.instance.database;

  Future<List<Notifikasi>> getByPelanggan(int idPelanggan) async {
    final db = await _db;
    final rows = await db.query(
      'notifikasi',
      where: 'id_pelanggan = ?',
      whereArgs: [idPelanggan],
      orderBy: 'created_at DESC',
    );
    return rows
        .map((row) => Notifikasi(
              id: row['id_notifikasi'] as int?,
              idPelanggan: row['id_pelanggan'] as int,
              idPesanan: row['id_pesanan'] as int,
              pesan: row['pesan'] as String,
              dibaca: (row['dibaca'] as int) == 1,
              createdAt: AppFormatters.fromDbString(row['created_at'] as String),
            ))
        .toList();
  }

  Future<void> markAsRead(int id) async {
    final db = await _db;
    await db.update('notifikasi', {'dibaca': 1}, where: 'id_notifikasi = ?', whereArgs: [id]);
  }

  Future<int> countUnread(int idPelanggan) async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS jumlah FROM notifikasi WHERE id_pelanggan = ? AND dibaca = 0',
      [idPelanggan],
    );
    return (result.first['jumlah'] as num).toInt();
  }
}
