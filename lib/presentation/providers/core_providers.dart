import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/session_service.dart';

// --- DATASOURCES ---
import '../../data/datasources/laporan_remote_datasource.dart';
import '../../data/datasources/pelanggan_remote_datasource.dart';
import '../../data/datasources/pembayaran_remote_datasource.dart';
import '../../data/datasources/pesanan_remote_datasource.dart';
import '../../data/datasources/user_remote_datasource.dart';
import '../../data/datasources/notifikasi_remote_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/layanan_remote_datasource.dart';

// --- REPOSITORIES IMPL ---
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/laporan_repository_impl.dart';
import '../../data/repositories/layanan_repository_impl.dart';
import '../../data/repositories/notifikasi_repository_impl.dart';
import '../../data/repositories/pelanggan_repository_impl.dart';
import '../../data/repositories/pembayaran_repository_impl.dart';
import '../../data/repositories/pesanan_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';

// --- DOMAIN REPOSITORIES ---
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/laporan_repository.dart';
import '../../domain/repositories/layanan_repository.dart';
import '../../domain/repositories/notifikasi_repository.dart';
import '../../domain/repositories/pelanggan_repository.dart';
import '../../domain/repositories/pembayaran_repository.dart';
import '../../domain/repositories/pesanan_repository.dart';
import '../../domain/repositories/user_repository.dart';

// --- USECASES ---
import '../../domain/usecases/auth_usecases.dart';
import '../../domain/usecases/laporan_usecases.dart';
import '../../domain/usecases/layanan_usecases.dart';
import '../../domain/usecases/notifikasi_usecases.dart';
import '../../domain/usecases/pelanggan_usecases.dart';
import '../../domain/usecases/pembayaran_usecases.dart';
import '../../domain/usecases/pesanan_usecases.dart';
import '../../domain/usecases/user_usecases.dart';

// ---------------- Services ----------------

final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService.instance);

final sessionServiceProvider =
    Provider<SessionService>((ref) => SessionService.instance);

// ---------------- Datasources ----------------

final authDatasourceProvider = Provider((ref) => AuthRemoteDatasource());

final layananDatasourceProvider = Provider((ref) => LayananRemoteDatasource());

final pesananDatasourceProvider = Provider((ref) => PesananRemoteDatasource());

final pembayaranDatasourceProvider =
    Provider((ref) => PembayaranRemoteDatasource());

final pelangganDatasourceProvider =
    Provider((ref) => PelangganRemoteDatasource());

final userDatasourceProvider = Provider((ref) => UserRemoteDatasource());

final laporanDatasourceProvider = Provider((ref) => LaporanRemoteDatasource());

final notifikasiDatasourceProvider =
    Provider((ref) => NotifikasiRemoteDatasource());

// ---------------- Repositories ----------------

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    ref.watch(authDatasourceProvider),
  ),
);

// PENTING:
// Sekarang layanan menggunakan Laravel REST API,
// bukan SQLite lokal.
final layananRepositoryProvider = Provider<LayananRepository>(
  (ref) => LayananRepositoryImpl(
    ref.watch(layananDatasourceProvider),
  ),
);

final pesananRepositoryProvider = Provider<PesananRepository>(
  (ref) => PesananRepositoryImpl(
    ref.watch(pesananDatasourceProvider),
    ref.watch(notificationServiceProvider),
  ),
);

final pembayaranRepositoryProvider = Provider<PembayaranRepository>(
  (ref) => PembayaranRepositoryImpl(
    ref.watch(pembayaranDatasourceProvider),
  ),
);

final pelangganRepositoryProvider = Provider<PelangganRepository>(
  (ref) => PelangganRepositoryImpl(
    ref.watch(pelangganDatasourceProvider),
  ),
);

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepositoryImpl(
    ref.watch(userDatasourceProvider),
  ),
);

final laporanRepositoryProvider = Provider<LaporanRepository>(
  (ref) => LaporanRepositoryImpl(
    ref.watch(laporanDatasourceProvider),
  ),
);

final notifikasiRepositoryProvider = Provider<NotifikasiRepository>(
  (ref) => NotifikasiRepositoryImpl(
    ref.watch(notifikasiDatasourceProvider),
  ),
);

// ---------------- Usecases ----------------

final loginUseCaseProvider = Provider((ref) => LoginUseCase(
      ref.watch(authRepositoryProvider),
    ));

final registerPelangganUseCaseProvider =
    Provider((ref) => RegisterPelangganUseCase(
          ref.watch(authRepositoryProvider),
        ));

final getLayananListUseCaseProvider = Provider((ref) => GetLayananListUseCase(
      ref.watch(layananRepositoryProvider),
    ));

final saveLayananUseCaseProvider = Provider((ref) => SaveLayananUseCase(
      ref.watch(layananRepositoryProvider),
    ));

final deleteLayananUseCaseProvider = Provider((ref) => DeleteLayananUseCase(
      ref.watch(layananRepositoryProvider),
    ));

final createOrderUseCaseProvider = Provider((ref) => CreateOrderUseCase(
      ref.watch(pesananRepositoryProvider),
    ));

final getOrderHistoryUseCaseProvider = Provider((ref) => GetOrderHistoryUseCase(
      ref.watch(pesananRepositoryProvider),
    ));

final getIncomingOrdersUseCaseProvider =
    Provider((ref) => GetIncomingOrdersUseCase(
          ref.watch(pesananRepositoryProvider),
        ));

final getOrderDetailUseCaseProvider = Provider((ref) => GetOrderDetailUseCase(
      ref.watch(pesananRepositoryProvider),
    ));

final processOrderUseCaseProvider = Provider((ref) => ProcessOrderUseCase(
      ref.watch(pesananRepositoryProvider),
    ));

final rejectOrderUseCaseProvider = Provider((ref) => RejectOrderUseCase(
      ref.watch(pesananRepositoryProvider),
    ));

final updateOrderStatusUseCaseProvider =
    Provider((ref) => UpdateOrderStatusUseCase(
          ref.watch(pesananRepositoryProvider),
        ));

final confirmActualWeightUseCaseProvider =
    Provider((ref) => ConfirmActualWeightUseCase(
          ref.watch(pesananRepositoryProvider),
        ));

final recordPaymentUseCaseProvider = Provider((ref) => RecordPaymentUseCase(
      ref.watch(pembayaranRepositoryProvider),
    ));

final getPaymentByOrderUseCaseProvider =
    Provider((ref) => GetPaymentByOrderUseCase(
          ref.watch(pembayaranRepositoryProvider),
        ));

final getAllPelangganUseCaseProvider = Provider((ref) => GetAllPelangganUseCase(
      ref.watch(pelangganRepositoryProvider),
    ));

final deletePelangganUseCaseProvider = Provider((ref) => DeletePelangganUseCase(
      ref.watch(pelangganRepositoryProvider),
    ));

final updatePelangganUseCaseProvider = Provider((ref) => UpdatePelangganUseCase(
      ref.watch(pelangganRepositoryProvider),
    ));

final getAllUsersUseCaseProvider = Provider((ref) => GetAllUsersUseCase(
      ref.watch(userRepositoryProvider),
    ));

final createUserUseCaseProvider = Provider((ref) => CreateUserUseCase(
      ref.watch(userRepositoryProvider),
    ));

final toggleUserActiveUseCaseProvider =
    Provider((ref) => ToggleUserActiveUseCase(
          ref.watch(userRepositoryProvider),
        ));

final deleteUserUseCaseProvider = Provider((ref) => DeleteUserUseCase(
      ref.watch(userRepositoryProvider),
    ));

final getRingkasanPendapatanUseCaseProvider =
    Provider((ref) => GetRingkasanPendapatanUseCase(
          ref.watch(laporanRepositoryProvider),
        ));

final getDashboardSummaryUseCaseProvider =
    Provider((ref) => GetDashboardSummaryUseCase(
          ref.watch(laporanRepositoryProvider),
        ));

final getNotifikasiUseCaseProvider = Provider((ref) => GetNotifikasiUseCase(
      ref.watch(notifikasiRepositoryProvider),
    ));

final markNotifikasiReadUseCaseProvider =
    Provider((ref) => MarkNotifikasiReadUseCase(
          ref.watch(notifikasiRepositoryProvider),
        ));

final countUnreadNotifikasiUseCaseProvider =
    Provider((ref) => CountUnreadNotifikasiUseCase(
          ref.watch(notifikasiRepositoryProvider),
        ));
