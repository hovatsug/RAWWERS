/// PresentationVideoPlayback
/// {
///     "properties": {
///         "playback_url": {
///             "type": "string",
///             "title": "Playback Url"
///         },
///         "expires_in": {
///             "type": "integer",
///             "title": "Expires In"
///         }
///     },
///     "type": "object",
///     "required": [
///         "playback_url",
///         "expires_in"
///     ],
///     "title": "PresentationVideoPlayback"
/// }
library presentation_video_playback;

import 'exports.dart';
part 'presentation_video_playback.freezed.dart';
part 'presentation_video_playback.g.dart'; // PresentationVideoPlayback

@freezed
abstract class PresentationVideoPlayback with _$PresentationVideoPlayback {
  const PresentationVideoPlayback._();

  @jsonSerializable
  const factory PresentationVideoPlayback({
    /// playbackUrl
    @JsonKey(name: PresentationVideoPlayback.playbackUrlKey_)
    required String playbackUrl,

    /// expiresIn
    @JsonKey(name: PresentationVideoPlayback.expiresInKey_)
    required int expiresIn,
  }) = _PresentationVideoPlayback;

  factory PresentationVideoPlayback.fromJson(Map<String, dynamic> json) =>
      _$PresentationVideoPlaybackFromJson(json);

  static const String playbackUrlKey_ = r'playback_url';

  static const String expiresInKey_ = r'expires_in';
}
