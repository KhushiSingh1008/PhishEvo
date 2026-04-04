import 'package:flutter/material.dart';

class SimilarityBar extends StatelessWidget {
  final double score;
  final String familyName;
  const SimilarityBar({super.key, required this.score, required this.familyName});
  
  @override 
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(familyName, style: const TextStyle(color: Colors.white70)),
            Text('%', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: score / 100,
          backgroundColor: Colors.white10,
          color: score > 50 ? Colors.amber : Colors.green,
        ),
      ],
    );
  }
}
