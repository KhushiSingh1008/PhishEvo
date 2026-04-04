class Prediction {
  final String id;
  final String familyName;
  final String predictedGenome;
  final String predictedUrlPattern;
  final double confidenceScore;
  final DateTime createdAt;

  Prediction({
    required this.id,
    required this.familyName,
    required this.predictedGenome,
    required this.predictedUrlPattern,
    required this.confidenceScore,
    required this.createdAt,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      id: json['id'] ?? '',
      familyName: json['familyName'] ?? '',
      predictedGenome: json['predictedGenome'] ?? '',
      predictedUrlPattern: json['predictedUrlPattern'] ?? '',
      confidenceScore: (json['confidenceScore'] ?? 0.0).toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'familyName': familyName,
      'predictedGenome': predictedGenome,
      'predictedUrlPattern': predictedUrlPattern,
      'confidenceScore': confidenceScore,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
