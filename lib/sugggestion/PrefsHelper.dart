import 'package:shared_preferences/shared_preferences.dart';

class PrefsHelper {
  static const _tokenKey = "auth_token";
  static const _adminIdKey = "admin_id";

  /// Save token and adminId to shared preferences
  static Future<void> saveAuthData(String token, int adminId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setInt(_adminIdKey, adminId);
      print(
        "[PrefsHelper] Saved auth data -> Token: $token, AdminID: $adminId",
      );
    } catch (e) {
      print("[PrefsHelper] Error saving auth data: $e");
    }
  }

  /// Get token from shared preferences
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      print("[PrefsHelper] Retrieved token: $token");
      return token;
    } catch (e) {
      print("[PrefsHelper] Error getting token: $e");
      return null;
    }
  }

  /// Get adminId from shared preferences
  static Future<int?> getAdminId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adminId = prefs.getInt(_adminIdKey);
      print("[PrefsHelper] Retrieved AdminID: $adminId");
      return adminId;
    } catch (e) {
      print("[PrefsHelper] Error getting adminId: $e");
      return null;
    }
  }

  /// Clear token and adminId from shared preferences
  static Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_adminIdKey);
      print("[PrefsHelper] Cleared auth data");
    } catch (e) {
      print("[PrefsHelper] Error clearing auth data: $e");
    }
  }
}
