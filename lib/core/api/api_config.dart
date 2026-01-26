import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const _key = 'API_BASE_URL';

  static Future<void> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, url);
  }

  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key) ?? '';
  }
}