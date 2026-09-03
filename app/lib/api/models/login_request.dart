/// LoginRequest
/// {
///     "properties": {
///         "email": {
///             "type": "string",
///             "title": "Email"
///         },
///         "password": {
///             "type": "string",
///             "title": "Password"
///         }
///     },
///     "type": "object",
///     "required": [
///         "email",
///         "password"
///     ],
///     "title": "LoginRequest"
/// }
library login_request;

import 'exports.dart';
part 'login_request.freezed.dart';
part 'login_request.g.dart'; // LoginRequest

@freezed
abstract class LoginRequest with _$LoginRequest {
  const LoginRequest._();

  @jsonSerializable
  const factory LoginRequest({
    /// email
    @JsonKey(name: LoginRequest.emailKey_) required String email,

    /// password
    @JsonKey(name: LoginRequest.passwordKey_) required String password,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  static const String emailKey_ = r'email';

  static const String passwordKey_ = r'password';
}
