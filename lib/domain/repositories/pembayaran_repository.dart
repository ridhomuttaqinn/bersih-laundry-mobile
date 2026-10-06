import '../../core/utils/result.dart';
import '../entities/pembayaran.dart';

abstract class PembayaranRepository {
  /// FR-7: mencatat pembayaran atas suatu pesanan.
  Future<Result<Pembayaran>> recordPayment({
    required int idPesanan,
    required String metodeBayar,
    required double jumlahBayar,
  });

  Future<Result<Pembayaran?>> getPaymentByPesanan(int idPesanan);
}
