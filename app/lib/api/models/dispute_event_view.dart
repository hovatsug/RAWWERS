/// DisputeEventView
/// {
///     "properties": {
///         "id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Id"
///         },
///         "dispute_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Dispute Id"
///         },
///         "from_status": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "From Status"
///         },
///         "to_status": {
///             "type": "string",
///             "title": "To Status"
///         },
///         "actor_type": {
///             "type": "string",
///             "title": "Actor Type"
///         },
///         "actor_user_id": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "uuid"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Actor User Id"
///         },
///         "note": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Note"
///         },
///         "payload": {
///             "type": "object",
///             "title": "Payload"
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
///         "dispute_id",
///         "to_status",
///         "actor_type",
///         "created_at"
///     ],
///     "title": "DisputeEventView"
/// }
library dispute_event_view;

import 'exports.dart';
part 'dispute_event_view.freezed.dart';
part 'dispute_event_view.g.dart'; // DisputeEventView

@freezed
abstract class DisputeEventView with _$DisputeEventView {
  const DisputeEventView._();

  @jsonSerializable
  const factory DisputeEventView({
    /// id
    @JsonKey(name: DisputeEventView.idKey_) required String id,

    /// disputeId
    @JsonKey(name: DisputeEventView.disputeIdKey_) required String disputeId,

    /// fromStatus
    @JsonKey(name: DisputeEventView.fromStatusKey_) String? fromStatus,

    /// toStatus
    @JsonKey(name: DisputeEventView.toStatusKey_) required String toStatus,

    /// actorType
    @JsonKey(name: DisputeEventView.actorTypeKey_) required String actorType,

    /// actorUserId
    @JsonKey(name: DisputeEventView.actorUserIdKey_) String? actorUserId,

    /// note
    @JsonKey(name: DisputeEventView.noteKey_) String? note,

    /// payload
    @JsonKey(name: DisputeEventView.payloadKey_) Map<String, dynamic>? payload,

    /// createdAt
    @JsonKey(name: DisputeEventView.createdAtKey_) required DateTime createdAt,
  }) = _DisputeEventView;

  factory DisputeEventView.fromJson(Map<String, dynamic> json) =>
      _$DisputeEventViewFromJson(json);

  static const String idKey_ = r'id';

  static const String disputeIdKey_ = r'dispute_id';

  static const String fromStatusKey_ = r'from_status';

  static const String toStatusKey_ = r'to_status';

  static const String actorTypeKey_ = r'actor_type';

  static const String actorUserIdKey_ = r'actor_user_id';

  static const String noteKey_ = r'note';

  static const String payloadKey_ = r'payload';

  static const String createdAtKey_ = r'created_at';
}
