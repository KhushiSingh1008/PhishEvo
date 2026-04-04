class CampaignFamily {
  final String id;
  final String familyName;
  final String referenceGenome;
  final String description;
  final int variantCount;

  CampaignFamily({
    required this.id,
    required this.familyName,
    required this.referenceGenome,
    required this.description,
    required this.variantCount,
  });

  factory CampaignFamily.fromJson(Map<String, dynamic> json) {
    return CampaignFamily(
      id: json['id'] ?? '',
      familyName: json['familyName'] ?? '',
      referenceGenome: json['referenceGenome'] ?? '',
      description: json['description'] ?? '',
      variantCount: json['variantCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'familyName': familyName,
      'referenceGenome': referenceGenome,
      'description': description,
      'variantCount': variantCount,
    };
  }
}
