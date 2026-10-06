import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/ringkasan_pendapatan.dart';

class LaporanLocalDatasource {
  Future<Database> get _db async => DatabaseHelper.instance.database;

  /// Pendapatan dihitung dari tabel `pembayaran` (uang yang benar-benar diterima),
  /// bukan sekadar `total_bayar` pada pesanan yang mungkin belum dibayar.
  Future<double> getTotalPendapatan({required DateTime rangeStart, required DateTime rangeEnd}) async {
    final db = await _db;
    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(jumlah_bayar), 0) AS total
      FROM pembayaran
      WHERE tanggal_bayar >= ? AND tanggal_bayar < ?
    ''', [AppFormatters.toDbString(rangeStart), AppFormatters.toDbString(rangeEnd)]);
    return (result.first['total'] as num).toDouble();
  }

  Future<int> getJumlahPesanan({required DateTime rangeStart, required DateTime rangeEnd}) async {
    final db = await _db;
    final result = await db.rawQuery('''
      SELECT COUNT(*) AS jumlah
      FROM pesanan
      WHERE tanggal_masuk >= ? AND tanggal_masuk < ? AND status_pesanan != 'ditolak'
    ''', [AppFormatters.toDbString(rangeStart), AppFormatters.toDbString(rangeEnd)]);
    return (result.first['jumlah'] as num).toInt();
  }

  Future<List<RingkasanPendapatan>> getRingkasan({
    required PeriodeLaporan periode,
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) async {
    final db = await _db;

    // Format grup tanggal SQLite berbeda per periode.
    final String groupFormat = switch (periode) {
      PeriodeLaporan.harian => '%Y-%m-%d',
      PeriodeLaporan.mingguan => '%Y-%W', // tahun-nomor minggu
      PeriodeLaporan.bulanan => '%Y-%m',
    };

    final rows = await db.rawQuery('''
      SELECT
        strftime('$groupFormat', tanggal_bayar) AS periode_key,
        MIN(tanggal_bayar) AS periode_awal,
        COALESCE(SUM(jumlah_bayar), 0) AS total,
        COUNT(DISTINCT id_pesanan) AS jumlah
      FROM pembayaran
      WHERE tanggal_bayar >= ? AND tanggal_bayar < ?
      GROUP BY periode_key
      ORDER BY periode_key ASC
    ''', [AppFormatters.toDbString(rangeStart), AppFormatters.toDbString(rangeEnd)]);

    return rows.map((row) {
      final periodeAwal = AppFormatters.fromDbString(row['periode_awal'] as String);
      return RingkasanPendapatan(
        label: _formatLabel(periode, periodeAwal),
        periodeAwal: periodeAwal,
        totalPendapatan: (row['total'] as num).toDouble(),
        jumlahPesanan: (row['jumlah'] as num).toInt(),
      );
    }).toList();
  }

  String _formatLabel(PeriodeLaporan periode, DateTime date) {
    switch (periode) {
      case PeriodeLaporan.harian:
        return AppFormatters.date(date);
      case PeriodeLaporan.mingguan:
        return 'Minggu ${_weekOfYear(date)}, ${date.year}';
      case PeriodeLaporan.bulanan:
        return _monthName(date.month);
    }
  }

  int _weekOfYear(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final days = date.difference(startOfYear).inDays;
    return (days / 7).ceil() + 1;
  }

  String _monthName(int month) {
    const names = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return names[month - 1];
  }
}
