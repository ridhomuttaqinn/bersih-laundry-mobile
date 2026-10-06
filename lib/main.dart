import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/constants/app_strings.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/auth/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi data locale Indonesia agar AppFormatters (format tanggal &
  // mata uang) dapat digunakan tanpa error LocaleDataException.
  await initializeDateFormatting('id_ID', null);

  // Inisialisasi notifikasi lokal lebih awal (FR-5) agar siap dipakai
  // segera setelah pengguna login dan status pesanan mulai berubah.
  await NotificationService.instance.init();

  runApp(const ProviderScope(child: BersihLaundryApp()));
}

class BersihLaundryApp extends StatelessWidget {
  const BersihLaundryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
      locale: const Locale('id', 'ID'),
      home: const SplashPage(),
    );
  }
}
