import 'package:flutter/material.dart';

/// Palet warna utama aplikasi Bersih Laundry.
/// Tema: biru bersih (trust, cleanliness) dengan aksen hijau (sukses) & kuning (proses).
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1F6FEB);
  static const Color primaryDark = Color(0xFF12459C);
  static const Color primaryLight = Color(0xFFE8F0FE);

  static const Color secondary = Color(0xFF00BFA6);

  static const Color background = Color(0xFFF6F8FB);
  static const Color surface = Color(0xFFFFFFFF);

  /// Warna dasar untuk soft-shadow pada card (dipakai dengan opacity rendah
  /// agar kesan elevasi lembut, bukan bayangan tegas/keras).
  static const Color shadow = Color(0xFF0F172A);

  static const Color textPrimary = Color(0xFF1A1E27);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color divider = Color(0xFFE5E7EB);

  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);

  // Warna status pesanan (selaras dengan activity diagram pada proposal)
  static const Color statusDiterima = Color(0xFF2563EB);
  static const Color statusDiproses = Color(0xFFF59E0B);
  static const Color statusSelesai = Color(0xFF16A34A);
  static const Color statusDiambil = Color(0xFF6D28D9);
  static const Color statusDitolak = Color(0xFFDC2626);
}
