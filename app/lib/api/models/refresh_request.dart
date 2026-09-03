/// RefreshRequest
/// {
///     "properties": {
///         "refresh_token": {
///             "type": "string",
///             "title": "Refresh Token"
///         }
///     },
///     "type": "object",
///     "required": [
///         "refresh_token"
///     ],
///     "title": "RefreshRequest"
/// }
library refresh_request;

import 'exports.dart';
part 'refresh_request.freezed.dart';
part 'refresh_request.g.dart'; // RefreshRequest

@freezed
abstract class RefreshRequest with _$RefreshRequest {
  const RefreshRequest._();

  @jsonSerializable
  const factory RefreshRequest({
    /// refreshToken
    @JsonKey(name: RefreshRequest.refreshTokenKey_)
    required String refreshToken,
  }) = _RefreshRequest;

  factory RefreshRequest.fromJson(Map<String, dynamic> json) =>
      _$RefreshRequestFromJson(json);

  static const String refreshTokenKey_ = r'refresh_token';
}
