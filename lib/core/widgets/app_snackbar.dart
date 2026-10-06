import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Helper untuk menampilkan SnackBar sukses/error secara konsisten.
class AppSnackbar {
  AppSnackbar._();

  static void success(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ]),
        backgroundColor: AppColors.success,
      ));
  }

  static void error(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.error, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ]),
        backgroundColor: AppColors.danger,
      ));
  }
}
