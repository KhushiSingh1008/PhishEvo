import 'package:flutter/material.dart';

class GenomeDisplay extends StatelessWidget {
  final String genomeString;

  const GenomeDisplay({super.key, required this.genomeString});

  Color _getColorForSymbol(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'B':
      case 'T':
        return Colors.red;
      case 'N':
        return Colors.orange;
      case 'C':
        return Colors.green;
      case 'M':
      case 'D':
        return Colors.amber;
      case 'Q':
        return Colors.purple;
      case 'A':
      case 'F':
      case 'G':
        return Colors.blue;
      case 'H':
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }

  String _getTooltipForSymbol(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'B':
        return 'Brand spoofing';
      case 'T':
        return 'Typosquatting target';
      case 'N':
        return 'Numbers substituted';
      case 'C':
        return 'Clean / Standard character';
      case 'M':
        return 'Malicious payload indicator';
      case 'D':
        return 'Deceptive domain extension';
      case 'Q':
        return 'Obfuscated query parameter';
      case 'A':
        return 'Action keyword found';
      case 'F':
        return 'Free/gift lure';
      case 'G':
        return 'Generic structure';
      case 'H':
        return 'Hidden hyphenation';
      default:
        return 'Unknown genomic marker';
    }
  }

  void _showSymbolDetails(BuildContext context, String symbol) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: _getColorForSymbol(symbol),
              radius: 30,
              child: Text(
                symbol,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _getTooltipForSymbol(symbol),
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: genomeString.split('').map((symbol) {
        return GestureDetector(
          onTap: () => _showSymbolDetails(context, symbol),
          child: Tooltip(
            message: _getTooltipForSymbol(symbol),
            child: Chip(
              label: Text(
                symbol,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: _getColorForSymbol(symbol),
              padding: EdgeInsets.zero,
            ),
          ),
        );
      }).toList(),
    );
  }
}
