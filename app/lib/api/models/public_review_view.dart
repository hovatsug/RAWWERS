/// PublicReviewView
/// {
///     "properties": {
///         "id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Id"
///         },
///         "rating": {
///             "type": "integer",
///             "title": "Rating"
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
///         "niche": {
///             "$ref": "#/components/schemas/ReviewNicheView"
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
///         "created_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Created At"
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
///         "rating",
///         "would_book_again",
///         "niche",
///         "created_at"
///     ],
///     "title": "PublicReviewView",
///     "description": "A review as anyone may see it, signed in or not.\n\nDeliberately without client_user_id and gig_id. Those let any visitor link\na client's account to a booking with a named photographer, which no client\nagreed to. What proves the review is real is that it came from a booking;\nthe niche and date say which kind and when. Whether a reviewer's name\nshould ever appear is a separate privacy decision, not made here."
/// }
library public_review_view;

import 'exports.dart';
part 'public_review_view.freezed.dart';
part 'public_review_view.g.dart'; // PublicReviewView

@freezed
abstract class PublicReviewView with _$PublicReviewView {
  const PublicReviewView._();

  @jsonSerializable
  const factory PublicReviewView({
    /// id
    @JsonKey(name: PublicReviewView.idKey_) required String id,

    /// rating
    @JsonKey(name: PublicReviewView.ratingKey_) required int rating,

    /// text
    @JsonKey(name: PublicReviewView.textKey_) String? text,

    /// wouldBookAgain
    @JsonKey(name: PublicReviewView.wouldBookAgainKey_)
    required bool wouldBookAgain,

    /// niche
    @JsonKey(name: PublicReviewView.nicheKey_) required ReviewNicheView niche,

    /// videoPlaybackId
    @JsonKey(name: PublicReviewView.videoPlaybackIdKey_)
    String? videoPlaybackId,

    /// createdAt
    @JsonKey(name: PublicReviewView.createdAtKey_) required DateTime createdAt,

    /// reply
    @JsonKey(name: PublicReviewView.replyKey_) ReviewReplyView? reply,
  }) = _PublicReviewView;

  factory PublicReviewView.fromJson(Map<String, dynamic> json) =>
      _$PublicReviewViewFromJson(json);

  static const String idKey_ = r'id';

  static const String ratingKey_ = r'rating';

  static const String textKey_ = r'text';

  static const String wouldBookAgainKey_ = r'would_book_again';

  static const String nicheKey_ = r'niche';

  static const String videoPlaybackIdKey_ = r'video_playback_id';

  static const String createdAtKey_ = r'created_at';

  static const String replyKey_ = r'reply';
}
