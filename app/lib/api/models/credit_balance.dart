/// CreditBalance
/// {
///     "properties": {
///         "balance": {
///             "type": "string",
///             "title": "Balance"
///         },
///         "currency": {
///             "type": "string",
///             "title": "Currency"
///         }
///     },
///     "type": "object",
///     "required": [
///         "balance",
///         "currency"
///     ],
///     "title": "CreditBalance"
/// }
library credit_balance;

import 'exports.dart';
part 'credit_balance.freezed.dart';
part 'credit_balance.g.dart'; // CreditBalance

@freezed
abstract class CreditBalance with _$CreditBalance {
  const CreditBalance._();

  @jsonSerializable
  const factory CreditBalance({
    /// balance
    @JsonKey(name: CreditBalance.balanceKey_) required String balance,

    /// currency
    @JsonKey(name: CreditBalance.currencyKey_) required String currency,
  }) = _CreditBalance;

  factory CreditBalance.fromJson(Map<String, dynamic> json) =>
      _$CreditBalanceFromJson(json);

  static const String balanceKey_ = r'balance';

  static const String currencyKey_ = r'currency';
}
