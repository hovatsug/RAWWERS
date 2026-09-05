/// SharePingResponse
/// {
///     "properties": {
///         "ok": {
///             "type": "boolean",
///             "title": "Ok"
///         },
///         "accumulated_seconds": {
///             "type": "integer",
///             "title": "Accumulated Seconds"
///         }
///     },
///     "type": "object",
///     "required": [
///         "ok",
///         "accumulated_seconds"
///     ],
///     "title": "SharePingResponse"
/// }
library share_ping_response;

import 'exports.dart';
part 'share_ping_response.freezed.dart';
part 'share_ping_response.g.dart'; // SharePingResponse

@freezed
abstract class SharePingResponse with _$SharePingResponse {
  const SharePingResponse._();

  @jsonSerializable
  const factory SharePingResponse({
    /// ok
    @JsonKey(name: SharePingResponse.okKey_) required bool ok,

    /// accumulatedSeconds
    @JsonKey(name: SharePingResponse.accumulatedSecondsKey_)
    required int accumulatedSeconds,
  }) = _SharePingResponse;

  factory SharePingResponse.fromJson(Map<String, dynamic> json) =>
      _$SharePingResponseFromJson(json);

  static const String okKey_ = r'ok';

  static const String accumulatedSecondsKey_ = r'accumulated_seconds';
}
