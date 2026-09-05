/// PublicPortfolioVideo
/// {
///     "properties": {
///         "media_asset_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Media Asset Id"
///         },
///         "playback_id": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Playback Id"
///         }
///     },
///     "type": "object",
///     "required": [
///         "media_asset_id"
///     ],
///     "title": "PublicPortfolioVideo"
/// }
library public_portfolio_video;

import 'exports.dart';
part 'public_portfolio_video.freezed.dart';
part 'public_portfolio_video.g.dart'; // PublicPortfolioVideo

@freezed
abstract class PublicPortfolioVideo with _$PublicPortfolioVideo {
  const PublicPortfolioVideo._();

  @jsonSerializable
  const factory PublicPortfolioVideo({
    /// mediaAssetId
    @JsonKey(name: PublicPortfolioVideo.mediaAssetIdKey_)
    required String mediaAssetId,

    /// playbackId
    @JsonKey(name: PublicPortfolioVideo.playbackIdKey_) String? playbackId,
  }) = _PublicPortfolioVideo;

  factory PublicPortfolioVideo.fromJson(Map<String, dynamic> json) =>
      _$PublicPortfolioVideoFromJson(json);

  static const String mediaAssetIdKey_ = r'media_asset_id';

  static const String playbackIdKey_ = r'playback_id';
}
