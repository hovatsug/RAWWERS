/// ProNicheSkillView
/// {
///     "properties": {
///         "niche_slug": {
///             "type": "string",
///             "title": "Niche Slug"
///         },
///         "niche_name": {
///             "type": "string",
///             "title": "Niche Name"
///         },
///         "tier": {
///             "$ref": "#/components/schemas/SkillTier"
///         },
///         "score": {
///             "type": "integer",
///             "default": 0,
///             "title": "Score"
///         },
///         "verified": {
///             "type": "boolean",
///             "default": false,
///             "title": "Verified"
///         },
///         "gigs_completed": {
///             "type": "integer",
///             "default": 0,
///             "title": "Gigs Completed"
///         },
///         "avg_rating": {
///             "type": "number",
///             "default": 0.0,
///             "title": "Avg Rating"
///         },
///         "review_count": {
///             "type": "integer",
///             "default": 0,
///             "title": "Review Count"
///         },
///         "capability_score": {
///             "type": "integer",
///             "title": "Capability Score"
///         },
///         "certification_score": {
///             "type": "integer",
///             "title": "Certification Score"
///         },
///         "confidence": {
///             "type": "number",
///             "title": "Confidence"
///         },
///         "evidence_gigs": {
///             "type": "integer",
///             "title": "Evidence Gigs"
///         },
///         "evidence_reviews": {
///             "type": "integer",
///             "title": "Evidence Reviews"
///         },
///         "evidence_portfolio": {
///             "type": "integer",
///             "title": "Evidence Portfolio"
///         },
///         "breakdown": {
///             "type": "object",
///             "title": "Breakdown"
///         },
///         "badges": {
///             "type": "array",
///             "items": {
///                 "type": "string"
///             },
///             "title": "Badges"
///         },
///         "last_promotion_at": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "date-time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Last Promotion At"
///         },
///         "last_demotion_at": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "date-time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Last Demotion At"
///         },
///         "updated_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Updated At"
///         }
///     },
///     "type": "object",
///     "required": [
///         "niche_slug",
///         "niche_name",
///         "tier",
///         "capability_score",
///         "certification_score",
///         "confidence",
///         "evidence_gigs",
///         "evidence_reviews",
///         "evidence_portfolio",
///         "updated_at"
///     ],
///     "title": "ProNicheSkillView"
/// }
library pro_niche_skill_view;

import 'exports.dart';
part 'pro_niche_skill_view.freezed.dart';
part 'pro_niche_skill_view.g.dart'; // ProNicheSkillView

@freezed
abstract class ProNicheSkillView with _$ProNicheSkillView {
  const ProNicheSkillView._();

  @jsonSerializable
  const factory ProNicheSkillView({
    /// nicheSlug
    @JsonKey(name: ProNicheSkillView.nicheSlugKey_) required String nicheSlug,

    /// nicheName
    @JsonKey(name: ProNicheSkillView.nicheNameKey_) required String nicheName,

    /// tier
    @JsonKey(name: ProNicheSkillView.tierKey_) required SkillTier tier,

    /// score
    @Default(0) @JsonKey(name: ProNicheSkillView.scoreKey_) int score,

    /// verified
    @Default(false)
    @JsonKey(name: ProNicheSkillView.verifiedKey_)
    bool verified,

    /// gigsCompleted
    @Default(0)
    @JsonKey(name: ProNicheSkillView.gigsCompletedKey_)
    int gigsCompleted,

    /// avgRating
    @Default(0.0)
    @JsonKey(name: ProNicheSkillView.avgRatingKey_)
    double avgRating,

    /// reviewCount
    @Default(0)
    @JsonKey(name: ProNicheSkillView.reviewCountKey_)
    int reviewCount,

    /// capabilityScore
    @JsonKey(name: ProNicheSkillView.capabilityScoreKey_)
    required int capabilityScore,

    /// certificationScore
    @JsonKey(name: ProNicheSkillView.certificationScoreKey_)
    required int certificationScore,

    /// confidence
    @JsonKey(name: ProNicheSkillView.confidenceKey_) required double confidence,

    /// evidenceGigs
    @JsonKey(name: ProNicheSkillView.evidenceGigsKey_)
    required int evidenceGigs,

    /// evidenceReviews
    @JsonKey(name: ProNicheSkillView.evidenceReviewsKey_)
    required int evidenceReviews,

    /// evidencePortfolio
    @JsonKey(name: ProNicheSkillView.evidencePortfolioKey_)
    required int evidencePortfolio,

    /// breakdown
    @JsonKey(name: ProNicheSkillView.breakdownKey_)
    Map<String, dynamic>? breakdown,

    /// badges
    @JsonKey(name: ProNicheSkillView.badgesKey_) List<String>? badges,

    /// lastPromotionAt
    @JsonKey(name: ProNicheSkillView.lastPromotionAtKey_)
    DateTime? lastPromotionAt,

    /// lastDemotionAt
    @JsonKey(name: ProNicheSkillView.lastDemotionAtKey_)
    DateTime? lastDemotionAt,

    /// updatedAt
    @JsonKey(name: ProNicheSkillView.updatedAtKey_) required DateTime updatedAt,
  }) = _ProNicheSkillView;

  factory ProNicheSkillView.fromJson(Map<String, dynamic> json) =>
      _$ProNicheSkillViewFromJson(json);

  static const String nicheSlugKey_ = r'niche_slug';

  static const String nicheNameKey_ = r'niche_name';

  static const String tierKey_ = r'tier';

  static const String scoreKey_ = r'score';

  static const String verifiedKey_ = r'verified';

  static const String gigsCompletedKey_ = r'gigs_completed';

  static const String avgRatingKey_ = r'avg_rating';

  static const String reviewCountKey_ = r'review_count';

  static const String capabilityScoreKey_ = r'capability_score';

  static const String certificationScoreKey_ = r'certification_score';

  static const String confidenceKey_ = r'confidence';

  static const String evidenceGigsKey_ = r'evidence_gigs';

  static const String evidenceReviewsKey_ = r'evidence_reviews';

  static const String evidencePortfolioKey_ = r'evidence_portfolio';

  static const String breakdownKey_ = r'breakdown';

  static const String badgesKey_ = r'badges';

  static const String lastPromotionAtKey_ = r'last_promotion_at';

  static const String lastDemotionAtKey_ = r'last_demotion_at';

  static const String updatedAtKey_ = r'updated_at';
}
