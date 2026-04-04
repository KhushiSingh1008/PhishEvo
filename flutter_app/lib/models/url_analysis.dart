class UrlAnalysis {
  final String id;
  final String rawUrl;
  final String genomeString;
  final String familyName;
  final double similarityScore;
  final List<Map<String, dynamic>> mutations;
  final String riskLevel;
  final DateTime analyzedAt;
  final String geminiReport;

  const UrlAnalysis({
    required this.id,
    required this.rawUrl,
    required this.genomeString,
    required this.familyName,
    required this.similarityScore,
    required this.mutations,
    required this.riskLevel,
    required this.analyzedAt,
    required this.geminiReport,
  });

  factory UrlAnalysis.fromJson(Map<String, dynamic> json) {
    return UrlAnalysis(
      id: json['id'] as String? ?? '',
      rawUrl: json['raw_url'] as String? ?? '',
      genomeString: json['genome'] as String? ?? '',
      familyName: json['family'] as String? ?? 'Unknown',
      similarityScore: (json['similarity'] ?? 0).toDouble(),
      mutations: List<Map<String, dynamic>>.from(
        (json['mutations'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map))
      ),
      riskLevel: _calculateRisk(json['similarity'] ?? 0),
      analyzedAt: DateTime.now(),
      geminiReport: json['gemini_report'] as String? ?? '',
    );
  }

  static String _calculateRisk(num score) {
    if (score >= 80) return 'DANGEROUS';
    if (score >= 50) return 'SUSPICIOUS';
    return 'SAFE';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'raw_url': rawUrl,
      'genome': genomeString,
      'family': familyName,
      'similarity': similarityScore,
      'mutations': mutations,
      'risk_level': riskLevel,
      'analyzed_at': analyzedAt.toIso8601String(),
      'gemini_report': geminiReport,
    };
  }

  UrlAnalysis copyWith({
    String? id,
    String? rawUrl,
    String? genomeString,
    String? familyName,
    double? similarityScore,
    List<Map<String, dynamic>>? mutations,
    String? riskLevel,
    DateTime? analyzedAt,
    String? geminiReport,
  }) {
    return UrlAnalysis(
      id: id ?? this.id,
      rawUrl: rawUrl ?? this.rawUrl,
      genomeString: genomeString ?? this.genomeString,
      familyName: familyName ?? this.familyName,
      similarityScore: similarityScore ?? this.similarityScore,
      mutations: mutations ?? this.mutations,
      riskLevel: riskLevel ?? this.riskLevel,
      analyzedAt: analyzedAt ?? this.analyzedAt,
      geminiReport: geminiReport ?? this.geminiReport,
    );
  }
}
