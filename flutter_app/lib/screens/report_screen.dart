import 'package:flutter/material.dart';
import '../models/url_analysis.dart';
import '../widgets/genome_chip.dart';
import '../services/api_service.dart';

class ReportScreen extends StatelessWidget {
  final UrlAnalysis analysis;

  const ReportScreen({super.key, required this.analysis});

  Color _getRiskColor() {
    final level = analysis.report?.threatLevel.toUpperCase() ?? 'UNKNOWN';
    switch (level) {
      case 'HIGH':
        return Colors.red;
      case 'MEDIUM':
        return Colors.orange;
      case 'LOW':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _addToBlocklist(BuildContext context) async {
    try {
      await ApiService.addToBlocklist(analysis.url);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('URL added to blocklist successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red.shade800),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final riskColor = _getRiskColor();
    final report = analysis.report;

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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(report?.threatLevel ?? 'UNKNOWN',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: riskColor)),
                        Text(analysis.url,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.white54)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Genome Sequence',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            GenomeRow(genome: analysis.genome),
            const SizedBox(height: 20),
            const Text('Campaign Match',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    analysis.campaignMatch,
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(analysis.confidence * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: analysis.confidence,
              backgroundColor: Colors.white10,
              color: Colors.deepPurple,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 20),
            if (report != null) ...[
              const Text('Summary',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child:
                      Text(report.summary, style: const TextStyle(height: 1.5)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Indicators of Compromise',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              if (report.indicators.isEmpty)
                const Text('No specific indicators extracted.',
                    style: TextStyle(color: Colors.white54))
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: report.indicators
                      .map((i) => Chip(
                            label:
                                Text(i, style: const TextStyle(fontSize: 12)),
                            backgroundColor: Colors.white10,
                          ))
                      .toList(),
                ),
              const SizedBox(height: 20),
              const Text('Recommended Actions',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              if (report.recommendedActions.isEmpty)
                const Text('Block this URL and report to your security team.',
                    style: TextStyle(color: Colors.white70, fontSize: 13))
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      report.recommendedActions.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle,
                              size: 18, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${entry.key + 1}. ${entry.value}',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 20),
              const Text('Campaign Context',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Card(
                color: Colors.deepPurple.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(report.campaignContext,
                      style: const TextStyle(height: 1.5)),
                ),
              ),
            ],
            const SizedBox(height: 20),
            const Text('Predicted Malicious Variants',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            if (analysis.predictedVariants.isEmpty)
              const Text('No variants predicted.',
                  style: TextStyle(color: Colors.white54))
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: analysis.predictedVariants.map((variant) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Genome: $variant',
                            style: const TextStyle(
                                fontFamily: 'monospace',
                                color: Colors.deepPurple)),
                        const SizedBox(height: 4),
                        GenomeRow(genome: variant),
                      ],
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _addToBlocklist(context),
                icon: const Icon(Icons.block),
                label: const Text('Add to Blocklist'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade900,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class ReportsListScreen extends StatefulWidget {
  final VoidCallback? onAnalyzeSelected;

  const ReportsListScreen({super.key, this.onAnalyzeSelected});

  @override
  State<ReportsListScreen> createState() => _ReportsListScreenState();
}

class _ReportsListScreenState extends State<ReportsListScreen> {
  List<UrlAnalysis> _analyses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final list = await ApiService.getAnalyses();
      if (mounted) {
        setState(() {
          _analyses = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error loading reports: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Reports'),
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _analyses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.article_outlined,
                          size: 64, color: Colors.white12),
                      const SizedBox(height: 16),
                      const Text('No analyses yet',
                          style:
                              TextStyle(color: Colors.white54, fontSize: 16)),
                      const Text('Analyze a URL to generate reports',
                          style:
                              TextStyle(color: Colors.white38, fontSize: 12)),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: widget.onAnalyzeSelected,
                        child: const Text('Analyze a URL'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _analyses.length,
                  itemBuilder: (context, index) {
                    final analysis = _analyses[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ReportScreen(analysis: analysis),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Family Name',
                                        style: TextStyle(
                                            color: Colors.white54,
                                            fontSize: 12)),
                                    Text(
                                      analysis.campaignMatch,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  analysis.report?.threatLevel ?? 'UNKNOWN',
                                  style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadHistory,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
