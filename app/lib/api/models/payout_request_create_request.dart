/// PayoutRequestCreateRequest
/// {
///     "properties": {
///         "amount": {
///             "anyOf": [
///                 {
///                     "type": "number"
///                 },
///                 {
///                     "type": "string"
///                 }
///             ],
///             "title": "Amount"
///         }
///     },
///     "type": "object",
///     "required": [
///         "amount"
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
    /// amount
    @JsonKey(name: PayoutRequestCreateRequest.amountKey_)
    required dynamic amount,
  }) = _PayoutRequestCreateRequest;

  factory PayoutRequestCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$PayoutRequestCreateRequestFromJson(json);

  static const String amountKey_ = r'amount';
}
