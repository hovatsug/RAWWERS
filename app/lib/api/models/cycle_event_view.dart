/// CycleEventView
/// {
///     "properties": {
///         "id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Id"
///         },
///         "cycle_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Cycle Id"
///         },
///         "user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "User Id"
///         },
///         "event_type": {
///             "type": "string",
///             "title": "Event Type"
///         },
///         "points_delta": {
///             "type": "integer",
///             "title": "Points Delta"
///         },
///         "reference_type": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Reference Type"
///         },
///         "reference_id": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Reference Id"
///         },
///         "created_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Created At"
///         }
///     },
///     "type": "object",
///     "required": [
///         "id",
///         "cycle_id",
///         "user_id",
///         "event_type",
///         "points_delta",
///         "created_at"
///     ],
///     "title": "CycleEventView"
/// }
library cycle_event_view;

import 'exports.dart';
part 'cycle_event_view.freezed.dart';
part 'cycle_event_view.g.dart'; // CycleEventView

@freezed
abstract class CycleEventView with _$CycleEventView {
  const CycleEventView._();

  @jsonSerializable
  const factory CycleEventView({
    /// id
    @JsonKey(name: CycleEventView.idKey_) required String id,

    /// cycleId
    @JsonKey(name: CycleEventView.cycleIdKey_) required String cycleId,

    /// userId
    @JsonKey(name: CycleEventView.userIdKey_) required String userId,

    /// eventType
    @JsonKey(name: CycleEventView.eventTypeKey_) required String eventType,

    /// pointsDelta
    @JsonKey(name: CycleEventView.pointsDeltaKey_) required int pointsDelta,

    /// referenceType
    @JsonKey(name: CycleEventView.referenceTypeKey_) String? referenceType,

    /// referenceId
    @JsonKey(name: CycleEventView.referenceIdKey_) String? referenceId,

    /// createdAt
    @JsonKey(name: CycleEventView.createdAtKey_) required DateTime createdAt,
  }) = _CycleEventView;

  factory CycleEventView.fromJson(Map<String, dynamic> json) =>
      _$CycleEventViewFromJson(json);

  static const String idKey_ = r'id';

  static const String cycleIdKey_ = r'cycle_id';

  static const String userIdKey_ = r'user_id';

  static const String eventTypeKey_ = r'event_type';

  static const String pointsDeltaKey_ = r'points_delta';

  static const String referenceTypeKey_ = r'reference_type';

  static const String referenceIdKey_ = r'reference_id';

  static const String createdAtKey_ = r'created_at';
}
