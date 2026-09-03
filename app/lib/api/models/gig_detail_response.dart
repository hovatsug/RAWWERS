/// GigDetailResponse
/// {
///     "properties": {
///         "gig": {
///             "$ref": "#/components/schemas/GigResponse"
///         },
///         "payment": {
///             "anyOf": [
///                 {
///                     "$ref": "#/components/schemas/PaymentSummary"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ]
///         },
///         "ledger_summary": {
///             "$ref": "#/components/schemas/LedgerSummary"
///         }
///     },
///     "type": "object",
///     "required": [
///         "gig",
///         "ledger_summary"
///     ],
///     "title": "GigDetailResponse"
/// }
library gig_detail_response;

import 'exports.dart';
part 'gig_detail_response.freezed.dart';
part 'gig_detail_response.g.dart'; // GigDetailResponse

@freezed
abstract class GigDetailResponse with _$GigDetailResponse {
  const GigDetailResponse._();

  @jsonSerializable
  const factory GigDetailResponse({
    /// gig
    @JsonKey(name: GigDetailResponse.gigKey_) required GigResponse gig,

    /// payment
    @JsonKey(name: GigDetailResponse.paymentKey_) PaymentSummary? payment,

    /// ledgerSummary
    @JsonKey(name: GigDetailResponse.ledgerSummaryKey_)
    required LedgerSummary ledgerSummary,
  }) = _GigDetailResponse;

  factory GigDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$GigDetailResponseFromJson(json);

  static const String gigKey_ = r'gig';

  static const String paymentKey_ = r'payment';

  static const String ledgerSummaryKey_ = r'ledger_summary';
}
