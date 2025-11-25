// lib/session_manager.dart

import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String keyLoggedIn = "logged_in";
  static const String keyEmail = "user_email";
  static const String keyUserId = "user_id";

  /// Save login session (email and numeric user id).
  /// Call: await SessionManager.saveLogin(email: email, userId: user.id);
  static Future<void> saveLogin({required String email, required int userId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyLoggedIn, true);
    await prefs.setString(keyEmail, email.trim().toLowerCase());
    await prefs.setInt(keyUserId, userId);
  }

  /// Clear session (logout)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyLoggedIn);
    await prefs.remove(keyEmail);
    await prefs.remove(keyUserId);
  }

  /// Whether a user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyLoggedIn) ?? false;
  }

  /// Return saved email or null
  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyEmail);
  }

  /// Return saved user id or null
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyUserId);
  }
}
