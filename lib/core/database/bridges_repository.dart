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
				b.RevisedBridgeNo,
				b.BridgeName,

				d.DistrictId,
				d.DistrictNo,
				d.DistrictName,

				s.SectionId,
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

			FROM Bridge b
			LEFT JOIN BridgeGeneralInfo gen ON gen.BridgeId = b.BridgeId
			
			LEFT JOIN Segment sg ON b.SegmentId = sg.SegmentId
			LEFT JOIN Section s ON sg.SectionId = s.SectionId
			LEFT JOIN District d ON s.DistrictId = d.DistrictId

			LEFT JOIN SubRoute sr ON b.SubRouteId = sr.SubRouteId
			LEFT JOIN MainRoute mr ON sr.MainRouteId = mr.MainRouteId

			WHERE b.BridgeId = ?
			''',
			[bridgeId],
		);

		return result.isEmpty ? null : result.first;
	}
	
	Future<void> updateBridge({
		required String bridgeId,
		required String bridgeNo,
		required String revisedBridgeNo,
		required String bridgeName,
		required String segmentId,
		required String subRouteId,
	}) async {
		final db = await _dbHelper.database;

		await db.update(
			'Bridge',
			{
				'BridgeNo': bridgeNo,
				'RevisedBridgeNo': revisedBridgeNo,
				'BridgeName': bridgeName,
				'SegmentId': segmentId,
				'SubRouteId': subRouteId,
			},
			where: 'BridgeId = ?',
			whereArgs: [bridgeId],
		);
	}
	
	Future<bool> bridgeNoExists(
		String bridgeNo,
		String excludeBridgeId,
	) async {
		final db = await _dbHelper.database;

		final result = await db.rawQuery(
			'''
			SELECT 1 FROM Bridge
			WHERE BridgeNo = ?
				AND BridgeId != ?
			LIMIT 1
			''',
			[bridgeNo, excludeBridgeId],
		);

		return result.isNotEmpty;
	}
	
	Future<void> insertBridge({
		required String bridgeId,
		required String bridgeNo,
		required String revisedBridgeNo,
		required String bridgeName,
		required String segmentId,
		required String subRouteId,
	}) async {
		final db = await _dbHelper.database;

		await db.insert(
			'Bridge',
			{
				'BridgeId': bridgeId,
				'BridgeNo': bridgeNo,
				'RevisedBridgeNo': revisedBridgeNo,
				'BridgeName': bridgeName,
				'SegmentId': segmentId,
				'SubRouteId': subRouteId,
			},
		);
	}
	
	Future<String?> getNextBridgeNoForSubRoute(String subRouteId) async {
		final db = await _dbHelper.database;

		final result = await db.rawQuery(
			'''
			SELECT BridgeNo
			FROM Bridge
			WHERE SubRouteId = ?
				AND BridgeNo IS NOT NULL
			ORDER BY
				CAST(
					SUBSTR(BridgeNo, INSTR(BridgeNo, '-') + 1)
					AS INTEGER
				) DESC
			LIMIT 1
			''',
			[subRouteId],
		);

		if (result.isEmpty) return null;

		return result.first['BridgeNo'] as String;
	}
	
	Future<Map<String, dynamic>?> getBridgeCoordinates(String bridgeId) async {
		final db = await _dbHelper.database;

		final result = await db.rawQuery('''
			SELECT 
				g.XCoord,
				g.YCoord,
				z.UtmZone
			FROM BridgeGeneralInfo g
			JOIN UTMZoneEthiopia z ON g.UtmZoneId = z.UtmZoneId
			WHERE g.BridgeId = ?
			LIMIT 1
		''', [bridgeId]);

		return result.isNotEmpty ? result.first : null;
	}
	
	Future<List<Map<String, dynamic>>> getBridgesInfoBySegment(String segmentId) async {
		final db = await _dbHelper.database;

		return db.rawQuery('''
			SELECT 
				b.BridgeId,
				b.BridgeNo,
				b.RevisedBridgeNo,
				b.BridgeName,
				s.SegmentNo,
				s.SegmentName,
				g.XCoord,
				g.YCoord,
				z.UtmZone
			FROM Bridge b
			JOIN BridgeGeneralInfo g ON b.BridgeId = g.BridgeId
			JOIN Segment s ON s.SegmentId = b.SegmentId
			JOIN UTMZoneEthiopia z ON g.UtmZoneId = z.UtmZoneId
			WHERE b.SegmentId = ?
				AND g.XCoord IS NOT NULL
				AND g.YCoord IS NOT NULL
		''', [segmentId]);
	}
}