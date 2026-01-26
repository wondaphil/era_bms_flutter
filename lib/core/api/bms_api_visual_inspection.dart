// lib/core/api/bms_api_visual_inspection.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

/// Assumes a global API_URL like:
/// const API_URL = 'http://example.com/';
class BmsApiVisualInspection {
  final String baseUrl;

  BmsApiVisualInspection(this.baseUrl);

  // ------------------------
  // Internal helper
  // ------------------------
  Future<List<dynamic>> _postList(String endpoint) async {
    final url = Uri.parse('$baseUrl/api/BmsAPIVisualInspection/$endpoint');
    final response = await http.post(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load $endpoint');
    }

    return jsonDecode(response.body) as List<dynamic>;
  }

  // ------------------------
  // Visual Inspection APIs
  // (parameter-less only)
  // ------------------------

  Future<List<dynamic>> getAllDamageInspVisuals() =>
      _postList('GetAllDamageInspVisuals');

  Future<List<dynamic>> getDamageSeverityList() =>
      _postList('GetDamageSeverityList');
}