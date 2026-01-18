import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/database/bridges_repository.dart';
import '../../core/utils/utm_converter.dart';

class BridgeMapPage extends StatefulWidget {
  final String bridgeId;

  const BridgeMapPage({
    super.key,
    required this.bridgeId,
  });

  @override
  State<BridgeMapPage> createState() => _BridgeMapPageState();
}

class _BridgeMapPageState extends State<BridgeMapPage> {
  final _repo = BridgesRepository();
	
	MapType _mapType = MapType.normal;

	final List<MapType> _mapTypes = [
		MapType.normal,
		MapType.satellite,
		MapType.hybrid,
	];

	final List<IconData> _mapTypeIcons = [
		Icons.map_outlined,
		Icons.satellite_alt_outlined,
		Icons.layers_outlined,
	];

	int _mapTypeIndex = 0;

  GoogleMapController? _controller;
  Marker? _marker;
  LatLng? _center;

  bool _loading = true;
	
	String? _bridgeNo;
	String? _bridgeName;

	String? _districtNo;
	String? _districtName;
	String? _sectionNo;
	String? _sectionName;
	String? _segmentNo;
	String? _segmentName;

	String? _xStr;
	String? _yStr;
	String? _latStr;
	String? _lngStr;
	
	String? _distance;

  @override
  void initState() {
    super.initState();
    _loadBridgeLocation();
  }

  Future<void> _loadBridgeLocation() async {
    final data = await _repo.getBridgeCoordinates(widget.bridgeId);

    if (data == null) {
      setState(() => _loading = false);
      return;
    }
		
		final bridge = await _repo.getBridgeDetail(widget.bridgeId);
		
		_bridgeNo = bridge!['BridgeNo'];
		_bridgeName = bridge['BridgeName'];

		_districtNo = bridge['DistrictNo']?.toString();
		_districtName = bridge['DistrictName'];

		_sectionNo = bridge['SectionNo']?.toString();
		_sectionName = bridge['SectionName'];

		_segmentNo = bridge['SegmentNo']?.toString();
		_segmentName = bridge['SegmentName'];
		
		final km = bridge['KMFromAddis'];

		_distance = km == null
				? null
				: (km as num).toStringAsFixed(2);

    final x = (data['XCoord'] as num).toDouble();
    final y = (data['YCoord'] as num).toDouble();
    final zone = int.parse(data['UtmZone'].toString());

    final latLng = UtmConverter.toLatLng(
      easting: x,
      northing: y,
      zone: zone,
    );

    final googleLatLng = LatLng(
      latLng.latitude,
      latLng.longitude,
    );
		
		final lat = latLng.latitude;
    final lng = latLng.longitude;
		
		_xStr = (data['XCoord'] as num).toDouble().toStringAsFixed(3);
    _yStr = (data['YCoord'] as num).toDouble().toStringAsFixed(3);
		_latStr = latLng.latitude.toStringAsFixed(6);
    _lngStr = latLng.longitude.toStringAsFixed(6);
		
    setState(() {
      _center = googleLatLng;
      _marker = Marker(
				markerId: MarkerId(widget.bridgeId),
				position: LatLng(lat, lng),
				icon: BitmapDescriptor.defaultMarkerWithHue(
					BitmapDescriptor.hueOrange,
				),
				infoWindow: InfoWindow(
					title: '${_bridgeNo} - ${_bridgeName}',
					snippet:
							'X: $_xStr, Y: $_yStr',
				),
			);
      _loading = false;
    });

    // Move camera if map already created
    if (_controller != null) {
      _controller!.animateCamera(
        CameraUpdate.newLatLngZoom(googleLatLng, 15),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bridge Map'),
				actions: [
					TextButton(
						onPressed: () {
							setState(() {
								_mapTypeIndex = (_mapTypeIndex + 1) % _mapTypes.length;
								_mapType = _mapTypes[_mapTypeIndex];
							});
						},
						child: IconButton(
							tooltip: 'Change map view',
							icon: Icon(
								_mapTypeIcons[_mapTypeIndex],
								size: 32,
								color: Colors.white,
							),
							onPressed: () {
								setState(() {
									_mapTypeIndex = (_mapTypeIndex + 1) % _mapTypes.length;
									_mapType = _mapTypes[_mapTypeIndex];
								});
							},
						),
					),
				],
			),
      body: _loading
					? const Center(child: CircularProgressIndicator())
					: _center == null
							? const Center(child: Text('Location not available'))
							: Column(
									children: [
										// ===== COMPACT HEADER =====
										Container(
											width: double.infinity,
											padding: const EdgeInsets.symmetric(
												horizontal: 12,
												vertical: 8,
											),
											color: Colors.grey.shade100,
											child: DefaultTextStyle(
												style: const TextStyle(
													fontSize: 12,
													color: Colors.black87,
												),
												child: Column(
													children: [
														_row(
															'Bridge',
															'${_bridgeNo} - ${_bridgeName}',
															'X',
															_xStr ?? '-',
														),
														_row(
															'District',
															'${_districtNo} - ${_districtName}',
															'Y',
															_yStr ?? '-',
														),
														_row(
															'Section',
															'${_sectionNo} - ${_sectionName}',
															'Lat',
															_latStr ?? '-',
														),
														_row(
															'Segment',
															'${_segmentNo} - ${_segmentName}',
															'Lng',
															_lngStr ?? '-',
														),
														_row(
															'',
															'',
															'Distance',
															_distance ?? '-',
														),
													],
												),
											),
										),

										// ===== MAP =====
										Expanded(
											child: GoogleMap(
												initialCameraPosition: CameraPosition(
													target: _center!,
													zoom: 15,
												),
												markers: _marker != null ? {_marker!} : {},
												onMapCreated: (controller) {
													_controller = controller;
													controller.animateCamera(
														CameraUpdate.newLatLngZoom(_center!, 15),
													);
												},
												mapType: _mapType,
												zoomControlsEnabled: true,
											),
										),
									],
								),
    );
  }
	
	Widget _row(
		String leftLabel,
		String leftValue,
		String rightLabel,
		String rightValue,
	) {
		const baseStyle = TextStyle(
			fontSize: 12,           // 👈 compact for map header
			color: Colors.black87,  // 👈 force normal color
			decoration: TextDecoration.none,
		);

		const valueStyle = TextStyle(
			fontWeight: FontWeight.w600,
		);

		return Padding(
			padding: const EdgeInsets.only(bottom: 4),
			child: Row(
				children: [
					Expanded(
						child: RichText(
							overflow: TextOverflow.ellipsis,
							text: TextSpan(
								style: baseStyle,
								children: leftLabel.isEmpty
										? []
										: [
												TextSpan(text: '$leftLabel: '),
												TextSpan(
													text: leftValue,
													style: valueStyle,
												),
											],
							),
						),
					),
					const SizedBox(width: 8),
					RichText(
						text: TextSpan(
							style: baseStyle,
							children: [
								TextSpan(text: '$rightLabel: '),
								TextSpan(
									text: rightValue,
									style: valueStyle,
								),
							],
						),
					),
				],
			),
		);
	}
}