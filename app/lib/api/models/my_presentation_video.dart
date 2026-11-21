/// MyPresentationVideo
/// {
///     "properties": {
///         "media_asset_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Media Asset Id"
///         },
///         "status": {
///             "type": "string",
///             "title": "Status"
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
///         "playback_url": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Playback Url"
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
///         "message": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Message"
///         }
///     },
///     "type": "object",
///     "required": [
///         "media_asset_id",
///         "status"
///     ],
///     "title": "MyPresentationVideo"
/// }
library my_presentation_video;

import 'exports.dart';
part 'my_presentation_video.freezed.dart';
part 'my_presentation_video.g.dart'; // MyPresentationVideo

@freezed
abstract class MyPresentationVideo with _$MyPresentationVideo {
  const MyPresentationVideo._();

  @jsonSerializable
  const factory MyPresentationVideo({
    /// mediaAssetId
    @JsonKey(name: MyPresentationVideo.mediaAssetIdKey_)
    required String mediaAssetId,

    /// status
    @JsonKey(name: MyPresentationVideo.statusKey_) required String status,

    /// posterUrl
    @JsonKey(name: MyPresentationVideo.posterUrlKey_) String? posterUrl,

    /// playbackUrl
    @JsonKey(name: MyPresentationVideo.playbackUrlKey_) String? playbackUrl,

    /// durationSeconds
    @JsonKey(name: MyPresentationVideo.durationSecondsKey_)
    int? durationSeconds,

    /// message
    @JsonKey(name: MyPresentationVideo.messageKey_) String? message,
  }) = _MyPresentationVideo;

  factory MyPresentationVideo.fromJson(Map<String, dynamic> json) =>
      _$MyPresentationVideoFromJson(json);

  static const String mediaAssetIdKey_ = r'media_asset_id';

  static const String statusKey_ = r'status';

  static const String posterUrlKey_ = r'poster_url';

  static const String playbackUrlKey_ = r'playback_url';

  static const String durationSecondsKey_ = r'duration_seconds';

  static const String messageKey_ = r'message';
}
