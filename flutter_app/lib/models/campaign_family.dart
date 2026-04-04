class CampaignFamily {
  final String id;
  final String familyName;
  final String referenceGenome;
  final String description;
  final int variantCount;

  const CampaignFamily({
    required this.id,
    required this.familyName,
    required this.referenceGenome,
    required this.description,
    required this.variantCount,
  });

  factory CampaignFamily.fromJson(Map<String, dynamic> json) {
    return CampaignFamily(
      id: json['id'] as String? ?? '',
      familyName: json['family_name'] as String? ?? 'Unknown',
      referenceGenome: json['reference_genome'] as String? ?? '',
      description: json['description'] as String? ?? '',
      variantCount: (json['variant_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'family_name': familyName,
      'reference_genome': referenceGenome,
      'description': description,
      'variant_count': variantCount,
    };
  }
}
