import '../models/pelanggan_model.dart';
import 'api_client.dart';

class PelangganRemoteDatasource {
  Future<List<PelangganModel>> getAll({String? search}) async {
    final data = await ApiClient.get('/pelanggan', queryParameters: {
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    }) as List;
    return data
        .map((item) =>
            PelangganModel.fromMap(Map<String, Object?>.from(item as Map)))
        .toList();
  }

  Future<void> delete(int id) async {
    await ApiClient.delete('/pelanggan/$id');
  }

  Future<PelangganModel> update(PelangganModel model) async {
    final data = await ApiClient.put('/pelanggan/${model.id}', body: {
      'nama': model.nama,
      'alamat': model.alamat,
      'no_telepon': model.noTelepon,
      'email': model.email,
    }) as Map;
    return PelangganModel.fromMap(Map<String, Object?>.from(data));
  }
}
