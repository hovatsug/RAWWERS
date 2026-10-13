/// AvailableNowUpdate
/// {
///     "properties": {
///         "switched_on": {
///             "type": "boolean",
///             "title": "Switched On"
///         },
///         "prep_hours": {
///             "anyOf": [
///                 {
///                     "type": "integer"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Prep Hours"
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

    /// prepHours
    @JsonKey(name: AvailableNowUpdate.prepHoursKey_) int? prepHours,
  }) = _AvailableNowUpdate;

  factory AvailableNowUpdate.fromJson(Map<String, dynamic> json) =>
      _$AvailableNowUpdateFromJson(json);

  static const String switchedOnKey_ = r'switched_on';

  static const String prepHoursKey_ = r'prep_hours';
}
