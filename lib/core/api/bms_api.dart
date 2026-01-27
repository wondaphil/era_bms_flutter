import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class BmsApi {
  Future<List<Map<String, dynamic>>> _getList(String endpoint) async {
    final baseUrl = await ApiConfig.getBaseUrl();

    if (baseUrl.isEmpty) {
      throw Exception('API URL not configured');
    }

    final uri = Uri.parse('$baseUrl/api/BmsAPI/$endpoint');

    final response = await http.post(uri); // POST (as you confirmed)

    if (response.statusCode != 200) {
      throw Exception('API error [$endpoint]: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception('Unexpected response format from $endpoint');
    }

    return decoded.cast<Map<String, dynamic>>();
  }

  // ============================================================
  // METHODS FROM BmsAPIController (NO PARAMETERS)
  // ============================================================

  Future<List<Map<String, dynamic>>> getAllBridges() =>
      _getList('GetAllBridges');

  Future<List<Map<String, dynamic>>> getAllCulverts() =>
      _getList('GetAllCulverts');

  Future<List<Map<String, dynamic>>> getDistrictList() =>
      _getList('GetDistrictList');

  Future<List<Map<String, dynamic>>> getAllSections() =>
      _getList('GetAllSections');

  Future<List<Map<String, dynamic>>> getAllSegments() =>
      _getList('GetAllSegments');

  Future<List<Map<String, dynamic>>> getMainRouteList() =>
      _getList('GetMainRouteList');

  Future<List<Map<String, dynamic>>> getAllSubRoutes() =>
      _getList('GetAllSubRoutes');

  Future<List<Map<String, dynamic>>> getDesignStandardList() =>
      _getList('GetDesignStandardList');

  Future<List<Map<String, dynamic>>> getRegionalGovernmentList() =>
      _getList('GetRegionalGovernmentList');

  Future<List<Map<String, dynamic>>> getRoadSurfaceTypeList() =>
      _getList('GetRoadSurfaceTypeList');

  Future<List<Map<String, dynamic>>> getRoadClassList() =>
      _getList('GetRoadClassList');
}