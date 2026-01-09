import 'database_helper.dart';

class BridgesRepository {
  final _dbHelper = DatabaseHelper.instance;

  Future<List<Map<String, dynamic>>> getBridgesBySegment(String segmentId) async {
    final db = await _dbHelper.database;
    return db.rawQuery(
      'SELECT * FROM Bridge WHERE SegmentId = ? ORDER BY BridgeNo',
      [segmentId],
    );
  }

  Future<List<Map<String, dynamic>>> getBridgesBySubRoute(String subRouteId) async {
    final db = await _dbHelper.database;
    return db.rawQuery(
      'SELECT * FROM Bridge WHERE SubRouteId = ? ORDER BY BridgeNo',
      [subRouteId],
    );
  }

  Future<List<Map<String, dynamic>>> searchBridges(String keyword) async {
    final db = await _dbHelper.database;
    return db.rawQuery(
      'SELECT * FROM Bridge WHERE BridgeName LIKE ? OR BridgeNo LIKE ? ORDER BY BridgeName',
      ['%$keyword%'],
    );
  }
}