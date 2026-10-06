import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Wrapper atas flutter_local_notifications untuk menampilkan notifikasi
/// setiap kali status pesanan pelanggan diperbarui (FR-5 pada proposal).
class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _plugin.initialize(settings);

    // Izin notifikasi Android 13+ ditangani otomatis oleh plugin saat initialize
    // pada versi terbaru; permintaan eksplisit tetap dilakukan untuk keamanan.
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  Future<void> showOrderStatusNotification({
    required int orderId,
    required String title,
    required String body,
  }) async {
    if (!_initialized) await init();

    const androidDetails = AndroidNotificationDetails(
      'order_status_channel',
      'Status Pesanan',
      channelDescription: 'Notifikasi perubahan status pesanan laundry',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(orderId, title, body, details);
  }
}
