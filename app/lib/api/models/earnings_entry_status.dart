// EarningsEntryStatus
// {
//     "type": "string",
//     "enum": [
//         "pending",
//         "available",
//         "held",
//         "reversed"
//     ],
//     "title": "EarningsEntryStatus"
// }

library earnings_entry_status;

import 'exports.dart';
part 'earnings_entry_status.g.dart';

@JsonEnum(alwaysCreate: true)
enum EarningsEntryStatus {
  @JsonValue("pending")
  pending,
  @JsonValue("available")
  available,
  @JsonValue("held")
  held,
  @JsonValue("reversed")
  reversed;

  factory EarningsEntryStatus.fromJson(String json) =>
      EarningsEntryStatus.values.firstWhere(
        (e) => e.toJson() == json,
        orElse: () => throw ArgumentError("Invalid EarningsEntryStatus"),
      );

  String toJson() => _$EarningsEntryStatusEnumMap[this]!;
}
