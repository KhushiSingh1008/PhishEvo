class Prediction {
  final String id;
  final String familyName;
  final String predictedGenome;
  final String predictedUrlPattern;
  final double confidenceScore;
  final DateTime createdAt;

  const Prediction({
    required this.id,
    required this.familyName,
    required this.predictedGenome,
    required this.predictedUrlPattern,
    required this.confidenceScore,
    required this.createdAt,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      id: json['id'] as String? ?? '',
      familyName: json['family_name'] as String? ?? 'Unknown',
      predictedGenome: json['predicted_genome'] as String? ?? '',
      predictedUrlPattern: json['predicted_url_pattern'] as String? ?? '',
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'family_name': familyName,
      'predicted_genome': predictedGenome,
      'predicted_url_pattern': predictedUrlPattern,
      'confidence_score': confidenceScore,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
