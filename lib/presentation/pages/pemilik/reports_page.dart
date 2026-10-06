import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/section_card.dart';
import '../../../domain/entities/ringkasan_pendapatan.dart';
import '../../providers/laporan_provider.dart';

/// FR-10: laporan rekap pendapatan harian/mingguan/bulanan untuk pemilik usaha.
class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  PeriodeLaporan _periode = PeriodeLaporan.harian;

  // PENTING: query dihitung SEKALI dan disimpan sebagai field (bukan getter
  // yang dipanggil ulang setiap build()). Ini memperbaiki bug "loading terus"
  // pada laporan pendapatan — lihat catatan lengkap di ReportQuery
  // (laporan_provider.dart) untuk penjelasan akar masalahnya.
  late ReportQuery _query = _buildQuery(_periode);

  ReportQuery _buildQuery(PeriodeLaporan periode) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (periode) {
      case PeriodeLaporan.harian:
        return ReportQuery(
          periode: periode,
          rangeStart: today.subtract(const Duration(days: 13)),
          rangeEnd: today.add(const Duration(days: 1)),
        );
      case PeriodeLaporan.mingguan:
        return ReportQuery(
          periode: periode,
          rangeStart: today.subtract(const Duration(days: 12 * 7)),
          rangeEnd: today.add(const Duration(days: 1)),
        );
      case PeriodeLaporan.bulanan:
        return ReportQuery(
          periode: periode,
          rangeStart: DateTime(now.year - 1, now.month, 1),
          rangeEnd: DateTime(now.year, now.month + 1, 1),
        );
    }
  }

  void _changePeriode(PeriodeLaporan periode) {
    setState(() {
      _periode = periode;
      _query = _buildQuery(periode);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(ringkasanPendapatanProvider(_query));

    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Pendapatan')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: SegmentedButton<PeriodeLaporan>(
              segments: const [
                ButtonSegment(value: PeriodeLaporan.harian, label: Text('Harian')),
                ButtonSegment(value: PeriodeLaporan.mingguan, label: Text('Mingguan')),
                ButtonSegment(value: PeriodeLaporan.bulanan, label: Text('Bulanan')),
              ],
              selected: {_periode},
              onSelectionChanged: (selection) => _changePeriode(selection.first),
            ),
          ),
          Expanded(
            child: reportAsync.when(
              data: (data) {
                if (data.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.bar_chart_outlined,
                    title: 'Belum ada data pendapatan',
                    subtitle: 'Laporan akan muncul setelah ada transaksi yang dibayar',
                  );
                }
                return ListView(
                  padding: const EdgeInsets.all(AppSizes.md),
                  children: [
                    SectionCard(
                      padding: const EdgeInsets.fromLTRB(8, 20, 20, 8),
                      child: SizedBox(
                        height: 240,
                        child: _RevenueChart(data: data),
                      ),
                    ),
                    const SizedBox(height: AppSizes.lg),
                    Text('Rincian per Periode', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSizes.sm),
                    ...data.reversed.map((item) => Card(
                          child: ListTile(
                            title: Text(item.label),
                            subtitle: Text('${item.jumlahPesanan} pesanan'),
                            trailing: Text(
                              AppFormatters.currency(item.totalPendapatan),
                              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                          ),
                        )),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => AppErrorView(
                message: 'Gagal memuat laporan pendapatan',
                onRetry: () => ref.invalidate(ringkasanPendapatanProvider(_query)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueChart extends StatelessWidget {
  final List<RingkasanPendapatan> data;
  const _RevenueChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxY = data.map((e) => e.totalPendapatan).fold<double>(0, (a, b) => a > b ? a : b);
    final safeMaxY = maxY <= 0 ? 100 : maxY * 1.2;

    return BarChart(
      BarChartData(
        maxY: safeMaxY.toDouble(),
        alignment: BarChartAlignment.spaceAround,
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (value, meta) => Text(
                _shortCurrency(value),
                style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
                final label = data[idx].label;
                final shortLabel = label.length > 8 ? '${label.substring(0, 6)}..' : label;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(shortLabel, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(data.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: data[i].totalPendapatan,
                color: AppColors.primary,
                width: 14,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }),
      ),
    );
  }

  String _shortCurrency(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}jt';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}rb';
    return value.toStringAsFixed(0);
  }
}
