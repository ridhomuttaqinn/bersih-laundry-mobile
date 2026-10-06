import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Meng-hash kata sandi dengan SHA-256 + salt statis aplikasi sebelum disimpan
/// ke database, sesuai kebutuhan non-fungsional "Security" pada proposal.
///
/// Catatan produksi: untuk aplikasi skala besar, pertimbangkan salt unik per
/// pengguna dan algoritma khusus password (mis. bcrypt/argon2) melalui backend
/// terpusat. Implementasi ini cukup untuk penyimpanan lokal on-device.
class PasswordHasher {
  PasswordHasher._();

  static const String _pepper = 'bersih_laundry_secure_pepper_v1';

  static String hash(String plainPassword) {
    final bytes = utf8.encode('$plainPassword::$_pepper');
    return sha256.convert(bytes).toString();
  }

  static bool verify(String plainPassword, String hashed) {
    return hash(plainPassword) == hashed;
  }
}
