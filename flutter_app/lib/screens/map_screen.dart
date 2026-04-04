import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;

  static const LatLng _center = LatLng(20.0, 0.0);

  final Set<Marker> _markers = {
    const Marker(
      markerId: MarkerId('US'),
      position: LatLng(37.0902, -95.7129),
      infoWindow: InfoWindow(
        title: 'AitM Proxy Campaign',
        snippet: 'Known variants: 142\nActive: Today',
      ),
    ),
    const Marker(
      markerId: MarkerId('RU'),
      position: LatLng(61.5240, 105.3188),
      infoWindow: InfoWindow(
        title: 'Evilginx Setup',
        snippet: 'Known variants: 89\nActive: Yesterday',
      ),
    ),
    const Marker(
      markerId: MarkerId('NG'),
      position: LatLng(9.0820, 8.6753),
      infoWindow: InfoWindow(
        title: 'Advance Fee Fraud URL',
        snippet: 'Known variants: 210\nActive: 2 days ago',
      ),
    ),
    const Marker(
      markerId: MarkerId('CN'),
      position: LatLng(35.8617, 104.1954),
      infoWindow: InfoWindow(
        title: 'E-commerce Clone',
        snippet: 'Known variants: 312\nActive: Today',
      ),
    ),
    const Marker(
      markerId: MarkerId('UA'),
      position: LatLng(48.3794, 31.1656),
      infoWindow: InfoWindow(
        title: 'Banking Trojan Drop',
        snippet: 'Known variants: 45\nActive: 5 days ago',
      ),
    ),
  };

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    // We would apply a custom dark theme map style here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: _center,
              zoom: 2.0,
            ),
            markers: _markers,
          ),
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Heatmap toggled!')),
                );
              },
              child: const Icon(Icons.map),
            ),
          ),
        ],
      ),
    );
  }
}
