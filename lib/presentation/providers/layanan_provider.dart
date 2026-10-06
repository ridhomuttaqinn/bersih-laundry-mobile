import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/layanan.dart';
import 'core_providers.dart';

/// Daftar layanan aktif untuk ditampilkan ke pelanggan (FR-2).
final activeLayananProvider = FutureProvider.autoDispose<List<Layanan>>((ref) async {
  final usecase = ref.watch(getLayananListUseCaseProvider);
  final result = await usecase(onlyActive: true);
  return result.when(success: (data) => data, failure: (f) => throw f);
});

/// State untuk halaman manajemen layanan oleh kasir (FR-9): daftar lengkap
/// (termasuk non-aktif) + status loading/error saat mutasi data.
class LayananManagementState {
  final bool isLoading;
  final List<Layanan> items;
  final Failure? error;

  const LayananManagementState({this.isLoading = false, this.items = const [], this.error});

  LayananManagementState copyWith({bool? isLoading, List<Layanan>? items, Failure? error, bool clearError = false}) {
    return LayananManagementState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class LayananManagementNotifier extends StateNotifier<LayananManagementState> {
  final Ref ref;
  LayananManagementNotifier(this.ref) : super(const LayananManagementState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final usecase = ref.read(getLayananListUseCaseProvider);
    final result = await usecase();
    result.when(
      success: (data) => state = state.copyWith(isLoading: false, items: data),
      failure: (f) => state = state.copyWith(isLoading: false, error: f),
    );
  }

  Future<bool> save(Layanan layanan) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final usecase = ref.read(saveLayananUseCaseProvider);
    final result = await usecase(layanan);
    final success = result.isSuccess;
    if (success) {
      await load();
    } else {
      state = state.copyWith(isLoading: false, error: result.failureOrNull);
    }
    return success;
  }

  Future<bool> delete(int id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final usecase = ref.read(deleteLayananUseCaseProvider);
    final result = await usecase(id);
    final success = result.isSuccess;
    if (success) {
      await load();
    } else {
      state = state.copyWith(isLoading: false, error: result.failureOrNull);
    }
    return success;
  }
}

final layananManagementProvider =
    StateNotifierProvider.autoDispose<LayananManagementNotifier, LayananManagementState>(
  (ref) => LayananManagementNotifier(ref),
);
