import '../models/detail_pesanan_model.dart';
import '../models/pesanan_model.dart';
import 'api_client.dart';

class PesananRemoteDatasource {
  Future<PesananModel> createPesanan({
    required int idPelanggan,
    required String alamatJemput,
    required String jadwalJemput,
    required List<DetailPesananModel> items,
    String? metodeBayarPilihan,
    bool isEstimasiBerat = false,
  }) async {
    final data = await ApiClient.post('/pesanan', body: {
      'id_pelanggan': idPelanggan,
      'alamat_jemput': alamatJemput,
      'jadwal_jemput': jadwalJemput,
      'metode_bayar_pilihan': metodeBayarPilihan,
      'is_estimasi_berat': isEstimasiBerat,
      'items': items
          .map((item) => {
                'id_layanan': item.layanan.id,
                'berat_qty': item.beratQty,
              })
          .toList(),
    });
    return _toPesanan(data);
  }

  Future<List<PesananModel>> getByPelanggan(int idPelanggan) async {
    final data = await ApiClient.get('/pesanan', queryParameters: {
      'id_pelanggan': '$idPelanggan',
    }) as List;
    return data.map(_toPesanan).toList();
  }

  Future<List<PesananModel>> getAll({String? statusFilter}) async {
    final data = await ApiClient.get('/pesanan', queryParameters: {
      if (statusFilter != null && statusFilter.isNotEmpty)
        'status': statusFilter,
    }) as List;
    return data.map(_toPesanan).toList();
  }

  Future<PesananModel> getById(int id) async {
    return _toPesanan(await ApiClient.get('/pesanan/$id'));
  }

  Future<PesananModel> updateStatus({
    required int idPesanan,
    required String statusBaru,
    int? idKasir,
    String? catatanPenolakan,
    bool setTanggalSelesai = false,
  }) async {
    final body = <String, dynamic>{'status_pesanan': statusBaru};
    if (idKasir != null) body['id_user'] = idKasir;
    if (catatanPenolakan != null) {
      body['catatan_penolakan'] = catatanPenolakan;
    }
    final data =
        await ApiClient.patch('/pesanan/$idPesanan/status', body: body);
    return _toPesanan(data);
  }

  Future<PesananModel> confirmActualWeight({
    required int idPesanan,
    required Map<int, double> beratAktualPerDetail,
  }) async {
    final data = await ApiClient.patch('/pesanan/$idPesanan/berat', body: {
      'berat_aktual_per_detail': beratAktualPerDetail,
    });
    return _toPesanan(data);
  }

  Future<void> insertNotification({
    required int idPelanggan,
    required int idPesanan,
    required String pesan,
  }) async {
    await ApiClient.post('/notifikasi', body: {
      'id_pelanggan': idPelanggan,
      'id_pesanan': idPesanan,
      'pesan': pesan,
    });
  }

  PesananModel _toPesanan(dynamic value) {
    final data = Map<String, Object?>.from(value as Map);
    final items = (data['items'] as List? ?? const [])
        .map((item) => DetailPesananModel.fromJoinedMap(
              Map<String, Object?>.from(item as Map),
            ))
        .toList();
    return PesananModel.fromJoinedMap(data, items: items);
  }
}
