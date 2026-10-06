import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'incoming_orders_page.dart';
import 'manage_layanan_page.dart';
import 'manage_pelanggan_page.dart';
import 'kasir_profile_page.dart';

/// Shell utama untuk aktor Kasir/Admin: Pesanan, Layanan, Pelanggan, Profil.
class KasirShell extends StatefulWidget {
  const KasirShell({super.key});

  @override
  State<KasirShell> createState() => _KasirShellState();
}

class _KasirShellState extends State<KasirShell> {
  int _index = 0;

  final _pages = const [
    IncomingOrdersPage(),
    ManageLayananPage(),
    ManagePelangganPage(),
    KasirProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.inbox_rounded), label: 'Pesanan'),
          BottomNavigationBarItem(icon: Icon(Icons.local_laundry_service_rounded), label: 'Layanan'),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'Pelanggan'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profil'),
        ],
        selectedItemColor: AppColors.primary,
      ),
    );
  }
}
