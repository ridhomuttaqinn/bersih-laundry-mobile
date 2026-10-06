import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../entities/detail_pesanan.dart';
import '../entities/pesanan.dart';
import '../repositories/pesanan_repository.dart';

/// FR-3 & FR-6: pelanggan membuat pesanan baru; total dihitung otomatis
/// dari penjumlahan subtotal setiap item (lihat [DetailPesanan.fromLayanan]).
class CreateOrderUseCase {
  final PesananRepository repository;
  const CreateOrderUseCase(this.repository);

  Future<Result<Pesanan>> call({
    required int idPelanggan,
    required String alamatJemput,
    required String jadwalJemput,
    required List<DetailPesanan> items,
    String? metodeBayarPilihan,
    bool isEstimasiBerat = false,
  }) {
    if (items.isEmpty) {
      return Future.value(
        const Result.failure(ValidationFailure('Pilih minimal satu jenis layanan')),
      );
    }
    if (alamatJemput.trim().isEmpty) {
      return Future.value(
        const Result.failure(ValidationFailure('Alamat penjemputan wajib diisi')),
      );
    }
    if (jadwalJemput.trim().isEmpty) {
      return Future.value(
        const Result.failure(ValidationFailure('Jadwal penjemputan wajib diisi')),
      );
    }
    for (final item in items) {
      if (item.beratQty <= 0) {
        return Future.value(
          Result.failure(ValidationFailure('Berat/jumlah untuk ${item.layanan.namaLayanan} harus lebih dari 0')),
        );
      }
    }

    return repository.createPesanan(
      idPelanggan: idPelanggan,
      alamatJemput: alamatJemput.trim(),
      jadwalJemput: jadwalJemput.trim(),
      items: items,
      metodeBayarPilihan: metodeBayarPilihan,
      isEstimasiBerat: isEstimasiBerat,
    );
  }
}

/// FR-4 & FR-8: melihat status pesanan real-time & riwayat transaksi pelanggan.
class GetOrderHistoryUseCase {
  final PesananRepository repository;
  const GetOrderHistoryUseCase(this.repository);

  Future<Result<List<Pesanan>>> call(int idPelanggan) => repository.getPesananByPelanggan(idPelanggan);
}

/// Kasir melihat seluruh pesanan masuk, dapat difilter berdasarkan status.
class GetIncomingOrdersUseCase {
  final PesananRepository repository;
  const GetIncomingOrdersUseCase(this.repository);

  Future<Result<List<Pesanan>>> call({String? statusFilter}) =>
      repository.getAllPesanan(statusFilter: statusFilter);
}

class GetOrderDetailUseCase {
  final PesananRepository repository;
  const GetOrderDetailUseCase(this.repository);

  Future<Result<Pesanan>> call(int id) => repository.getPesananById(id);
}

/// Kasir menerima & memproses pesanan (activity diagram: valid -> proses).
class ProcessOrderUseCase {
  final PesananRepository repository;
  const ProcessOrderUseCase(this.repository);

  Future<Result<Pesanan>> call({required int idPesanan, required int idKasir}) =>
      repository.prosesPesanan(idPesanan: idPesanan, idKasir: idKasir);
}

/// Kasir menolak pesanan tidak valid (activity diagram: tidak valid -> tolak).
class RejectOrderUseCase {
  final PesananRepository repository;
  const RejectOrderUseCase(this.repository);

  Future<Result<Pesanan>> call({
    required int idPesanan,
    required int idKasir,
    required String alasan,
  }) {
    if (alasan.trim().isEmpty) {
      return Future.value(const Result.failure(ValidationFailure('Alasan penolakan wajib diisi')));
    }
    return repository.tolakPesanan(idPesanan: idPesanan, idKasir: idKasir, alasan: alasan.trim());
  }
}

/// Kasir memperbarui status progres cucian (diproses -> selesai -> diambil).
class UpdateOrderStatusUseCase {
  final PesananRepository repository;
  const UpdateOrderStatusUseCase(this.repository);

  Future<Result<Pesanan>> call({required int idPesanan, required String statusBaru}) =>
      repository.updateStatusPesanan(idPesanan: idPesanan, statusBaru: statusBaru);
}

/// Revisi poin #4: kasir/kurir mengonfirmasi berat aktual hasil penimbangan,
/// menggantikan estimasi awal pelanggan, dan memicu perhitungan ulang total
/// (tetap konsisten dengan FR-6: total selalu dihitung otomatis dari rincian).
class ConfirmActualWeightUseCase {
  final PesananRepository repository;
  const ConfirmActualWeightUseCase(this.repository);

  Future<Result<Pesanan>> call({
    required int idPesanan,
    required Map<int, double> beratAktualPerDetail,
  }) {
    if (beratAktualPerDetail.isEmpty) {
      return Future.value(
        const Result.failure(ValidationFailure('Tidak ada rincian berat untuk dikonfirmasi')),
      );
    }
    for (final berat in beratAktualPerDetail.values) {
      if (berat <= 0) {
        return Future.value(
          const Result.failure(ValidationFailure('Berat aktual harus lebih dari 0')),
        );
      }
    }
    return repository.confirmActualWeight(idPesanan: idPesanan, beratAktualPerDetail: beratAktualPerDetail);
  }
}
