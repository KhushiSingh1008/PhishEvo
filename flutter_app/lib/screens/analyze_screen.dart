import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../models/url_analysis.dart';
import '../widgets/genome_display.dart';
import '../widgets/similarity_bar.dart';
import '../widgets/threat_card.dart';
import 'report_screen.dart';

class AnalyzeScreen extends StatefulWidget {
  const AnalyzeScreen({super.key});

  @override
  State<AnalyzeScreen> createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends State<AnalyzeScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;
  UrlAnalysis? _result;
  String? _error;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _analyzeUrl() async {
    if (_urlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a URL')),
      );
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
    });
    try {
      final result = await ApiService.analyzeUrl(_urlController.text.trim());
      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _pasteFromClipboard() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _urlController.text = data!.text!;
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
                          hintText: 'https://suspicious-url.xyz/login',
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
                              label: Text(_isLoading ? 'Analyzing...' : 'Analyze Genome'),
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
                            onPressed: _pasteFromClipboard,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red))),
                    ],
                  ),
                ),
              ],
              if (_result != null) ...[
                const SizedBox(height: 24),
                const Text('Analysis Result', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ThreatCard(analysis: _result!),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.article),
                    label: const Text('View Full Gemini Report'),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ReportScreen(analysis: _result!)),
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
