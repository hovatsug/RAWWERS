// SessionBlockLabel
// {
//     "type": "string",
//     "enum": [
//         "morning",
//         "afternoon",
//         "evening"
//     ],
//     "title": "SessionBlockLabel"
// }

library session_block_label;

import 'exports.dart';
part 'session_block_label.g.dart';

@JsonEnum(alwaysCreate: true)
enum SessionBlockLabel {
  @JsonValue("morning")
  morning,
  @JsonValue("afternoon")
  afternoon,
  @JsonValue("evening")
  evening;

  factory SessionBlockLabel.fromJson(String json) =>
      SessionBlockLabel.values.firstWhere(
        (e) => e.toJson() == json,
        orElse: () => throw ArgumentError("Invalid SessionBlockLabel"),
      );

  String toJson() => _$SessionBlockLabelEnumMap[this]!;
}
