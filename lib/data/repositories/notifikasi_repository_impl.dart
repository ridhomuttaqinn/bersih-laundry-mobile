import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/notifikasi.dart';
import '../../domain/repositories/notifikasi_repository.dart';
import '../datasources/notifikasi_remote_datasource.dart';

class NotifikasiRepositoryImpl implements NotifikasiRepository {
  final NotifikasiRemoteDatasource datasource;
  const NotifikasiRepositoryImpl(this.datasource);

  @override
  Future<Result<List<Notifikasi>>> getByPelanggan(int idPelanggan) async {
    try {
      return Result.success(await datasource.getByPelanggan(idPelanggan));
    } catch (e) {
      return Result.failure(DatabaseFailure('Gagal memuat notifikasi: $e'));
    }
  }

  @override
  Future<Result<void>> markAsRead(int id) async {
    try {
      await datasource.markAsRead(id);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(
          DatabaseFailure('Gagal memperbarui notifikasi: $e'));
    }
  }

  @override
  Future<Result<int>> countUnread(int idPelanggan) async {
    try {
      return Result.success(await datasource.countUnread(idPelanggan));
    } catch (e) {
      return Result.failure(DatabaseFailure('Gagal menghitung notifikasi: $e'));
    }
  }
}
