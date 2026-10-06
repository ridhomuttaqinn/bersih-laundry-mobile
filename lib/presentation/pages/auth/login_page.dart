import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../kasir/kasir_shell.dart';
import '../pelanggan/pelanggan_shell.dart';
import '../pemilik/pemilik_shell.dart';
import 'register_page.dart';

/// Login terpadu: pelanggan login dengan email, kasir/pemilik dengan username.
/// Role ditentukan otomatis oleh backend (AuthRepository) berdasarkan hasil pencarian.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Mengisi form login otomatis untuk akun demo (hanya dipanggil dari tombol
  /// yang hanya tampil di [kDebugMode]) — tidak pernah menampilkan password
  /// mentah di layar.
  void _fillDemoAccount(String identifier, String password) {
    _identifierController.text = identifier;
    _passwordController.text = password;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final success = await ref.read(authProvider.notifier).login(
          _identifierController.text.trim(),
          _passwordController.text,
        );

    if (!mounted) return;

    if (success) {
      final role = ref.read(authProvider).session!.role;
      Widget target = switch (role) {
        'kasir' => const KasirShell(),
        'pemilik' => const PemilikShell(),
        _ => const PelangganShell(),
      };
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => target), (r) => false);
    } else {
      final error = ref.read(authProvider).error;
      AppSnackbar.error(context, error?.message ?? 'Login gagal, periksa kembali data Anda');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSizes.xxl),
                Container(
                  width: 84,
                  height: 84,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  ),
                  child: const Icon(Icons.local_laundry_service_rounded, color: AppColors.primary, size: 44),
                ),
                const SizedBox(height: AppSizes.lg),
                Text(
                  AppStrings.appName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Masuk untuk melanjutkan',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSizes.xl),
                AppTextField(
                  controller: _identifierController,
                  label: 'Email (pelanggan) / Username (kasir & pemilik)',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  validator: (v) => Validators.required(v, field: 'Kolom ini'),
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  controller: _passwordController,
                  label: 'Kata Sandi',
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) => Validators.required(v, field: 'Kata sandi'),
                ),
                const SizedBox(height: AppSizes.lg),
                AppPrimaryButton(
                  label: 'Masuk',
                  isLoading: authState.isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppSizes.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Belum punya akun pelanggan?', style: TextStyle(color: AppColors.textSecondary)),
                    TextButton(
                      onPressed: () => Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) => const RegisterPage())),
                      child: const Text('Daftar'),
                    ),
                  ],
                ),
                // Kartu akun demo HANYA muncul saat `flutter run` (debug mode).
                // Otomatis hilang total pada build rilis (`flutter build apk/appbundle`),
                // sehingga tidak membocorkan credential kasir/pemilik ke publik.
                if (kDebugMode) ...[
                  const SizedBox(height: AppSizes.lg),
                  _DemoAccountsHint(
                    onFillKasir: () => _fillDemoAccount('kasir', 'kasir123'),
                    onFillPemilik: () => _fillDemoAccount('owner', 'owner123'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Info akun demo untuk mode pengembangan (debug) SAJA. Tidak pernah tampil
/// pada build rilis, dan tidak pernah menampilkan password mentah — hanya
/// tombol "Isi Otomatis" yang mengisi form login di belakang layar.
class _DemoAccountsHint extends StatelessWidget {
  final VoidCallback onFillKasir;
  final VoidCallback onFillPemilik;

  const _DemoAccountsHint({required this.onFillKasir, required this.onFillPemilik});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bug_report_outlined, size: 16, color: AppColors.primaryDark),
              SizedBox(width: 6),
              Text(
                'Mode Pengembangan — Akun Demo',
                style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryDark, fontSize: 12.5),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Kartu ini otomatis hilang pada build rilis.',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSizes.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: onFillKasir,
                icon: const Icon(Icons.support_agent_rounded, size: 16),
                label: const Text('Isi Otomatis: Kasir'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  textStyle: const TextStyle(fontSize: 12.5),
                ),
              ),
              OutlinedButton.icon(
                onPressed: onFillPemilik,
                icon: const Icon(Icons.storefront_rounded, size: 16),
                label: const Text('Isi Otomatis: Pemilik'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  textStyle: const TextStyle(fontSize: 12.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
