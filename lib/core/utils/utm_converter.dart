import 'package:proj4dart/proj4dart.dart';

class LatLngPoint {
  final double latitude;
  final double longitude;

  const LatLngPoint(this.latitude, this.longitude);
}

class UtmConverter {
  static LatLngPoint toLatLng({
    required double easting,
    required double northing,
    required int zone,
  }) {
    final utm = Projection.parse(
      '+proj=utm +zone=$zone +north +datum=WGS84 +units=m +no_defs',
    );

    final wgs84 = Projection.WGS84;
    final point = Point(x: easting, y: northing);

    final result = utm.transform(wgs84, point);
    return LatLngPoint(result.y, result.x);
  }
}