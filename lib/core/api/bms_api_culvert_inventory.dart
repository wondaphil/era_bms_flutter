import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class BmsApiCulvertInventory {
  Future<List<Map<String, dynamic>>> _getList(String endpoint) async {
    final baseUrl = await ApiConfig.getBaseUrl();

    if (baseUrl.isEmpty) {
      throw Exception('API URL not configured');
    }

    final uri = Uri.parse('$baseUrl/api/BmsAPICulvertInventory/$endpoint');

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
  // Culvert Inventory APIs
  // (parameter-less only)
  // ------------------------

  Future<List<Map<String, dynamic>>> getCulvertTypeList() =>
      _getList('GetCulvertTypeList');

  Future<List<Map<String, dynamic>>> getParapetMaterialTypeList() =>
      _getList('GetParapetMaterialTypeList');

  Future<List<Map<String, dynamic>>> getEndWallTypeList() =>
      _getList('GetEndWallTypeList');

  Future<List<Map<String, dynamic>>> getCulvertGeneralInfoList() =>
      _getList('GetCulvertGeneralInfoList');

  Future<List<Map<String, dynamic>>> getCulvertStructureList() =>
      _getList('GetCulvertStructureList');

  Future<List<Map<String, dynamic>>> getCulvertMediaList() =>
      _getList('GetCulvertMediaList');
}