/// PresentationVideoView
/// {
///     "properties": {
///         "playback_url": {
///             "type": "string",
///             "title": "Playback Url"
///         },
///         "poster_url": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Poster Url"
///         },
///         "duration_seconds": {
///             "anyOf": [
///                 {
///                     "type": "integer"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Duration Seconds"
///         },
///         "media_asset_id": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "uuid"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Media Asset Id"
///         }
///     },
///     "type": "object",
///     "required": [
///         "playback_url"
///     ],
///     "title": "PresentationVideoView",
///     "description": "A photographer's \"Meet the photographer\" video, sent only while they\nare live and it is ready (services/presentation_video). `playback_url` is\nsigned for five minutes; the app asks for a fresh one when tapped."
/// }
library presentation_video_view;

import 'exports.dart';
part 'presentation_video_view.freezed.dart';
part 'presentation_video_view.g.dart'; // PresentationVideoView

@freezed
abstract class PresentationVideoView with _$PresentationVideoView {
  const PresentationVideoView._();

  @jsonSerializable
  const factory PresentationVideoView({
    /// playbackUrl
    @JsonKey(name: PresentationVideoView.playbackUrlKey_)
    required String playbackUrl,

    /// posterUrl
    @JsonKey(name: PresentationVideoView.posterUrlKey_) String? posterUrl,

    /// durationSeconds
    @JsonKey(name: PresentationVideoView.durationSecondsKey_)
    int? durationSeconds,

    /// mediaAssetId
    @JsonKey(name: PresentationVideoView.mediaAssetIdKey_) String? mediaAssetId,
  }) = _PresentationVideoView;

  factory PresentationVideoView.fromJson(Map<String, dynamic> json) =>
      _$PresentationVideoViewFromJson(json);

  static const String playbackUrlKey_ = r'playback_url';

  static const String posterUrlKey_ = r'poster_url';

  static const String durationSecondsKey_ = r'duration_seconds';

  static const String mediaAssetIdKey_ = r'media_asset_id';
}
