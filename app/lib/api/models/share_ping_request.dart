/// SharePingRequest
/// {
///     "properties": {
///         "seconds_viewed": {
///             "type": "integer",
///             "default": 1,
///             "title": "Seconds Viewed"
///         }
///     },
///     "type": "object",
///     "title": "SharePingRequest"
/// }
library share_ping_request;

import 'exports.dart';
part 'share_ping_request.freezed.dart';
part 'share_ping_request.g.dart'; // SharePingRequest

@freezed
abstract class SharePingRequest with _$SharePingRequest {
  const SharePingRequest._();

  @jsonSerializable
  const factory SharePingRequest({
    /// secondsViewed
    @Default(1)
    @JsonKey(name: SharePingRequest.secondsViewedKey_)
    int secondsViewed,
  }) = _SharePingRequest;

  factory SharePingRequest.fromJson(Map<String, dynamic> json) =>
      _$SharePingRequestFromJson(json);

  static const String secondsViewedKey_ = r'seconds_viewed';
}
