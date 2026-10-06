import 'package:equatable/equatable.dart';

/// Representasi kegagalan yang bersih (tanpa membocorkan detail teknis)
/// untuk ditampilkan ke lapisan presentasi (UI).
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Kegagalan yang berasal dari operasi database lokal (SQLite).
class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'Terjadi kesalahan pada penyimpanan data.']);
}

/// Kegagalan validasi input pengguna.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Kegagalan otentikasi (login/registrasi).
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Data yang dicari tidak ditemukan.
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Data tidak ditemukan.']);
}

/// Kegagalan tak terduga (fallback).
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Terjadi kesalahan yang tidak terduga.']);
}
