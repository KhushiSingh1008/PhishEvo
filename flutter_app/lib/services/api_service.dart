import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/url_analysis.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiService {
  static Future<UrlAnalysis> analyzeUrl(String url) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'url': url}),
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return UrlAnalysis.fromJson(decoded);
      } else {
        throw ApiException('Failed to analyze URL (Status ${response.statusCode})');
      }
    } on SocketException {
      throw ApiException('Network error. Unable to reach the server.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('An unexpected error occurred: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getFamilies() async {
    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/families'))
          .timeout(AppConfig.apiTimeout);
      if (response.statusCode == 200) {
        final List<dynamic> decoded = json.decode(response.body);
        return decoded.cast<Map<String, dynamic>>();
      } else {
        throw ApiException('Failed to fetch families (Status ${response.statusCode})');
      }
    } on SocketException {
      throw ApiException('Network error. Unable to reach the server.');
    } catch (e) {
      throw ApiException('An unexpected error occurred: $e');
    }
  }

  static Future<List<UrlAnalysis>> getAnalyses() async {
    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/analyses'))
          .timeout(AppConfig.apiTimeout);
      if (response.statusCode == 200) {
        final List<dynamic> decoded = json.decode(response.body);
        return decoded.map((json) => UrlAnalysis.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to fetch recent analyses (Status ${response.statusCode})');
      }
    } on SocketException {
      throw ApiException('Network error. Unable to reach the server.');
    } catch (e) {
      throw ApiException('An unexpected error occurred: $e');
    }
  }

  static Future<List<String>> getBlocklist() async {
    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/blocklist'))
          .timeout(AppConfig.apiTimeout);
      if (response.statusCode == 200) {
        final List<dynamic> decoded = json.decode(response.body);
        return decoded.map((e) => (e['url_pattern'] ?? '').toString()).toList();
      } else {
        throw ApiException('Failed to fetch blocklist (Status ${response.statusCode})');
      }
    } on SocketException {
      throw ApiException('Network error. Unable to reach the server.');
    } catch (e) {
      throw ApiException('An unexpected error occurred: $e');
    }
  }

  static Future<void> addToBlocklist(String url) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/blocklist'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'url': url}),
      ).timeout(AppConfig.apiTimeout);
      
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ApiException('Failed to add to blocklist (Status ${response.statusCode})');
      }
    } on SocketException {
      throw ApiException('Network error. Unable to reach the server.');
    } catch (e) {
      throw ApiException('An unexpected error occurred: $e');
    }
  }
}
