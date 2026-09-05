/// PlaybackTokenRequest
/// {
///     "properties": {
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
///     "title": "PlaybackTokenRequest"
/// }
library playback_token_request;

import 'exports.dart';
part 'playback_token_request.freezed.dart';
part 'playback_token_request.g.dart'; // PlaybackTokenRequest

@freezed
abstract class PlaybackTokenRequest with _$PlaybackTokenRequest {
  const PlaybackTokenRequest._();

  @jsonSerializable
  const factory PlaybackTokenRequest({
    /// playbackId
    @JsonKey(name: PlaybackTokenRequest.playbackIdKey_) String? playbackId,
  }) = _PlaybackTokenRequest;

  factory PlaybackTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$PlaybackTokenRequestFromJson(json);

  static const String playbackIdKey_ = r'playback_id';
}
