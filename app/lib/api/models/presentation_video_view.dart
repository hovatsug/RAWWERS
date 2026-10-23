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
///         }
///     },
///     "type": "object",
///     "required": [
///         "playback_url"
///     ],
///     "title": "PresentationVideoView",
///     "description": "The slot for a photographer's presentation video. Nothing produces one\nyet: it is sent only once videos exist and PRESENTATION_VIDEO_ENABLED is on."
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
  }) = _PresentationVideoView;

  factory PresentationVideoView.fromJson(Map<String, dynamic> json) =>
      _$PresentationVideoViewFromJson(json);

  static const String playbackUrlKey_ = r'playback_url';

  static const String posterUrlKey_ = r'poster_url';

  static const String durationSecondsKey_ = r'duration_seconds';
}
