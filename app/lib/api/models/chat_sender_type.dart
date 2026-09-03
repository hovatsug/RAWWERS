// ChatSenderType
// {
//     "type": "string",
//     "enum": [
//         "client",
//         "ai",
//         "pro",
//         "system"
//     ],
//     "title": "ChatSenderType"
// }

library chat_sender_type;

import 'exports.dart';
part 'chat_sender_type.g.dart';

@JsonEnum(alwaysCreate: true)
enum ChatSenderType {
  @JsonValue("client")
  client,
  @JsonValue("ai")
  aI,
  @JsonValue("pro")
  pro,
  @JsonValue("system")
  system;

  factory ChatSenderType.fromJson(String json) =>
      ChatSenderType.values.firstWhere(
        (e) => e.toJson() == json,
        orElse: () => throw ArgumentError("Invalid ChatSenderType"),
      );

  String toJson() => _$ChatSenderTypeEnumMap[this]!;
}
