/// ClientWaitlistCreateResponse
/// {
///     "properties": {
///         "accepted": {
///             "type": "boolean",
///             "default": true,
///             "title": "Accepted"
///         }
///     },
///     "type": "object",
///     "title": "ClientWaitlistCreateResponse"
/// }
library client_waitlist_create_response;

import 'exports.dart';
part 'client_waitlist_create_response.freezed.dart';
part 'client_waitlist_create_response.g.dart'; // ClientWaitlistCreateResponse

@freezed
abstract class ClientWaitlistCreateResponse
    with _$ClientWaitlistCreateResponse {
  const ClientWaitlistCreateResponse._();

  @jsonSerializable
  const factory ClientWaitlistCreateResponse({
    /// accepted
    @Default(true)
    @JsonKey(name: ClientWaitlistCreateResponse.acceptedKey_)
    bool accepted,
  }) = _ClientWaitlistCreateResponse;

  factory ClientWaitlistCreateResponse.fromJson(Map<String, dynamic> json) =>
      _$ClientWaitlistCreateResponseFromJson(json);

  static const String acceptedKey_ = r'accepted';
}
