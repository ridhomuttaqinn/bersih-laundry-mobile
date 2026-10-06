import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../constants/app_strings.dart';
import '../utils/formatters.dart';
import '../utils/password_hasher.dart';

/// Helper singleton yang mengelola koneksi & skema database SQLite lokal.
///
/// Skema tabel (pelanggan, user, layanan, pesanan, detail_pesanan, pembayaran)
/// diimplementasikan sesuai ERD & DDL pada proposal. Terdapat dua tambahan
/// kecil di luar ERD asli agar seluruh kebutuhan fungsional benar-benar
/// dapat berjalan sebagai aplikasi mobile mandiri:
///   1. Kolom `alamat_jemput`, `jadwal_jemput`, `catatan_penolakan` pada
///      tabel `pesanan` — dibutuhkan FR-3 (alamat & jadwal penjemputan) dan
///      alur "tolak pesanan" pada activity diagram.
///   2. Tabel `notifikasi` — dibutuhkan FR-5 (riwayat notifikasi ke pelanggan).
///   3. Kolom `pesanan.metode_bayar_pilihan` — preferensi metode pembayaran
///      dari pelanggan saat memesan (revisi poin #6), bersifat opsional dan
///      terpisah dari `pembayaran.metode_bayar` yang tetap jadi sumber
///      kebenaran akhir saat kasir mencatat pembayaran riil.
///   4. Kolom `pesanan.berat_dikonfirmasi` — menandai apakah berat cucian
///      sudah final (1) atau masih estimasi pelanggan menunggu konfirmasi
///      kasir/kurir (0) (revisi poin #4).
/// Seluruh penambahan ini didokumentasikan pula pada README.md.
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;
  // v1 -> v2: menambah `pesanan.metode_bayar_pilihan` (preferensi metode
  // pembayaran dari pelanggan, poin revisi #6) dan `pesanan.berat_dikonfirmasi`
  // (flag apakah berat cucian sudah final/dikonfirmasi kasir, poin revisi #4).
  static const int _dbVersion = 2;
  static const String _dbName = 'bersih_laundry.db';

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE pesanan ADD COLUMN metode_bayar_pilihan TEXT
          CHECK (metode_bayar_pilihan IN ('tunai','transfer','e-wallet'));
      ''');
      // Data lama dianggap sudah final (bukan estimasi) agar perilaku
      // aplikasi untuk pesanan lama tidak berubah setelah update.
      await db.execute('''
        ALTER TABLE pesanan ADD COLUMN berat_dikonfirmasi INTEGER NOT NULL DEFAULT 1;
      ''');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();

    batch.execute('''
      CREATE TABLE pelanggan (
        id_pelanggan INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        alamat TEXT NOT NULL,
        no_telepon TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        created_at TEXT NOT NULL
      );
    ''');

    batch.execute('''
      CREATE TABLE user (
        id_user INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL CHECK (role IN ('kasir','pemilik')),
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      );
    ''');

    batch.execute('''
      CREATE TABLE layanan (
        id_layanan INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_layanan TEXT NOT NULL,
        harga_per_unit REAL NOT NULL,
        satuan TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1
      );
    ''');

    batch.execute('''
      CREATE TABLE pesanan (
        id_pesanan INTEGER PRIMARY KEY AUTOINCREMENT,
        id_pelanggan INTEGER NOT NULL,
        id_user INTEGER,
        tanggal_masuk TEXT NOT NULL,
        tanggal_selesai TEXT,
        alamat_jemput TEXT NOT NULL,
        jadwal_jemput TEXT NOT NULL,
        status_pesanan TEXT NOT NULL DEFAULT 'diterima'
          CHECK (status_pesanan IN ('diterima','diproses','selesai','diambil','ditolak')),
        catatan_penolakan TEXT,
        total_bayar REAL NOT NULL DEFAULT 0,
        metode_bayar_pilihan TEXT
          CHECK (metode_bayar_pilihan IN ('tunai','transfer','e-wallet')),
        berat_dikonfirmasi INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (id_pelanggan) REFERENCES pelanggan (id_pelanggan) ON DELETE CASCADE,
        FOREIGN KEY (id_user) REFERENCES user (id_user) ON DELETE SET NULL
      );
    ''');

    batch.execute('''
      CREATE TABLE detail_pesanan (
        id_detail INTEGER PRIMARY KEY AUTOINCREMENT,
        id_pesanan INTEGER NOT NULL,
        id_layanan INTEGER NOT NULL,
        berat_qty REAL NOT NULL,
        subtotal REAL NOT NULL,
        FOREIGN KEY (id_pesanan) REFERENCES pesanan (id_pesanan) ON DELETE CASCADE,
        FOREIGN KEY (id_layanan) REFERENCES layanan (id_layanan)
      );
    ''');

    batch.execute('''
      CREATE TABLE pembayaran (
        id_pembayaran INTEGER PRIMARY KEY AUTOINCREMENT,
        id_pesanan INTEGER NOT NULL UNIQUE,
        tanggal_bayar TEXT NOT NULL,
        metode_bayar TEXT NOT NULL CHECK (metode_bayar IN ('tunai','transfer','e-wallet')),
        jumlah_bayar REAL NOT NULL,
        FOREIGN KEY (id_pesanan) REFERENCES pesanan (id_pesanan) ON DELETE CASCADE
      );
    ''');

    // Tabel tambahan (di luar ERD inti) untuk mendukung FR-5: notifikasi status.
    batch.execute('''
      CREATE TABLE notifikasi (
        id_notifikasi INTEGER PRIMARY KEY AUTOINCREMENT,
        id_pelanggan INTEGER NOT NULL,
        id_pesanan INTEGER NOT NULL,
        pesan TEXT NOT NULL,
        dibaca INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (id_pelanggan) REFERENCES pelanggan (id_pelanggan) ON DELETE CASCADE,
        FOREIGN KEY (id_pesanan) REFERENCES pesanan (id_pesanan) ON DELETE CASCADE
      );
    ''');

    batch.execute('CREATE INDEX idx_pesanan_pelanggan ON pesanan (id_pelanggan);');
    batch.execute('CREATE INDEX idx_pesanan_status ON pesanan (status_pesanan);');
    batch.execute('CREATE INDEX idx_detail_pesanan ON detail_pesanan (id_pesanan);');
    batch.execute('CREATE INDEX idx_notifikasi_pelanggan ON notifikasi (id_pelanggan);');

    await batch.commit(noResult: true);
    await _seedInitialData(db);
  }

  /// Data awal (seed) agar aplikasi langsung bisa dicoba tanpa setup manual:
  /// 1 akun pemilik, 1 akun kasir, dan 4 jenis layanan laundry standar.
  Future<void> _seedInitialData(Database db) async {
    final now = AppFormatters.toDbString(DateTime.now());

    await db.insert('user', {
      'nama': 'Owner Bersih Laundry',
      'username': 'owner',
      'password': PasswordHasher.hash('owner123'),
      'role': AppRole.pemilik,
      'is_active': 1,
      'created_at': now,
    });

    await db.insert('user', {
      'nama': 'Kasir Bersih Laundry',
      'username': 'kasir',
      'password': PasswordHasher.hash('kasir123'),
      'role': AppRole.kasir,
      'is_active': 1,
      'created_at': now,
    });

    final layananSeed = [
      {'nama_layanan': 'Cuci Kering', 'harga_per_unit': 6000.0, 'satuan': 'kg'},
      {'nama_layanan': 'Cuci Setrika', 'harga_per_unit': 8000.0, 'satuan': 'kg'},
      {'nama_layanan': 'Setrika Saja', 'harga_per_unit': 5000.0, 'satuan': 'kg'},
      {'nama_layanan': 'Cuci Sepatu', 'harga_per_unit': 20000.0, 'satuan': 'pasang'},
    ];
    for (final item in layananSeed) {
      await db.insert('layanan', {...item, 'is_active': 1});
    }
  }

  Future<void> closeDatabase() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
