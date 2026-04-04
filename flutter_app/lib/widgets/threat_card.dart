import 'package:flutter/material.dart';
import '../models/url_analysis.dart';

class ThreatCard extends StatelessWidget {
  final UrlAnalysis analysis;
  const ThreatCard({super.key, required this.analysis});
  
  @override 
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Family Name', style: TextStyle(color: Colors.white54, fontSize: 12)),
              Text(analysis.familyName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(analysis.riskLevel, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
