import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/formatters.dart';
import '../models/pembayaran_model.dart';

class PembayaranLocalDatasource {
  Future<Database> get _db async => DatabaseHelper.instance.database;

  Future<PembayaranModel> recordPayment({
    required int idPesanan,
    required String metodeBayar,
    required double jumlahBayar,
  }) async {
    final db = await _db;
    final existing = await db.query(
      'pembayaran',
      where: 'id_pesanan = ?',
      whereArgs: [idPesanan],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      throw const DuplicateException('Pesanan ini sudah memiliki data pembayaran');
    }

    final now = DateTime.now();
    final id = await db.insert('pembayaran', {
      'id_pesanan': idPesanan,
      'tanggal_bayar': AppFormatters.toDbString(now),
      'metode_bayar': metodeBayar,
      'jumlah_bayar': jumlahBayar,
    });

    return PembayaranModel(
      id: id,
      idPesanan: idPesanan,
      tanggalBayar: now,
      metodeBayar: metodeBayar,
      jumlahBayar: jumlahBayar,
    );
  }

  Future<PembayaranModel?> getByPesanan(int idPesanan) async {
    final db = await _db;
    final rows = await db.query('pembayaran', where: 'id_pesanan = ?', whereArgs: [idPesanan], limit: 1);
    if (rows.isEmpty) return null;
    return PembayaranModel.fromMap(rows.first);
  }
}
