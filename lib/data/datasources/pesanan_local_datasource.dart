import 'package:sqflite/sqflite.dart' hide DatabaseException;
import '../../core/database/database_helper.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/formatters.dart';
import '../models/detail_pesanan_model.dart';
import '../models/pesanan_model.dart';

class PesananLocalDatasource {
  Future<Database> get _db async => DatabaseHelper.instance.database;

  static const String _joinedSelect = '''
    SELECT 
      p.*, 
      pel.nama AS nama_pelanggan, 
      u.nama AS nama_kasir
    FROM pesanan p
    LEFT JOIN pelanggan pel ON pel.id_pelanggan = p.id_pelanggan
    LEFT JOIN user u ON u.id_user = p.id_user
  ''';

  Future<List<DetailPesananModel>> _getItemsForOrder(
      Database db, int idPesanan) async {
    final rows = await db.rawQuery('''
      SELECT dp.*, l.nama_layanan, l.harga_per_unit, l.satuan
      FROM detail_pesanan dp
      JOIN layanan l ON l.id_layanan = dp.id_layanan
      WHERE dp.id_pesanan = ?
    ''', [idPesanan]);
    return rows.map(DetailPesananModel.fromJoinedMap).toList();
  }

  Future<PesananModel> createPesanan({
    required int idPelanggan,
    required String alamatJemput,
    required String jadwalJemput,
    required List<DetailPesananModel> items,
    String? metodeBayarPilihan,
    bool isEstimasiBerat = false,
  }) async {
    final db = await _db;
    final now = AppFormatters.toDbString(DateTime.now());
    final total = items.fold<double>(0, (sum, item) => sum + item.subtotal);

    late int newId;
    await db.transaction((txn) async {
      newId = await txn.insert('pesanan', {
        'id_pelanggan': idPelanggan,
        'id_user': null,
        'tanggal_masuk': now,
        'tanggal_selesai': null,
        'alamat_jemput': alamatJemput,
        'jadwal_jemput': jadwalJemput,
        'status_pesanan': 'diterima',
        'catatan_penolakan': null,
        'total_bayar': total,
        'metode_bayar_pilihan': metodeBayarPilihan,
        'berat_dikonfirmasi': isEstimasiBerat ? 0 : 1,
      });

      for (final item in items) {
        await txn.insert('detail_pesanan', {
          'id_pesanan': newId,
          'id_layanan': item.layanan.id,
          'berat_qty': item.beratQty,
          'subtotal': item.subtotal,
        });
      }
    });

    return getById(newId);
  }

  Future<PesananModel> getById(int id) async {
    final db = await _db;
    final rows =
        await db.rawQuery('$_joinedSelect WHERE p.id_pesanan = ?', [id]);
    if (rows.isEmpty) throw const NotFoundException('Pesanan tidak ditemukan');
    final items = await _getItemsForOrder(db, id);
    return PesananModel.fromJoinedMap(rows.first, items: items);
  }

  Future<List<PesananModel>> getByPelanggan(int idPelanggan) async {
    final db = await _db;
    final rows = await db.rawQuery(
      '$_joinedSelect WHERE p.id_pelanggan = ? ORDER BY p.tanggal_masuk DESC',
      [idPelanggan],
    );
    final results = <PesananModel>[];
    for (final row in rows) {
      final items = await _getItemsForOrder(db, row['id_pesanan'] as int);
      results.add(PesananModel.fromJoinedMap(row, items: items));
    }
    return results;
  }

  Future<List<PesananModel>> getAll({String? statusFilter}) async {
    final db = await _db;
    final where = (statusFilter != null && statusFilter.isNotEmpty)
        ? 'WHERE p.status_pesanan = ?'
        : '';
    final args = (statusFilter != null && statusFilter.isNotEmpty)
        ? [statusFilter]
        : <Object?>[];
    final rows = await db.rawQuery(
      '$_joinedSelect $where ORDER BY p.tanggal_masuk DESC',
      args,
    );
    final results = <PesananModel>[];
    for (final row in rows) {
      final items = await _getItemsForOrder(db, row['id_pesanan'] as int);
      results.add(PesananModel.fromJoinedMap(row, items: items));
    }
    return results;
  }

  Future<PesananModel> updateStatus({
    required int idPesanan,
    required String statusBaru,
    int? idKasir,
    String? catatanPenolakan,
    bool setTanggalSelesai = false,
  }) async {
    final db = await _db;
    final values = <String, Object?>{
      'status_pesanan': statusBaru,
    };
    if (idKasir != null) values['id_user'] = idKasir;
    if (catatanPenolakan != null) {
      values['catatan_penolakan'] = catatanPenolakan;
    }
    if (setTanggalSelesai) {
      values['tanggal_selesai'] = AppFormatters.toDbString(DateTime.now());
    }

    final count = await db.update(
      'pesanan',
      values,
      where: 'id_pesanan = ?',
      whereArgs: [idPesanan],
    );
    if (count == 0) throw const NotFoundException('Pesanan tidak ditemukan');
    return getById(idPesanan);
  }

  Future<PesananModel> confirmActualWeight({
    required int idPesanan,
    required Map<int, double> beratAktualPerDetail,
  }) async {
    final db = await _db;

    await db.transaction((txn) async {
      double newTotal = 0;

      for (final entry in beratAktualPerDetail.entries) {
        final idDetail = entry.key;
        final beratBaru = entry.value;

        final rows = await txn.rawQuery('''
          SELECT dp.id_pesanan, l.harga_per_unit
          FROM detail_pesanan dp
          JOIN layanan l ON l.id_layanan = dp.id_layanan
          WHERE dp.id_detail = ?
        ''', [idDetail]);

        if (rows.isEmpty) {
          throw NotFoundException('Rincian pesanan #$idDetail tidak ditemukan');
        }
        if (rows.first['id_pesanan'] != idPesanan) {
          throw const DatabaseException(
              'Rincian pesanan tidak sesuai dengan pesanan yang dikonfirmasi');
        }

        final hargaPerUnit = (rows.first['harga_per_unit'] as num).toDouble();
        final subtotalBaru = hargaPerUnit * beratBaru;

        await txn.update(
          'detail_pesanan',
          {'berat_qty': beratBaru, 'subtotal': subtotalBaru},
          where: 'id_detail = ?',
          whereArgs: [idDetail],
        );
      }

      final totalRows = await txn.rawQuery(
        'SELECT COALESCE(SUM(subtotal), 0) AS total FROM detail_pesanan WHERE id_pesanan = ?',
        [idPesanan],
      );
      newTotal = (totalRows.first['total'] as num).toDouble();

      final count = await txn.update(
        'pesanan',
        {'total_bayar': newTotal, 'berat_dikonfirmasi': 1},
        where: 'id_pesanan = ?',
        whereArgs: [idPesanan],
      );
      if (count == 0) throw const NotFoundException('Pesanan tidak ditemukan');
    });

    return getById(idPesanan);
  }

  Future<void> insertNotification({
    required int idPelanggan,
    required int idPesanan,
    required String pesan,
  }) async {
    final db = await _db;
    await db.insert('notifikasi', {
      'id_pelanggan': idPelanggan,
      'id_pesanan': idPesanan,
      'pesan': pesan,
      'dibaca': 0,
      'created_at': AppFormatters.toDbString(DateTime.now()),
    });
  }
}
