class ThreatReport {
  final String threatLevel;
  final String summary;
  final List<String> indicators;
  final List<String> recommendedActions;
  final String campaignContext;

  ThreatReport({
    required this.threatLevel,
    required this.summary,
    required this.indicators,
    required this.recommendedActions,
    required this.campaignContext,
  });

  factory ThreatReport.fromJson(Map<String, dynamic> json) {
    return ThreatReport(
      threatLevel: json['threat_level'] ?? 'UNKNOWN',
      summary: json['summary'] ?? 'No summary available.',
      indicators: List<String>.from(json['indicators'] ?? []),
      recommendedActions: List<String>.from(json['recommended_actions'] ??
          ['Block URL immediately', 'Report to security team']),
      campaignContext: json['campaign_context'] ?? 'No context available.',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'threat_level': threatLevel,
      'summary': summary,
      'indicators': indicators,
      'recommended_actions': recommendedActions,
      'campaign_context': campaignContext,
    };
  }
}

class UrlAnalysis {
  final String url;
  final String genome;
  final String campaignMatch;
  final double confidence;
  final List<String> predictedVariants;
  final ThreatReport? report;

  static String _calculateRisk(double score) {
    if (score >= 70) return 'DANGEROUS';
    if (score >= 40) return 'SUSPICIOUS';
    if (score >= 15) return 'MEDIUM';
    return 'SAFE';
  }

  UrlAnalysis({
    required this.url,
    required this.genome,
    required this.campaignMatch,
    required this.confidence,
    required this.predictedVariants,
    this.report,
  });

  factory UrlAnalysis.fromJson(Map<String, dynamic> json) {
    final double similarity = (json['confidence'] ??
            json['similarity_score'] ??
            json['similarity'] ??
            0.0)
        .toDouble();
    return UrlAnalysis(
      url: json['url'] ?? json['raw_url'] ?? '',
      genome: json['genome'] ?? json['genome_string'] ?? '',
      campaignMatch: json['campaign_match'] ?? json['family_name'] ?? 'Unknown',
      confidence: similarity,
      predictedVariants: List<String>.from(
          json['predicted_variants'] ?? json['predictions'] ?? []),
      report: json['report'] != null
          ? ThreatReport.fromJson(json['report'])
          : ThreatReport.fromJson({
              'threat_level':
                  json['risk_level'] ?? _calculateRisk(similarity * 100),
              'summary': json['gemini_report'] ?? 'Summary pending.',
              'recommended_actions': json['recommended_actions']
            }),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'genome': genome,
      'campaign_match': campaignMatch,
      'confidence': confidence,
      'predicted_variants': predictedVariants,
      if (report != null) 'report': report!.toJson(),
    };
  }
}
