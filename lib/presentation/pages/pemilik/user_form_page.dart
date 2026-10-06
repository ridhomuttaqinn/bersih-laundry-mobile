import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/utils/validators.dart';
import '../../providers/user_provider.dart';

/// Form penambahan akun baru (kasir/pemilik) oleh Pemilik.
class UserFormPage extends ConsumerStatefulWidget {
  const UserFormPage({super.key});

  @override
  ConsumerState<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends ConsumerState<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = AppRole.kasir;
  bool _isSaving = false;

  @override
  void dispose() {
    _namaController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final success = await ref.read(userManagementProvider.notifier).createUser(
          nama: _namaController.text,
          username: _usernameController.text,
          password: _passwordController.text,
          role: _role,
        );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      AppSnackbar.success(context, 'Akun berhasil ditambahkan');
      Navigator.pop(context);
    } else {
      final error = ref.read(userManagementProvider).error;
      AppSnackbar.error(context, error?.message ?? 'Gagal menambahkan akun');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Akun')),
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
                  validator: (v) => Validators.required(v, field: 'Nama'),
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  controller: _usernameController,
                  label: 'Username',
                  validator: (v) => Validators.required(v, field: 'Username'),
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  controller: _passwordController,
                  label: 'Kata Sandi',
                  obscureText: true,
                  validator: Validators.password,
                ),
                const SizedBox(height: AppSizes.md),
                Text('Peran', style: Theme.of(context).textTheme.titleMedium),
                RadioListTile<String>(
                  value: AppRole.kasir,
                  groupValue: _role,
                  onChanged: (v) => setState(() => _role = v!),
                  title: const Text('Kasir / Admin'),
                  contentPadding: EdgeInsets.zero,
                ),
                RadioListTile<String>(
                  value: AppRole.pemilik,
                  groupValue: _role,
                  onChanged: (v) => setState(() => _role = v!),
                  title: const Text('Pemilik'),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: AppSizes.lg),
                AppPrimaryButton(label: 'Simpan Akun', isLoading: _isSaving, onPressed: _submit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
