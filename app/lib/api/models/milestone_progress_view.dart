/// MilestoneProgressView
/// {
///     "properties": {
///         "milestone_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Milestone Id"
///         },
///         "status": {
///             "$ref": "#/components/schemas/MilestoneProgressStatus"
///         },
///         "progress_value": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Progress Value"
///         },
///         "progress_meta": {
///             "type": "object",
///             "title": "Progress Meta"
///         },
///         "started_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Started At"
///         },
///         "completed_at": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "date-time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Completed At"
///         },
///         "last_evaluated_at": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "date-time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Last Evaluated At"
///         },
///         "completions_count": {
///             "type": "integer",
///             "default": 0,
///             "title": "Completions Count"
///         },
///         "last_completed_at": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "date-time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Last Completed At"
///         }
///     },
///     "type": "object",
///     "required": [
///         "milestone_id",
///         "status",
///         "progress_value",
///         "started_at"
///     ],
///     "title": "MilestoneProgressView"
/// }
library milestone_progress_view;

import 'exports.dart';
part 'milestone_progress_view.freezed.dart';
part 'milestone_progress_view.g.dart'; // MilestoneProgressView

@freezed
abstract class MilestoneProgressView with _$MilestoneProgressView {
  const MilestoneProgressView._();

  @jsonSerializable
  const factory MilestoneProgressView({
    /// milestoneId
    @JsonKey(name: MilestoneProgressView.milestoneIdKey_)
    required String milestoneId,

    /// status
    @JsonKey(name: MilestoneProgressView.statusKey_)
    required MilestoneProgressStatus status,

    /// progressValue
    @JsonKey(name: MilestoneProgressView.progressValueKey_)
    required String progressValue,

    /// progressMeta
    @JsonKey(name: MilestoneProgressView.progressMetaKey_)
    Map<String, dynamic>? progressMeta,

    /// startedAt
    @JsonKey(name: MilestoneProgressView.startedAtKey_)
    required DateTime startedAt,

    /// completedAt
    @JsonKey(name: MilestoneProgressView.completedAtKey_) DateTime? completedAt,

    /// lastEvaluatedAt
    @JsonKey(name: MilestoneProgressView.lastEvaluatedAtKey_)
    DateTime? lastEvaluatedAt,

    /// completionsCount
    @Default(0)
    @JsonKey(name: MilestoneProgressView.completionsCountKey_)
    int completionsCount,

    /// lastCompletedAt
    @JsonKey(name: MilestoneProgressView.lastCompletedAtKey_)
    DateTime? lastCompletedAt,
  }) = _MilestoneProgressView;

  factory MilestoneProgressView.fromJson(Map<String, dynamic> json) =>
      _$MilestoneProgressViewFromJson(json);

  static const String milestoneIdKey_ = r'milestone_id';

  static const String statusKey_ = r'status';

  static const String progressValueKey_ = r'progress_value';

  static const String progressMetaKey_ = r'progress_meta';

  static const String startedAtKey_ = r'started_at';

  static const String completedAtKey_ = r'completed_at';

  static const String lastEvaluatedAtKey_ = r'last_evaluated_at';

  static const String completionsCountKey_ = r'completions_count';

  static const String lastCompletedAtKey_ = r'last_completed_at';
}
