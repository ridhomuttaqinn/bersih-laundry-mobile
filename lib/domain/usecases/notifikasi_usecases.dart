import '../../core/utils/result.dart';
import '../entities/notifikasi.dart';
import '../repositories/notifikasi_repository.dart';

/// FR-5: pelanggan melihat riwayat notifikasi status pesanan.
class GetNotifikasiUseCase {
  final NotifikasiRepository repository;
  const GetNotifikasiUseCase(this.repository);

  Future<Result<List<Notifikasi>>> call(int idPelanggan) => repository.getByPelanggan(idPelanggan);
}

class MarkNotifikasiReadUseCase {
  final NotifikasiRepository repository;
  const MarkNotifikasiReadUseCase(this.repository);

  Future<Result<void>> call(int id) => repository.markAsRead(id);
}

class CountUnreadNotifikasiUseCase {
  final NotifikasiRepository repository;
  const CountUnreadNotifikasiUseCase(this.repository);

  Future<Result<int>> call(int idPelanggan) => repository.countUnread(idPelanggan);
}
