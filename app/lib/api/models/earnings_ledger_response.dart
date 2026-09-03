/// EarningsLedgerResponse
/// {
///     "properties": {
///         "items": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/EarningsLedgerItemView"
///             },
///             "title": "Items"
///         }
///     },
///     "type": "object",
///     "title": "EarningsLedgerResponse"
/// }
library earnings_ledger_response;

import 'exports.dart';
part 'earnings_ledger_response.freezed.dart';
part 'earnings_ledger_response.g.dart'; // EarningsLedgerResponse

@freezed
abstract class EarningsLedgerResponse with _$EarningsLedgerResponse {
  const EarningsLedgerResponse._();

  @jsonSerializable
  const factory EarningsLedgerResponse({
    /// items
    @JsonKey(name: EarningsLedgerResponse.itemsKey_)
    List<EarningsLedgerItemView>? items,
  }) = _EarningsLedgerResponse;

  factory EarningsLedgerResponse.fromJson(Map<String, dynamic> json) =>
      _$EarningsLedgerResponseFromJson(json);

  static const String itemsKey_ = r'items';
}
