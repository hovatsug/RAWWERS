/// VerifyEmailRequest
/// {
///     "properties": {
///         "email": {
///             "type": "string",
///             "title": "Email"
///         }
///     },
///     "type": "object",
///     "required": [
///         "email"
///     ],
///     "title": "VerifyEmailRequest"
/// }
library verify_email_request;

import 'exports.dart';
part 'verify_email_request.freezed.dart';
part 'verify_email_request.g.dart'; // VerifyEmailRequest

@freezed
abstract class VerifyEmailRequest with _$VerifyEmailRequest {
  const VerifyEmailRequest._();

  @jsonSerializable
  const factory VerifyEmailRequest({
    /// email
    @JsonKey(name: VerifyEmailRequest.emailKey_) required String email,
  }) = _VerifyEmailRequest;

  factory VerifyEmailRequest.fromJson(Map<String, dynamic> json) =>
      _$VerifyEmailRequestFromJson(json);

  static const String emailKey_ = r'email';
}
