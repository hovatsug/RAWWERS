/// PairingCodeResponse
/// {
///     "properties": {
///         "code": {
///             "type": "string",
///             "title": "Code"
///         },
///         "expires_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Expires At"
///         },
///         "valid_minutes": {
///             "type": "integer",
///             "title": "Valid Minutes"
///         }
///     },
///     "type": "object",
///     "required": [
///         "code",
///         "expires_at",
///         "valid_minutes"
///     ],
///     "title": "PairingCodeResponse"
/// }
library pairing_code_response;

import 'exports.dart';
part 'pairing_code_response.freezed.dart';
part 'pairing_code_response.g.dart'; // PairingCodeResponse

@freezed
abstract class PairingCodeResponse with _$PairingCodeResponse {
  const PairingCodeResponse._();

  @jsonSerializable
  const factory PairingCodeResponse({
    /// code
    @JsonKey(name: PairingCodeResponse.codeKey_) required String code,

    /// expiresAt
    @JsonKey(name: PairingCodeResponse.expiresAtKey_)
    required DateTime expiresAt,

    /// validMinutes
    @JsonKey(name: PairingCodeResponse.validMinutesKey_)
    required int validMinutes,
  }) = _PairingCodeResponse;

  factory PairingCodeResponse.fromJson(Map<String, dynamic> json) =>
      _$PairingCodeResponseFromJson(json);

  static const String codeKey_ = r'code';

  static const String expiresAtKey_ = r'expires_at';

  static const String validMinutesKey_ = r'valid_minutes';
}
