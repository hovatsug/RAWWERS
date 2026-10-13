/// NicheSkillOverrideView
/// {
///     "properties": {
///         "tier": {
///             "anyOf": [
///                 {
///                     "$ref": "#/components/schemas/SkillTier"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ]
///         },
///         "score": {
///             "anyOf": [
///                 {
///                     "type": "integer"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Score"
///         },
///         "verified": {
///             "anyOf": [
///                 {
///                     "type": "boolean"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Verified"
///         },
///         "by": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "uuid"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "By"
///         },
///         "at": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "date-time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "At"
///         },
///         "reason": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Reason"
///         }
///     },
///     "type": "object",
///     "title": "NicheSkillOverrideView"
/// }
library niche_skill_override_view;

import 'exports.dart';
part 'niche_skill_override_view.freezed.dart';
part 'niche_skill_override_view.g.dart'; // NicheSkillOverrideView

@freezed
abstract class NicheSkillOverrideView with _$NicheSkillOverrideView {
  const NicheSkillOverrideView._();

  @jsonSerializable
  const factory NicheSkillOverrideView({
    /// tier
    @JsonKey(name: NicheSkillOverrideView.tierKey_) SkillTier? tier,

    /// score
    @JsonKey(name: NicheSkillOverrideView.scoreKey_) int? score,

    /// verified
    @JsonKey(name: NicheSkillOverrideView.verifiedKey_) bool? verified,

    /// by
    @JsonKey(name: NicheSkillOverrideView.byKey_) String? by,

    /// at
    @JsonKey(name: NicheSkillOverrideView.atKey_) DateTime? at,

    /// reason
    @JsonKey(name: NicheSkillOverrideView.reasonKey_) String? reason,
  }) = _NicheSkillOverrideView;

  factory NicheSkillOverrideView.fromJson(Map<String, dynamic> json) =>
      _$NicheSkillOverrideViewFromJson(json);

  static const String tierKey_ = r'tier';

  static const String scoreKey_ = r'score';

  static const String verifiedKey_ = r'verified';

  static const String byKey_ = r'by';

  static const String atKey_ = r'at';

  static const String reasonKey_ = r'reason';
}
