import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/section_card.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_page.dart';

class KasirProfilePage extends ConsumerWidget {
  const KasirProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authProvider).session;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Kasir')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          Center(
            child: Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
              child: const Icon(Icons.support_agent_rounded, size: 44, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Center(child: Text(session?.nama ?? '-', style: Theme.of(context).textTheme.titleLarge)),
          const Center(
            child: Text('Kasir / Admin', style: TextStyle(color: AppColors.textSecondary)),
          ),
          const SizedBox(height: AppSizes.lg),
          SectionCard(
            child: Row(
              children: [
                const Icon(Icons.account_circle_outlined, color: AppColors.textSecondary),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Username', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      Text(session?.appUser?.username ?? '-', style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
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
