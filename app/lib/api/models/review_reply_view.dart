/// ReviewReplyView
/// {
///     "properties": {
///         "id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Id"
///         },
///         "review_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Review Id"
///         },
///         "pro_user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Pro User Id"
///         },
///         "text": {
///             "type": "string",
///             "title": "Text"
///         },
///         "created_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Created At"
///         },
///         "updated_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Updated At"
///         }
///     },
///     "type": "object",
///     "required": [
///         "id",
///         "review_id",
///         "pro_user_id",
///         "text",
///         "created_at",
///         "updated_at"
///     ],
///     "title": "ReviewReplyView"
/// }
library review_reply_view;

import 'exports.dart';
part 'review_reply_view.freezed.dart';
part 'review_reply_view.g.dart'; // ReviewReplyView

@freezed
abstract class ReviewReplyView with _$ReviewReplyView {
  const ReviewReplyView._();

  @jsonSerializable
  const factory ReviewReplyView({
    /// id
    @JsonKey(name: ReviewReplyView.idKey_) required String id,

    /// reviewId
    @JsonKey(name: ReviewReplyView.reviewIdKey_) required String reviewId,

    /// proUserId
    @JsonKey(name: ReviewReplyView.proUserIdKey_) required String proUserId,

    /// text
    @JsonKey(name: ReviewReplyView.textKey_) required String text,

    /// createdAt
    @JsonKey(name: ReviewReplyView.createdAtKey_) required DateTime createdAt,

    /// updatedAt
    @JsonKey(name: ReviewReplyView.updatedAtKey_) required DateTime updatedAt,
  }) = _ReviewReplyView;

  factory ReviewReplyView.fromJson(Map<String, dynamic> json) =>
      _$ReviewReplyViewFromJson(json);

  static const String idKey_ = r'id';

  static const String reviewIdKey_ = r'review_id';

  static const String proUserIdKey_ = r'pro_user_id';

  static const String textKey_ = r'text';

  static const String createdAtKey_ = r'created_at';

  static const String updatedAtKey_ = r'updated_at';
}
