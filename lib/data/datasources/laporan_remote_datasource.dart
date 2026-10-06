import '../../core/utils/formatters.dart';
import '../../domain/entities/ringkasan_pendapatan.dart';
import 'api_client.dart';

class LaporanRemoteDatasource {
  Future<double> getTotalPendapatan({
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) async {
    final data = await ApiClient.get('/laporan/total-pendapatan',
        queryParameters: _range(rangeStart, rangeEnd));
    return (data as num).toDouble();
  }

  Future<int> getJumlahPesanan({
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) async {
    final data = await ApiClient.get('/laporan/jumlah-pesanan',
        queryParameters: _range(rangeStart, rangeEnd));
    return (data as num).toInt();
  }

  Future<List<RingkasanPendapatan>> getRingkasan({
    required PeriodeLaporan periode,
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) async {
    final data = await ApiClient.get('/laporan/ringkasan', queryParameters: {
      ..._range(rangeStart, rangeEnd),
      'periode': periode.name,
    }) as List;
    return data.map((item) {
      final row = Map<String, dynamic>.from(item as Map);
      return RingkasanPendapatan(
        label: row['label'] as String,
        periodeAwal: AppFormatters.fromDbString(row['periode_awal'] as String),
        totalPendapatan: (row['total_pendapatan'] as num).toDouble(),
        jumlahPesanan: (row['jumlah_pesanan'] as num).toInt(),
      );
    }).toList();
  }

  Map<String, String> _range(DateTime rangeStart, DateTime rangeEnd) => {
        'range_start': AppFormatters.toDbString(rangeStart),
        'range_end': AppFormatters.toDbString(rangeEnd),
      };
}
