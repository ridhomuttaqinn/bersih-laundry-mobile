import '../../core/utils/result.dart';
import '../entities/detail_pesanan.dart';
import '../entities/pesanan.dart';

abstract class PesananRepository {
  /// FR-3: pelanggan membuat pesanan baru berisi satu atau lebih [items] layanan.
  /// [metodeBayarPilihan] adalah preferensi pelanggan (revisi poin #6, opsional,
  /// bukan sumber kebenaran akhir — lihat [PembayaranRepository]).
  /// [isEstimasiBerat] menandai bahwa berat masih perkiraan dan perlu
  /// dikonfirmasi ulang oleh kasir/kurir saat penjemputan (revisi poin #4).
  Future<Result<Pesanan>> createPesanan({
    required int idPelanggan,
    required String alamatJemput,
    required String jadwalJemput,
    required List<DetailPesanan> items,
    String? metodeBayarPilihan,
    bool isEstimasiBerat = false,
  });

  Future<Result<List<Pesanan>>> getPesananByPelanggan(int idPelanggan);

  Future<Result<List<Pesanan>>> getAllPesanan({String? statusFilter});

  Future<Result<Pesanan>> getPesananById(int id);

  /// Kasir menerima pesanan & mulai memproses (FR-4, activity diagram langkah "Ya").
  Future<Result<Pesanan>> prosesPesanan({required int idPesanan, required int idKasir});

  /// Kasir menolak pesanan tidak valid (activity diagram langkah "Tidak").
  Future<Result<Pesanan>> tolakPesanan({
    required int idPesanan,
    required int idKasir,
    required String alasan,
  });

  /// Kasir memperbarui status pesanan (diproses -> selesai -> diambil).
  Future<Result<Pesanan>> updateStatusPesanan({
    required int idPesanan,
    required String statusBaru,
  });

  /// Revisi poin #4: kasir/kurir mengonfirmasi berat aktual hasil penimbangan,
  /// menggantikan estimasi awal pelanggan. [beratAktualPerDetail] memetakan
  /// id_detail -> berat aktual (kg). Subtotal per item dan total_bayar
  /// pesanan dihitung ulang otomatis (tetap menjaga FR-6).
  Future<Result<Pesanan>> confirmActualWeight({
    required int idPesanan,
    required Map<int, double> beratAktualPerDetail,
  });
}

