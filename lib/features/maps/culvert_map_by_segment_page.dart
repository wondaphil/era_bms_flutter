import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/database/culverts_repository.dart';
import '../../core/utils/utm_converter.dart';

class CulvertMapBySegmentPage extends StatefulWidget {
  final String segmentId;

  const CulvertMapBySegmentPage({
    super.key,
    required this.segmentId,
  });

  @override
  State<CulvertMapBySegmentPage> createState() => _CulvertMapBySegmentPageState();
}

class _CulvertMapBySegmentPageState extends State<CulvertMapBySegmentPage> {
  final _repo = CulvertsRepository();
	
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
  final Set<Marker> _markers = {};
  LatLngBounds? _bounds;

  bool _loading = true;
	
	String? _segmentNo;
	String? _segmentName;
	int _culvertCount = 0;

  @override
  void initState() {
    super.initState();
    _loadSegmentCulverts();
  }

  Future<void> _loadSegmentCulverts() async {
    final culverts = await _repo.getCulvertsInfoBySegment(widget.segmentId);

    if (culverts.isEmpty) {
      setState(() => _loading = false);
      return;
    }
		
		final first = culverts.first;
		_segmentNo = first['SegmentNo']?.toString();
		_segmentName = first['SegmentName']?.toString();
		_culvertCount = culverts.length;

    final List<LatLng> points = [];

    for (final b in culverts) {
			final culvertNo = b['CulvertNo'];
      
			final x = (b['XCoord'] as num).toDouble();
      final y = (b['YCoord'] as num).toDouble();
      final zone = int.parse(b['UtmZone'].toString());
			
			final xStr = x.toStringAsFixed(3);
      final yStr = y.toStringAsFixed(3);
			
      final latLng = UtmConverter.toLatLng(
        easting: x,
        northing: y,
        zone: zone,
      );

      final pos = LatLng(latLng.latitude, latLng.longitude);
      points.add(pos);

      _markers.add(
        Marker(
          markerId: MarkerId(b['CulvertId'].toString()),
          position: pos,
					icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
          infoWindow: InfoWindow(
            title: '$culvertNo',
						snippet: 'X: $xStr, Y: $yStr',
          ),
        ),
      );
    }

    _bounds = _calculateBounds(points);

    setState(() => _loading = false);

    if (_controller != null && _bounds != null) {
      _controller!.animateCamera(
        CameraUpdate.newLatLngBounds(_bounds!, 60),
      );
    }
  }

  LatLngBounds _calculateBounds(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      minLat = p.latitude < minLat ? p.latitude : minLat;
      maxLat = p.latitude > maxLat ? p.latitude : maxLat;
      minLng = p.longitude < minLng ? p.longitude : minLng;
      maxLng = p.longitude > maxLng ? p.longitude : maxLng;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
				title: const Text('Culvert Map by Segment'),
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
    : _markers.isEmpty
        ? const Center(child: Text('No culverts found'))
        : Column(
            children: [
              // ---------- SEGMENT INFO (COMPACT) ----------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: const Border(
                    bottom: BorderSide(color: Colors.black12),
                  ),
                ),
                child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Text.rich(
											TextSpan(
												children: [
													const TextSpan(text: 'Segment: '),
													TextSpan(
														text: '${_segmentNo ?? '-'} - ${_segmentName ?? '-'}',
														style: const TextStyle(fontWeight: FontWeight.w600),
													),
												],
											),
											overflow: TextOverflow.ellipsis,
										),
										const SizedBox(height: 2),
										Text.rich(
											TextSpan(
												children: [
													const TextSpan(text: 'No. of Culverts: '),
													TextSpan(
														text: _culvertCount.toString(),
														style: const TextStyle(fontWeight: FontWeight.w600),
													),
												],
											),											
										),
									],
								),
              ),

              // ---------- MAP ----------
              Expanded(
                child: GoogleMap(
                  onMapCreated: (controller) {
                    _controller = controller;
                    if (_bounds != null) {
                      controller.animateCamera(
                        CameraUpdate.newLatLngBounds(_bounds!, 60),
                      );
                    }
                  },
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(9.0, 38.7), // fallback (Ethiopia)
                    zoom: 6,
                  ),
                  markers: _markers,
                  mapType: _mapType,
                  zoomControlsEnabled: true,
                ),
              ),
            ],
          ),
    );
  }
}