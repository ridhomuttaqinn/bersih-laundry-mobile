# Bersih Laundry — APK percobaan

Kode Flutter dari project asli, dengan alamat API lewat dart-define dan header X-Deploy-Test-Token. Tidak ada token/password di paket ini.

## Build dari HP
Buat repository PRIVATE baru bernama bersih-laundry-mobile. Upload seluruh isi folder ini lewat git di Termux, termasuk .github/workflows/build-apk.yml. Login gh mungkin perlu tambahan izin workflow jika push ditolak.
Repository Settings → Secrets and variables → Actions → New repository secret: nama DEPLOY_TEST_TOKEN, nilai sama dengan .env backend di HP. Jangan masukkan nilai ke kode atau workflow.
Actions → Build APK Percobaan → Run workflow. Isi api_base_url alamat tunnel aktif dengan akhiran /api/v1.
Setelah hijau, buka run dan download artifact Bersih-Laundry-APK-Percobaan; ekstrak untuk memperoleh app-release.apk.

## Batasan
APK ini untuk uji coba; konfigurasi asli memakai debug signing jika keystore release tidak tersedia. Bukan paket Play Store. Token pengujian bersama dapat diekstrak dari APK; hanya gunakan data fiktif dan jangan distribusikan luas. Hak akses per pengguna belum diterapkan pada backend. Jika alamat tunnel berubah, build ulang dengan alamat baru. Server PHP dan cloudflared di HP harus tetap hidup.
Paket telah diperiksa secara statis, tetapi Flutter/Android SDK tidak tersedia di lingkungan penyusunan. Belum ada APK hasil build dan workflow belum dijalankan. GitHub Actions akan menjalankan tes asli dan build; kirim log jika gagal. Pemakaian Actions mengikuti kuota akun; jangan menyetujui tagihan jika diminta.
Android menggunakan AGP 8.6.1, Gradle 8.7, Kotlin 1.9.24 dan compile SDK 35. Flutter dipilih 3.24.5 untuk sesuai batas intl 0.19 project.
