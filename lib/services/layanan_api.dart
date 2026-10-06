import '../data/datasources/api_client.dart';
class LayananApi {
  static Future<List<dynamic>> getLayanan() async {
    final data = await ApiClient.get('/layanan');
    return List<dynamic>.from(data as List);
  }
}
