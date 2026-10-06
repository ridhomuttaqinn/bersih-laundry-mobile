import 'api_client.dart';
import '../models/layanan_model.dart';

class LayananRemoteDatasource {
  Future<List<LayananModel>> getAll({bool onlyActive = false}) async {
    final data = await ApiClient.get('/layanan', queryParameters: {
      if (onlyActive) 'only_active': '1',
    }) as List;
    return data
        .map((item) =>
            LayananModel.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<LayananModel> getById(int id) async {
    final data = await ApiClient.get('/layanan/$id') as Map;
    return LayananModel.fromJson(Map<String, dynamic>.from(data));
  }

  Future<LayananModel> create(LayananModel model) async {
    final data = await ApiClient.post('/layanan', body: model.toJson()) as Map;
    return LayananModel.fromJson(Map<String, dynamic>.from(data));
  }

  Future<LayananModel> update(LayananModel model) async {
    final data =
        await ApiClient.put('/layanan/${model.id}', body: model.toJson())
            as Map;
    return LayananModel.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> delete(int id) async {
    await ApiClient.delete('/layanan/$id');
  }
}
