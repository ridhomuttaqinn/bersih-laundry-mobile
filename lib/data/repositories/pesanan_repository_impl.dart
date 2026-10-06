import '../../core/constants/app_strings.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/services/notification_service.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/detail_pesanan.dart';
import '../../domain/entities/pesanan.dart';
import '../../domain/repositories/pesanan_repository.dart';
import '../datasources/pesanan_remote_datasource.dart';
import '../models/detail_pesanan_model.dart';

class PesananRepositoryImpl implements PesananRepository {
  final PesananRemoteDatasource datasource;
  final NotificationService notificationService;

  const PesananRepositoryImpl(
    this.datasource,
    this.notificationService,
  );

  @override
  Future<Result<Pesanan>> createPesanan({
    required int idPelanggan,
    required String alamatJemput,
    required String jadwalJemput,
    required List<DetailPesanan> items,
    String? metodeBayarPilihan,
    bool isEstimasiBerat = false,
  }) async {
    try {
      final itemModels = items
          .map((e) => DetailPesananModel(
              layanan: e.layanan, beratQty: e.beratQty, subtotal: e.subtotal))
          .toList();
      final pesanan = await datasource.createPesanan(
        idPelanggan: idPelanggan,
        alamatJemput: alamatJemput,
        jadwalJemput: jadwalJemput,
        items: itemModels,
        metodeBayarPilihan: metodeBayarPilihan,
        isEstimasiBerat: isEstimasiBerat,
      );
      return Result.success(pesanan);
    } catch (e) {
      return Result.failure(DatabaseFailure('Gagal membuat pesanan: $e'));
    }
  }

  @override
  Future<Result<List<Pesanan>>> getPesananByPelanggan(int idPelanggan) async {
    try {
      return Result.success(await datasource.getByPelanggan(idPelanggan));
    } catch (e) {
      return Result.failure(
          DatabaseFailure('Gagal memuat riwayat pesanan: $e'));
    }
  }

  @override
  Future<Result<List<Pesanan>>> getAllPesanan({String? statusFilter}) async {
    try {
      return Result.success(
          await datasource.getAll(statusFilter: statusFilter));
    } catch (e) {
      return Result.failure(DatabaseFailure('Gagal memuat daftar pesanan: $e'));
    }
  }

  @override
  Future<Result<Pesanan>> getPesananById(int id) async {
    try {
      return Result.success(await datasource.getById(id));
    } on NotFoundException catch (e) {
      return Result.failure(NotFoundFailure(e.message));
    } catch (e) {
      return Result.failure(DatabaseFailure('Gagal memuat detail pesanan: $e'));
    }
  }

  @override
  Future<Result<Pesanan>> prosesPesanan(
      {required int idPesanan, required int idKasir}) async {
    try {
      final pesanan = await datasource.updateStatus(
        idPesanan: idPesanan,
        statusBaru: OrderStatus.diproses,
        idKasir: idKasir,
      );
      await _notify(pesanan,
          'Pesanan #$idPesanan Anda sedang diproses oleh Bersih Laundry.');
      return Result.success(pesanan);
    } on NotFoundException catch (e) {
      return Result.failure(NotFoundFailure(e.message));
    } catch (e) {
      return Result.failure(DatabaseFailure('Gagal memproses pesanan: $e'));
    }
  }

  @override
  Future<Result<Pesanan>> tolakPesanan({
    required int idPesanan,
    required int idKasir,
    required String alasan,
  }) async {
    try {
      final pesanan = await datasource.updateStatus(
        idPesanan: idPesanan,
        statusBaru: OrderStatus.ditolak,
        idKasir: idKasir,
        catatanPenolakan: alasan,
      );
      await _notify(
          pesanan, 'Pesanan #$idPesanan Anda ditolak. Alasan: $alasan');
      return Result.success(pesanan);
    } on NotFoundException catch (e) {
      return Result.failure(NotFoundFailure(e.message));
    } catch (e) {
      return Result.failure(DatabaseFailure('Gagal menolak pesanan: $e'));
    }
  }

  @override
  Future<Result<Pesanan>> updateStatusPesanan(
      {required int idPesanan, required String statusBaru}) async {
    try {
      final pesanan = await datasource.updateStatus(
        idPesanan: idPesanan,
        statusBaru: statusBaru,
        setTanggalSelesai: statusBaru == OrderStatus.selesai,
      );

      final pesan = switch (statusBaru) {
        OrderStatus.selesai =>
          'Cucian Anda pada pesanan #$idPesanan telah selesai dan siap diambil/diantar.',
        OrderStatus.diambil =>
          'Pesanan #$idPesanan telah diambil. Terima kasih telah menggunakan Bersih Laundry!',
        _ =>
          'Status pesanan #$idPesanan diperbarui menjadi ${statusBaru.toUpperCase()}.',
      };
      await _notify(pesanan, pesan);

      return Result.success(pesanan);
    } on NotFoundException catch (e) {
      return Result.failure(NotFoundFailure(e.message));
    } catch (e) {
      return Result.failure(
          DatabaseFailure('Gagal memperbarui status pesanan: $e'));
    }
  }

  /// Revisi poin #4: konfirmasi berat aktual oleh kasir/kurir, menghitung
  /// ulang total, dan memberi tahu pelanggan jika totalnya berubah.
  @override
  Future<Result<Pesanan>> confirmActualWeight({
    required int idPesanan,
    required Map<int, double> beratAktualPerDetail,
  }) async {
    try {
      final before = await datasource.getById(idPesanan);
      final pesanan = await datasource.confirmActualWeight(
        idPesanan: idPesanan,
        beratAktualPerDetail: beratAktualPerDetail,
      );

      final selisih = pesanan.totalBayar - before.totalBayar;
      final pesan = selisih.abs() < 1
          ? 'Berat pesanan #$idPesanan telah dikonfirmasi sesuai timbangan aktual.'
          : 'Berat pesanan #$idPesanan telah dikonfirmasi. Total disesuaikan menjadi '
              '${pesanan.totalBayar.toStringAsFixed(0)} berdasarkan hasil timbangan aktual.';
      await _notify(pesanan, pesan);

      return Result.success(pesanan);
    } on NotFoundException catch (e) {
      return Result.failure(NotFoundFailure(e.message));
    } catch (e) {
      return Result.failure(
          DatabaseFailure('Gagal mengonfirmasi berat aktual: $e'));
    }
  }

  /// FR-5: menyimpan riwayat notifikasi ke DB sekaligus menampilkan
  /// notifikasi lokal (push-like) kepada pelanggan.
  Future<void> _notify(Pesanan pesanan, String pesan) async {
    await datasource.insertNotification(
      idPelanggan: pesanan.idPelanggan,
      idPesanan: pesanan.id!,
      pesan: pesan,
    );
    await notificationService.showOrderStatusNotification(
      orderId: pesanan.id!,
      title: 'Bersih Laundry',
      body: pesan,
    );
  }
}
