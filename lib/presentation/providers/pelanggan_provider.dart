import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/pelanggan.dart';
import 'core_providers.dart';

class PelangganManagementState {
  final bool isLoading;
  final List<Pelanggan> items;
  final Failure? error;

  const PelangganManagementState({this.isLoading = false, this.items = const [], this.error});

  PelangganManagementState copyWith({bool? isLoading, List<Pelanggan>? items, Failure? error}) {
    return PelangganManagementState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      error: error,
    );
  }
}

class PelangganManagementNotifier extends StateNotifier<PelangganManagementState> {
  final Ref ref;
  PelangganManagementNotifier(this.ref) : super(const PelangganManagementState()) {
    load();
  }

  Future<void> load({String? search}) async {
    state = state.copyWith(isLoading: true, error: null);
    final usecase = ref.read(getAllPelangganUseCaseProvider);
    final result = await usecase(search: search);
    result.when(
      success: (data) => state = state.copyWith(isLoading: false, items: data),
      failure: (f) => state = state.copyWith(isLoading: false, error: f),
    );
  }

  Future<bool> delete(int id) async {
    final usecase = ref.read(deletePelangganUseCaseProvider);
    final result = await usecase(id);
    if (result.isSuccess) await load();
    return result.isSuccess;
  }
}

final pelangganManagementProvider =
    StateNotifierProvider.autoDispose<PelangganManagementNotifier, PelangganManagementState>(
  (ref) => PelangganManagementNotifier(ref),
);
