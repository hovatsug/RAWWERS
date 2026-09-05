/// WebhookAckResponse
/// {
///     "properties": {
///         "ok": {
///             "type": "boolean",
///             "title": "Ok"
///         }
///     },
///     "type": "object",
///     "required": [
///         "ok"
///     ],
///     "title": "WebhookAckResponse"
/// }
library webhook_ack_response;

import 'exports.dart';
part 'webhook_ack_response.freezed.dart';
part 'webhook_ack_response.g.dart'; // WebhookAckResponse

@freezed
abstract class WebhookAckResponse with _$WebhookAckResponse {
  const WebhookAckResponse._();

  @jsonSerializable
  const factory WebhookAckResponse({
    /// ok
    @JsonKey(name: WebhookAckResponse.okKey_) required bool ok,
  }) = _WebhookAckResponse;

  factory WebhookAckResponse.fromJson(Map<String, dynamic> json) =>
      _$WebhookAckResponseFromJson(json);

  static const String okKey_ = r'ok';
}
