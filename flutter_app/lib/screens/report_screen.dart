import 'package:flutter/material.dart';
import '../models/url_analysis.dart';
import '../widgets/genome_display.dart';
import '../widgets/similarity_bar.dart';

class ReportScreen extends StatelessWidget {
  final UrlAnalysis analysis;
  const ReportScreen({super.key, required this.analysis});

  Color _getRiskColor() {
    switch (analysis.riskLevel.toUpperCase()) {
      case 'DANGEROUS': return Colors.red;
      case 'SUSPICIOUS': return Colors.amber;
      case 'SAFE': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final riskColor = _getRiskColor();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Threat Report'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: riskColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.shield, size: 40, color: riskColor),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(analysis.riskLevel, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: riskColor)),
                      Text(analysis.familyName, style: const TextStyle(fontSize: 14, color: Colors.white54)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Genome Sequence', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            GenomeDisplay(genome: analysis.genomeString),
            const SizedBox(height: 20),
            const Text('Family Match', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            SimilarityBar(score: analysis.similarityScore, familyName: analysis.familyName),
            const SizedBox(height: 20),
            const Text('Mutations Detected', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            if (analysis.mutations.isEmpty)
              const Text('No mutations from reference genome', style: TextStyle(color: Colors.white54))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: analysis.mutations.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final mutation = analysis.mutations[index];
                  final type = mutation['mutation_type'] ?? '';
                  IconData iconData = Icons.help_outline;
                  Color iconColor = Colors.grey;

                  if (type.toLowerCase().contains('substitution')) {
                    iconData = Icons.swap_horiz;
                    iconColor = Colors.orange;
                  } else if (type.toLowerCase().contains('insertion')) {
                    iconData = Icons.add_circle;
                    iconColor = Colors.green;
                  } else if (type.toLowerCase().contains('deletion')) {
                    iconData = Icons.remove_circle;
                    iconColor = Colors.red;
                  }

                  return ListTile(
                    leading: Icon(iconData, color: iconColor),
                    title: Text('Position ${mutation['position']}'),
                    subtitle: Text('${mutation['original']} \u2192 ${mutation['mutated']}'),
                    trailing: Chip(
                      label: Text(type),
                      backgroundColor: iconColor.withOpacity(0.15),
                    ),
                  );
                },
              ),
            const SizedBox(height: 20),
            const Text('Gemini Intelligence Report', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: analysis.geminiReport.isEmpty
                    ? const Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 12),
                            Text('Generating report...', style: TextStyle(color: Colors.white54)),
                          ],
                        ),
                      )
                    : SelectableText(
                        analysis.geminiReport,
                        style: const TextStyle(fontSize: 14, height: 1.6),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Analyzed URL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            SelectableText(
              analysis.rawUrl,
              style: const TextStyle(fontFamily: 'monospace', color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
