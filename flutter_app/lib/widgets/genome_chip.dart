import 'package:flutter/material.dart';

class GenomeChip extends StatelessWidget {
  final String character;

  const GenomeChip({super.key, required this.character});

  Color _getColor() {
    switch (character.toUpperCase()) {
      case 'B': return Colors.red;
      case 'N': return Colors.orange;
      case 'T': return Colors.yellow;
      case 'M': return Colors.blue;
      case 'Q': return Colors.purple;
      case 'S': return Colors.teal;
      case 'H': return Colors.pink;
      default: return Colors.grey;
    }
  }

  String _getTooltip() {
    switch (character.toUpperCase()) {
      case 'B': return 'Brand Impersonation';
      case 'N': return 'Number Substitution';
      case 'T': return 'Suspicious TLD';
      case 'M': return 'Deep Path';
      case 'Q': return 'Query Parameters';
      case 'S': return 'Subdomain Abuse';
      case 'H': return 'Hyphen Abuse';
      default: return 'Unknown Trait';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: _getTooltip(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: _getColor().withOpacity(0.2),
          border: Border.all(color: _getColor(), width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          character.toUpperCase(),
          style: TextStyle(
            color: _getColor(),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class GenomeRow extends StatelessWidget {
  final String genome;

  const GenomeRow({super.key, required this.genome});

  @override
  Widget build(BuildContext context) {
    if (genome.isEmpty) {
      return const Text('No genome data', style: TextStyle(color: Colors.white54));
    }
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: genome.split('').map((c) => GenomeChip(character: c)).toList(),
    );
  }
}
