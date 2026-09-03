/// SignedUrlResponse
/// {
///     "properties": {
///         "url": {
///             "type": "string",
///             "title": "Url"
///         },
///         "expires_in_seconds": {
///             "type": "integer",
///             "title": "Expires In Seconds"
///         }
///     },
///     "type": "object",
///     "required": [
///         "url",
///         "expires_in_seconds"
///     ],
///     "title": "SignedUrlResponse"
/// }
library signed_url_response;

import 'exports.dart';
part 'signed_url_response.freezed.dart';
part 'signed_url_response.g.dart'; // SignedUrlResponse

@freezed
abstract class SignedUrlResponse with _$SignedUrlResponse {
  const SignedUrlResponse._();

  @jsonSerializable
  const factory SignedUrlResponse({
    /// url
    @JsonKey(name: SignedUrlResponse.urlKey_) required String url,

    /// expiresInSeconds
    @JsonKey(name: SignedUrlResponse.expiresInSecondsKey_)
    required int expiresInSeconds,
  }) = _SignedUrlResponse;

  factory SignedUrlResponse.fromJson(Map<String, dynamic> json) =>
      _$SignedUrlResponseFromJson(json);

  static const String urlKey_ = r'url';

  static const String expiresInSecondsKey_ = r'expires_in_seconds';
}
