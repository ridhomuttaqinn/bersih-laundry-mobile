import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/section_card.dart';
import '../../providers/auth_provider.dart';
import '../../providers/laporan_provider.dart';

/// FR-10: ringkasan pendapatan & jumlah pesanan sebagai landing pemilik.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authProvider).session;
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Halo, ${session?.nama.split(' ').first ?? ''} 👋')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(dashboardSummaryProvider),
        child: summaryAsync.when(
          data: (summary) => ListView(
            padding: const EdgeInsets.all(AppSizes.md),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'Pendapatan Hari Ini',
                      value: AppFormatters.currency(summary.pendapatanHariIni),
                      icon: Icons.payments_rounded,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Pesanan Hari Ini',
                      value: '${summary.jumlahPesananHariIni}',
                      icon: Icons.receipt_long_rounded,
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.sm),
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'Pendapatan Bulan Ini',
                      value: AppFormatters.currency(summary.pendapatanBulanIni),
                      icon: Icons.trending_up_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Pesanan Bulan Ini',
                      value: '${summary.jumlahPesananBulanIni}',
                      icon: Icons.calendar_month_rounded,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.lg),
              const SectionCard(
                child: Row(
                  children: [
                    Icon(Icons.bar_chart_rounded, color: AppColors.primary),
                    SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: Text(
                        'Lihat rekap pendapatan harian, mingguan, dan bulanan lebih detail di tab Laporan.',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => AppErrorView(
            message: 'Gagal memuat ringkasan dashboard',
            onRetry: () => ref.invalidate(dashboardSummaryProvider),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
