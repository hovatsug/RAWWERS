/// PlaybackTokenResponse
/// {
///     "properties": {
///         "token": {
///             "type": "string",
///             "title": "Token"
///         },
///         "playback_id": {
///             "type": "string",
///             "title": "Playback Id"
///         },
///         "expires_in": {
///             "type": "integer",
///             "title": "Expires In"
///         }
///     },
///     "type": "object",
///     "required": [
///         "token",
///         "playback_id",
///         "expires_in"
///     ],
///     "title": "PlaybackTokenResponse"
/// }
library playback_token_response;

import 'exports.dart';
part 'playback_token_response.freezed.dart';
part 'playback_token_response.g.dart'; // PlaybackTokenResponse

@freezed
abstract class PlaybackTokenResponse with _$PlaybackTokenResponse {
  const PlaybackTokenResponse._();

  @jsonSerializable
  const factory PlaybackTokenResponse({
    /// token
    @JsonKey(name: PlaybackTokenResponse.tokenKey_) required String token,

    /// playbackId
    @JsonKey(name: PlaybackTokenResponse.playbackIdKey_)
    required String playbackId,

    /// expiresIn
    @JsonKey(name: PlaybackTokenResponse.expiresInKey_) required int expiresIn,
  }) = _PlaybackTokenResponse;

  factory PlaybackTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$PlaybackTokenResponseFromJson(json);

  static const String tokenKey_ = r'token';

  static const String playbackIdKey_ = r'playback_id';

  static const String expiresInKey_ = r'expires_in';
}
