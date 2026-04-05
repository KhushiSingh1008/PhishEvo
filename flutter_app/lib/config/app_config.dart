import 'package:flutter/foundation.dart';

class AppConfig {
  // For physical devices connected via USB, use 127.0.0.1 with ADB reverse mapping
  static const String baseUrl = 'http://127.0.0.1:8000';
  static const Duration apiTimeout = Duration(seconds: 15);
  // Add your Google Maps API key here. The map defaults to a generic info box if empty.
  static const String googleMapsApiKey = 'AIzaSyBAV27U-faqH6fQS5IFjlxL_nhpD_CCfDQ';
}
