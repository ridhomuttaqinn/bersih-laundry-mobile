import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../kasir/kasir_shell.dart';
import '../pelanggan/pelanggan_shell.dart';
import '../pemilik/pemilik_shell.dart';
import 'login_page.dart';

/// Halaman pembuka: memeriksa sesi tersimpan lalu mengarahkan ke shell
/// sesuai role, atau ke halaman login jika belum ada sesi.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  bool _navigated = false;

  void _navigateIfNeeded(AuthState state) {
    if (_navigated || state.checkingSession) return;
    _navigated = true;

    Widget target;
    if (!state.isLoggedIn) {
      target = const LoginPage();
    } else {
      switch (state.session!.role) {
        case 'kasir':
          target = const KasirShell();
          break;
        case 'pemilik':
          target = const PemilikShell();
          break;
        default:
          target = const PelangganShell();
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => target));
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) => _navigateIfNeeded(next));

    final authState = ref.watch(authProvider);
    _navigateIfNeeded(authState);

    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_laundry_service_rounded, color: Colors.white, size: 72),
            SizedBox(height: 16),
            Text(
              AppStrings.appName,
              style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8),
            Text(
              AppStrings.appTagline,
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            SizedBox(height: 32),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.6, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
