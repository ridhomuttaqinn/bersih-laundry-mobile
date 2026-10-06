import '../models/app_user_model.dart';
import 'api_client.dart';

class UserRemoteDatasource {
  Future<List<AppUserModel>> getAll() async {
    final data = await ApiClient.get('/users') as List;
    return data
        .map((item) =>
            AppUserModel.fromMap(Map<String, Object?>.from(item as Map)))
        .toList();
  }

  Future<AppUserModel> create({
    required String nama,
    required String username,
    required String password,
    required String role,
  }) async {
    final data = await ApiClient.post('/users', body: {
      'nama': nama,
      'username': username,
      'password': password,
      'role': role,
    }) as Map;
    return AppUserModel.fromMap(Map<String, Object?>.from(data));
  }

  Future<AppUserModel> toggleActive(int id, bool isActive) async {
    final data = await ApiClient.patch('/users/$id', body: {
      'is_active': isActive,
    }) as Map;
    return AppUserModel.fromMap(Map<String, Object?>.from(data));
  }

  Future<void> delete(int id) async {
    await ApiClient.delete('/users/$id');
  }
}
