/// LogoutRequest
/// {
///     "properties": {
///         "refresh_token": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Refresh Token"
///         },
///         "revoke_family": {
///             "type": "boolean",
///             "default": false,
///             "title": "Revoke Family"
///         }
///     },
///     "type": "object",
///     "title": "LogoutRequest"
/// }
library logout_request;

import 'exports.dart';
part 'logout_request.freezed.dart';
part 'logout_request.g.dart'; // LogoutRequest

@freezed
abstract class LogoutRequest with _$LogoutRequest {
  const LogoutRequest._();

  @jsonSerializable
  const factory LogoutRequest({
    /// refreshToken
    @JsonKey(name: LogoutRequest.refreshTokenKey_) String? refreshToken,

    /// revokeFamily
    @Default(false)
    @JsonKey(name: LogoutRequest.revokeFamilyKey_)
    bool revokeFamily,
  }) = _LogoutRequest;

  factory LogoutRequest.fromJson(Map<String, dynamic> json) =>
      _$LogoutRequestFromJson(json);

  static const String refreshTokenKey_ = r'refresh_token';

  static const String revokeFamilyKey_ = r'revoke_family';
}
