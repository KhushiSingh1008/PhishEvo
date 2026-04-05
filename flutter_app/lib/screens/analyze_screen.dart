import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../models/url_analysis.dart';
import '../widgets/genome_chip.dart';
import 'report_screen.dart';
import 'lineage_screen.dart';

class AnalyzeScreen extends StatefulWidget {
  const AnalyzeScreen({super.key});

  @override
  State<AnalyzeScreen> createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends State<AnalyzeScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;
  UrlAnalysis? _result;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _analyzeUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid URL to scan')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final analysis = await ApiService.analyzeUrl(url);
      if (mounted) {
        setState(() {
          _result = analysis;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    }
  }

  Color _getBadgeColor(String level) {
    switch (level.toUpperCase()) {
      case 'HIGH': return Colors.red;
      case 'MEDIUM': return Colors.orange;
      case 'LOW': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text('URL Genome Analyzer', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const Text('Paste any URL to detect phishing campaign family', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _urlController,
                        maxLines: 2,
                        style: const TextStyle(fontFamily: 'monospace'),
                        decoration: InputDecoration(
                          hintText: 'Enter suspicious URL...',
                          prefixIcon: const Icon(Icons.link, color: Colors.deepPurple),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _analyzeUrl,
                              icon: _isLoading 
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                                : const Icon(Icons.biotech),
                              label: Text(_isLoading ? 'Scanning...' : 'Scan URL'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                minimumSize: const Size.fromHeight(48),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.paste),
                            tooltip: 'Paste from clipboard',
                            onPressed: () async {
                              ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
                              if (data?.text != null) _urlController.text = data!.text!;
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (_result != null) ...[
                const SizedBox(height: 24),
                const Text('Analysis Result', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Mapped Genome', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getBadgeColor(_result!.report?.threatLevel ?? 'UNKNOWN').withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: _getBadgeColor(_result!.report?.threatLevel ?? 'UNKNOWN')),
                              ),
                              child: Text(
                                _result!.report?.threatLevel ?? 'UNKNOWN',
                                style: TextStyle(
                                  color: _getBadgeColor(_result!.report?.threatLevel ?? 'UNKNOWN'),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        GenomeRow(genome: _result!.genome),
                        const SizedBox(height: 24),
                        const Text('Campaign Match', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: Text(_result!.campaignMatch, style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold))),
                            Text('\${(_result!.confidence * 100).toStringAsFixed(1)}%'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: _result!.confidence,
                          backgroundColor: Colors.white10,
                          color: Colors.deepPurple,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.article),
                                label: const Text('View Full Report'),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => ReportScreen(analysis: _result!)),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton.icon(
                                icon: const Icon(Icons.account_tree),
                                label: const Text('View Lineage'),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const LineageScreen()),
                                  );
                                },
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
              if (_result == null && !_isLoading) ...[
                const SizedBox(height: 60),
                const Center(
                  child: Column(
                    children: [
                      Icon(Icons.biotech_outlined, size: 64, color: Colors.white54),
                      SizedBox(height: 16),
                      Text('Enter a URL above to begin analysis', style: TextStyle(color: Colors.white54)),
                      SizedBox(height: 8),
                      Text(
                        'The genome encoder will map the URL structure\nto a comparable DNA-like sequence', 
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
