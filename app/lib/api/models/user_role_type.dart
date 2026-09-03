// UserRoleType
// {
//     "type": "string",
//     "enum": [
//         "admin",
//         "pro",
//         "client"
//     ],
//     "title": "UserRoleType"
// }

library user_role_type;

import 'exports.dart';
part 'user_role_type.g.dart';

@JsonEnum(alwaysCreate: true)
enum UserRoleType {
  @JsonValue("admin")
  admin,
  @JsonValue("pro")
  pro,
  @JsonValue("client")
  client;

  factory UserRoleType.fromJson(String json) => UserRoleType.values.firstWhere(
    (e) => e.toJson() == json,
    orElse: () => throw ArgumentError("Invalid UserRoleType"),
  );

  String toJson() => _$UserRoleTypeEnumMap[this]!;
}
