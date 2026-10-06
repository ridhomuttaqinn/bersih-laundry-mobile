import '../../domain/repositories/auth_repository.dart';
import '../models/app_user_model.dart';
import '../models/pelanggan_model.dart';
import 'api_client.dart';

class AuthRemoteDatasource {
  Future<LoginResult> login({
    required String identifier,
    required String password,
  }) async {
    final result = await ApiClient.post('/auth/login', body: {
      'identifier': identifier,
      'password': password,
    }) as Map;
    final customerData = result['pelanggan'];
    final userData = result['user'];

    return LoginResult(
      pelanggan: customerData == null
          ? null
          : PelangganModel.fromMap(
              Map<String, Object?>.from(customerData as Map)),
      appUser: userData == null
          ? null
          : AppUserModel.fromMap(Map<String, Object?>.from(userData as Map)),
    );
  }

  Future<PelangganModel> registerPelanggan({
    required String nama,
    required String alamat,
    required String noTelepon,
    required String email,
    required String password,
  }) async {
    final result = await ApiClient.post('/auth/register', body: {
      'nama': nama,
      'alamat': alamat,
      'no_telepon': noTelepon,
      'email': email,
      'password': password,
    }) as Map;
    return PelangganModel.fromMap(Map<String, Object?>.from(result));
  }

  Future<PelangganModel> getPelangganById(int id) async {
    final result = await ApiClient.get('/pelanggan/$id') as Map;
    return PelangganModel.fromMap(Map<String, Object?>.from(result));
  }

  Future<AppUserModel> getUserById(int id) async {
    final result = await ApiClient.get('/users/$id') as Map;
    return AppUserModel.fromMap(Map<String, Object?>.from(result));
  }
}
