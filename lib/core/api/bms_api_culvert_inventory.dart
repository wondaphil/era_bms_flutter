// lib/core/api/bms_api_culvert_inventory.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

/// Assumes a global API_URL like:
/// const API_URL = 'http://example.com/';
class BmsApiCulvertInventory {
  final String baseUrl;

  BmsApiCulvertInventory(this.baseUrl);

  // ------------------------
  // Internal helper
  // ------------------------
  Future<List<dynamic>> _postList(String endpoint) async {
    final url = Uri.parse('$baseUrl/api/BmsAPICulvertInventory/$endpoint');
    final response = await http.post(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load $endpoint');
    }

    return jsonDecode(response.body) as List<dynamic>;
  }

  // ------------------------
  // Culvert Inventory APIs
  // (parameter-less only)
  // ------------------------

  Future<List<dynamic>> getCulvertTypeList() =>
      _postList('GetCulvertTypeList');

  Future<List<dynamic>> getParapetMaterialTypeList() =>
      _postList('GetParapetMaterialTypeList');

  Future<List<dynamic>> getEndWallTypeList() =>
      _postList('GetEndWallTypeList');

  Future<List<dynamic>> getCulvertGeneralInfoList() =>
      _postList('GetCulvertGeneralInfoList');

  Future<List<dynamic>> getCulvertStructureList() =>
      _postList('GetCulvertStructureList');
}