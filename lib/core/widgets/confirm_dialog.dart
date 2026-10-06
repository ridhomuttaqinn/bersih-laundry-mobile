import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Dialog konfirmasi generik untuk aksi destruktif (hapus, tolak, dsb).
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Ya, Lanjutkan',
  String cancelLabel = 'Batal',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(cancelLabel)),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            confirmLabel,
            style: TextStyle(color: destructive ? AppColors.danger : AppColors.primary),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}
