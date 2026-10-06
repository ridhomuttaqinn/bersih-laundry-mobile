import '../../core/utils/result.dart';
import '../entities/app_user.dart';

/// Pemilik mengelola akun kasir/pemilik lain di dalam sistem
/// (use case "Mengelola Data Akun" pada proposal).
abstract class UserRepository {
  Future<Result<List<AppUser>>> getAllUsers();
  Future<Result<AppUser>> createUser({
    required String nama,
    required String username,
    required String password,
    required String role,
  });
  Future<Result<AppUser>> toggleActive(int id, bool isActive);
  Future<Result<void>> deleteUser(int id);
}
