import '../../core/utils/result.dart';
import '../entities/layanan.dart';

abstract class LayananRepository {
  Future<Result<List<Layanan>>> getAllLayanan({bool onlyActive = false});
  Future<Result<Layanan>> getLayananById(int id);
  Future<Result<Layanan>> createLayanan(Layanan layanan);
  Future<Result<Layanan>> updateLayanan(Layanan layanan);
  Future<Result<void>> deleteLayanan(int id);
}
