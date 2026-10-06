import '../../core/utils/result.dart';
import '../entities/pelanggan.dart';

/// FR-9: kasir/admin mengelola data pelanggan.
abstract class PelangganRepository {
  Future<Result<List<Pelanggan>>> getAllPelanggan({String? search});
  Future<Result<void>> deletePelanggan(int id);
  Future<Result<Pelanggan>> updatePelanggan(Pelanggan pelanggan);
}
