// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pro_niche_skill_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProNicheSkillView _$ProNicheSkillViewFromJson(Map<String, dynamic> json) =>
    _ProNicheSkillView(
      nicheSlug: json['niche_slug'] as String,
      nicheName: json['niche_name'] as String,
      tier: SkillTier.fromJson(json['tier'] as String),
      score: (json['score'] as num?)?.toInt() ?? 0,
      verified: json['verified'] as bool? ?? false,
      gigsCompleted: (json['gigs_completed'] as num?)?.toInt() ?? 0,
      avgRating: (json['avg_rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      capabilityScore: (json['capability_score'] as num).toInt(),
      certificationScore: (json['certification_score'] as num).toInt(),
      confidence: (json['confidence'] as num).toDouble(),
      evidenceGigs: (json['evidence_gigs'] as num).toInt(),
      evidenceReviews: (json['evidence_reviews'] as num).toInt(),
      evidencePortfolio: (json['evidence_portfolio'] as num).toInt(),
      breakdown: json['breakdown'] as Map<String, dynamic>?,
      badges: (json['badges'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      lastPromotionAt: json['last_promotion_at'] == null
          ? null
          : DateTime.parse(json['last_promotion_at'] as String),
      lastDemotionAt: json['last_demotion_at'] == null
          ? null
          : DateTime.parse(json['last_demotion_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ProNicheSkillViewToJson(_ProNicheSkillView instance) =>
    <String, dynamic>{
      'niche_slug': instance.nicheSlug,
      'niche_name': instance.nicheName,
      'tier': instance.tier,
      'score': instance.score,
      'verified': instance.verified,
      'gigs_completed': instance.gigsCompleted,
      'avg_rating': instance.avgRating,
      'review_count': instance.reviewCount,
      'capability_score': instance.capabilityScore,
      'certification_score': instance.certificationScore,
      'confidence': instance.confidence,
      'evidence_gigs': instance.evidenceGigs,
      'evidence_reviews': instance.evidenceReviews,
      'evidence_portfolio': instance.evidencePortfolio,
      'breakdown': instance.breakdown,
      'badges': instance.badges,
      'last_promotion_at': instance.lastPromotionAt?.toIso8601String(),
      'last_demotion_at': instance.lastDemotionAt?.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
