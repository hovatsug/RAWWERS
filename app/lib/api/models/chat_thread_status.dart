// ChatThreadStatus
// {
//     "type": "string",
//     "enum": [
//         "open",
//         "pro_takeover",
//         "pro_active",
//         "closed"
//     ],
//     "title": "ChatThreadStatus"
// }

library chat_thread_status;

import 'exports.dart';
part 'chat_thread_status.g.dart';

@JsonEnum(alwaysCreate: true)
enum ChatThreadStatus {
  @JsonValue("open")
  open,
  @JsonValue("pro_takeover")
  proTakeover,
  @JsonValue("pro_active")
  proActive,
  @JsonValue("closed")
  closed;

  factory ChatThreadStatus.fromJson(String json) =>
      ChatThreadStatus.values.firstWhere(
        (e) => e.toJson() == json,
        orElse: () => throw ArgumentError("Invalid ChatThreadStatus"),
      );

  String toJson() => _$ChatThreadStatusEnumMap[this]!;
}
