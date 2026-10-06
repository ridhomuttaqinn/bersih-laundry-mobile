import '../../core/utils/result.dart';
import '../entities/pelanggan.dart';
import '../entities/app_user.dart';

/// Hasil login generik: menampung salah satu dari [pelanggan] atau [appUser]
/// tergantung role yang berhasil login.
class LoginResult {
  final Pelanggan? pelanggan;
  final AppUser? appUser;
  const LoginResult({this.pelanggan, this.appUser});

  String get role => pelanggan != null ? 'pelanggan' : (appUser?.role ?? '');
  int get id => pelanggan?.id ?? appUser!.id!;
  String get nama => pelanggan?.nama ?? appUser!.nama;
}

abstract class AuthRepository {
  /// Login unified: mencoba email (pelanggan) lalu username (kasir/pemilik).
  Future<Result<LoginResult>> login({required String identifier, required String password});

  Future<Result<Pelanggan>> registerPelanggan({
    required String nama,
    required String alamat,
    required String noTelepon,
    required String email,
    required String password,
  });

  Future<Result<Pelanggan>> getPelangganById(int id);
  Future<Result<AppUser>> getUserById(int id);
}
