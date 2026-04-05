class AppConfig {
  // For Android Emulator use 10.0.2.2. For physical devices on same WiFi use PC's IP.
  static const String baseUrl = 'http://192.168.1.4:8080';
  static const Duration apiTimeout = Duration(seconds: 15);
  // Add your Google Maps API key here. The map defaults to a generic info box if empty.
  static const String googleMapsApiKey =
      'AIzaSyBAV27U-faqH6fQS5IFjlxL_nhpD_CCfDQ';
}
