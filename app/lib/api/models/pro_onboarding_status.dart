// ProOnboardingStatus
// {
//     "type": "string",
//     "enum": [
//         "started",
//         "profile_completed",
//         "portfolio_uploaded",
//         "packages_configured",
//         "niches_selected",
//         "kyc_submitted",
//         "kyc_approved",
//         "ready_for_review",
//         "approved_public",
//         "rejected"
//     ],
//     "title": "ProOnboardingStatus"
// }

library pro_onboarding_status;

import 'exports.dart';
part 'pro_onboarding_status.g.dart';

@JsonEnum(alwaysCreate: true)
enum ProOnboardingStatus {
  @JsonValue("started")
  started,
  @JsonValue("profile_completed")
  profileCompleted,
  @JsonValue("portfolio_uploaded")
  portfolioUploaded,
  @JsonValue("packages_configured")
  packagesConfigured,
  @JsonValue("niches_selected")
  nichesSelected,
  @JsonValue("kyc_submitted")
  kycSubmitted,
  @JsonValue("kyc_approved")
  kycApproved,
  @JsonValue("ready_for_review")
  readyForReview,
  @JsonValue("approved_public")
  approvedPublic,
  @JsonValue("rejected")
  rejected;

  factory ProOnboardingStatus.fromJson(String json) =>
      ProOnboardingStatus.values.firstWhere(
        (e) => e.toJson() == json,
        orElse: () => throw ArgumentError("Invalid ProOnboardingStatus"),
      );

  String toJson() => _$ProOnboardingStatusEnumMap[this]!;
}
