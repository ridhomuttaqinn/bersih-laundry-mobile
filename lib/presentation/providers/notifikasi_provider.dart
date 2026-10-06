import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/notifikasi.dart';
import 'core_providers.dart';

final notifikasiListProvider =
    FutureProvider.autoDispose.family<List<Notifikasi>, int>((ref, idPelanggan) async {
  final usecase = ref.watch(getNotifikasiUseCaseProvider);
  final result = await usecase(idPelanggan);
  return result.when(success: (data) => data, failure: (f) => throw f);
});

final unreadNotifikasiCountProvider = FutureProvider.autoDispose.family<int, int>((ref, idPelanggan) async {
  final usecase = ref.watch(countUnreadNotifikasiUseCaseProvider);
  final result = await usecase(idPelanggan);
  return result.when(success: (data) => data, failure: (_) => 0);
});
