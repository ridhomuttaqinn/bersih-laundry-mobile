import '../../core/utils/result.dart';
import '../entities/notifikasi.dart';

abstract class NotifikasiRepository {
  Future<Result<List<Notifikasi>>> getByPelanggan(int idPelanggan);
  Future<Result<void>> markAsRead(int id);
  Future<Result<int>> countUnread(int idPelanggan);
}
