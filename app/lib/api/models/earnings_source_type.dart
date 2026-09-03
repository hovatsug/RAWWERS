// EarningsSourceType
// {
//     "type": "string",
//     "enum": [
//         "gig_base",
//         "extra_images",
//         "studioverse_sale"
//     ],
//     "title": "EarningsSourceType"
// }

library earnings_source_type;

import 'exports.dart';
part 'earnings_source_type.g.dart';

@JsonEnum(alwaysCreate: true)
enum EarningsSourceType {
  @JsonValue("gig_base")
  gigBase,
  @JsonValue("extra_images")
  extraImages,
  @JsonValue("studioverse_sale")
  studioverseSale;

  factory EarningsSourceType.fromJson(String json) =>
      EarningsSourceType.values.firstWhere(
        (e) => e.toJson() == json,
        orElse: () => throw ArgumentError("Invalid EarningsSourceType"),
      );

  String toJson() => _$EarningsSourceTypeEnumMap[this]!;
}
