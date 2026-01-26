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
				b.revisedCulvertNo,
				
				d.DistrictId,
				d.DistrictNo,
				d.DistrictName,

				s.SectionId,r
				s.SectionNo,
				s.SectionName,

				sg.SegmentId,
				sg.SegmentNo,
				sg.SegmentName,

				mr.MainRouteId,
				mr.MainRouteNo,
				mr.MainRouteName,

				sr.SubRouteId,
				sr.SubRouteNo,
				sr.SubRouteName,
				
				gen.KMFromAddis

			FROM Culvert b
			LEFT JOIN CulvertGeneralInfo gen ON gen.CulvertId = b.CulvertId
			
			LEFT JOIN Segment sg ON b.SegmentId = sg.SegmentId
			LEFT JOIN Section s ON sg.SectionId = s.SectionId
			LEFT JOIN District d ON s.DistrictId = d.DistrictId

			LEFT JOIN SubRoute sr ON b.SubRouteId = sr.SubRouteId
			LEFT JOIN MainRoute mr ON sr.MainRouteId = mr.MainRouteId

			WHERE b.CulvertId = ?
			''',
			[culvertId],
		);

		return result.isEmpty ? null : result.first;
	}
	
	Future<void> updateCulvert({
		required String culvertId,
		required String culvertNo,
		required String revisedCulvertNo,
		required String segmentId,
		required String subRouteId,
	}) async {
		final db = await _dbHelper.database;

		await db.update(
			'Culvert',
			{
				'CulvertNo': culvertNo,
				'RevisedCulvertNo': revisedCulvertNo,
				'SegmentId': segmentId,
				'SubRouteId': subRouteId,
			},
			where: 'CulvertId = ?',
			whereArgs: [culvertId],
		);
	}
	
	Future<bool> culvertNoExists(
		String culvertNo,
		String excludeCulvertId,
	) async {
		final db = await _dbHelper.database;

		final result = await db.rawQuery(
			'''
			SELECT 1 FROM Culvert
			WHERE CulvertNo = ?
				AND CulvertId != ?
			LIMIT 1
			''',
			[culvertNo, excludeCulvertId],
		);

		return result.isNotEmpty;
	}
	
	Future<void> insertCulvert({
		required String culvertId,
		required String culvertNo,
		required String revisedCulvertNo,
		required String segmentId,
		required String subRouteId,
	}) async {
		final db = await _dbHelper.database;

		await db.insert(
			'Culvert',
			{
				'CulvertId': culvertId,
				'CulvertNo': culvertNo,
				'RevisedCulvertNo': revisedCulvertNo,
				'revisedCulvertNo': revisedCulvertNo,
				'SegmentId': segmentId,
				'SubRouteId': subRouteId,
			},
		);
	}
	
	Future<String?> getNextCulvertNoForSubRoute(String subRouteId) async {
		final db = await _dbHelper.database;

		final result = await db.rawQuery(
			'''
			SELECT CulvertNo
			FROM Culvert
			WHERE SubRouteId = ?
				AND CulvertNo IS NOT NULL
			ORDER BY
				CAST(
					SUBSTR(CulvertNo, INSTR(CulvertNo, '-') + 1)
					AS INTEGER
				) DESC
			LIMIT 1
			''',
			[subRouteId],
		);

		if (result.isEmpty) return null;

		return result.first['CulvertNo'] as String;
	}
	
	Future<Map<String, dynamic>?> getCulvertCoordinates(String culvertId) async {
		final db = await _dbHelper.database;

		final result = await db.rawQuery('''
			SELECT 
				g.XCoord,
				g.YCoord,
				z.UtmZone
			FROM CulvertGeneralInfo g
			JOIN UTMZoneEthiopia z ON g.UtmZoneId = z.UtmZoneId
			WHERE g.CulvertId = ?
			LIMIT 1
		''', [culvertId]);

		return result.isNotEmpty ? result.first : null;
	}
	
	Future<List<Map<String, dynamic>>> getCulvertsInfoBySegment(String segmentId) async {
		final db = await _dbHelper.database;

		return db.rawQuery('''
			SELECT 
				b.CulvertId,
				b.CulvertNo,
				b.RevisedCulvertNo,
				s.SegmentNo,
				s.SegmentName,
				g.XCoord,
				g.YCoord,
				z.UtmZone
			FROM Culvert b
			JOIN CulvertGeneralInfo g ON b.CulvertId = g.CulvertId
			JOIN Segment s ON s.SegmentId = b.SegmentId
			JOIN UTMZoneEthiopia z ON g.UtmZoneId = z.UtmZoneId
			WHERE b.SegmentId = ?
				AND g.XCoord IS NOT NULL
				AND g.YCoord IS NOT NULL
		''', [segmentId]);
	}
}