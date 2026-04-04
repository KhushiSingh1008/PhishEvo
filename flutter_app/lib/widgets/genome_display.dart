import 'package:flutter/material.dart';

class GenomeDisplay extends StatelessWidget {
  final String genome;

  const GenomeDisplay({super.key, required this.genome});

  Color _getSymbolColor(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'B': return const Color(0xFFE53935);
      case 'N': return const Color(0xFFFF6F00);
      case 'T': return const Color(0xFFC62828);
      case 'C': return const Color(0xFF2E7D32);
      case 'M': return const Color(0xFFFF8F00);
      case 'D': return const Color(0xFFBF360C);
      case 'S': return const Color(0xFF00695C);
      case 'Z': return const Color(0xFF37474F);
      case 'Q': return const Color(0xFF6A1B9A);
      case 'X': return const Color(0xFF424242);
      case 'A': return const Color(0xFF1565C0);
      case 'F': return const Color(0xFF0277BD);
      case 'G': return const Color(0xFF00838F);
      case 'H': return const Color(0xFFE65100);
      default: return Colors.grey;
    }
  }

  String _getSymbolLabel(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'B': return 'Brand';
      case 'N': return 'NumSub';
      case 'T': return 'BadTLD';
      case 'C': return 'SafeTLD';
      case 'M': return 'MidPath';
      case 'D': return 'DeepPath';
      case 'S': return 'ShortPath';
      case 'Z': return 'NoPath';
      case 'Q': return 'HasParams';
      case 'X': return 'NoParams';
      case 'A': return 'NoDomain';
      case 'F': return 'SubDomain';
      case 'G': return 'DeepSub';
      case 'H': return 'HighEnt';
      default: return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (genome.isEmpty) {
      return const Text(
        'No genome data available',
        style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic),
      );
    }

    final List<String> characters = genome.split('');
    final Set<String> uniqueSymbols = characters.toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Genome Sequence',
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: characters.map((symbol) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _getSymbolColor(symbol),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          symbol.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getSymbolLabel(symbol),
                      style: const TextStyle(fontSize: 9, color: Colors.white54),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: uniqueSymbols.map((symbol) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getSymbolColor(symbol),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  _getSymbolLabel(symbol),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
