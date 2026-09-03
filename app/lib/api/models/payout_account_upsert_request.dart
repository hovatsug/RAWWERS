/// PayoutAccountUpsertRequest
/// {
///     "properties": {
///         "payout_method": {
///             "$ref": "#/components/schemas/PayoutMethod"
///         },
///         "stripe_connect_account_id": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Stripe Connect Account Id"
///         },
///         "bank_details_encrypted": {
///             "anyOf": [
///                 {
///                     "type": "object"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Bank Details Encrypted"
///         },
///         "status": {
///             "$ref": "#/components/schemas/PayoutAccountStatus",
///             "default": "pending_verification"
///         }
///     },
///     "type": "object",
///     "required": [
///         "payout_method"
///     ],
///     "title": "PayoutAccountUpsertRequest"
/// }
library payout_account_upsert_request;

import 'exports.dart';
part 'payout_account_upsert_request.freezed.dart';
part 'payout_account_upsert_request.g.dart'; // PayoutAccountUpsertRequest

@freezed
abstract class PayoutAccountUpsertRequest with _$PayoutAccountUpsertRequest {
  const PayoutAccountUpsertRequest._();

  @jsonSerializable
  const factory PayoutAccountUpsertRequest({
    /// payoutMethod
    @JsonKey(name: PayoutAccountUpsertRequest.payoutMethodKey_)
    required PayoutMethod payoutMethod,

    /// stripeConnectAccountId
    @JsonKey(name: PayoutAccountUpsertRequest.stripeConnectAccountIdKey_)
    String? stripeConnectAccountId,

    /// bankDetailsEncrypted
    @JsonKey(name: PayoutAccountUpsertRequest.bankDetailsEncryptedKey_)
    Map<String, dynamic>? bankDetailsEncrypted,

    /// status
    @Default(PayoutAccountStatus.pendingVerification)
    @JsonKey(name: PayoutAccountUpsertRequest.statusKey_)
    PayoutAccountStatus status,
  }) = _PayoutAccountUpsertRequest;

  factory PayoutAccountUpsertRequest.fromJson(Map<String, dynamic> json) =>
      _$PayoutAccountUpsertRequestFromJson(json);

  static const String payoutMethodKey_ = r'payout_method';

  static const String stripeConnectAccountIdKey_ = r'stripe_connect_account_id';

  static const String bankDetailsEncryptedKey_ = r'bank_details_encrypted';

  static const String statusKey_ = r'status';
}
