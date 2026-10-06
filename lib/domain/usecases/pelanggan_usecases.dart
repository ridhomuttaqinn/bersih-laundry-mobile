import '../../core/utils/result.dart';
import '../entities/pelanggan.dart';
import '../repositories/pelanggan_repository.dart';

/// FR-9: kasir/admin mengelola data pelanggan.
class GetAllPelangganUseCase {
  final PelangganRepository repository;
  const GetAllPelangganUseCase(this.repository);

  Future<Result<List<Pelanggan>>> call({String? search}) => repository.getAllPelanggan(search: search);
}

class DeletePelangganUseCase {
  final PelangganRepository repository;
  const DeletePelangganUseCase(this.repository);

  Future<Result<void>> call(int id) => repository.deletePelanggan(id);
}

class UpdatePelangganUseCase {
  final PelangganRepository repository;
  const UpdatePelangganUseCase(this.repository);

  Future<Result<Pelanggan>> call(Pelanggan pelanggan) => repository.updatePelanggan(pelanggan);
}
