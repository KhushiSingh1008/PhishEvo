import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../config/app_config.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (AppConfig.googleMapsApiKey.trim().isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Global Phishing Map'),
          backgroundColor: Colors.transparent,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Card(
              color: Colors.orange.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.orange, width: 1.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.map_outlined, size: 64, color: Colors.orange),
                    SizedBox(height: 16),
                    Text(
                      'Google Maps API key not configured',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Add it to app_config.dart to enable geospatial threat mapping.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Phishing Map'),
        backgroundColor: Colors.transparent,
      ),
      body: const GoogleMap(
        initialCameraPosition: CameraPosition(target: LatLng(0, 0), zoom: 2),
        myLocationButtonEnabled: false,
        zoomControlsEnabled: true,
      ),
    );
  }
}
