/// MilestoneView
/// {
///     "properties": {
///         "id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Id"
///         },
///         "code": {
///             "type": "string",
///             "title": "Code"
///         },
///         "name": {
///             "type": "string",
///             "title": "Name"
///         },
///         "description": {
///             "type": "string",
///             "title": "Description"
///         },
///         "name_key": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Name Key"
///         },
///         "description_key": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Description Key"
///         },
///         "scope": {
///             "$ref": "#/components/schemas/MilestoneScope"
///         },
///         "niche_id": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "uuid"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Niche Id"
///         },
///         "difficulty": {
///             "$ref": "#/components/schemas/MilestoneDifficulty"
///         },
///         "audience": {
///             "$ref": "#/components/schemas/MilestoneAudience"
///         },
///         "is_repeatable": {
///             "type": "boolean",
///             "title": "Is Repeatable"
///         },
///         "cooldown_days": {
///             "anyOf": [
///                 {
///                     "type": "integer"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Cooldown Days"
///         },
///         "start_at": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "date-time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Start At"
///         },
///         "end_at": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "date-time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "End At"
///         },
///         "criteria": {
///             "type": "object",
///             "title": "Criteria"
///         },
///         "reward_rule_code": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Reward Rule Code"
///         },
///         "is_active": {
///             "type": "boolean",
///             "title": "Is Active"
///         },
///         "created_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Created At"
///         },
///         "updated_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Updated At"
///         }
///     },
///     "type": "object",
///     "required": [
///         "id",
///         "code",
///         "name",
///         "description",
///         "scope",
///         "difficulty",
///         "audience",
///         "is_repeatable",
///         "is_active",
///         "created_at",
///         "updated_at"
///     ],
///     "title": "MilestoneView"
/// }
library milestone_view;

import 'exports.dart';
part 'milestone_view.freezed.dart';
part 'milestone_view.g.dart'; // MilestoneView

@freezed
abstract class MilestoneView with _$MilestoneView {
  const MilestoneView._();

  @jsonSerializable
  const factory MilestoneView({
    /// id
    @JsonKey(name: MilestoneView.idKey_) required String id,

    /// code
    @JsonKey(name: MilestoneView.codeKey_) required String code,

    /// name
    @JsonKey(name: MilestoneView.nameKey_) required String name,

    /// description
    @JsonKey(name: MilestoneView.descriptionKey_) required String description,

    /// nameKey
    @JsonKey(name: MilestoneView.nameKeyKey_) String? nameKey,

    /// descriptionKey
    @JsonKey(name: MilestoneView.descriptionKeyKey_) String? descriptionKey,

    /// scope
    @JsonKey(name: MilestoneView.scopeKey_) required MilestoneScope scope,

    /// nicheId
    @JsonKey(name: MilestoneView.nicheIdKey_) String? nicheId,

    /// difficulty
    @JsonKey(name: MilestoneView.difficultyKey_)
    required MilestoneDifficulty difficulty,

    /// audience
    @JsonKey(name: MilestoneView.audienceKey_)
    required MilestoneAudience audience,

    /// isRepeatable
    @JsonKey(name: MilestoneView.isRepeatableKey_) required bool isRepeatable,

    /// cooldownDays
    @JsonKey(name: MilestoneView.cooldownDaysKey_) int? cooldownDays,

    /// startAt
    @JsonKey(name: MilestoneView.startAtKey_) DateTime? startAt,

    /// endAt
    @JsonKey(name: MilestoneView.endAtKey_) DateTime? endAt,

    /// criteria
    @JsonKey(name: MilestoneView.criteriaKey_) Map<String, dynamic>? criteria,

    /// rewardRuleCode
    @JsonKey(name: MilestoneView.rewardRuleCodeKey_) String? rewardRuleCode,

    /// isActive
    @JsonKey(name: MilestoneView.isActiveKey_) required bool isActive,

    /// createdAt
    @JsonKey(name: MilestoneView.createdAtKey_) required DateTime createdAt,

    /// updatedAt
    @JsonKey(name: MilestoneView.updatedAtKey_) required DateTime updatedAt,
  }) = _MilestoneView;

  factory MilestoneView.fromJson(Map<String, dynamic> json) =>
      _$MilestoneViewFromJson(json);

  static const String idKey_ = r'id';

  static const String codeKey_ = r'code';

  static const String nameKey_ = r'name';

  static const String descriptionKey_ = r'description';

  static const String nameKeyKey_ = r'name_key';

  static const String descriptionKeyKey_ = r'description_key';

  static const String scopeKey_ = r'scope';

  static const String nicheIdKey_ = r'niche_id';

  static const String difficultyKey_ = r'difficulty';

  static const String audienceKey_ = r'audience';

  static const String isRepeatableKey_ = r'is_repeatable';

  static const String cooldownDaysKey_ = r'cooldown_days';

  static const String startAtKey_ = r'start_at';

  static const String endAtKey_ = r'end_at';

  static const String criteriaKey_ = r'criteria';

  static const String rewardRuleCodeKey_ = r'reward_rule_code';

  static const String isActiveKey_ = r'is_active';

  static const String createdAtKey_ = r'created_at';

  static const String updatedAtKey_ = r'updated_at';
}
