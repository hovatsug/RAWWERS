/// LedgerSummary
/// {
///     "properties": {
///         "currency": {
///             "type": "string",
///             "title": "Currency"
///         },
///         "total_inflow": {
///             "type": "string",
///             "title": "Total Inflow"
///         },
///         "total_outflow": {
///             "type": "string",
///             "title": "Total Outflow"
///         },
///         "net": {
///             "type": "string",
///             "title": "Net"
///         }
///     },
///     "type": "object",
///     "required": [
///         "currency",
///         "total_inflow",
///         "total_outflow",
///         "net"
///     ],
///     "title": "LedgerSummary"
/// }
library ledger_summary;

import 'exports.dart';
part 'ledger_summary.freezed.dart';
part 'ledger_summary.g.dart'; // LedgerSummary

@freezed
abstract class LedgerSummary with _$LedgerSummary {
  const LedgerSummary._();

  @jsonSerializable
  const factory LedgerSummary({
    /// currency
    @JsonKey(name: LedgerSummary.currencyKey_) required String currency,

    /// totalInflow
    @JsonKey(name: LedgerSummary.totalInflowKey_) required String totalInflow,

    /// totalOutflow
    @JsonKey(name: LedgerSummary.totalOutflowKey_) required String totalOutflow,

    /// net
    @JsonKey(name: LedgerSummary.netKey_) required String net,
  }) = _LedgerSummary;

  factory LedgerSummary.fromJson(Map<String, dynamic> json) =>
      _$LedgerSummaryFromJson(json);

  static const String currencyKey_ = r'currency';

  static const String totalInflowKey_ = r'total_inflow';

  static const String totalOutflowKey_ = r'total_outflow';

  static const String netKey_ = r'net';
}
