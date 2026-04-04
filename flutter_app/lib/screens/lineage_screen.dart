import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/campaign_family.dart';
import '../widgets/genome_display.dart';

class LineageScreen extends StatefulWidget {
  const LineageScreen({super.key});

  @override
  State<LineageScreen> createState() => _LineageScreenState();
}

class _LineageScreenState extends State<LineageScreen> {
  List<CampaignFamily> _families = [];
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadFamilies();
  }

  Future<void> _loadFamilies() async {
    setState(() => _isLoading = true);
    final families = await ApiService.getFamilies();
    setState(() {
      _families = families;
      _isLoading = false;
    });
  }

  Widget _statBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepPurple)),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildEvolutionTimeline(int familyIndex) {
    // Hardcodec 4-step timeline showing mock evolution
    final mocks = [
      {"gen": "1", "genome": "BCSMX", "desc": "Original campaign"},
      {"gen": "2", "genome": "BNTMX", "desc": "TLD mutation detected"},
      {"gen": "3", "genome": "BNTMQ", "desc": "Added query params"},
      {"gen": "4", "genome": "BNTDQ", "desc": "Deeper path structure"},
    ];

    return Column(
      children: mocks.map((mock) {
        final isLast = mocks.last == mock;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(color: Colors.deepPurple, shape: BoxShape.circle),
                  child: Center(child: Text(mock["gen"]!, style: const TextStyle(fontWeight: FontWeight.bold))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Generation ${mock["gen"]}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(mock["genome"]!, style: const TextStyle(fontFamily: 'monospace', color: Colors.deepPurple, fontSize: 13)),
                      Text(mock["desc"]!, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            if (!isLast)
              Container(
                height: 30,
                width: 2,
                color: Colors.deepPurple,
                margin: const EdgeInsets.only(left: 14),
              ),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Campaign Lineage', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const Text('Known phishing family evolution trees', style: TextStyle(color: Colors.white54, fontSize: 13)),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_families.isEmpty)
                      const Center(child: Text('No families loaded. Is backend running?', style: TextStyle(color: Colors.white54)))
                    else ...[
                      SizedBox(
                        height: 44,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _families.length,
                          itemBuilder: (context, index) {
                            final family = _families[index];
                            final isSelected = index == _selectedIndex;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedIndex = index),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.deepPurple : Colors.white10,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    family.familyName,
                                    style: TextStyle(color: isSelected ? Colors.white : Colors.white54, fontSize: 13),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_families.isNotEmpty) ...[
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.deepPurple,
                                      child: Text(_families[_selectedIndex].familyName.isNotEmpty ? _families[_selectedIndex].familyName[0] : '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(_families[_selectedIndex].familyName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        Text(_families[_selectedIndex].description, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Text('Reference Genome', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 8),
                                GenomeDisplay(genome: _families[_selectedIndex].referenceGenome),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    _statBox('Variants', _families[_selectedIndex].variantCount.toString()),
                                    const SizedBox(width: 12),
                                    _statBox('Risk Level', 'HIGH'),
                                    const SizedBox(width: 12),
                                    _statBox('Active', 'Yes'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text('Evolution Timeline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 12),
                        _buildEvolutionTimeline(_selectedIndex),
                      ],
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
