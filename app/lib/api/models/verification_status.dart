// VerificationStatus
// {
//     "type": "string",
//     "enum": [
//         "verified",
//         "declared",
//         "pending_review",
//         "rejected"
//     ],
//     "title": "VerificationStatus"
// }

library verification_status;

import 'exports.dart';
part 'verification_status.g.dart';

@JsonEnum(alwaysCreate: true)
enum VerificationStatus {
  @JsonValue("verified")
  verified,
  @JsonValue("declared")
  declared,
  @JsonValue("pending_review")
  pendingReview,
  @JsonValue("rejected")
  rejected;

  factory VerificationStatus.fromJson(String json) =>
      VerificationStatus.values.firstWhere(
        (e) => e.toJson() == json,
        orElse: () => throw ArgumentError("Invalid VerificationStatus"),
      );

  String toJson() => _$VerificationStatusEnumMap[this]!;
}
