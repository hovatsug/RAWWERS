/// EarningsBalanceView
/// {
///     "properties": {
///         "currency": {
///             "type": "string",
///             "title": "Currency"
///         },
///         "pending": {
///             "type": "string",
///             "title": "Pending"
///         },
///         "available": {
///             "type": "string",
///             "title": "Available"
///         },
///         "held": {
///             "type": "string",
///             "title": "Held"
///         },
///         "requested": {
///             "type": "string",
///             "default": "0.00",
///             "title": "Requested"
///         },
///         "reserved": {
///             "type": "string",
///             "title": "Reserved"
///         },
///         "paid_out": {
///             "type": "string",
///             "default": "0.00",
///             "title": "Paid Out"
///         },
///         "lifetime": {
///             "type": "string",
///             "default": "0.00",
///             "title": "Lifetime"
///         },
///         "withdrawable": {
///             "type": "string",
///             "title": "Withdrawable"
///         },
///         "adjustment_owed": {
///             "type": "string",
///             "default": "0.00",
///             "title": "Adjustment Owed"
///         },
///         "payout_minimum": {
///             "type": "string",
///             "title": "Payout Minimum"
///         }
///     },
///     "type": "object",
///     "required": [
///         "currency",
///         "pending",
///         "available",
///         "held",
///         "reserved",
///         "withdrawable",
///         "payout_minimum"
///     ],
///     "title": "EarningsBalanceView",
///     "description": "available + requested + reserved + paid_out + pending + held == lifetime, always.\n\n`available` is the real figure and may be negative - money paid out\nthat a later refund took back. A photographer's screen shows\n`withdrawable` (never below 0) and `adjustment_owed` instead.\n\nEvery amount is in `currency`, the photographer's one currency."
/// }
library earnings_balance_view;

import 'exports.dart';
part 'earnings_balance_view.freezed.dart';
part 'earnings_balance_view.g.dart'; // EarningsBalanceView

@freezed
abstract class EarningsBalanceView with _$EarningsBalanceView {
  const EarningsBalanceView._();

  @jsonSerializable
  const factory EarningsBalanceView({
    /// currency
    @JsonKey(name: EarningsBalanceView.currencyKey_) required String currency,

    /// pending
    @JsonKey(name: EarningsBalanceView.pendingKey_) required String pending,

    /// available
    @JsonKey(name: EarningsBalanceView.availableKey_) required String available,

    /// held
    @JsonKey(name: EarningsBalanceView.heldKey_) required String held,

    /// requested
    @Default('0.00')
    @JsonKey(name: EarningsBalanceView.requestedKey_)
    String requested,

    /// reserved
    @JsonKey(name: EarningsBalanceView.reservedKey_) required String reserved,

    /// paidOut
    @Default('0.00')
    @JsonKey(name: EarningsBalanceView.paidOutKey_)
    String paidOut,

    /// lifetime
    @Default('0.00')
    @JsonKey(name: EarningsBalanceView.lifetimeKey_)
    String lifetime,

    /// withdrawable
    @JsonKey(name: EarningsBalanceView.withdrawableKey_)
    required String withdrawable,

    /// adjustmentOwed
    @Default('0.00')
    @JsonKey(name: EarningsBalanceView.adjustmentOwedKey_)
    String adjustmentOwed,

    /// payoutMinimum
    @JsonKey(name: EarningsBalanceView.payoutMinimumKey_)
    required String payoutMinimum,
  }) = _EarningsBalanceView;

  factory EarningsBalanceView.fromJson(Map<String, dynamic> json) =>
      _$EarningsBalanceViewFromJson(json);

  static const String currencyKey_ = r'currency';

  static const String pendingKey_ = r'pending';

  static const String availableKey_ = r'available';

  static const String heldKey_ = r'held';

  static const String requestedKey_ = r'requested';

  static const String reservedKey_ = r'reserved';

  static const String paidOutKey_ = r'paid_out';

  static const String lifetimeKey_ = r'lifetime';

  static const String withdrawableKey_ = r'withdrawable';

  static const String adjustmentOwedKey_ = r'adjustment_owed';

  static const String payoutMinimumKey_ = r'payout_minimum';
}
