import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../../core/api/api_config.dart';
import 'device_identity.dart';
import 'user_tracking_service.dart';

class ActiveUsersMapPage extends StatefulWidget {
  const ActiveUsersMapPage({super.key});

  @override
  State<ActiveUsersMapPage> createState() => _ActiveUsersMapPageState();
}

class _ActiveUsersMapPageState extends State<ActiveUsersMapPage> {
  final UserTrackingService _trackingService = UserTrackingService();

  GoogleMapController? _mapController;
  Timer? _pollingTimer;

  Set<Marker> _markers = {};
  String? _myDeviceId;
  bool _firstCameraMove = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _myDeviceId = await DeviceIdentity.getDeviceId();

    await _trackingService.start();

    // initial load
    await _loadActiveUsers();

    // poll every 5 sec
    _pollingTimer =
        Timer.periodic(const Duration(seconds: 5), (_) async {
      await _loadActiveUsers();
    });
  }

  @override
  void dispose() {
    _trackingService.stop();
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadActiveUsers() async {
    final baseUrl = await ApiConfig.getBaseUrl();
    final url = Uri.parse('${baseUrl}api/BmsAPI/GetActiveUsers');

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) return;

      final List<dynamic> data = jsonDecode(response.body);

      final Set<Marker> updatedMarkers = {};

      for (final user in data) {
        final deviceId = user['DeviceId'];
        final userName = user['UserName'] ?? deviceId;
        final lat = (user['Latitude'] as num).toDouble();
        final lng = (user['Longitude'] as num).toDouble();
        final lastSeen = user['LastSeen'];

        final isMe = deviceId == _myDeviceId;

        updatedMarkers.add(
          Marker(
            markerId: MarkerId(deviceId),
            position: LatLng(lat, lng),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              isMe
                  ? BitmapDescriptor.hueBlue
                  : BitmapDescriptor.hueOrange,
            ),
            infoWindow: InfoWindow(
              title: userName,
              snippet: 'Last seen: $lastSeen',
            ),
          ),
        );

        // Move camera only first time
        if (_firstCameraMove && _mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(lat, lng),
              14,
            ),
          );
          _firstCameraMove = false;
        }
      }

      if (!mounted) return;

      setState(() {
        _markers = updatedMarkers;
      });
    } catch (_) {
      // silently ignore errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Active Users')),
      body: GoogleMap(
        myLocationEnabled: true,
        markers: _markers,
        initialCameraPosition: const CameraPosition(
          target: LatLng(9.0, 38.7),
          zoom: 6,
        ),
        onMapCreated: (controller) {
          _mapController = controller;
        },
      ),
    );
  }
}