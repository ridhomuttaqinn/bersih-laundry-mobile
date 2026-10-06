import 'package:shared_preferences/shared_preferences.dart';

/// Menyimpan sesi login (id, role) secara lokal agar pengguna tidak perlu
/// login ulang setiap membuka aplikasi.
class SessionService {
  SessionService._internal();
  static final SessionService instance = SessionService._internal();

  static const String _keyUserId = 'session_user_id';
  static const String _keyRole = 'session_role';
  static const String _keyName = 'session_name';

  Future<void> saveSession({required int userId, required String role, required String name}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, userId);
    await prefs.setString(_keyRole, role);
    await prefs.setString(_keyName, name);
  }

  Future<Map<String, Object>?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_keyUserId);
    final role = prefs.getString(_keyRole);
    final name = prefs.getString(_keyName);
    if (id == null || role == null || name == null) return null;
    return {'id': id, 'role': role, 'name': name};
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyRole);
    await prefs.remove(_keyName);
  }
}
