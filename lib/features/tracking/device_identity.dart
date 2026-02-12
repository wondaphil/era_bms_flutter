import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class DeviceIdentity {
  static const _deviceIdKey = 'device_id';

  /// Get persistent UUID
  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();

    String? id = prefs.getString(_deviceIdKey);

    if (id == null) {
      id = const Uuid().v4();
      await prefs.setString(_deviceIdKey, id);
    }

    return id;
  }

  /// Get device model name
  static Future<String> getUserName() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      return android.model ?? 'Android Device';
    }

    if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      return ios.name ?? 'iOS Device';
    }

    return 'Unknown Device';
  }
}