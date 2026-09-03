/// AvailabilityExceptionItem
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
///         }
///     },
///     "type": "object",
///     "required": [
///         "start_at_utc",
///         "end_at_utc"
///     ],
///     "title": "AvailabilityExceptionItem"
/// }
library availability_exception_item;

import 'exports.dart';
part 'availability_exception_item.freezed.dart';
part 'availability_exception_item.g.dart'; // AvailabilityExceptionItem

@freezed
abstract class AvailabilityExceptionItem with _$AvailabilityExceptionItem {
  const AvailabilityExceptionItem._();

  @jsonSerializable
  const factory AvailabilityExceptionItem({
    /// startAtUtc
    @JsonKey(name: AvailabilityExceptionItem.startAtUtcKey_)
    required DateTime startAtUtc,

    /// endAtUtc
    @JsonKey(name: AvailabilityExceptionItem.endAtUtcKey_)
    required DateTime endAtUtc,

    /// reason
    @JsonKey(name: AvailabilityExceptionItem.reasonKey_) String? reason,
  }) = _AvailabilityExceptionItem;

  factory AvailabilityExceptionItem.fromJson(Map<String, dynamic> json) =>
      _$AvailabilityExceptionItemFromJson(json);

  static const String startAtUtcKey_ = r'start_at_utc';

  static const String endAtUtcKey_ = r'end_at_utc';

  static const String reasonKey_ = r'reason';
}
