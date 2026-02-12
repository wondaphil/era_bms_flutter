import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceIdentity {
  static const _deviceIdKey = 'device_uuid';

  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();

    String? id = prefs.getString(_deviceIdKey);

    if (id == null) {
      id = const Uuid().v4();
      await prefs.setString(_deviceIdKey, id);
    }

    return id;
  }

  static Future<String> getDeviceName() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.model ?? 'Android Device';
    }

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.name ?? 'iOS Device';
    }

    return 'Unknown Device';
  }
}