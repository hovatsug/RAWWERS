/// CreateReviewReplyRequest
/// {
///     "properties": {
///         "text": {
///             "type": "string",
///             "maxLength": 5000,
///             "minLength": 1,
///             "title": "Text"
///         }
///     },
///     "type": "object",
///     "required": [
///         "text"
///     ],
///     "title": "CreateReviewReplyRequest"
/// }
library create_review_reply_request;

import 'exports.dart';
part 'create_review_reply_request.freezed.dart';
part 'create_review_reply_request.g.dart'; // CreateReviewReplyRequest

@freezed
abstract class CreateReviewReplyRequest with _$CreateReviewReplyRequest {
  const CreateReviewReplyRequest._();

  @jsonSerializable
  const factory CreateReviewReplyRequest({
    /// text
    @JsonKey(name: CreateReviewReplyRequest.textKey_) required String text,
  }) = _CreateReviewReplyRequest;

  factory CreateReviewReplyRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateReviewReplyRequestFromJson(json);

  static const String textKey_ = r'text';
}
