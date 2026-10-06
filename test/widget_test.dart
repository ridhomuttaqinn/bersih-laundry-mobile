import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bersih_laundry_app/main.dart';

/// Smoke test dasar: memastikan aplikasi dapat dibangun (build) tanpa error
/// dan halaman awal (SplashPage) tampil sebagai entry point pertama.
void main() {
  testWidgets('App builds and shows splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: BersihLaundryApp()));

    // Splash page menampilkan nama aplikasi & indikator loading saat
    // sesi login sedang diperiksa.
    expect(find.text('Bersih Laundry'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
