/// PasswordResetConfirmRequest
/// {
///     "properties": {
///         "code": {
///             "type": "string",
///             "title": "Code"
///         },
///         "new_password": {
///             "type": "string",
///             "title": "New Password"
///         }
///     },
///     "type": "object",
///     "required": [
///         "code",
///         "new_password"
///     ],
///     "title": "PasswordResetConfirmRequest"
/// }
library password_reset_confirm_request;

import 'exports.dart';
part 'password_reset_confirm_request.freezed.dart';
part 'password_reset_confirm_request.g.dart'; // PasswordResetConfirmRequest

@freezed
abstract class PasswordResetConfirmRequest with _$PasswordResetConfirmRequest {
  const PasswordResetConfirmRequest._();

  @jsonSerializable
  const factory PasswordResetConfirmRequest({
    /// code
    @JsonKey(name: PasswordResetConfirmRequest.codeKey_) required String code,

    /// newPassword
    @JsonKey(name: PasswordResetConfirmRequest.newPasswordKey_)
    required String newPassword,
  }) = _PasswordResetConfirmRequest;

  factory PasswordResetConfirmRequest.fromJson(Map<String, dynamic> json) =>
      _$PasswordResetConfirmRequestFromJson(json);

  static const String codeKey_ = r'code';

  static const String newPasswordKey_ = r'new_password';
}
