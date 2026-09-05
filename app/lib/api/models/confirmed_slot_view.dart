/// ConfirmedSlotView
/// {
///     "properties": {
///         "id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Id"
///         },
///         "gig_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Gig Id"
///         },
///         "pro_user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Pro User Id"
///         },
///         "client_user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Client User Id"
///         },
///         "start_at_utc": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Start At Utc"
///         },
///         "end_at_utc": {
///             "type": "string",
///             "format": "date-time",
///             "title": "End At Utc"
///         },
///         "status": {
///             "$ref": "#/components/schemas/ConfirmedSlotStatus"
///         },
///         "cancellation_reason": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Cancellation Reason"
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
///         "gig_id",
///         "pro_user_id",
///         "client_user_id",
///         "start_at_utc",
///         "end_at_utc",
///         "status",
///         "created_at",
///         "updated_at"
///     ],
///     "title": "ConfirmedSlotView"
/// }
library confirmed_slot_view;

import 'exports.dart';
part 'confirmed_slot_view.freezed.dart';
part 'confirmed_slot_view.g.dart'; // ConfirmedSlotView

@freezed
abstract class ConfirmedSlotView with _$ConfirmedSlotView {
  const ConfirmedSlotView._();

  @jsonSerializable
  const factory ConfirmedSlotView({
    /// id
    @JsonKey(name: ConfirmedSlotView.idKey_) required String id,

    /// gigId
    @JsonKey(name: ConfirmedSlotView.gigIdKey_) required String gigId,

    /// proUserId
    @JsonKey(name: ConfirmedSlotView.proUserIdKey_) required String proUserId,

    /// clientUserId
    @JsonKey(name: ConfirmedSlotView.clientUserIdKey_)
    required String clientUserId,

    /// startAtUtc
    @JsonKey(name: ConfirmedSlotView.startAtUtcKey_)
    required DateTime startAtUtc,

    /// endAtUtc
    @JsonKey(name: ConfirmedSlotView.endAtUtcKey_) required DateTime endAtUtc,

    /// status
    @JsonKey(name: ConfirmedSlotView.statusKey_)
    required ConfirmedSlotStatus status,

    /// cancellationReason
    @JsonKey(name: ConfirmedSlotView.cancellationReasonKey_)
    String? cancellationReason,

    /// createdAt
    @JsonKey(name: ConfirmedSlotView.createdAtKey_) required DateTime createdAt,

    /// updatedAt
    @JsonKey(name: ConfirmedSlotView.updatedAtKey_) required DateTime updatedAt,
  }) = _ConfirmedSlotView;

  factory ConfirmedSlotView.fromJson(Map<String, dynamic> json) =>
      _$ConfirmedSlotViewFromJson(json);

  static const String idKey_ = r'id';

  static const String gigIdKey_ = r'gig_id';

  static const String proUserIdKey_ = r'pro_user_id';

  static const String clientUserIdKey_ = r'client_user_id';

  static const String startAtUtcKey_ = r'start_at_utc';

  static const String endAtUtcKey_ = r'end_at_utc';

  static const String statusKey_ = r'status';

  static const String cancellationReasonKey_ = r'cancellation_reason';

  static const String createdAtKey_ = r'created_at';

  static const String updatedAtKey_ = r'updated_at';
}
