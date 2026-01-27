import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class BmsApiBridgeInventory {
  Future<List<Map<String, dynamic>>> _getList(String endpoint) async {
    final baseUrl = await ApiConfig.getBaseUrl();

    if (baseUrl.isEmpty) {
      throw Exception('API URL not configured');
    }

    final uri = Uri.parse('$baseUrl/api/BmsAPIBridgeInventory/$endpoint');

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

  // ------------------------
  // Bridge Inventory APIs
  // ------------------------

  Future<List<Map<String, dynamic>>> getBridgeGeneralInfoList() =>
      _getList('GetBridgeGeneralInfoList');

  Future<List<Map<String, dynamic>>> getSuperStructureList() =>
      _getList('GetSuperStructureList');

  Future<List<Map<String, dynamic>>> getAbutmentList() =>
      _getList('GetAbutmentList');

  Future<List<Map<String, dynamic>>> getAncillariesList() =>
      _getList('GetAncillariesList');

  Future<List<Map<String, dynamic>>> getPierList() =>
      _getList('GetPierList');

  Future<List<Map<String, dynamic>>> getDocTypeList() =>
      _getList('GetDocTypeList');

  Future<List<Map<String, dynamic>>> getBridgeDocList() =>
      _getList('GetBridgeDocList');

  Future<List<Map<String, dynamic>>> getBridgeMediaList() =>
      _getList('GetBridgeMediaList');

  // ------------------------
  // Reference / Lookup Tables
  // ------------------------

  Future<List<Map<String, dynamic>>> getRoadAlignmentTypeList() =>
      _getList('GetRoadAlignmentTypeList');

  Future<List<Map<String, dynamic>>> getBridgeTypeList() =>
      _getList('GetBridgeTypeList');

  Future<List<Map<String, dynamic>>> getSpanSupportTypeList() =>
      _getList('GetSpanSupportTypeList');

  Future<List<Map<String, dynamic>>> getDeckSlabTypeList() =>
      _getList('GetDeckSlabTypeList');

  Future<List<Map<String, dynamic>>> getGirderTypeList() =>
      _getList('GetGirderTypeList');

  Future<List<Map<String, dynamic>>> getAbutmentTypeList() =>
      _getList('GetAbutmentTypeList');

  Future<List<Map<String, dynamic>>> getFoundationTypeList() =>
      _getList('GetFoundationTypeList');

  Future<List<Map<String, dynamic>>> getSoilTypeList() =>
      _getList('GetSoilTypeList');

  Future<List<Map<String, dynamic>>> getExpansionJointTypeList() =>
      _getList('GetExpansionJointTypeList');

  Future<List<Map<String, dynamic>>> getBearingTypeList() =>
      _getList('GetBearingTypeList');

  Future<List<Map<String, dynamic>>> getGuardRailingTypeList() =>
      _getList('GetGuardRailingTypeList');

  Future<List<Map<String, dynamic>>> getSurfaceTypeList() =>
      _getList('GetSurfaceTypeList');

  Future<List<Map<String, dynamic>>> getPierTypeList() =>
      _getList('GetPierTypeList');

  Future<List<Map<String, dynamic>>> getMediaTypeList() =>
      _getList('GetMediaTypeList');
}