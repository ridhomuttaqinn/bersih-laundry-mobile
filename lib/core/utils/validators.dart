/// Kumpulan validator untuk form input, dipakai bersama [TextFormField.validator].
class Validators {
  Validators._();

  static String? required(String? value, {String field = 'Kolom ini'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field wajib diisi';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email wajib diisi';
    final regex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!regex.hasMatch(value.trim())) return 'Format email tidak valid';
    return null;
  }

  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) return 'Kata sandi wajib diisi';
    if (value.length < minLength) return 'Kata sandi minimal $minLength karakter';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nomor telepon wajib diisi';
    final regex = RegExp(r'^[0-9+\-\s]{8,15}$');
    if (!regex.hasMatch(value.trim())) return 'Nomor telepon tidak valid';
    return null;
  }

  static String? positiveNumber(String? value, {String field = 'Nilai'}) {
    if (value == null || value.trim().isEmpty) return '$field wajib diisi';
    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
    if (parsed == null) return '$field harus berupa angka';
    if (parsed <= 0) return '$field harus lebih besar dari 0';
    return null;
  }

  static String? Function(String?) combine(List<String? Function(String?)> validators) {
    return (value) {
      for (final v in validators) {
        final result = v(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}
