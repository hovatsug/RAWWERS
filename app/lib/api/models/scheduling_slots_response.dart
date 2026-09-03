/// SchedulingSlotsResponse
/// {
///     "properties": {
///         "slots": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/SchedulingSlotView"
///             },
///             "title": "Slots"
///         }
///     },
///     "type": "object",
///     "title": "SchedulingSlotsResponse"
/// }
library scheduling_slots_response;

import 'exports.dart';
part 'scheduling_slots_response.freezed.dart';
part 'scheduling_slots_response.g.dart'; // SchedulingSlotsResponse

@freezed
abstract class SchedulingSlotsResponse with _$SchedulingSlotsResponse {
  const SchedulingSlotsResponse._();

  @jsonSerializable
  const factory SchedulingSlotsResponse({
    /// slots
    @JsonKey(name: SchedulingSlotsResponse.slotsKey_)
    List<SchedulingSlotView>? slots,
  }) = _SchedulingSlotsResponse;

  factory SchedulingSlotsResponse.fromJson(Map<String, dynamic> json) =>
      _$SchedulingSlotsResponseFromJson(json);

  static const String slotsKey_ = r'slots';
}
