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
///         "reserved_eur": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Reserved Eur"
///         },
///         "withdrawable_eur": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Withdrawable Eur"
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
///     "title": "EarningsBalanceView"
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

    /// reservedEur
    @JsonKey(name: EarningsBalanceView.reservedEurKey_)
    required String reservedEur,

    /// withdrawableEur
    @JsonKey(name: EarningsBalanceView.withdrawableEurKey_)
    required String withdrawableEur,
  }) = _EarningsBalanceView;

  factory EarningsBalanceView.fromJson(Map<String, dynamic> json) =>
      _$EarningsBalanceViewFromJson(json);

  static const String pendingEurKey_ = r'pending_eur';

  static const String availableEurKey_ = r'available_eur';

  static const String heldEurKey_ = r'held_eur';

  static const String reservedEurKey_ = r'reserved_eur';

  static const String withdrawableEurKey_ = r'withdrawable_eur';
}
