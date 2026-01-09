import 'database_helper.dart';

class CulvertsRepository {
  final _dbHelper = DatabaseHelper.instance;

  Future<List<Map<String, dynamic>>> getCulvertsBySegment(String segmentId) async {
    final db = await _dbHelper.database;
    return db.rawQuery(
      'SELECT * FROM Culvert WHERE SegmentId = ? ORDER BY CulvertNo',
      [segmentId],
    );
  }

  Future<List<Map<String, dynamic>>> getCulvertsBySubRoute(String subRouteId) async {
    final db = await _dbHelper.database;
    return db.rawQuery(
      'SELECT * FROM Culvert WHERE SubRouteId = ? ORDER BY CulvertNo',
      [subRouteId],
    );
  }

  Future<List<Map<String, dynamic>>> searchCulverts(String keyword) async {
    final db = await _dbHelper.database;
    return db.rawQuery(
      'SELECT * FROM Culvert WHERE CulvertNo LIKE ? ORDER BY CulvertName',
      ['%$keyword%'],
    );
  }
}