import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _accessKeyKey = 'manager_access_key';
  static const String _roleKey = 'manager_role';
  
  static Future<void> saveSession(String accessKey, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessKeyKey, accessKey);
    await prefs.setString(_roleKey, role);
  }
  
  static Future<Map<String, String>?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final accessKey = prefs.getString(_accessKeyKey);
    final role = prefs.getString(_roleKey);
    
    if (accessKey != null && role != null) {
      return {'accessKey': accessKey, 'role': role};
    }
    return null;
  }
  
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessKeyKey);
    await prefs.remove(_roleKey);
  }
}