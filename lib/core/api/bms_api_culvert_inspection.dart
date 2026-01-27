import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class BmsApiCulvertInspection {
	Future<List<Map<String, dynamic>>> _getList(String endpoint) async {
    final baseUrl = await ApiConfig.getBaseUrl();

    if (baseUrl.isEmpty) {
      throw Exception('API URL not configured');
    }

    final uri = Uri.parse('$baseUrl/api/BmsAPICulvertInspection/$endpoint');

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
	
  // ------------------------------------------------
  // Culvert Inspection APIs (parameter-less only)
  // ------------------------------------------------

  Future<List<Map<String, dynamic>>> getCulvertImprovementList() =>
      _getList('GetCulvertImprovementList');

  Future<List<Map<String, dynamic>>> getculHydrDamageTypeList() =>
      _getList('GetculHydrDamageTypeList');

  Future<List<Map<String, dynamic>>> getculDamageRateAndCostList() =>
      _getList('GetculDamageRateAndCostList');

  Future<List<Map<String, dynamic>>> getculStructureItemList() =>
      _getList('GetculStructureItemList');

  Future<List<Map<String, dynamic>>> getculDamageInspStructureList() =>
      _getList('GetculDamageInspStructureList');

  Future<List<Map<String, dynamic>>> getculDamageInspHydraulicList() =>
      _getList('GetculDamageInspHydraulicList');

  Future<List<Map<String, dynamic>>> getObservationAndRecommendationList() =>
      _getList('GetObservationAndRecommendationList');

  Future<List<Map<String, dynamic>>> getResultInspCulvertList() =>
      _getList('GetResultInspCulvertList');
}