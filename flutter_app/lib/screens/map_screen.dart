import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  bool _showHeatmapInfo = false;

  @override
  void initState() {
    super.initState();
    _buildMarkers();
  }

  void _buildMarkers() {
    final Map<String, double> hues = {
      'PayPal': BitmapDescriptor.hueRed,
      'Amazon': BitmapDescriptor.hueOrange,
      'Banking': BitmapDescriptor.hueViolet,
      'Crypto': BitmapDescriptor.hueYellow,
      'Netflix': BitmapDescriptor.hueCyan,
    };

    final locations = [
      {'country': 'Russia', 'lat': 55.7558, 'lng': 37.6173, 'family': 'Banking-Fraud', 'count': 34, 'active': 'Today'},
      {'country': 'Nigeria', 'lat': 6.5244, 'lng': 3.3792, 'family': 'Amazon-Scam', 'count': 28, 'active': 'Today'},
      {'country': 'China', 'lat': 39.9042, 'lng': 116.4074, 'family': 'Crypto-Theft', 'count': 41, 'active': 'Today'},
      {'country': 'Romania', 'lat': 44.4268, 'lng': 26.1025, 'family': 'PayPal-Impersonation', 'count': 19, 'active': 'Yesterday'},
      {'country': 'Brazil', 'lat': -23.5505, 'lng': -46.6333, 'family': 'Netflix-Phish', 'count': 15, 'active': '2 days ago'},
      {'country': 'Ukraine', 'lat': 50.4501, 'lng': 30.5234, 'family': 'Banking-Fraud', 'count': 22, 'active': 'Today'},
      {'country': 'USA', 'lat': 40.0583, 'lng': -74.4057, 'family': 'PayPal-Impersonation', 'count': 31, 'active': 'Today'},
      {'country': 'Bangladesh', 'lat': 23.8103, 'lng': 90.4125, 'family': 'Amazon-Scam', 'count': 12, 'active': '3 days ago'},
      {'country': 'Indonesia', 'lat': -6.2088, 'lng': 106.8456, 'family': 'Crypto-Theft', 'count': 18, 'active': 'Today'},
      {'country': 'Ghana', 'lat': 5.6037, 'lng': -0.1870, 'family': 'Netflix-Phish', 'count': 9, 'active': 'Yesterday'},
    ];

    setState(() {
      _markers = locations.map((loc) {
        final familyName = loc['family'] as String;
        final baseFamily = familyName.split('-').first;
        final hue = hues[baseFamily] ?? BitmapDescriptor.hueRed;

        return Marker(
          markerId: MarkerId(loc['country'] as String),
          position: LatLng(loc['lat'] as double, loc['lng'] as double),
          icon: BitmapDescriptor.defaultMarkerWithHue(hue),
          infoWindow: InfoWindow(
            title: familyName,
            snippet: '${loc['country']} \u2022 ${loc['count']} variants \u2022 ${loc['active']}',
          ),
        );
      }).toSet();
    });
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white54)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Phishing Map'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => setState(() => _showHeatmapInfo = !_showHeatmapInfo),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(target: LatLng(20.0, 0.0), zoom: 2.0),
            markers: _markers,
            onMapCreated: (controller) => _mapController = controller,
            mapType: MapType.normal,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
          ),
          Positioned(
            bottom: 16, left: 16, right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Campaign Origins', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8, runSpacing: 4,
                      children: [
                        _legendDot(Colors.red, 'PayPal'),
                        _legendDot(Colors.orange, 'Amazon'),
                        _legendDot(Colors.purple, 'Banking'),
                        _legendDot(Colors.yellow, 'Crypto'),
                        _legendDot(Colors.cyan, 'Netflix'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_showHeatmapInfo)
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                color: Colors.black87,
                padding: const EdgeInsets.all(16),
                child: const Text(
                  '10 active campaign origins detected worldwide.\nTap any marker to see campaign details.',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
