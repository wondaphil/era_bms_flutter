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

  GoogleMapController? _controller;
  Timer? _pollingTimer;

  Set<Marker> _markers = {};
	GoogleMapController? _mapController;
  String? _myDeviceId;

  bool _loading = true;

  static const LatLng _defaultCenter = LatLng(9.03, 38.74);

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _myDeviceId = await DeviceIdentity.getDeviceId();

    await _trackingService.start();

    await _loadActiveUsers();

    _pollingTimer =
        Timer.periodic(const Duration(seconds: 5), (_) {
      _loadActiveUsers();
    });
  }

  @override
  void dispose() {
    _trackingService.stop();
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadActiveUsers() async {
		try {
			final baseUrl = await ApiConfig.getBaseUrl();
			final url = Uri.parse('${baseUrl}/api/BmsAPI/GetActiveUsers');

			final response = await http.get(url);

			if (response.statusCode != 200) {
				print("API error: ${response.statusCode}");
				return;
			}

			final List<dynamic> data = jsonDecode(response.body);

			if (data.isEmpty) {
				print("No active users returned.");
				setState(() {
					_markers.clear();
					_loading = false;
				});
				return;
			}

			final Set<Marker> newMarkers = {};
			LatLng? firstPosition;

			for (final user in data) {
				final double lat = (user['Latitude'] as num).toDouble();
				final double lng = (user['Longitude'] as num).toDouble();

				final deviceId = user['DeviceId'];
				final isMe = deviceId == _myDeviceId;

				final position = LatLng(lat, lng);

				firstPosition ??= position; // Save first marker for camera

				newMarkers.add(
					Marker(
						markerId: MarkerId(deviceId),
						position: position,
						icon: BitmapDescriptor.defaultMarkerWithHue(
							isMe
									? BitmapDescriptor.hueBlue
									: BitmapDescriptor.hueOrange,
						),
						infoWindow: InfoWindow(
							title: user['UserName'] ?? deviceId,
						),
					),
				);
			}

			setState(() {
				_markers
					..clear()
					..addAll(newMarkers);

				_loading = false;
			});

			// 🔥 Move camera only once (when first loaded)
			if (_mapController != null && firstPosition != null) {
				_mapController!.animateCamera(
					CameraUpdate.newLatLngZoom(firstPosition, 15),
				);
			}

		} catch (e) {
			print("ERROR: $e");

			setState(() {
				_loading = false;
			});
		}
	}

  LatLngBounds _calculateBounds(List<LatLng> positions) {
    double minLat = positions.first.latitude;
    double maxLat = positions.first.latitude;
    double minLng = positions.first.longitude;
    double maxLng = positions.first.longitude;

    for (final p in positions) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Active Users')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              myLocationEnabled: true,
              initialCameraPosition: const CameraPosition(
                target: _defaultCenter,
                zoom: 6,
              ),
              markers: _markers,
              onMapCreated: (controller) {
                _controller = controller;
              },
            ),
    );
  }
}