import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/layanan.dart';
import '../../providers/layanan_provider.dart';

class LayananFormPage extends ConsumerStatefulWidget {
  final Layanan? layanan;
  const LayananFormPage({super.key, this.layanan});

  @override
  ConsumerState<LayananFormPage> createState() => _LayananFormPageState();
}

class _LayananFormPageState extends ConsumerState<LayananFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaController;
  late final TextEditingController _hargaController;
  late final TextEditingController _satuanController;
  late bool _isActive;
  bool _isSaving = false;

  bool get _isEdit => widget.layanan != null;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.layanan?.namaLayanan ?? '');
    _hargaController = TextEditingController(
      text: widget.layanan != null ? widget.layanan!.hargaPerUnit.toStringAsFixed(0) : '',
    );
    _satuanController = TextEditingController(text: widget.layanan?.satuan ?? 'kg');
    _isActive = widget.layanan?.isActive ?? true;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _satuanController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final layanan = Layanan(
      id: widget.layanan?.id,
      namaLayanan: _namaController.text.trim(),
      hargaPerUnit: double.parse(_hargaController.text.replaceAll(',', '.')),
      satuan: _satuanController.text.trim(),
      isActive: _isActive,
    );

    final success = await ref.read(layananManagementProvider.notifier).save(layanan);
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      AppSnackbar.success(context, _isEdit ? 'Layanan diperbarui' : 'Layanan ditambahkan');
      Navigator.pop(context);
    } else {
      final error = ref.read(layananManagementProvider).error;
      AppSnackbar.error(context, error?.message ?? 'Gagal menyimpan layanan');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Layanan' : 'Tambah Layanan')),
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
                  label: 'Nama Layanan',
                  validator: (v) => Validators.required(v, field: 'Nama layanan'),
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  controller: _hargaController,
                  label: 'Harga per Satuan (Rp)',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => Validators.positiveNumber(v, field: 'Harga'),
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  controller: _satuanController,
                  label: 'Satuan (contoh: kg, pasang)',
                  validator: (v) => Validators.required(v, field: 'Satuan'),
                ),
                const SizedBox(height: AppSizes.md),
                SwitchListTile(
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                  title: const Text('Aktifkan Layanan'),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: AppSizes.lg),
                AppPrimaryButton(label: 'Simpan', isLoading: _isSaving, onPressed: _submit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
