import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../config/app_config.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  void _buildMarkers() {
    final Set<Marker> markers = {};

    final locations = [
      {
        'lat': 55.7558,
        'lng': 37.6173,
        'city': 'Moscow',
        'country': 'Russia',
        'family': 'Banking-Fraud',
        'variants': 34,
        'hue': BitmapDescriptor.hueViolet
      },
      {
        'lat': 6.5244,
        'lng': 3.3792,
        'city': 'Lagos',
        'country': 'Nigeria',
        'family': 'Amazon-Scam',
        'variants': 28,
        'hue': BitmapDescriptor.hueOrange
      },
      {
        'lat': 39.9042,
        'lng': 116.4074,
        'city': 'Beijing',
        'country': 'China',
        'family': 'Crypto-Theft',
        'variants': 41,
        'hue': BitmapDescriptor.hueYellow
      },
      {
        'lat': 44.4268,
        'lng': 26.1025,
        'city': 'Bucharest',
        'country': 'Romania',
        'family': 'PayPal-Impersonation',
        'variants': 19,
        'hue': BitmapDescriptor.hueRed
      },
      {
        'lat': -23.5505,
        'lng': -46.6333,
        'city': 'Sao Paulo',
        'country': 'Brazil',
        'family': 'Netflix-Phish',
        'variants': 15,
        'hue': BitmapDescriptor.hueCyan
      },
      {
        'lat': 50.4501,
        'lng': 30.5234,
        'city': 'Kyiv',
        'country': 'Ukraine',
        'family': 'Banking-Fraud',
        'variants': 22,
        'hue': BitmapDescriptor.hueViolet
      },
      {
        'lat': 40.0583,
        'lng': -74.4057,
        'city': 'New Jersey',
        'country': 'USA',
        'family': 'PayPal-Impersonation',
        'variants': 31,
        'hue': BitmapDescriptor.hueRed
      },
      {
        'lat': 23.8103,
        'lng': 90.4125,
        'city': 'Dhaka',
        'country': 'Bangladesh',
        'family': 'Amazon-Scam',
        'variants': 12,
        'hue': BitmapDescriptor.hueOrange
      },
      {
        'lat': -6.2088,
        'lng': 106.8456,
        'city': 'Jakarta',
        'country': 'Indonesia',
        'family': 'Crypto-Theft',
        'variants': 18,
        'hue': BitmapDescriptor.hueYellow
      },
      {
        'lat': 5.6037,
        'lng': -0.1870,
        'city': 'Accra',
        'country': 'Ghana',
        'family': 'Netflix-Phish',
        'variants': 9,
        'hue': BitmapDescriptor.hueCyan
      },
    ];

    for (final loc in locations) {
      markers.add(Marker(
        markerId: MarkerId(loc['city'] as String),
        position: LatLng(loc['lat'] as double, loc['lng'] as double),
        icon: BitmapDescriptor.defaultMarkerWithHue(loc['hue'] as double),
        infoWindow: InfoWindow(
          title: '${loc['city']}, ${loc['country']}',
          snippet: '${loc['family']} • ${loc['variants']} variants',
        ),
      ));
    }

    if (mounted) {
      setState(() {
        _markers = markers;
      });
    }
  }

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
              child: const Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.map_outlined, size: 64, color: Colors.orange),
                    SizedBox(height: 16),
                    Text(
                      'Google Maps API key not configured',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange),
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
      body: GoogleMap(
        initialCameraPosition:
            const CameraPosition(target: LatLng(0, 0), zoom: 2),
        myLocationButtonEnabled: false,
        zoomControlsEnabled: true,
        markers: _markers,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
          _buildMarkers();
        },
      ),
    );
  }
}
