import 'dart:convert';
import 'package:http/http.dart' as http;

/// NOTE:
/// API_URL is assumed to be a global value
/// e.g. const API_URL = 'https://example.com/';
///
/// All endpoints are POST (matching your controller)
class BmsApiBridgeInventory {
  final String baseUrl;

  BmsApiBridgeInventory(this.baseUrl);

  // ------------------------
  // Internal helper
  // ------------------------
  Future<List<dynamic>> _postList(String endpoint) async {
    final url = Uri.parse('$baseUrl/api/BmsAPIBridgeInventory/$endpoint');

    final response = await http.post(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load $endpoint');
    }

    return jsonDecode(response.body) as List<dynamic>;
  }

  // ------------------------
  // Bridge Inventory APIs
  // ------------------------

  Future<List<dynamic>> getSuperStructureList() =>
      _postList('GetSuperStructureList');

  Future<List<dynamic>> getAbutmentList() =>
      _postList('GetAbutmentList');

  Future<List<dynamic>> getAncillariesList() =>
      _postList('GetAncillariesList');

  Future<List<dynamic>> getPierList() =>
      _postList('GetPierList');

  Future<List<dynamic>> getBridgeDocList() =>
      _postList('GetBridgeDocList');

  Future<List<dynamic>> getBridgeMediaList() =>
      _postList('GetBridgeMediaList');

  // ------------------------
  // Reference / Lookup Tables
  // ------------------------

  Future<List<dynamic>> getRoadAlignmentTypeList() =>
      _postList('GetRoadAlignmentTypeList');

  Future<List<dynamic>> getBridgeTypeList() =>
      _postList('GetBridgeTypeList');

  Future<List<dynamic>> getSpanSupportTypeList() =>
      _postList('GetSpanSupportTypeList');

  Future<List<dynamic>> getDeckSlabTypeList() =>
      _postList('GetDeckSlabTypeList');

  Future<List<dynamic>> getGirderTypeList() =>
      _postList('GetGirderTypeList');

  Future<List<dynamic>> getAbutmentTypeList() =>
      _postList('GetAbutmentTypeList');

  Future<List<dynamic>> getFoundationTypeList() =>
      _postList('GetFoundationTypeList');

  Future<List<dynamic>> getSoilTypeList() =>
      _postList('GetSoilTypeList');

  Future<List<dynamic>> getExpansionJointTypeList() =>
      _postList('GetExpansionJointTypeList');

  Future<List<dynamic>> getBearingTypeList() =>
      _postList('GetBearingTypeList');

  Future<List<dynamic>> getGuardRailingTypeList() =>
      _postList('GetGuardRailingTypeList');

  Future<List<dynamic>> getSurfaceTypeList() =>
      _postList('GetSurfaceTypeList');

  Future<List<dynamic>> getPierTypeList() =>
      _postList('GetPierTypeList');

  Future<List<dynamic>> getMediaTypeList() =>
      _postList('GetMediaTypeList');
}