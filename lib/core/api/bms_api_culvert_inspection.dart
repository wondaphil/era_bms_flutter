// lib/core/api/bms_api_culvert_inspection.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

/// Assumes a global API_URL like:
/// const API_URL = 'http://example.com/';
class BmsApiCulvertInspection {
  final String baseUrl;

  BmsApiCulvertInspection(this.baseUrl);

  // ------------------------
  // Internal helper
  // ------------------------
  Future<List<dynamic>> _postList(String endpoint) async {
    final url = Uri.parse('$baseUrl/api/BmsAPICulvertInspection/$endpoint');
    final response = await http.post(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load $endpoint');
    }

    return jsonDecode(response.body) as List<dynamic>;
  }

  // ------------------------------------------------
  // Culvert Inspection APIs (parameter-less only)
  // ------------------------------------------------

  Future<List<dynamic>> getCulvertImprovementList() =>
      _postList('GetCulvertImprovementList');

  Future<List<dynamic>> getCulHydrDamageTypeList() =>
      _postList('GetculHydrDamageTypeList');

  Future<List<dynamic>> getCulDamageRateAndCostList() =>
      _postList('GetculDamageRateAndCostList');

  Future<List<dynamic>> getCulStructureItemList() =>
      _postList('GetculStructureItemList');

  Future<List<dynamic>> getCulDamageInspStructureList() =>
      _postList('GetculDamageInspStructureList');

  Future<List<dynamic>> getCulDamageInspHydraulicList() =>
      _postList('GetculDamageInspHydraulicList');

  Future<List<dynamic>> getObservationAndRecommendationList() =>
      _postList('GetObservationAndRecommendationList');

  Future<List<dynamic>> getResultInspCulvertList() =>
      _postList('GetResultInspCulvertList');
}