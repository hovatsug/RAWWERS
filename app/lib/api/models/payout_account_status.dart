// PayoutAccountStatus
// {
//     "type": "string",
//     "enum": [
//         "not_set",
//         "pending_verification",
//         "active",
//         "disabled"
//     ],
//     "title": "PayoutAccountStatus"
// }

library payout_account_status;

import 'exports.dart';
part 'payout_account_status.g.dart';

@JsonEnum(alwaysCreate: true)
enum PayoutAccountStatus {
  @JsonValue("not_set")
  notSet,
  @JsonValue("pending_verification")
  pendingVerification,
  @JsonValue("active")
  active,
  @JsonValue("disabled")
  disabled;

  factory PayoutAccountStatus.fromJson(String json) =>
      PayoutAccountStatus.values.firstWhere(
        (e) => e.toJson() == json,
        orElse: () => throw ArgumentError("Invalid PayoutAccountStatus"),
      );

  String toJson() => _$PayoutAccountStatusEnumMap[this]!;
}
