import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/pelanggan.dart';
import '../../domain/repositories/pelanggan_repository.dart';
import '../datasources/pelanggan_remote_datasource.dart';
import '../models/pelanggan_model.dart';

class PelangganRepositoryImpl implements PelangganRepository {
  final PelangganRemoteDatasource datasource;
  const PelangganRepositoryImpl(this.datasource);

  @override
  Future<Result<List<Pelanggan>>> getAllPelanggan({String? search}) async {
    try {
      return Result.success(await datasource.getAll(search: search));
    } catch (e) {
      return Result.failure(DatabaseFailure('Gagal memuat data pelanggan: $e'));
    }
  }

  @override
  Future<Result<void>> deletePelanggan(int id) async {
    try {
      await datasource.delete(id);
      return const Result.success(null);
    } on NotFoundException catch (e) {
      return Result.failure(NotFoundFailure(e.message));
    } catch (e) {
      return Result.failure(DatabaseFailure('Gagal menghapus pelanggan: $e'));
    }
  }

  @override
  Future<Result<Pelanggan>> updatePelanggan(Pelanggan pelanggan) async {
    try {
      final model = PelangganModel(
        id: pelanggan.id,
        nama: pelanggan.nama,
        alamat: pelanggan.alamat,
        noTelepon: pelanggan.noTelepon,
        email: pelanggan.email,
        createdAt: pelanggan.createdAt,
        passwordHash: '', // tidak diubah lewat alur ini
      );
      return Result.success(await datasource.update(model));
    } on NotFoundException catch (e) {
      return Result.failure(NotFoundFailure(e.message));
    } catch (e) {
      return Result.failure(
          DatabaseFailure('Gagal memperbarui data pelanggan: $e'));
    }
  }
}
