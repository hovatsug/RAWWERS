// NotificationDigestMode
// {
//     "type": "string",
//     "enum": [
//         "instant",
//         "daily",
//         "weekly"
//     ],
//     "title": "NotificationDigestMode"
// }

library notification_digest_mode;

import 'exports.dart';
part 'notification_digest_mode.g.dart';

@JsonEnum(alwaysCreate: true)
enum NotificationDigestMode {
  @JsonValue("instant")
  instant,
  @JsonValue("daily")
  daily,
  @JsonValue("weekly")
  weekly;

  factory NotificationDigestMode.fromJson(String json) =>
      NotificationDigestMode.values.firstWhere(
        (e) => e.toJson() == json,
        orElse: () => throw ArgumentError("Invalid NotificationDigestMode"),
      );

  String toJson() => _$NotificationDigestModeEnumMap[this]!;
}
