// NotificationSeverity
// {
//     "type": "string",
//     "enum": [
//         "info",
//         "important",
//         "critical"
//     ],
//     "title": "NotificationSeverity"
// }

library notification_severity;

import 'exports.dart';
part 'notification_severity.g.dart';

@JsonEnum(alwaysCreate: true)
enum NotificationSeverity {
  @JsonValue("info")
  info,
  @JsonValue("important")
  important,
  @JsonValue("critical")
  critical;

  factory NotificationSeverity.fromJson(String json) =>
      NotificationSeverity.values.firstWhere(
        (e) => e.toJson() == json,
        orElse: () => throw ArgumentError("Invalid NotificationSeverity"),
      );

  String toJson() => _$NotificationSeverityEnumMap[this]!;
}
