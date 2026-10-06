import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// Tampilan error yang seragam untuk seluruh AsyncValue.error di aplikasi,
/// lengkap dengan tombol "Coba Lagi" agar UX tetap baik saat terjadi kegagalan.
class AppErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorView({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 56, color: AppColors.danger),
            const SizedBox(height: AppSizes.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSizes.md),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Coba Lagi'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
