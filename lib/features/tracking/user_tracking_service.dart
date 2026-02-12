import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../../core/api/api_config.dart';
import 'device_identity.dart';

class UserTrackingService {
  static final UserTrackingService _instance =
      UserTrackingService._internal();

  factory UserTrackingService() => _instance;

  UserTrackingService._internal();

  Timer? _timer;
  bool _running = false;

  Future<void> start() async {
    if (_running) return;

    _running = true;

    // Ask permission if needed
    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _running = false;
      return;
    }

    // Send immediately
    await _sendLocation();

    // Then every 10 seconds (battery safe)
    _timer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _sendLocation(),
    );
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _running = false;
  }

  Future<void> _sendLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low, // 🔋 battery safe
      );

      final deviceId = await DeviceIdentity.getDeviceId();
      final userName = await DeviceIdentity.getDeviceName();
      final baseUrl = await ApiConfig.getBaseUrl();

      final url =
          Uri.parse('${baseUrl}/api/BmsAPI/UpdateLocation');

      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: '''
        {
          "DeviceId": "$deviceId",
          "UserName": "$userName",
          "Latitude": ${position.latitude},
          "Longitude": ${position.longitude}
        }
        ''',
      );
    } catch (_) {
      // silently ignore to prevent crashes
    }
  }
}