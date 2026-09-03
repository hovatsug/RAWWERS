/// TokenResponse
/// {
///     "properties": {
///         "access_token": {
///             "type": "string",
///             "title": "Access Token"
///         },
///         "refresh_token": {
///             "type": "string",
///             "title": "Refresh Token"
///         },
///         "expires_in": {
///             "type": "integer",
///             "title": "Expires In"
///         }
///     },
///     "type": "object",
///     "required": [
///         "access_token",
///         "refresh_token",
///         "expires_in"
///     ],
///     "title": "TokenResponse"
/// }
library token_response;

import 'exports.dart';
part 'token_response.freezed.dart';
part 'token_response.g.dart'; // TokenResponse

@freezed
abstract class TokenResponse with _$TokenResponse {
  const TokenResponse._();

  @jsonSerializable
  const factory TokenResponse({
    /// accessToken
    @JsonKey(name: TokenResponse.accessTokenKey_) required String accessToken,

    /// refreshToken
    @JsonKey(name: TokenResponse.refreshTokenKey_) required String refreshToken,

    /// expiresIn
    @JsonKey(name: TokenResponse.expiresInKey_) required int expiresIn,
  }) = _TokenResponse;

  factory TokenResponse.fromJson(Map<String, dynamic> json) =>
      _$TokenResponseFromJson(json);

  static const String accessTokenKey_ = r'access_token';

  static const String refreshTokenKey_ = r'refresh_token';

  static const String expiresInKey_ = r'expires_in';
}
