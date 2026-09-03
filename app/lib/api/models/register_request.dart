/// RegisterRequest
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
///     "title": "RegisterRequest"
/// }
library register_request;

import 'exports.dart';
part 'register_request.freezed.dart';
part 'register_request.g.dart'; // RegisterRequest

@freezed
abstract class RegisterRequest with _$RegisterRequest {
  const RegisterRequest._();

  @jsonSerializable
  const factory RegisterRequest({
    /// email
    @JsonKey(name: RegisterRequest.emailKey_) required String email,

    /// password
    @JsonKey(name: RegisterRequest.passwordKey_) required String password,
  }) = _RegisterRequest;

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);

  static const String emailKey_ = r'email';

  static const String passwordKey_ = r'password';
}
