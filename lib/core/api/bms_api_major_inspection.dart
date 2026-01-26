// lib/core/api/bms_api_major_inspection.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

/// Assumes a global API_URL like:
/// const API_URL = 'http://example.com/';
class BmsApiMajorInspection {
  final String baseUrl;

  BmsApiMajorInspection(this.baseUrl);

  // ------------------------
  // Internal helper
  // ------------------------
  Future<List<dynamic>> _postList(String endpoint) async {
    final url = Uri.parse('$baseUrl/api/BmsAPIMajorInspection/$endpoint');
    final response = await http.post(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load $endpoint');
    }

    return jsonDecode(response.body) as List<dynamic>;
  }

  // ------------------------
  // Major Inspection APIs
  // (parameter-less only)
  // ------------------------

  Future<List<dynamic>> getBridgePartList() =>
      _postList('GetBridgePartList');

  Future<List<dynamic>> getBridgePartDmgWtList() =>
      _postList('GetBridgePartDmgWtList');

  Future<List<dynamic>> getDamageConditionRangeList() =>
      _postList('GetDamageConditionRangeList');

  Future<List<dynamic>> getDamageRankList() =>
      _postList('GetDamageRankList');

  Future<List<dynamic>> getDamageRateAndCostList() =>
      _postList('GetDamageRateAndCostList');

  Future<List<dynamic>> getDamageTypeList() =>
      _postList('GetDamageTypeList');

  Future<List<dynamic>> getMaintenanceUrgencyList() =>
      _postList('GetMaintenanceUrgencyList');

  Future<List<dynamic>> getStructureItemList() =>
      _postList('GetStructureItemList');

  Future<List<dynamic>> getStructureItemDmgWtList() =>
      _postList('GetStructureItemDmgWtList');

  Future<List<dynamic>> getImprovementTypeList() =>
      _postList('GetImprovementTypeList');

  Future<List<dynamic>> getAllDamageInspMajors() =>
      _postList('GetAllDamageInspMajors');

  Future<List<dynamic>> getAllBridgeComments() =>
      _postList('GetAllBridgeComments');

  Future<List<dynamic>> getAllBridgeObservation() =>
      _postList('GetAllBridgeObservation');

  Future<List<dynamic>> getAllResultInspMajorList() =>
      _postList('GetAllResultInspMajorList');

  Future<List<dynamic>> getBridgeImprovementList() =>
      _postList('GetBridgeImprovementList');

  Future<List<dynamic>> getDamagePrioritizationCriteriaList() =>
      _postList('GetDamagePrioritizationCriteriaList');

  Future<List<dynamic>> getDamagePriorityList() =>
      _postList('GetDamagePriorityList');

  Future<List<dynamic>> getRequiredActionList() =>
      _postList('GetRequiredActionList');
}