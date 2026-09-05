/// ReviewView
/// {
///     "properties": {
///         "id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Id"
///         },
///         "gig_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Gig Id"
///         },
///         "pro_user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Pro User Id"
///         },
///         "client_user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Client User Id"
///         },
///         "niche_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Niche Id"
///         },
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
///         },
///         "video_playback_id": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Video Playback Id"
///         },
///         "status": {
///             "$ref": "#/components/schemas/ReviewStatus"
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
///         },
///         "reply": {
///             "anyOf": [
///                 {
///                     "$ref": "#/components/schemas/ReviewReplyView"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ]
///         }
///     },
///     "type": "object",
///     "required": [
///         "id",
///         "gig_id",
///         "pro_user_id",
///         "client_user_id",
///         "niche_id",
///         "rating",
///         "tags",
///         "would_book_again",
///         "status",
///         "created_at",
///         "updated_at"
///     ],
///     "title": "ReviewView"
/// }
library review_view;

import 'exports.dart';
part 'review_view.freezed.dart';
part 'review_view.g.dart'; // ReviewView

@freezed
abstract class ReviewView with _$ReviewView {
  const ReviewView._();

  @jsonSerializable
  const factory ReviewView({
    /// id
    @JsonKey(name: ReviewView.idKey_) required String id,

    /// gigId
    @JsonKey(name: ReviewView.gigIdKey_) required String gigId,

    /// proUserId
    @JsonKey(name: ReviewView.proUserIdKey_) required String proUserId,

    /// clientUserId
    @JsonKey(name: ReviewView.clientUserIdKey_) required String clientUserId,

    /// nicheId
    @JsonKey(name: ReviewView.nicheIdKey_) required String nicheId,

    /// rating
    @JsonKey(name: ReviewView.ratingKey_) required int rating,

    /// tags
    @JsonKey(name: ReviewView.tagsKey_) required List<String> tags,

    /// text
    @JsonKey(name: ReviewView.textKey_) String? text,

    /// wouldBookAgain
    @JsonKey(name: ReviewView.wouldBookAgainKey_) required bool wouldBookAgain,

    /// videoMediaAssetId
    @JsonKey(name: ReviewView.videoMediaAssetIdKey_) String? videoMediaAssetId,

    /// videoPlaybackId
    @JsonKey(name: ReviewView.videoPlaybackIdKey_) String? videoPlaybackId,

    /// status
    @JsonKey(name: ReviewView.statusKey_) required ReviewStatus status,

    /// createdAt
    @JsonKey(name: ReviewView.createdAtKey_) required DateTime createdAt,

    /// updatedAt
    @JsonKey(name: ReviewView.updatedAtKey_) required DateTime updatedAt,

    /// reply
    @JsonKey(name: ReviewView.replyKey_) ReviewReplyView? reply,
  }) = _ReviewView;

  factory ReviewView.fromJson(Map<String, dynamic> json) =>
      _$ReviewViewFromJson(json);

  static const String idKey_ = r'id';

  static const String gigIdKey_ = r'gig_id';

  static const String proUserIdKey_ = r'pro_user_id';

  static const String clientUserIdKey_ = r'client_user_id';

  static const String nicheIdKey_ = r'niche_id';

  static const String ratingKey_ = r'rating';

  static const String tagsKey_ = r'tags';

  static const String textKey_ = r'text';

  static const String wouldBookAgainKey_ = r'would_book_again';

  static const String videoMediaAssetIdKey_ = r'video_media_asset_id';

  static const String videoPlaybackIdKey_ = r'video_playback_id';

  static const String statusKey_ = r'status';

  static const String createdAtKey_ = r'created_at';

  static const String updatedAtKey_ = r'updated_at';

  static const String replyKey_ = r'reply';
}
