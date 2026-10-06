import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../core/utils/validators.dart';
import '../entities/app_user.dart';
import '../repositories/user_repository.dart';

/// Use case "Mengelola Data Akun" oleh Pemilik pada proposal.
class GetAllUsersUseCase {
  final UserRepository repository;
  const GetAllUsersUseCase(this.repository);

  Future<Result<List<AppUser>>> call() => repository.getAllUsers();
}

class CreateUserUseCase {
  final UserRepository repository;
  const CreateUserUseCase(this.repository);

  Future<Result<AppUser>> call({
    required String nama,
    required String username,
    required String password,
    required String role,
  }) {
    final namaError = Validators.required(nama, field: 'Nama');
    final usernameError = Validators.required(username, field: 'Username');
    final passError = Validators.password(password);
    final firstError =
        [namaError, usernameError, passError].firstWhere((e) => e != null, orElse: () => null);
    if (firstError != null) {
      return Future.value(Result.failure(ValidationFailure(firstError)));
    }
    return repository.createUser(
      nama: nama.trim(),
      username: username.trim().toLowerCase(),
      password: password,
      role: role,
    );
  }
}

class ToggleUserActiveUseCase {
  final UserRepository repository;
  const ToggleUserActiveUseCase(this.repository);

  Future<Result<AppUser>> call(int id, bool isActive) => repository.toggleActive(id, isActive);
}

class DeleteUserUseCase {
  final UserRepository repository;
  const DeleteUserUseCase(this.repository);

  Future<Result<void>> call(int id) => repository.deleteUser(id);
}
