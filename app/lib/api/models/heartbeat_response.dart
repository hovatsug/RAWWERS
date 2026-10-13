/// HeartbeatResponse
/// {
///     "properties": {
///         "recorded": {
///             "type": "boolean",
///             "title": "Recorded"
///         }
///     },
///     "type": "object",
///     "required": [
///         "recorded"
///     ],
///     "title": "HeartbeatResponse"
/// }
library heartbeat_response;

import 'exports.dart';
part 'heartbeat_response.freezed.dart';
part 'heartbeat_response.g.dart'; // HeartbeatResponse

@freezed
abstract class HeartbeatResponse with _$HeartbeatResponse {
  const HeartbeatResponse._();

  @jsonSerializable
  const factory HeartbeatResponse({
    /// recorded
    @JsonKey(name: HeartbeatResponse.recordedKey_) required bool recorded,
  }) = _HeartbeatResponse;

  factory HeartbeatResponse.fromJson(Map<String, dynamic> json) =>
      _$HeartbeatResponseFromJson(json);

  static const String recordedKey_ = r'recorded';
}
