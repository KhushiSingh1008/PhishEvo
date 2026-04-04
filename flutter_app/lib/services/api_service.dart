import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/url_analysis.dart';
import '../models/campaign_family.dart';

class ApiService {
  static const String baseUrl = 'https://phishevo-backend-xxxx-uc.a.run.app';

  Future<UrlAnalysis?> analyzeUrl(String url) async {
    try {
      final response = await http.post(
        Uri.parse('\$baseUrl/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'url': url}),
      );

      if (response.statusCode == 200) {
        return UrlAnalysis.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to analyze URL');
      }
    } catch (e) {
      print('API Error: \$e');
      return null;
    }
  }

  Future<List<CampaignFamily>> getFamilies() async {
    try {
      final response = await http.get(Uri.parse('\$baseUrl/families'));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => CampaignFamily.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('API Error: \$e');
      return [];
    }
  }

  Future<List<UrlAnalysis>> getRecentAnalyses() async {
    try {
      final response = await http.get(Uri.parse('\$baseUrl/recent'));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => UrlAnalysis.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('API Error: \$e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getBlocklist() async {
    try {
      final response = await http.get(Uri.parse('\$baseUrl/blocklist'));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      print('API Error: \$e');
      return [];
    }
  }
}
