import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class BmsApiVisualInspection {
  Future<List<Map<String, dynamic>>> _getList(String endpoint) async {
    final baseUrl = await ApiConfig.getBaseUrl();

    if (baseUrl.isEmpty) {
      throw Exception('API URL not configured');
    }

    final uri = Uri.parse('$baseUrl/api/BmsAPIVisualInspection/$endpoint');

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
  // Visual Inspection APIs
  // (parameter-less only)
  // ------------------------

  Future<List<Map<String, dynamic>>> getDamageInspVisualList() =>
      _getList('GetDamageInspVisualList');

  Future<List<Map<String, dynamic>>> getDamageSeverityList() =>
      _getList('GetDamageSeverityList');
}