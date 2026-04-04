import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/url_analysis.dart';
import '../services/api_service.dart';
import '../widgets/genome_display.dart';

class AnalyzeScreen extends StatefulWidget {
  const AnalyzeScreen({super.key});

  @override
  State<AnalyzeScreen> createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends State<AnalyzeScreen> {
  final TextEditingController _urlController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  UrlAnalysis? _result;

  Future<void> _analyze() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() {
      _isLoading = true;
      _result = null;
    });

    final res = await _apiService.analyzeUrl(url);

    setState(() {
      _isLoading = false;
      _result = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _urlController,
            decoration: InputDecoration(
              labelText: 'Enter URL',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.paste),
                onPressed: () async {
                  final data = await Clipboard.getData(Clipboard.kTextPlain);
                  if (data != null && data.text != null) {
                    _urlController.text = data.text!;
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _analyze,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Analyze', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 32),
          if (_result != null) _buildResultCard(),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _result!.familyName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(_result!.riskLevel),
                  backgroundColor:
                      _result!.riskLevel.toLowerCase() == 'dangerous'
                      ? Colors.red
                      : (_result!.riskLevel.toLowerCase() == 'suspicious'
                            ? Colors.amber
                            : Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Genome Sequence',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            GenomeDisplay(genomeString: _result!.genomeString),
            const SizedBox(height: 24),
            Text(
              'Similarity: \${_result!.similarityScore}%',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _result!.similarityScore / 100,
              backgroundColor: Colors.grey[800],
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 24),
            const Text(
              'Mutations',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            ..._result!.mutationMap.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text('\t• \${e.key}: \${e.value}'),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Navigate to report_screen (not yet implemented fully in this boilerplate)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Report screen routing...')),
                  );
                },
                child: const Text('View Full Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
