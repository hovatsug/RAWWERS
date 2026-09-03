// ConsentChannel
// {
//     "type": "string",
//     "enum": [
//         "sms",
//         "email",
//         "phone_call"
//     ],
//     "title": "ConsentChannel"
// }

library consent_channel;

import 'exports.dart';
part 'consent_channel.g.dart';

@JsonEnum(alwaysCreate: true)
enum ConsentChannel {
  @JsonValue("sms")
  sms,
  @JsonValue("email")
  email,
  @JsonValue("phone_call")
  phoneCall;

  factory ConsentChannel.fromJson(String json) =>
      ConsentChannel.values.firstWhere(
        (e) => e.toJson() == json,
        orElse: () => throw ArgumentError("Invalid ConsentChannel"),
      );

  String toJson() => _$ConsentChannelEnumMap[this]!;
}
