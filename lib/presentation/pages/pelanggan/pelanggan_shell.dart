import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'home_page.dart';
import 'order_history_page.dart';
import 'notifications_page.dart';
import 'profile_page.dart';

/// Shell utama untuk aktor Pelanggan: Beranda, Riwayat, Notifikasi, Profil.
class PelangganShell extends StatefulWidget {
  const PelangganShell({super.key});

  @override
  State<PelangganShell> createState() => _PelangganShellState();
}

class _PelangganShellState extends State<PelangganShell> {
  int _index = 0;

  final _pages = const [
    PelangganHomePage(),
    OrderHistoryPage(),
    NotificationsPage(),
    ProfilePage(),
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
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_rounded), label: 'Notifikasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profil'),
        ],
        selectedItemColor: AppColors.primary,
      ),
    );
  }
}
