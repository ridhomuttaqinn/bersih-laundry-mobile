import '../models/pembayaran_model.dart';
import 'api_client.dart';

class PembayaranRemoteDatasource {
  Future<PembayaranModel> recordPayment({
    required int idPesanan,
    required String metodeBayar,
    required double jumlahBayar,
  }) async {
    final data = await ApiClient.post('/pesanan/$idPesanan/pembayaran', body: {
      'metode_bayar': metodeBayar,
      'jumlah_bayar': jumlahBayar,
    }) as Map;
    return PembayaranModel.fromMap(Map<String, Object?>.from(data));
  }

  Future<PembayaranModel?> getByPesanan(int idPesanan) async {
    final data = await ApiClient.get('/pesanan/$idPesanan/pembayaran');
    if (data == null) return null;
    return PembayaranModel.fromMap(Map<String, Object?>.from(data as Map));
  }
}
