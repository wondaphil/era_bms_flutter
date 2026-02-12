import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../../core/api/api_config.dart';
import 'device_identity.dart';

class UserTrackingService {
  Timer? _timer;

  Future<void> start() async {
    final permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission denied');
    }

    _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await _sendLocation();
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _sendLocation() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );

    final deviceId = await DeviceIdentity.getDeviceId();
    final userName = await DeviceIdentity.getUserName();

    final baseUrl = await ApiConfig.getBaseUrl();

    final url = Uri.parse('${baseUrl}/api/BmsAPI/UpdateLocation');

    await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'deviceId': deviceId,
        'userName': userName,
        'latitude': position.latitude,
        'longitude': position.longitude,
      }),
    );
  }
}