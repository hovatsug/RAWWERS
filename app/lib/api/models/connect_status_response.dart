/// ConnectStatusResponse
/// {
///     "properties": {
///         "stripe_account_id": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Stripe Account Id"
///         },
///         "account_status": {
///             "type": "string",
///             "title": "Account Status"
///         },
///         "charges_enabled": {
///             "type": "boolean",
///             "default": false,
///             "title": "Charges Enabled"
///         },
///         "payouts_enabled": {
///             "type": "boolean",
///             "default": false,
///             "title": "Payouts Enabled"
///         },
///         "details_submitted": {
///             "type": "boolean",
///             "default": false,
///             "title": "Details Submitted"
///         },
///         "currently_due": {
///             "type": "array",
///             "items": {
///                 "type": "string"
///             },
///             "title": "Currently Due"
///         },
///         "past_due": {
///             "type": "array",
///             "items": {
///                 "type": "string"
///             },
///             "title": "Past Due"
///         },
///         "disabled_reason": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Disabled Reason"
///         }
///     },
///     "type": "object",
///     "required": [
///         "account_status"
///     ],
///     "title": "ConnectStatusResponse"
/// }
library connect_status_response;

import 'exports.dart';
part 'connect_status_response.freezed.dart';
part 'connect_status_response.g.dart'; // ConnectStatusResponse

@freezed
abstract class ConnectStatusResponse with _$ConnectStatusResponse {
  const ConnectStatusResponse._();

  @jsonSerializable
  const factory ConnectStatusResponse({
    /// stripeAccountId
    @JsonKey(name: ConnectStatusResponse.stripeAccountIdKey_)
    String? stripeAccountId,

    /// accountStatus
    @JsonKey(name: ConnectStatusResponse.accountStatusKey_)
    required String accountStatus,

    /// chargesEnabled
    @Default(false)
    @JsonKey(name: ConnectStatusResponse.chargesEnabledKey_)
    bool chargesEnabled,

    /// payoutsEnabled
    @Default(false)
    @JsonKey(name: ConnectStatusResponse.payoutsEnabledKey_)
    bool payoutsEnabled,

    /// detailsSubmitted
    @Default(false)
    @JsonKey(name: ConnectStatusResponse.detailsSubmittedKey_)
    bool detailsSubmitted,

    /// currentlyDue
    @JsonKey(name: ConnectStatusResponse.currentlyDueKey_)
    List<String>? currentlyDue,

    /// pastDue
    @JsonKey(name: ConnectStatusResponse.pastDueKey_) List<String>? pastDue,

    /// disabledReason
    @JsonKey(name: ConnectStatusResponse.disabledReasonKey_)
    String? disabledReason,
  }) = _ConnectStatusResponse;

  factory ConnectStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$ConnectStatusResponseFromJson(json);

  static const String stripeAccountIdKey_ = r'stripe_account_id';

  static const String accountStatusKey_ = r'account_status';

  static const String chargesEnabledKey_ = r'charges_enabled';

  static const String payoutsEnabledKey_ = r'payouts_enabled';

  static const String detailsSubmittedKey_ = r'details_submitted';

  static const String currentlyDueKey_ = r'currently_due';

  static const String pastDueKey_ = r'past_due';

  static const String disabledReasonKey_ = r'disabled_reason';
}
