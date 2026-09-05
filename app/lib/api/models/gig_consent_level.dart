// GigConsentLevel
// {
//     "type": "string",
//     "enum": [
//         "none",
//         "pro_marketing_only",
//         "rawwers_marketing_only",
//         "both_pro_and_rawwers"
//     ],
//     "title": "GigConsentLevel"
// }

library gig_consent_level;

import 'exports.dart';
part 'gig_consent_level.g.dart';

@JsonEnum(alwaysCreate: true)
enum GigConsentLevel {
  @JsonValue("none")
  none,
  @JsonValue("pro_marketing_only")
  proMarketingOnly,
  @JsonValue("rawwers_marketing_only")
  rawwersMarketingOnly,
  @JsonValue("both_pro_and_rawwers")
  bothProAndRawwers;

  factory GigConsentLevel.fromJson(String json) =>
      GigConsentLevel.values.firstWhere(
        (e) => e.toJson() == json,
        orElse: () => throw ArgumentError("Invalid GigConsentLevel"),
      );

  String toJson() => _$GigConsentLevelEnumMap[this]!;
}
