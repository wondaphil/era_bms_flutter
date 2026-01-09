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
      ['%$keyword%', '%$keyword%'],
    );
  }
	
	Future<Map<String, dynamic>?> getBridgeDetail(String bridgeId) async {
		final db = await _dbHelper.database;

		final result = await db.rawQuery(
			'''
			SELECT 
				b.BridgeId,
				b.BridgeNo,
				b.BridgeName,

				d.DistrictName,
				s.SectionName,
				sg.SegmentName,

				mr.MainRouteName,
				sr.SubRouteName

			FROM Bridge b
			LEFT JOIN Segment sg ON b.SegmentId = sg.SegmentId
			LEFT JOIN Section s ON sg.SectionId = s.SectionId
			LEFT JOIN District d ON s.DistrictId = d.DistrictId

			LEFT JOIN SubRoute sr ON b.SubRouteId = sr.SubRouteId
			LEFT JOIN MainRoute mr ON sr.MainRouteId = mr.MainRouteId

			WHERE b.BridgeId = ?
			''',
			[bridgeId],
		);

		if (result.isEmpty) return null;
		return result.first;
	}
}