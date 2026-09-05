// PayoutMethod
// {
//     "type": "string",
//     "enum": [
//         "stripe_connect",
//         "bank_manual"
//     ],
//     "title": "PayoutMethod"
// }

library payout_method;

import 'exports.dart';
part 'payout_method.g.dart';

@JsonEnum(alwaysCreate: true)
enum PayoutMethod {
  @JsonValue("stripe_connect")
  stripeConnect,
  @JsonValue("bank_manual")
  bankManual;

  factory PayoutMethod.fromJson(String json) => PayoutMethod.values.firstWhere(
    (e) => e.toJson() == json,
    orElse: () => throw ArgumentError("Invalid PayoutMethod"),
  );

  String toJson() => _$PayoutMethodEnumMap[this]!;
}
