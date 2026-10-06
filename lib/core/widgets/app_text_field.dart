import 'package:flutter/material.dart';

/// Text field standar dengan label & validator, dipakai di seluruh form aplikasi.
///
/// Untuk field "tap untuk pilih" (mis. tanggal/jadwal), gunakan [readOnly]
/// bersama [onTap] alih-alih `enabled: false` + suffix icon terpisah — ini
/// membuat SELURUH area field bisa diketuk (bukan cuma ikon kecil di kanan)
/// dan teksnya tetap tampil normal, tidak pudar seperti field non-aktif.
class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onTap;
  final void Function(String)? onChanged;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.suffixIcon,
    this.prefixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: obscureText ? 1 : maxLines,
      enabled: enabled,
      readOnly: readOnly,
      onTap: onTap,
      // Saat readOnly+onTap dipakai untuk membuka picker, sembunyikan kursor
      // teks & jangan munculkan keyboard agar terasa seperti tombol, bukan
      // input teks biasa.
      showCursor: readOnly && onTap != null ? false : null,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
      ),
    );
  }
}
