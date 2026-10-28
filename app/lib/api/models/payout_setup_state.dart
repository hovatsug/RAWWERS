// PayoutSetupState
// {
//     "type": "string",
//     "enum": [
//         "not_started",
//         "in_progress",
//         "under_review",
//         "action_needed",
//         "ready",
//         "disabled"
//     ],
//     "title": "PayoutSetupState",
//     "description": "Where a photographer's payout setup stands, as the app shows it.\n\nNot stored: worked out from the Stripe account on every status read, by\nthe same function that gives the stored PayoutAccountStatus\n(stripe_connect.setup_from_account), so the two cannot disagree. ready\nis exactly the stored active."
// }

library payout_setup_state;

import 'exports.dart';
part 'payout_setup_state.g.dart';

@JsonEnum(alwaysCreate: true)
enum PayoutSetupState {
  @JsonValue("not_started")
  notStarted,
  @JsonValue("in_progress")
  inProgress,
  @JsonValue("under_review")
  underReview,
  @JsonValue("action_needed")
  actionNeeded,
  @JsonValue("ready")
  ready,
  @JsonValue("disabled")
  disabled;

  factory PayoutSetupState.fromJson(String json) =>
      PayoutSetupState.values.firstWhere(
        (e) => e.toJson() == json,
        orElse: () => throw ArgumentError("Invalid PayoutSetupState"),
      );

  String toJson() => _$PayoutSetupStateEnumMap[this]!;
}
