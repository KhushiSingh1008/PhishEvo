import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

import '../models/url_analysis.dart';
import '../models/campaign_family.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  static Future<UrlAnalysis> analyzeUrl(String url) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/analyze"),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'url': url}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return UrlAnalysis.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
            'Error: HTTP ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to API: $e');
    }
  }

  static Future<List<CampaignFamily>> getFamilies() async {
    try {
      final response = await http
          .get(Uri.parse("$baseUrl/families"))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => CampaignFamily.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<UrlAnalysis>> getRecentAnalyses() async {
    try {
      final response = await http
          .get(Uri.parse("$baseUrl/analyses"))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => UrlAnalysis.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse("$baseUrl/health"))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
