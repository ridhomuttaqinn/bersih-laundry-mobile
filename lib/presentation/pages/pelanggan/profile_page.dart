import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/section_card.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authProvider).session;
    final pelanggan = session?.pelanggan;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Saya')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          Center(
            child: Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
              child: const Icon(Icons.person_rounded, size: 44, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Center(
            child: Text(session?.nama ?? '-', style: Theme.of(context).textTheme.titleLarge),
          ),
          const SizedBox(height: AppSizes.lg),
          SectionCard(
            child: Column(
              children: [
                _ProfileRow(icon: Icons.email_outlined, label: 'Email', value: pelanggan?.email ?? '-'),
                const Divider(height: 24),
                _ProfileRow(icon: Icons.phone_outlined, label: 'Telepon', value: pelanggan?.noTelepon ?? '-'),
                const Divider(height: 24),
                _ProfileRow(icon: Icons.home_outlined, label: 'Alamat', value: pelanggan?.alamat ?? '-'),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.xl),
          OutlinedButton.icon(
            onPressed: () async {
              final confirmed = await showConfirmDialog(
                context,
                title: 'Keluar Akun',
                message: 'Apakah Anda yakin ingin keluar?',
                confirmLabel: 'Keluar',
                destructive: true,
              );
              if (!confirmed) return;
              await ref.read(authProvider.notifier).logout();
              if (!context.mounted) return;
              Navigator.of(context)
                  .pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginPage()), (r) => false);
            },
            icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
            label: const Text('Keluar', style: TextStyle(color: AppColors.danger)),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ProfileRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 20),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}
