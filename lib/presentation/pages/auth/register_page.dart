import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../pelanggan/pelanggan_shell.dart';

/// FR-1: registrasi akun pelanggan baru.
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _teleponController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _namaController.dispose();
    _alamatController.dispose();
    _teleponController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final success = await ref.read(authProvider.notifier).register(
          nama: _namaController.text,
          alamat: _alamatController.text,
          noTelepon: _teleponController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (!mounted) return;

    if (success) {
      AppSnackbar.success(context, 'Registrasi berhasil! Selamat datang.');
      Navigator.of(context)
          .pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const PelangganShell()), (r) => false);
    } else {
      final error = ref.read(authProvider).error;
      AppSnackbar.error(context, error?.message ?? 'Registrasi gagal');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun Pelanggan')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  controller: _namaController,
                  label: 'Nama Lengkap',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  validator: (v) => Validators.required(v, field: 'Nama'),
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  controller: _alamatController,
                  label: 'Alamat',
                  maxLines: 2,
                  prefixIcon: const Icon(Icons.home_outlined),
                  validator: (v) => Validators.required(v, field: 'Alamat'),
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  controller: _teleponController,
                  label: 'Nomor Telepon',
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  validator: Validators.phone,
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: Validators.email,
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
                  validator: Validators.password,
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  controller: _confirmPasswordController,
                  label: 'Konfirmasi Kata Sandi',
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  validator: (v) {
                    if (v != _passwordController.text) return 'Konfirmasi kata sandi tidak cocok';
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.lg),
                AppPrimaryButton(
                  label: 'Daftar Sekarang',
                  isLoading: authState.isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppSizes.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
