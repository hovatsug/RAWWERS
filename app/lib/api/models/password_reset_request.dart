/// PasswordResetRequest
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
///     "title": "PasswordResetRequest"
/// }
library password_reset_request;

import 'exports.dart';
part 'password_reset_request.freezed.dart';
part 'password_reset_request.g.dart'; // PasswordResetRequest

@freezed
abstract class PasswordResetRequest with _$PasswordResetRequest {
  const PasswordResetRequest._();

  @jsonSerializable
  const factory PasswordResetRequest({
    /// email
    @JsonKey(name: PasswordResetRequest.emailKey_) required String email,
  }) = _PasswordResetRequest;

  factory PasswordResetRequest.fromJson(Map<String, dynamic> json) =>
      _$PasswordResetRequestFromJson(json);

  static const String emailKey_ = r'email';
}
