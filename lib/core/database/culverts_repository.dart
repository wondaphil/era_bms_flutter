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
      'SELECT * FROM Culvert WHERE CulvertNo LIKE ? ORDER BY CulvertNo',
      ['%$keyword%'],
    );
  }
	
	Future<Map<String, dynamic>?> getCulvertDetail(String culvertId) async {
		final db = await _dbHelper.database;

		final result = await db.rawQuery(
			'''
			SELECT 
				b.CulvertId,
				b.CulvertNo,
				
				d.DistrictName,
				s.SectionName,
				sg.SegmentName,

				mr.MainRouteName,
				sr.SubRouteName

			FROM Culvert b
			LEFT JOIN Segment sg ON b.SegmentId = sg.SegmentId
			LEFT JOIN Section s ON sg.SectionId = s.SectionId
			LEFT JOIN District d ON s.DistrictId = d.DistrictId

			LEFT JOIN SubRoute sr ON b.SubRouteId = sr.SubRouteId
			LEFT JOIN MainRoute mr ON sr.MainRouteId = mr.MainRouteId

			WHERE b.CulvertId = ?
			''',
			[culvertId],
		);

		if (result.isEmpty) return null;
		return result.first;
	}
}