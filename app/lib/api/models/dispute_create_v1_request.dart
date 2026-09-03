/// DisputeCreateV1Request
/// {
///     "properties": {
///         "gig_id": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "uuid"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Gig Id"
///         },
///         "extra_purchase_id": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "uuid"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Extra Purchase Id"
///         },
///         "category": {
///             "$ref": "#/components/schemas/DisputeCategory"
///         },
///         "reason": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Reason"
///         },
///         "summary": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Summary"
///         },
///         "requested_refund_amount": {
///             "anyOf": [
///                 {
///                     "type": "number"
///                 },
///                 {
///                     "type": "string",
///                     "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Requested Refund Amount"
///         },
///         "currency": {
///             "type": "string",
///             "default": "EUR",
///             "title": "Currency"
///         }
///     },
///     "type": "object",
///     "required": [
///         "category"
///     ],
///     "title": "DisputeCreateV1Request"
/// }
library dispute_create_v1_request;

import 'exports.dart';
part 'dispute_create_v1_request.freezed.dart';
part 'dispute_create_v1_request.g.dart'; // DisputeCreateV1Request

@freezed
abstract class DisputeCreateV1Request with _$DisputeCreateV1Request {
  const DisputeCreateV1Request._();

  @jsonSerializable
  const factory DisputeCreateV1Request({
    /// gigId
    @JsonKey(name: DisputeCreateV1Request.gigIdKey_) String? gigId,

    /// extraPurchaseId
    @JsonKey(name: DisputeCreateV1Request.extraPurchaseIdKey_)
    String? extraPurchaseId,

    /// category
    @JsonKey(name: DisputeCreateV1Request.categoryKey_)
    required DisputeCategory category,

    /// reason
    @JsonKey(name: DisputeCreateV1Request.reasonKey_) String? reason,

    /// summary
    @JsonKey(name: DisputeCreateV1Request.summaryKey_) String? summary,

    /// requestedRefundAmount
    @JsonKey(name: DisputeCreateV1Request.requestedRefundAmountKey_)
    dynamic? requestedRefundAmount,

    /// currency
    @Default('EUR')
    @JsonKey(name: DisputeCreateV1Request.currencyKey_)
    String currency,
  }) = _DisputeCreateV1Request;

  factory DisputeCreateV1Request.fromJson(Map<String, dynamic> json) =>
      _$DisputeCreateV1RequestFromJson(json);

  static const String gigIdKey_ = r'gig_id';

  static const String extraPurchaseIdKey_ = r'extra_purchase_id';

  static const String categoryKey_ = r'category';

  static const String reasonKey_ = r'reason';

  static const String summaryKey_ = r'summary';

  static const String requestedRefundAmountKey_ = r'requested_refund_amount';

  static const String currencyKey_ = r'currency';
}
