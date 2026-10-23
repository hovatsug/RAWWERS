/// EarningsBalanceView
/// {
///     "properties": {
///         "pending_eur": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Pending Eur"
///         },
///         "available_eur": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Available Eur"
///         },
///         "held_eur": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Held Eur"
///         },
///         "requested_eur": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "default": "0.00",
///             "title": "Requested Eur"
///         },
///         "reserved_eur": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Reserved Eur"
///         },
///         "paid_out_eur": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "default": "0.00",
///             "title": "Paid Out Eur"
///         },
///         "lifetime_eur": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "default": "0.00",
///             "title": "Lifetime Eur"
///         },
///         "withdrawable_eur": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Withdrawable Eur"
///         },
///         "adjustment_owed_eur": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "default": "0.00",
///             "title": "Adjustment Owed Eur"
///         }
///     },
///     "type": "object",
///     "required": [
///         "pending_eur",
///         "available_eur",
///         "held_eur",
///         "reserved_eur",
///         "withdrawable_eur"
///     ],
///     "title": "EarningsBalanceView",
///     "description": "available + requested + reserved + paid_out + pending + held == lifetime, always.\n\n`available_eur` is the real figure and may be negative - money paid out\nthat a later refund took back. A photographer's screen shows\n`withdrawable_eur` (never below 0) and `adjustment_owed_eur` instead."
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
    /// pendingEur
    @JsonKey(name: EarningsBalanceView.pendingEurKey_)
    required String pendingEur,

    /// availableEur
    @JsonKey(name: EarningsBalanceView.availableEurKey_)
    required String availableEur,

    /// heldEur
    @JsonKey(name: EarningsBalanceView.heldEurKey_) required String heldEur,

    /// requestedEur
    @Default('0.00')
    @JsonKey(name: EarningsBalanceView.requestedEurKey_)
    String requestedEur,

    /// reservedEur
    @JsonKey(name: EarningsBalanceView.reservedEurKey_)
    required String reservedEur,

    /// paidOutEur
    @Default('0.00')
    @JsonKey(name: EarningsBalanceView.paidOutEurKey_)
    String paidOutEur,

    /// lifetimeEur
    @Default('0.00')
    @JsonKey(name: EarningsBalanceView.lifetimeEurKey_)
    String lifetimeEur,

    /// withdrawableEur
    @JsonKey(name: EarningsBalanceView.withdrawableEurKey_)
    required String withdrawableEur,

    /// adjustmentOwedEur
    @Default('0.00')
    @JsonKey(name: EarningsBalanceView.adjustmentOwedEurKey_)
    String adjustmentOwedEur,
  }) = _EarningsBalanceView;

  factory EarningsBalanceView.fromJson(Map<String, dynamic> json) =>
      _$EarningsBalanceViewFromJson(json);

  static const String pendingEurKey_ = r'pending_eur';

  static const String availableEurKey_ = r'available_eur';

  static const String heldEurKey_ = r'held_eur';

  static const String requestedEurKey_ = r'requested_eur';

  static const String reservedEurKey_ = r'reserved_eur';

  static const String paidOutEurKey_ = r'paid_out_eur';

  static const String lifetimeEurKey_ = r'lifetime_eur';

  static const String withdrawableEurKey_ = r'withdrawable_eur';

  static const String adjustmentOwedEurKey_ = r'adjustment_owed_eur';
}
