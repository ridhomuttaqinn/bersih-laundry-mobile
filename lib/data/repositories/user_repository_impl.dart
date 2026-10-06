import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDatasource datasource;
  const UserRepositoryImpl(this.datasource);

  @override
  Future<Result<List<AppUser>>> getAllUsers() async {
    try {
      return Result.success(await datasource.getAll());
    } catch (e) {
      return Result.failure(DatabaseFailure('Gagal memuat daftar akun: $e'));
    }
  }

  @override
  Future<Result<AppUser>> createUser({
    required String nama,
    required String username,
    required String password,
    required String role,
  }) async {
    try {
      final result = await datasource.create(
        nama: nama,
        username: username,
        password: password,
        role: role,
      );
      return Result.success(result);
    } on DuplicateException catch (e) {
      return Result.failure(ValidationFailure(e.message));
    } catch (e) {
      return Result.failure(DatabaseFailure('Gagal membuat akun: $e'));
    }
  }

  @override
  Future<Result<AppUser>> toggleActive(int id, bool isActive) async {
    try {
      return Result.success(await datasource.toggleActive(id, isActive));
    } on NotFoundException catch (e) {
      return Result.failure(NotFoundFailure(e.message));
    } catch (e) {
      return Result.failure(
          DatabaseFailure('Gagal memperbarui status akun: $e'));
    }
  }

  @override
  Future<Result<void>> deleteUser(int id) async {
    try {
      await datasource.delete(id);
      return const Result.success(null);
    } on NotFoundException catch (e) {
      return Result.failure(NotFoundFailure(e.message));
    } catch (e) {
      return Result.failure(DatabaseFailure('Gagal menghapus akun: $e'));
    }
  }
}
