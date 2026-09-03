/// TimeWindowItem
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
///         }
///     },
///     "type": "object",
///     "required": [
///         "start_at_utc",
///         "end_at_utc"
///     ],
///     "title": "TimeWindowItem"
/// }
library time_window_item;

import 'exports.dart';
part 'time_window_item.freezed.dart';
part 'time_window_item.g.dart'; // TimeWindowItem

@freezed
abstract class TimeWindowItem with _$TimeWindowItem {
  const TimeWindowItem._();

  @jsonSerializable
  const factory TimeWindowItem({
    /// startAtUtc
    @JsonKey(name: TimeWindowItem.startAtUtcKey_) required DateTime startAtUtc,

    /// endAtUtc
    @JsonKey(name: TimeWindowItem.endAtUtcKey_) required DateTime endAtUtc,
  }) = _TimeWindowItem;

  factory TimeWindowItem.fromJson(Map<String, dynamic> json) =>
      _$TimeWindowItemFromJson(json);

  static const String startAtUtcKey_ = r'start_at_utc';

  static const String endAtUtcKey_ = r'end_at_utc';
}
