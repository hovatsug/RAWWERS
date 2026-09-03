// CredentialMode
// {
//     "type": "string",
//     "enum": [
//         "current",
//         "highest_ever"
//     ],
//     "title": "CredentialMode"
// }

library credential_mode;

import 'exports.dart';
part 'credential_mode.g.dart';

@JsonEnum(alwaysCreate: true)
enum CredentialMode {
  @JsonValue("current")
  current,
  @JsonValue("highest_ever")
  highestEver;

  factory CredentialMode.fromJson(String json) =>
      CredentialMode.values.firstWhere(
        (e) => e.toJson() == json,
        orElse: () => throw ArgumentError("Invalid CredentialMode"),
      );

  String toJson() => _$CredentialModeEnumMap[this]!;
}
