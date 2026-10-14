/// AvailableNowUpdate
/// {
///     "properties": {
///         "switched_on": {
///             "type": "boolean",
///             "title": "Switched On"
///         },
///         "prep_minutes": {
///             "anyOf": [
///                 {
///                     "type": "integer"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Prep Minutes"
///         }
///     },
///     "type": "object",
///     "required": [
///         "switched_on"
///     ],
///     "title": "AvailableNowUpdate"
/// }
library available_now_update;

import 'exports.dart';
part 'available_now_update.freezed.dart';
part 'available_now_update.g.dart'; // AvailableNowUpdate

@freezed
abstract class AvailableNowUpdate with _$AvailableNowUpdate {
  const AvailableNowUpdate._();

  @jsonSerializable
  const factory AvailableNowUpdate({
    /// switchedOn
    @JsonKey(name: AvailableNowUpdate.switchedOnKey_) required bool switchedOn,

    /// prepMinutes
    @JsonKey(name: AvailableNowUpdate.prepMinutesKey_) int? prepMinutes,
  }) = _AvailableNowUpdate;

  factory AvailableNowUpdate.fromJson(Map<String, dynamic> json) =>
      _$AvailableNowUpdateFromJson(json);

  static const String switchedOnKey_ = r'switched_on';

  static const String prepMinutesKey_ = r'prep_minutes';
}
