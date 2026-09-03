/// AvailabilityExceptionView
/// {
///     "properties": {
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
///         },
///         "id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Id"
///         },
///         "pro_user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Pro User Id"
///         },
///         "created_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Created At"
///         }
///     },
///     "type": "object",
///     "required": [
///         "start_at_utc",
///         "end_at_utc",
///         "id",
///         "pro_user_id",
///         "created_at"
///     ],
///     "title": "AvailabilityExceptionView"
/// }
library availability_exception_view;

import 'exports.dart';
part 'availability_exception_view.freezed.dart';
part 'availability_exception_view.g.dart'; // AvailabilityExceptionView

@freezed
abstract class AvailabilityExceptionView with _$AvailabilityExceptionView {
  const AvailabilityExceptionView._();

  @jsonSerializable
  const factory AvailabilityExceptionView({
    /// startAtUtc
    @JsonKey(name: AvailabilityExceptionView.startAtUtcKey_)
    required DateTime startAtUtc,

    /// endAtUtc
    @JsonKey(name: AvailabilityExceptionView.endAtUtcKey_)
    required DateTime endAtUtc,

    /// reason
    @JsonKey(name: AvailabilityExceptionView.reasonKey_) String? reason,

    /// id
    @JsonKey(name: AvailabilityExceptionView.idKey_) required String id,

    /// proUserId
    @JsonKey(name: AvailabilityExceptionView.proUserIdKey_)
    required String proUserId,

    /// createdAt
    @JsonKey(name: AvailabilityExceptionView.createdAtKey_)
    required DateTime createdAt,
  }) = _AvailabilityExceptionView;

  factory AvailabilityExceptionView.fromJson(Map<String, dynamic> json) =>
      _$AvailabilityExceptionViewFromJson(json);

  static const String startAtUtcKey_ = r'start_at_utc';

  static const String endAtUtcKey_ = r'end_at_utc';

  static const String reasonKey_ = r'reason';

  static const String idKey_ = r'id';

  static const String proUserIdKey_ = r'pro_user_id';

  static const String createdAtKey_ = r'created_at';
}
