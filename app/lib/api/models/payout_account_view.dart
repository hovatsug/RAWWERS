/// PayoutAccountView
/// {
///     "properties": {
///         "pro_user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Pro User Id"
///         },
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
///             "$ref": "#/components/schemas/PayoutAccountStatus"
///         },
///         "updated_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Updated At"
///         }
///     },
///     "type": "object",
///     "required": [
///         "pro_user_id",
///         "payout_method",
///         "status",
///         "updated_at"
///     ],
///     "title": "PayoutAccountView"
/// }
library payout_account_view;

import 'exports.dart';
part 'payout_account_view.freezed.dart';
part 'payout_account_view.g.dart'; // PayoutAccountView

@freezed
abstract class PayoutAccountView with _$PayoutAccountView {
  const PayoutAccountView._();

  @jsonSerializable
  const factory PayoutAccountView({
    /// proUserId
    @JsonKey(name: PayoutAccountView.proUserIdKey_) required String proUserId,

    /// payoutMethod
    @JsonKey(name: PayoutAccountView.payoutMethodKey_)
    required PayoutMethod payoutMethod,

    /// stripeConnectAccountId
    @JsonKey(name: PayoutAccountView.stripeConnectAccountIdKey_)
    String? stripeConnectAccountId,

    /// bankDetailsEncrypted
    @JsonKey(name: PayoutAccountView.bankDetailsEncryptedKey_)
    Map<String, dynamic>? bankDetailsEncrypted,

    /// status
    @JsonKey(name: PayoutAccountView.statusKey_)
    required PayoutAccountStatus status,

    /// updatedAt
    @JsonKey(name: PayoutAccountView.updatedAtKey_) required DateTime updatedAt,
  }) = _PayoutAccountView;

  factory PayoutAccountView.fromJson(Map<String, dynamic> json) =>
      _$PayoutAccountViewFromJson(json);

  static const String proUserIdKey_ = r'pro_user_id';

  static const String payoutMethodKey_ = r'payout_method';

  static const String stripeConnectAccountIdKey_ = r'stripe_connect_account_id';

  static const String bankDetailsEncryptedKey_ = r'bank_details_encrypted';

  static const String statusKey_ = r'status';

  static const String updatedAtKey_ = r'updated_at';
}
