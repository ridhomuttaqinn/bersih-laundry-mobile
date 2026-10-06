import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/pelanggan.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource datasource;
  const AuthRepositoryImpl(this.datasource);

  @override
  Future<Result<LoginResult>> login(
      {required String identifier, required String password}) async {
    try {
      return Result.success(await datasource.login(
        identifier: identifier,
        password: password,
      ));
    } catch (e) {
      return Result.failure(AuthFailure('Gagal melakukan login: $e'));
    }
  }

  @override
  Future<Result<Pelanggan>> registerPelanggan({
    required String nama,
    required String alamat,
    required String noTelepon,
    required String email,
    required String password,
  }) async {
    try {
      final model = await datasource.registerPelanggan(
        nama: nama,
        alamat: alamat,
        noTelepon: noTelepon,
        email: email,
        password: password,
      );
      return Result.success(model);
    } catch (e) {
      return Result.failure(AuthFailure('Gagal melakukan registrasi: $e'));
    }
  }

  @override
  Future<Result<Pelanggan>> getPelangganById(int id) async {
    try {
      return Result.success(await datasource.getPelangganById(id));
    } catch (e) {
      return Result.failure(
          NotFoundFailure('Gagal mengambil data pelanggan: $e'));
    }
  }

  @override
  Future<Result<AppUser>> getUserById(int id) async {
    try {
      return Result.success(await datasource.getUserById(id));
    } catch (e) {
      return Result.failure(
          NotFoundFailure('Gagal mengambil data pengguna: $e'));
    }
  }
}
