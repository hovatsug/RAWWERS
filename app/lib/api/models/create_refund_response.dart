/// CreateRefundResponse
/// {
///     "properties": {
///         "refund_id": {
///             "type": "string",
///             "title": "Refund Id"
///         },
///         "status": {
///             "type": "string",
///             "title": "Status"
///         },
///         "refund_ids": {
///             "type": "array",
///             "items": {
///                 "type": "string"
///             },
///             "default": [],
///             "title": "Refund Ids"
///         }
///     },
///     "type": "object",
///     "required": [
///         "refund_id",
///         "status"
///     ],
///     "title": "CreateRefundResponse"
/// }
library create_refund_response;

import 'exports.dart';
part 'create_refund_response.freezed.dart';
part 'create_refund_response.g.dart'; // CreateRefundResponse

@freezed
abstract class CreateRefundResponse with _$CreateRefundResponse {
  const CreateRefundResponse._();

  @jsonSerializable
  const factory CreateRefundResponse({
    /// refundId
    @JsonKey(name: CreateRefundResponse.refundIdKey_) required String refundId,

    /// status
    @JsonKey(name: CreateRefundResponse.statusKey_) required String status,

    /// refundIds
    @Default(const [])
    @JsonKey(name: CreateRefundResponse.refundIdsKey_)
    List<String> refundIds,
  }) = _CreateRefundResponse;

  factory CreateRefundResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateRefundResponseFromJson(json);

  static const String refundIdKey_ = r'refund_id';

  static const String statusKey_ = r'status';

  static const String refundIdsKey_ = r'refund_ids';
}
