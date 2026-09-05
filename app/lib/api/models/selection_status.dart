// SelectionStatus
// {
//     "type": "string",
//     "enum": [
//         "draft",
//         "submitted",
//         "locked"
//     ],
//     "title": "SelectionStatus"
// }

library selection_status;

import 'exports.dart';
part 'selection_status.g.dart';

@JsonEnum(alwaysCreate: true)
enum SelectionStatus {
  @JsonValue("draft")
  draft,
  @JsonValue("submitted")
  submitted,
  @JsonValue("locked")
  locked;

  factory SelectionStatus.fromJson(String json) =>
      SelectionStatus.values.firstWhere(
        (e) => e.toJson() == json,
        orElse: () => throw ArgumentError("Invalid SelectionStatus"),
      );

  String toJson() => _$SelectionStatusEnumMap[this]!;
}
