import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class BmsApiMajorInspection {
  Future<List<Map<String, dynamic>>> _getList(String endpoint) async {
    final baseUrl = await ApiConfig.getBaseUrl();

    if (baseUrl.isEmpty) {
      throw Exception('API URL not configured');
    }

    final uri = Uri.parse('$baseUrl/api/BmsAPIMajorInspection/$endpoint');

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
  // Major Inspection APIs
  // (parameter-less only)
  // ------------------------

  Future<List<Map<String, dynamic>>> getBridgePartList() =>
      _getList('GetBridgePartList');

  Future<List<Map<String, dynamic>>> getBridgePartDmgWtList() =>
      _getList('GetBridgePartDmgWtList');

  Future<List<Map<String, dynamic>>> getDamageConditionRangeList() =>
      _getList('GetDamageConditionRangeList');

  Future<List<Map<String, dynamic>>> getDamageRankList() =>
      _getList('GetDamageRankList');

  Future<List<Map<String, dynamic>>> getDamageRateAndCostList() =>
      _getList('GetDamageRateAndCostList');

  Future<List<Map<String, dynamic>>> getDamageTypeList() =>
      _getList('GetDamageTypeList');

  Future<List<Map<String, dynamic>>> getMaintenanceUrgencyList() =>
      _getList('GetMaintenanceUrgencyList');

  Future<List<Map<String, dynamic>>> getStructureItemList() =>
      _getList('GetStructureItemList');

  Future<List<Map<String, dynamic>>> getStructureItemDmgWtList() =>
      _getList('GetStructureItemDmgWtList');

  Future<List<Map<String, dynamic>>> getImprovementTypeList() =>
      _getList('GetImprovementTypeList');

  Future<List<Map<String, dynamic>>> getDamageInspMajorList() =>
      _getList('GetDamageInspMajorList');

  Future<List<Map<String, dynamic>>> getResultInspMajorList() =>
      _getList('GetResultInspMajorList');

  Future<List<Map<String, dynamic>>> getBridgeCommentList() =>
      _getList('GetBridgeCommentList');

  Future<List<Map<String, dynamic>>> getBridgeObservationList() =>
      _getList('GetBridgeObservationList');

  Future<List<Map<String, dynamic>>> getAllResultInspMajorList() =>
      _getList('GetAllResultInspMajorList');

  Future<List<Map<String, dynamic>>> getBridgeImprovementList() =>
      _getList('GetBridgeImprovementList');

  Future<List<Map<String, dynamic>>> getDamagePrioritizationCriteriaList() =>
      _getList('GetDamagePrioritizationCriteriaList');

  Future<List<Map<String, dynamic>>> getDamagePriorityList() =>
      _getList('GetDamagePriorityList');

  Future<List<Map<String, dynamic>>> getRequiredActionList() =>
      _getList('GetRequiredActionList');
}