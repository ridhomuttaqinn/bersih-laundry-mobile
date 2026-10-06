import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// Ditampilkan saat sebuah daftar kosong (mis. belum ada pesanan).
/// Ikon dibungkus badge lingkaran berwarna lembut agar tidak terasa polos
/// (lihat revisi poin #8: peningkatan tema visual & estetika).
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? accentColor;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.primary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(color: color.withOpacity(0.10), shape: BoxShape.circle),
              child: Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(color: color.withOpacity(0.14), shape: BoxShape.circle),
                  child: Icon(icon, size: 32, color: color),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSizes.xs),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
