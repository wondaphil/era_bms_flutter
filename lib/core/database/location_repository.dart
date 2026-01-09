import 'database_helper.dart';

class LocationRepository {
  final _dbHelper = DatabaseHelper.instance;

  Future<List<Map<String, dynamic>>> getDistricts() async {
    final db = await _dbHelper.database;
    return db.rawQuery(
      'SELECT DistrictId, DistrictNo, DistrictName FROM District ORDER BY DistrictNo',
    );
  }

  Future<List<Map<String, dynamic>>> getSections(String districtId) async {
    final db = await _dbHelper.database;
    return db.rawQuery(
      'SELECT SectionId, SectionNo, SectionName FROM Section WHERE DistrictId = ? ORDER BY SectionNo',
      [districtId],
    );
  }

  Future<List<Map<String, dynamic>>> getSegments(String sectionId) async {
    final db = await _dbHelper.database;
    return db.rawQuery(
      'SELECT SegmentId, SegmentNo, SegmentName FROM Segment WHERE SectionId = ? ORDER BY SegmentNo',
      [sectionId],
    );
  }
}