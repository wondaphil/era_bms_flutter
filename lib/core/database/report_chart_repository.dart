import 'database_helper.dart';

class ReportChartRepository {
  final _dbHelper = DatabaseHelper.instance;

  /// -----------------------------
  /// Inspection years (shared)
  /// -----------------------------
  Future<List<int>> getInspectionYears() async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery('''
      SELECT DISTINCT InspectionYear
      FROM ResultInspMajor
      WHERE InspectionYear IS NOT NULL
      ORDER BY InspectionYear DESC
    ''');

    return result
        .map((e) => e['InspectionYear'])
        .whereType<int>()
        .toList();
  }
	
	// =============================
  // Inventory reports/charts
  // =============================

  Future<List<Map<String, dynamic>>> getBridgesAndCulvertsByDistrict() async {
		final db = await _dbHelper.database;

		return db.rawQuery('''
			SELECT
				d.DistrictNo,
				d.DistrictName,
				COUNT(DISTINCT b.BridgeId) AS BridgeCount,
				COUNT(DISTINCT c.CulvertId) AS CulvertCount
			FROM District d
			LEFT JOIN Section s ON s.DistrictId = d.DistrictId
			LEFT JOIN Segment g ON g.SectionId = s.SectionId
			LEFT JOIN Bridge b ON b.SegmentId = g.SegmentId
			LEFT JOIN Culvert c ON c.SegmentId = g.SegmentId
			GROUP BY d.DistrictId, d.DistrictNo, d.DistrictName
			ORDER BY d.DistrictNo
		''');
	}
	
	Future<List<Map<String, dynamic>>> getBridgesByDistrict() async {
		final db = await _dbHelper.database;

		return db.rawQuery('''
			SELECT
				d.DistrictNo,
				d.DistrictName,
				COUNT(*) AS BridgeCount
			FROM Bridge b
			JOIN Segment s   ON b.SegmentId = s.SegmentId
			JOIN Section sec ON s.SectionId = sec.SectionId
			JOIN District d  ON sec.DistrictId = d.DistrictId
			GROUP BY d.DistrictId, d.DistrictNo, d.DistrictName
			ORDER BY d.DistrictNo
		''');
	}
	
	Future<List<Map<String, dynamic>>> getCulvertsByDistrict() async {
		final db = await _dbHelper.database;

		return db.rawQuery('''
			SELECT
				d.DistrictNo,
				d.DistrictName,
				COUNT(*) AS CulvertCount
			FROM Culvert c
			JOIN Segment s   ON c.SegmentId = s.SegmentId
			JOIN Section sec ON s.SectionId = sec.SectionId
			JOIN District d  ON sec.DistrictId = d.DistrictId
			GROUP BY d.DistrictId, d.DistrictNo, d.DistrictName
			ORDER BY d.DistrictNo
		''');
	}
	
	Future<List<Map<String, dynamic>>> getBridgesByConstructionYear() async {
		final db = await _dbHelper.database;

		return db.rawQuery('''
			SELECT
				cy.CategoryId AS Id,
				cy.ConstructionYears AS ConstructionYear,
				COUNT(*) AS BridgeCount
			FROM BridgeGeneralInfo bg
			JOIN ConstructionYear cy
				ON bg.ReplacedYear BETWEEN cy.FromYear AND cy.ToYear
			GROUP BY cy.CategoryId, cy.ConstructionYears
			ORDER BY cy.ConstructionYears
		''');
	}

	Future<List<Map<String, dynamic>>> getBridgesByLength() async {
		final db = await _dbHelper.database;

		return db.rawQuery('''
			SELECT
				bl.BridgeLengthId AS Id,
				bl.BridgeLengthName AS BridgeLength,
				COUNT(*) AS BridgeCount
			FROM BridgeGeneralInfo bg
			JOIN BridgeLength bl
				ON bg.BridgeLength >= bl.FromLength
			 AND bg.BridgeLength <  bl.ToLength
			GROUP BY bl.BridgeLengthId, bl.BridgeLengthName
			ORDER BY bl.BridgeLengthId
		''');
	}
	
	Future<List<Map<String, dynamic>>> getBridgesByBridgeType() async {
		final db = await _dbHelper.database;

		return db.rawQuery('''
			SELECT
				bt.BridgeTypeName AS TypeName,
				COUNT(*) AS BridgeCount
			FROM Bridge b
			JOIN SuperStructure ss ON b.BridgeId = ss.BridgeId
			JOIN BridgeType bt     ON ss.BridgeTypeId = bt.BridgeTypeId
			GROUP BY bt.BridgeTypeId, bt.BridgeTypeName
			ORDER BY bt.BridgeTypeId
		''');
	}

	Future<List<Map<String, dynamic>>> getCulvertsByCulvertType() async {
		final db = await _dbHelper.database;

		return db.rawQuery('''
			SELECT
				ct.CulvertTypeName AS TypeName,
				COUNT(*) AS CulvertCount
			FROM Culvert c
			JOIN CulvertStructure cs ON c.CulvertId = cs.CulvertId
			JOIN CulvertType ct      ON cs.CulvertTypeId = ct.CulvertTypeId
			GROUP BY ct.CulvertTypeId, ct.CulvertTypeName
			ORDER BY ct.CulvertTypeId
		''');
	}

  // =============================
  // Inspection reports/charts
  // =============================

  Future<List<Map<String, dynamic>>> getInspectedBridgesByInspectionYear() async {
		final db = await _dbHelper.database;
		return db.rawQuery('''
			SELECT InspectionYear, COUNT(*) AS BridgeCount
			FROM ResultInspMajor
			GROUP BY InspectionYear
			ORDER BY InspectionYear
		''');
	}
	
	Future<List<Map<String, dynamic>>> getInspectedCulvertsByInspectionYear() async {
		final db = await _dbHelper.database;

		return db.rawQuery('''
			SELECT
				miy.InspectionYear AS InspectionYear,
				COUNT(*) AS CulvertCount
			FROM ResultInspCulvert ric
			JOIN MajorInspectionYear miy
				ON CAST(
						 strftime(
							 '%Y',
							 (ric.InspectionDate - 621355968000000000) / 10000000,
							 'unixepoch'
						 ) AS INTEGER
					 )
					 BETWEEN miy.StartYear AND miy.EndYear
			GROUP BY miy.InspectionYear
			ORDER BY miy.InspectionYear
		''');
	}

	Future<List<Map<String, dynamic>>> getBridgesByServiceCondition(int inspectionYear) async {
		final db = await _dbHelper.database;

		return db.rawQuery('''
			SELECT
				dcr.DamageConditionName AS Condition,
				COUNT(*) AS BridgeCount
			FROM ResultInspMajor rim
			JOIN DamageConditionRange dcr
				ON rim.DmgPerc >= dcr.ValueFrom
			 AND rim.DmgPerc <  dcr.ValueTo
			WHERE rim.InspectionYear = ?
			GROUP BY dcr.DamageConditionName
			ORDER BY dcr.DamageConditionId
		''', [inspectionYear]);
	}

	Future<List<Map<String, dynamic>>> getInspectedBridgesByDistrict(int inspectionYear) async {
		final db = await _dbHelper.database;

		return db.rawQuery('''
			SELECT
				d.DistrictNo,
				d.DistrictName,
				COUNT(*) AS BridgeCount
			FROM Bridge b
			JOIN Segment s   ON b.SegmentId = s.SegmentId
			JOIN Section sec ON s.SectionId = sec.SectionId
			JOIN District d  ON sec.DistrictId = d.DistrictId
			JOIN ResultInspMajor rim
					 ON b.BridgeId = rim.BridgeId
			WHERE rim.InspectionYear = ?
			GROUP BY d.DistrictId, d.DistrictNo, d.DistrictName
			ORDER BY d.DistrictNo
		''', [inspectionYear]);
	}

	Future<List<Map<String, dynamic>>> getInspectedCulvertsByDistrict(int inspectionYear) async {
		final db = await _dbHelper.database;

		return db.rawQuery('''
			SELECT
				d.DistrictNo,
				d.DistrictName,
				COUNT(*) AS CulvertCount
			FROM Culvert c
			JOIN Segment s   ON c.SegmentId = s.SegmentId
			JOIN Section sec ON s.SectionId = sec.SectionId
			JOIN District d  ON sec.DistrictId = d.DistrictId
			JOIN ResultInspCulvert ric
					 ON c.CulvertId = ric.CulvertId
			JOIN MajorInspectionYear miy
					 ON CAST(
								strftime(
									'%Y',
									(ric.InspectionDate - 621355968000000000) / 10000000,
									'unixepoch'
								) AS INTEGER
							)
							BETWEEN miy.StartYear AND miy.EndYear
			WHERE miy.InspectionYear = ?
			GROUP BY d.DistrictId, d.DistrictNo, d.DistrictName
			ORDER BY d.DistrictNo
		''', [inspectionYear]);
	}
}