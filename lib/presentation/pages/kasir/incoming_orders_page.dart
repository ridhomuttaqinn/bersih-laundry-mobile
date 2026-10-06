import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/section_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../domain/entities/pesanan.dart';
import '../../providers/pesanan_provider.dart';
import 'order_process_page.dart';

/// FR-4 & use case "Mengelola Data Pesanan Masuk": kasir melihat & memfilter
/// seluruh pesanan berdasarkan status.
class IncomingOrdersPage extends ConsumerStatefulWidget {
  const IncomingOrdersPage({super.key});

  @override
  ConsumerState<IncomingOrdersPage> createState() => _IncomingOrdersPageState();
}

class _IncomingOrdersPageState extends ConsumerState<IncomingOrdersPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = <String?>[null, OrderStatus.diterima, OrderStatus.diproses, OrderStatus.selesai, OrderStatus.diambil];
  static const _tabLabels = ['Semua', 'Diterima', 'Diproses', 'Selesai', 'Diambil'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan Masuk'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabLabels.map((l) => Tab(text: l)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((status) => _OrderListView(statusFilter: status)).toList(),
      ),
    );
  }
}

class _OrderListView extends ConsumerWidget {
  final String? statusFilter;
  const _OrderListView({required this.statusFilter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(incomingOrdersProvider(statusFilter));

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(incomingOrdersProvider(statusFilter)),
      child: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 120),
                EmptyStateWidget(icon: Icons.inbox_outlined, title: 'Tidak ada pesanan'),
              ],
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSizes.md),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
            itemBuilder: (context, i) => _OrderTile(order: orders[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorView(
          message: 'Gagal memuat pesanan',
          onRetry: () => ref.invalidate(incomingOrdersProvider(statusFilter)),
        ),
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final Pesanan order;
  const _OrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => OrderProcessPage(orderId: order.id!)))
          .then((_) {
        // Refresh handled by provider invalidation inside the process page.
      }),
      child: SectionCard(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('#${order.id} • ${order.namaPelanggan ?? '-'}',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(AppFormatters.dateTime(order.tanggalMasuk),
                      style: const TextStyle(fontSize: 12.5, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(AppFormatters.currency(order.totalBayar), style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            StatusBadge(status: order.statusPesanan),
          ],
        ),
      ),
    );
  }
}
