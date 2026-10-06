/// Kumpulan string konstan: nama aplikasi, role, status pesanan, dsb.
/// Menjaga nilai enum-seperti agar konsisten dengan skema database (proposal ERD).
class AppStrings {
  AppStrings._();

  static const String appName = 'Bersih Laundry';
  static const String appTagline = 'Laundry kiloan jadi lebih rapi & terpantau';
}

/// Role pengguna sistem — selaras dengan aktor pada use case diagram proposal.
class AppRole {
  AppRole._();

  static const String pelanggan = 'pelanggan';
  static const String kasir = 'kasir';
  static const String pemilik = 'pemilik';
}

/// Status pesanan — selaras dengan activity diagram pada proposal.
class OrderStatus {
  OrderStatus._();

  static const String diterima = 'diterima';
  static const String diproses = 'diproses';
  static const String selesai = 'selesai';
  static const String diambil = 'diambil';
  static const String ditolak = 'ditolak';

  static const List<String> all = [diterima, diproses, selesai, diambil, ditolak];

  static String label(String status) {
    switch (status) {
      case diterima:
        return 'Diterima';
      case diproses:
        return 'Diproses';
      case selesai:
        return 'Selesai';
      case diambil:
        return 'Sudah Diambil';
      case ditolak:
        return 'Ditolak';
      default:
        return status;
    }
  }
}

/// Metode pembayaran — sesuai skema tabel `pembayaran` pada proposal.
class PaymentMethod {
  PaymentMethod._();

  static const String tunai = 'tunai';
  static const String transfer = 'transfer';
  static const String eWallet = 'e-wallet';

  static const List<String> all = [tunai, transfer, eWallet];

  static String label(String method) {
    switch (method) {
      case tunai:
        return 'Tunai';
      case transfer:
        return 'Transfer Bank';
      case eWallet:
        return 'E-Wallet';
      default:
        return method;
    }
  }
}
