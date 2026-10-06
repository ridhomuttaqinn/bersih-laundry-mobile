import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';

/// Kartu pembungkus konten dengan padding & style konsisten.
class SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const SectionCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSizes.md),
        child: child,
      ),
    );
  }
}
