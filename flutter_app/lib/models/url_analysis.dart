class UrlAnalysis {
  final String id;
  final String rawUrl;
  final String genomeString;
  final String familyName;
  final double similarityScore;
  final Map<String, dynamic> mutationMap;
  final String riskLevel;
  final DateTime analyzedAt;
  final String geminiReport;

  UrlAnalysis({
    required this.id,
    required this.rawUrl,
    required this.genomeString,
    required this.familyName,
    required this.similarityScore,
    required this.mutationMap,
    required this.riskLevel,
    required this.analyzedAt,
    required this.geminiReport,
  });

  factory UrlAnalysis.fromJson(Map<String, dynamic> json) {
    return UrlAnalysis(
      id: json['id'] ?? '',
      rawUrl: json['rawUrl'] ?? '',
      genomeString: json['genomeString'] ?? '',
      familyName: json['familyName'] ?? 'Unknown',
      similarityScore: (json['similarityScore'] ?? 0.0).toDouble(),
      mutationMap: Map<String, dynamic>.from(json['mutationMap'] ?? {}),
      riskLevel: json['riskLevel'] ?? 'Unknown',
      analyzedAt: json['analyzedAt'] != null
          ? DateTime.parse(json['analyzedAt'])
          : DateTime.now(),
      geminiReport: json['geminiReport'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rawUrl': rawUrl,
      'genomeString': genomeString,
      'familyName': familyName,
      'similarityScore': similarityScore,
      'mutationMap': mutationMap,
      'riskLevel': riskLevel,
      'analyzedAt': analyzedAt.toIso8601String(),
      'geminiReport': geminiReport,
    };
  }
}
