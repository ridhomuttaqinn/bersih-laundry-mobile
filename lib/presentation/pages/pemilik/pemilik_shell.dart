import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'dashboard_page.dart';
import 'reports_page.dart';
import 'manage_user_page.dart';
import 'pemilik_profile_page.dart';

/// Shell utama untuk aktor Pemilik: Dashboard, Laporan, Akun, Profil.
class PemilikShell extends StatefulWidget {
  const PemilikShell({super.key});

  @override
  State<PemilikShell> createState() => _PemilikShellState();
}

class _PemilikShellState extends State<PemilikShell> {
  int _index = 0;

  final _pages = const [
    DashboardPage(),
    ReportsPage(),
    ManageUserPage(),
    PemilikProfilePage(),
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
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Laporan'),
          BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings_rounded), label: 'Akun'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profil'),
        ],
        selectedItemColor: AppColors.primary,
      ),
    );
  }
}
