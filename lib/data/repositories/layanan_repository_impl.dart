import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/layanan.dart';
import '../../domain/repositories/layanan_repository.dart';
import '../datasources/layanan_remote_datasource.dart';
import '../models/layanan_model.dart';

class LayananRepositoryImpl implements LayananRepository {
  final LayananRemoteDatasource datasource;

  LayananRepositoryImpl(this.datasource);

  @override
  Future<Result<List<Layanan>>> getAllLayanan({
    bool onlyActive = false,
  }) async {
    try {
      return Result.success(
        await datasource.getAll(onlyActive: onlyActive),
      );
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Gagal memuat daftar layanan: $e'),
      );
    }
  }

  @override
  Future<Result<Layanan>> getLayananById(int id) async {
    try {
      return Result.success(await datasource.getById(id));
    } on NotFoundException catch (e) {
      return Result.failure(NotFoundFailure(e.message));
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Gagal memuat layanan: $e'),
      );
    }
  }

  @override
  Future<Result<Layanan>> createLayanan(Layanan layanan) async {
    try {
      return Result.success(
        await datasource.create(
          LayananModel.fromEntity(layanan),
        ),
      );
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Gagal menambahkan layanan: $e'),
      );
    }
  }

  @override
  Future<Result<Layanan>> updateLayanan(Layanan layanan) async {
    try {
      return Result.success(
        await datasource.update(
          LayananModel.fromEntity(layanan),
        ),
      );
    } on NotFoundException catch (e) {
      return Result.failure(NotFoundFailure(e.message));
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Gagal memperbarui layanan: $e'),
      );
    }
  }

  @override
  Future<Result<void>> deleteLayanan(int id) async {
    try {
      await datasource.delete(id);
      return const Result.success(null);
    } on NotFoundException catch (e) {
      return Result.failure(NotFoundFailure(e.message));
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Gagal menghapus layanan: $e'),
      );
    }
  }
}
