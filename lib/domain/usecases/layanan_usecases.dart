import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../entities/layanan.dart';
import '../repositories/layanan_repository.dart';

/// FR-2: menampilkan daftar layanan & harga.
class GetLayananListUseCase {
  final LayananRepository repository;
  const GetLayananListUseCase(this.repository);

  Future<Result<List<Layanan>>> call({bool onlyActive = false}) {
    return repository.getAllLayanan(onlyActive: onlyActive);
  }
}

/// FR-9: kasir/admin mengelola (tambah/ubah/hapus) data layanan & harga.
class SaveLayananUseCase {
  final LayananRepository repository;
  const SaveLayananUseCase(this.repository);

  Future<Result<Layanan>> call(Layanan layanan) {
    if (layanan.namaLayanan.trim().isEmpty) {
      return Future.value(const Result.failure(ValidationFailure('Nama layanan wajib diisi')));
    }
    if (layanan.hargaPerUnit <= 0) {
      return Future.value(const Result.failure(ValidationFailure('Harga harus lebih besar dari 0')));
    }
    if (layanan.satuan.trim().isEmpty) {
      return Future.value(const Result.failure(ValidationFailure('Satuan wajib diisi')));
    }
    return layanan.id == null
        ? repository.createLayanan(layanan)
        : repository.updateLayanan(layanan);
  }
}

class DeleteLayananUseCase {
  final LayananRepository repository;
  const DeleteLayananUseCase(this.repository);

  Future<Result<void>> call(int id) => repository.deleteLayanan(id);
}
