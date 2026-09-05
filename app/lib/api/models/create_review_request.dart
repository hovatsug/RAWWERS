/// CreateReviewRequest
/// {
///     "properties": {
///         "rating": {
///             "type": "integer",
///             "title": "Rating"
///         },
///         "tags": {
///             "type": "array",
///             "items": {
///                 "type": "string"
///             },
///             "title": "Tags"
///         },
///         "text": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Text"
///         },
///         "would_book_again": {
///             "type": "boolean",
///             "default": true,
///             "title": "Would Book Again"
///         },
///         "video_media_asset_id": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "uuid"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Video Media Asset Id"
///         }
///     },
///     "type": "object",
///     "required": [
///         "rating"
///     ],
///     "title": "CreateReviewRequest"
/// }
library create_review_request;

import 'exports.dart';
part 'create_review_request.freezed.dart';
part 'create_review_request.g.dart'; // CreateReviewRequest

@freezed
abstract class CreateReviewRequest with _$CreateReviewRequest {
  const CreateReviewRequest._();

  @jsonSerializable
  const factory CreateReviewRequest({
    /// rating
    @JsonKey(name: CreateReviewRequest.ratingKey_) required int rating,

    /// tags
    @JsonKey(name: CreateReviewRequest.tagsKey_) List<String>? tags,

    /// text
    @JsonKey(name: CreateReviewRequest.textKey_) String? text,

    /// wouldBookAgain
    @Default(true)
    @JsonKey(name: CreateReviewRequest.wouldBookAgainKey_)
    bool wouldBookAgain,

    /// videoMediaAssetId
    @JsonKey(name: CreateReviewRequest.videoMediaAssetIdKey_)
    String? videoMediaAssetId,
  }) = _CreateReviewRequest;

  factory CreateReviewRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateReviewRequestFromJson(json);

  static const String ratingKey_ = r'rating';

  static const String tagsKey_ = r'tags';

  static const String textKey_ = r'text';

  static const String wouldBookAgainKey_ = r'would_book_again';

  static const String videoMediaAssetIdKey_ = r'video_media_asset_id';
}
