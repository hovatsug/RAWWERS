/// MeResponse
/// {
///     "properties": {
///         "user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "User Id"
///         },
///         "email": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Email"
///         },
///         "email_verified_at": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "date-time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Email Verified At"
///         },
///         "status": {
///             "type": "string",
///             "title": "Status"
///         },
///         "roles": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/UserRoleType"
///             },
///             "title": "Roles"
///         },
///         "locale": {
///             "type": "string",
///             "default": "en-GB",
///             "title": "Locale"
///         },
///         "is_impersonating": {
///             "type": "boolean",
///             "default": false,
///             "title": "Is Impersonating"
///         },
///         "impersonation_admin_user_id": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "uuid"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Impersonation Admin User Id"
///         }
///     },
///     "type": "object",
///     "required": [
///         "user_id",
///         "status"
///     ],
///     "title": "MeResponse"
/// }
library me_response;

import 'exports.dart';
part 'me_response.freezed.dart';
part 'me_response.g.dart'; // MeResponse

@freezed
abstract class MeResponse with _$MeResponse {
  const MeResponse._();

  @jsonSerializable
  const factory MeResponse({
    /// userId
    @JsonKey(name: MeResponse.userIdKey_) required String userId,

    /// email
    @JsonKey(name: MeResponse.emailKey_) String? email,

    /// emailVerifiedAt
    @JsonKey(name: MeResponse.emailVerifiedAtKey_) DateTime? emailVerifiedAt,

    /// status
    @JsonKey(name: MeResponse.statusKey_) required String status,

    /// roles
    @JsonKey(name: MeResponse.rolesKey_) List<UserRoleType>? roles,

    /// locale
    @Default('en-GB') @JsonKey(name: MeResponse.localeKey_) String locale,

    /// isImpersonating
    @Default(false)
    @JsonKey(name: MeResponse.isImpersonatingKey_)
    bool isImpersonating,

    /// impersonationAdminUserId
    @JsonKey(name: MeResponse.impersonationAdminUserIdKey_)
    String? impersonationAdminUserId,
  }) = _MeResponse;

  factory MeResponse.fromJson(Map<String, dynamic> json) =>
      _$MeResponseFromJson(json);

  static const String userIdKey_ = r'user_id';

  static const String emailKey_ = r'email';

  static const String emailVerifiedAtKey_ = r'email_verified_at';

  static const String statusKey_ = r'status';

  static const String rolesKey_ = r'roles';

  static const String localeKey_ = r'locale';

  static const String isImpersonatingKey_ = r'is_impersonating';

  static const String impersonationAdminUserIdKey_ =
      r'impersonation_admin_user_id';
}
