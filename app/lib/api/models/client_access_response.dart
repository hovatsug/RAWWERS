/// ClientAccessResponse
/// {
///     "properties": {
///         "enabled": {
///             "type": "boolean",
///             "title": "Enabled"
///         },
///         "reason": {
///             "type": "string",
///             "title": "Reason"
///         },
///         "waitlist_available": {
///             "type": "boolean",
///             "default": true,
///             "title": "Waitlist Available"
///         }
///     },
///     "type": "object",
///     "required": [
///         "enabled",
///         "reason"
///     ],
///     "title": "ClientAccessResponse"
/// }
library client_access_response;

import 'exports.dart';
part 'client_access_response.freezed.dart';
part 'client_access_response.g.dart'; // ClientAccessResponse

@freezed
abstract class ClientAccessResponse with _$ClientAccessResponse {
  const ClientAccessResponse._();

  @jsonSerializable
  const factory ClientAccessResponse({
    /// enabled
    @JsonKey(name: ClientAccessResponse.enabledKey_) required bool enabled,

    /// reason
    @JsonKey(name: ClientAccessResponse.reasonKey_) required String reason,

    /// waitlistAvailable
    @Default(true)
    @JsonKey(name: ClientAccessResponse.waitlistAvailableKey_)
    bool waitlistAvailable,
  }) = _ClientAccessResponse;

  factory ClientAccessResponse.fromJson(Map<String, dynamic> json) =>
      _$ClientAccessResponseFromJson(json);

  static const String enabledKey_ = r'enabled';

  static const String reasonKey_ = r'reason';

  static const String waitlistAvailableKey_ = r'waitlist_available';
}
