// ConfirmedSlotStatus
// {
//     "type": "string",
//     "enum": [
//         "reserved",
//         "confirmed",
//         "cancelled",
//         "completed"
//     ],
//     "title": "ConfirmedSlotStatus"
// }

library confirmed_slot_status;

import 'exports.dart';
part 'confirmed_slot_status.g.dart';

@JsonEnum(alwaysCreate: true)
enum ConfirmedSlotStatus {
  @JsonValue("reserved")
  reserved,
  @JsonValue("confirmed")
  confirmed,
  @JsonValue("cancelled")
  cancelled,
  @JsonValue("completed")
  completed;

  factory ConfirmedSlotStatus.fromJson(String json) =>
      ConfirmedSlotStatus.values.firstWhere(
        (e) => e.toJson() == json,
        orElse: () => throw ArgumentError("Invalid ConfirmedSlotStatus"),
      );

  String toJson() => _$ConfirmedSlotStatusEnumMap[this]!;
}
