/// CreateRefundRequest
/// {
///     "properties": {
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
///         }
///     },
///     "type": "object",
///     "title": "CreateRefundRequest"
/// }
library create_refund_request;

import 'exports.dart';
part 'create_refund_request.freezed.dart';
part 'create_refund_request.g.dart'; // CreateRefundRequest

@freezed
abstract class CreateRefundRequest with _$CreateRefundRequest {
  const CreateRefundRequest._();

  @jsonSerializable
  const factory CreateRefundRequest({
    /// reason
    @JsonKey(name: CreateRefundRequest.reasonKey_) String? reason,
  }) = _CreateRefundRequest;

  factory CreateRefundRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateRefundRequestFromJson(json);

  static const String reasonKey_ = r'reason';
}
