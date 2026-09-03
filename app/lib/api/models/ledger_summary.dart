/// LedgerSummary
/// {
///     "properties": {
///         "total_inflow": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Total Inflow"
///         },
///         "total_outflow": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Total Outflow"
///         },
///         "net": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Net"
///         }
///     },
///     "type": "object",
///     "required": [
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
    /// totalInflow
    @JsonKey(name: LedgerSummary.totalInflowKey_) required String totalInflow,

    /// totalOutflow
    @JsonKey(name: LedgerSummary.totalOutflowKey_) required String totalOutflow,

    /// net
    @JsonKey(name: LedgerSummary.netKey_) required String net,
  }) = _LedgerSummary;

  factory LedgerSummary.fromJson(Map<String, dynamic> json) =>
      _$LedgerSummaryFromJson(json);

  static const String totalInflowKey_ = r'total_inflow';

  static const String totalOutflowKey_ = r'total_outflow';

  static const String netKey_ = r'net';
}
