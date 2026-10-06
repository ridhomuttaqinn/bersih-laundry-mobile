import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/app_user.dart';
import 'core_providers.dart';

class UserManagementState {
  final bool isLoading;
  final List<AppUser> items;
  final Failure? error;

  const UserManagementState({this.isLoading = false, this.items = const [], this.error});

  UserManagementState copyWith({bool? isLoading, List<AppUser>? items, Failure? error}) {
    return UserManagementState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      error: error,
    );
  }
}

class UserManagementNotifier extends StateNotifier<UserManagementState> {
  final Ref ref;
  UserManagementNotifier(this.ref) : super(const UserManagementState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    final usecase = ref.read(getAllUsersUseCaseProvider);
    final result = await usecase();
    result.when(
      success: (data) => state = state.copyWith(isLoading: false, items: data),
      failure: (f) => state = state.copyWith(isLoading: false, error: f),
    );
  }

  Future<bool> createUser({
    required String nama,
    required String username,
    required String password,
    required String role,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final usecase = ref.read(createUserUseCaseProvider);
    final result = await usecase(nama: nama, username: username, password: password, role: role);
    if (result.isSuccess) {
      await load();
    } else {
      state = state.copyWith(isLoading: false, error: result.failureOrNull);
    }
    return result.isSuccess;
  }

  Future<bool> toggleActive(int id, bool isActive) async {
    final usecase = ref.read(toggleUserActiveUseCaseProvider);
    final result = await usecase(id, isActive);
    if (result.isSuccess) await load();
    return result.isSuccess;
  }

  Future<bool> delete(int id) async {
    final usecase = ref.read(deleteUserUseCaseProvider);
    final result = await usecase(id);
    if (result.isSuccess) await load();
    return result.isSuccess;
  }
}

final userManagementProvider = StateNotifierProvider.autoDispose<UserManagementNotifier, UserManagementState>(
  (ref) => UserManagementNotifier(ref),
);
