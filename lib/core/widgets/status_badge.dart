import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

/// Menampilkan status pesanan sebagai chip berwarna (selaras dengan
/// activity diagram: diterima -> diproses -> selesai -> diambil, atau ditolak).
class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const StatusBadge({super.key, required this.status, this.fontSize = 12});

  Color get _color {
    switch (status) {
      case OrderStatus.diterima:
        return AppColors.statusDiterima;
      case OrderStatus.diproses:
        return AppColors.statusDiproses;
      case OrderStatus.selesai:
        return AppColors.statusSelesai;
      case OrderStatus.diambil:
        return AppColors.statusDiambil;
      case OrderStatus.ditolak:
        return AppColors.statusDitolak;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        OrderStatus.label(status),
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: fontSize),
      ),
    );
  }
}
