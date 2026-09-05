/// VerifyEmailConfirmRequest
/// {
///     "properties": {
///         "code": {
///             "type": "string",
///             "title": "Code"
///         }
///     },
///     "type": "object",
///     "required": [
///         "code"
///     ],
///     "title": "VerifyEmailConfirmRequest"
/// }
library verify_email_confirm_request;

import 'exports.dart';
part 'verify_email_confirm_request.freezed.dart';
part 'verify_email_confirm_request.g.dart'; // VerifyEmailConfirmRequest

@freezed
abstract class VerifyEmailConfirmRequest with _$VerifyEmailConfirmRequest {
  const VerifyEmailConfirmRequest._();

  @jsonSerializable
  const factory VerifyEmailConfirmRequest({
    /// code
    @JsonKey(name: VerifyEmailConfirmRequest.codeKey_) required String code,
  }) = _VerifyEmailConfirmRequest;

  factory VerifyEmailConfirmRequest.fromJson(Map<String, dynamic> json) =>
      _$VerifyEmailConfirmRequestFromJson(json);

  static const String codeKey_ = r'code';
}
