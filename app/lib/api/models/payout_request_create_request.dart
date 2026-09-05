/// PayoutRequestCreateRequest
/// {
///     "properties": {
///         "amount_eur": {
///             "anyOf": [
///                 {
///                     "type": "number"
///                 },
///                 {
///                     "type": "string",
///                     "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$"
///                 }
///             ],
///             "title": "Amount Eur"
///         }
///     },
///     "type": "object",
///     "required": [
///         "amount_eur"
///     ],
///     "title": "PayoutRequestCreateRequest"
/// }
library payout_request_create_request;

import 'exports.dart';
part 'payout_request_create_request.freezed.dart';
part 'payout_request_create_request.g.dart'; // PayoutRequestCreateRequest

@freezed
abstract class PayoutRequestCreateRequest with _$PayoutRequestCreateRequest {
  const PayoutRequestCreateRequest._();

  @jsonSerializable
  const factory PayoutRequestCreateRequest({
    /// amountEur
    @JsonKey(name: PayoutRequestCreateRequest.amountEurKey_)
    required dynamic amountEur,
  }) = _PayoutRequestCreateRequest;

  factory PayoutRequestCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$PayoutRequestCreateRequestFromJson(json);

  static const String amountEurKey_ = r'amount_eur';
}
