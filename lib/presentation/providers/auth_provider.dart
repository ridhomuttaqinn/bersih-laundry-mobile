import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/failures.dart';
import '../../core/services/session_service.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/pelanggan.dart';
import '../../domain/repositories/auth_repository.dart';
import 'core_providers.dart';

/// Representasi pengguna yang sedang login, terlepas dari role-nya.
class AuthSession {
  final int id;
  final String nama;
  final String role;
  final Pelanggan? pelanggan;
  final AppUser? appUser;

  const AuthSession({
    required this.id,
    required this.nama,
    required this.role,
    this.pelanggan,
    this.appUser,
  });
}

/// State autentikasi aplikasi: null berarti belum ada sesi (perlu login).
class AuthState {
  final bool isLoading;
  final AuthSession? session;
  final Failure? error;
  final bool checkingSession;

  const AuthState({
    this.isLoading = false,
    this.session,
    this.error,
    this.checkingSession = true,
  });

  bool get isLoggedIn => session != null;

  AuthState copyWith({
    bool? isLoading,
    AuthSession? session,
    Failure? error,
    bool? checkingSession,
    bool clearError = false,
    bool clearSession = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      session: clearSession ? null : (session ?? this.session),
      error: clearError ? null : (error ?? this.error),
      checkingSession: checkingSession ?? this.checkingSession,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  AuthNotifier(this.ref) : super(const AuthState()) {
    _restoreSession();
  }

  AuthRepository get _authRepository => ref.read(authRepositoryProvider);
  SessionService get _sessionService => ref.read(sessionServiceProvider);

  Future<void> _restoreSession() async {
    final saved = await _sessionService.getSession();
    if (saved == null) {
      state = state.copyWith(checkingSession: false);
      return;
    }

    final id = saved['id'] as int;
    final role = saved['role'] as String;

    if (role == 'pelanggan') {
      final result = await _authRepository.getPelangganById(id);
      result.when(
        success: (p) => state = state.copyWith(
          checkingSession: false,
          session: AuthSession(id: p.id!, nama: p.nama, role: 'pelanggan', pelanggan: p),
        ),
        failure: (_) => state = state.copyWith(checkingSession: false),
      );
    } else {
      final result = await _authRepository.getUserById(id);
      result.when(
        success: (u) => state = state.copyWith(
          checkingSession: false,
          session: AuthSession(id: u.id!, nama: u.nama, role: u.role, appUser: u),
        ),
        failure: (_) => state = state.copyWith(checkingSession: false),
      );
    }
  }

  Future<bool> login(String identifier, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final loginUseCase = ref.read(loginUseCaseProvider);
    final result = await loginUseCase(identifier: identifier, password: password);

    return result.when(
      success: (loginResult) {
        final session = AuthSession(
          id: loginResult.id,
          nama: loginResult.nama,
          role: loginResult.role,
          pelanggan: loginResult.pelanggan,
          appUser: loginResult.appUser,
        );
        state = state.copyWith(isLoading: false, session: session, clearError: true);
        _sessionService.saveSession(userId: session.id, role: session.role, name: session.nama);
        return true;
      },
      failure: (f) {
        state = state.copyWith(isLoading: false, error: f);
        return false;
      },
    );
  }

  Future<bool> register({
    required String nama,
    required String alamat,
    required String noTelepon,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final registerUseCase = ref.read(registerPelangganUseCaseProvider);
    final result = await registerUseCase(
      nama: nama,
      alamat: alamat,
      noTelepon: noTelepon,
      email: email,
      password: password,
    );

    return result.when(
      success: (pelanggan) {
        final session = AuthSession(id: pelanggan.id!, nama: pelanggan.nama, role: 'pelanggan', pelanggan: pelanggan);
        state = state.copyWith(isLoading: false, session: session, clearError: true);
        _sessionService.saveSession(userId: session.id, role: session.role, name: session.nama);
        return true;
      },
      failure: (f) {
        state = state.copyWith(isLoading: false, error: f);
        return false;
      },
    );
  }

  Future<void> logout() async {
    await _sessionService.clearSession();
    state = state.copyWith(clearSession: true, clearError: true);
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier(ref));
