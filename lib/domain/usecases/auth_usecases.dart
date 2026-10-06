import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../core/utils/validators.dart';
import '../entities/pelanggan.dart';
import '../repositories/auth_repository.dart';

/// FR-1: registrasi & login untuk pelanggan, kasir, dan pemilik dengan role berbeda.
class LoginUseCase {
  final AuthRepository repository;
  const LoginUseCase(this.repository);

  Future<Result<LoginResult>> call({required String identifier, required String password}) {
    if (identifier.trim().isEmpty || password.isEmpty) {
      return Future.value(
        const Result.failure(ValidationFailure('Identitas dan kata sandi wajib diisi')),
      );
    }
    return repository.login(identifier: identifier.trim(), password: password);
  }
}

class RegisterPelangganUseCase {
  final AuthRepository repository;
  const RegisterPelangganUseCase(this.repository);

  Future<Result<Pelanggan>> call({
    required String nama,
    required String alamat,
    required String noTelepon,
    required String email,
    required String password,
  }) {
    final emailError = Validators.email(email);
    final passError = Validators.password(password);
    final namaError = Validators.required(nama, field: 'Nama');
    final alamatError = Validators.required(alamat, field: 'Alamat');
    final phoneError = Validators.phone(noTelepon);

    final firstError = [namaError, alamatError, phoneError, emailError, passError]
        .firstWhere((e) => e != null, orElse: () => null);

    if (firstError != null) {
      return Future.value(Result.failure(ValidationFailure(firstError)));
    }

    return repository.registerPelanggan(
      nama: nama.trim(),
      alamat: alamat.trim(),
      noTelepon: noTelepon.trim(),
      email: email.trim().toLowerCase(),
      password: password,
    );
  }
}
