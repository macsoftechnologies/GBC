import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _isLoggedInKey = "is_logged_in";
  static const String _legacyKey = "isLoggedIn";

  /// Call this right after successful OTP verification.
  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, value);
    await prefs.setBool(_legacyKey, value);
  }

  /// Returns true only if the key exists AND is true.
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getBool(_isLoggedInKey) ?? prefs.getBool(_legacyKey)) ?? false;
  }

  /// Call this to get current logged in user_id.
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  /// Call this on logout to fully clear the session.
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_legacyKey);
    await prefs.remove('user_id');
  }
}