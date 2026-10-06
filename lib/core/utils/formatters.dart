import 'package:intl/intl.dart';

/// Formatter mata uang & tanggal agar konsisten di seluruh aplikasi (locale Indonesia).
class AppFormatters {
  AppFormatters._();

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final DateFormat _dateFormat = DateFormat('d MMM yyyy', 'id_ID');
  static final DateFormat _dateTimeFormat = DateFormat('d MMM yyyy, HH:mm', 'id_ID');
  static final DateFormat _timeFormat = DateFormat('HH:mm', 'id_ID');
  static final DateFormat _dbFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  static String currency(num value) => _currencyFormat.format(value);

  static String date(DateTime value) => _dateFormat.format(value);

  static String dateTime(DateTime value) => _dateTimeFormat.format(value);

  static String time(DateTime value) => _timeFormat.format(value);

  /// Format untuk disimpan ke kolom TEXT (ISO-like) pada SQLite.
  static String toDbString(DateTime value) => _dbFormat.format(value);

  static DateTime fromDbString(String value) => _dbFormat.parse(value);

  static String relativeFromNow(DateTime value) {
    final diff = DateTime.now().difference(value);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return date(value);
  }
}
