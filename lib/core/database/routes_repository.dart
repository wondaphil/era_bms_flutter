import 'database_helper.dart';

class RoutesRepository {
  final _dbHelper = DatabaseHelper.instance;

  Future<List<Map<String, dynamic>>> getMainRoutes() async {
    final db = await _dbHelper.database;
    return db.rawQuery(
      'SELECT MainRouteId, MainRouteNo, MainRouteName FROM MainRoute ORDER BY MainRouteNo',
    );
  }

  Future<List<Map<String, dynamic>>> getSubRoutes(String districtId) async {
    final db = await _dbHelper.database;
    return db.rawQuery(
      'SELECT SubRouteId, SubRouteNo, SubRouteName FROM SubRoute WHERE MainRouteId = ? ORDER BY SubRouteNo',
      [districtId],
    );
  }
}