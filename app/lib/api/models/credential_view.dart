/// CredentialView
/// {
///     "properties": {
///         "id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Id"
///         },
///         "pro_user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Pro User Id"
///         },
///         "niche_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Niche Id"
///         },
///         "credential_code": {
///             "type": "string",
///             "title": "Credential Code"
///         },
///         "display_name": {
///             "type": "string",
///             "title": "Display Name"
///         },
///         "tier": {
///             "$ref": "#/components/schemas/SkillTier"
///         },
///         "mode": {
///             "$ref": "#/components/schemas/CredentialMode"
///         },
///         "awarded_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Awarded At"
///         },
///         "meta": {
///             "type": "object",
///             "title": "Meta"
///         }
///     },
///     "type": "object",
///     "required": [
///         "id",
///         "pro_user_id",
///         "niche_id",
///         "credential_code",
///         "display_name",
///         "tier",
///         "mode",
///         "awarded_at"
///     ],
///     "title": "CredentialView"
/// }
library credential_view;

import 'exports.dart';
part 'credential_view.freezed.dart';
part 'credential_view.g.dart'; // CredentialView

@freezed
abstract class CredentialView with _$CredentialView {
  const CredentialView._();

  @jsonSerializable
  const factory CredentialView({
    /// id
    @JsonKey(name: CredentialView.idKey_) required String id,

    /// proUserId
    @JsonKey(name: CredentialView.proUserIdKey_) required String proUserId,

    /// nicheId
    @JsonKey(name: CredentialView.nicheIdKey_) required String nicheId,

    /// credentialCode
    @JsonKey(name: CredentialView.credentialCodeKey_)
    required String credentialCode,

    /// displayName
    @JsonKey(name: CredentialView.displayNameKey_) required String displayName,

    /// tier
    @JsonKey(name: CredentialView.tierKey_) required SkillTier tier,

    /// mode
    @JsonKey(name: CredentialView.modeKey_) required CredentialMode mode,

    /// awardedAt
    @JsonKey(name: CredentialView.awardedAtKey_) required DateTime awardedAt,

    /// meta
    @JsonKey(name: CredentialView.metaKey_) Map<String, dynamic>? meta,
  }) = _CredentialView;

  factory CredentialView.fromJson(Map<String, dynamic> json) =>
      _$CredentialViewFromJson(json);

  static const String idKey_ = r'id';

  static const String proUserIdKey_ = r'pro_user_id';

  static const String nicheIdKey_ = r'niche_id';

  static const String credentialCodeKey_ = r'credential_code';

  static const String displayNameKey_ = r'display_name';

  static const String tierKey_ = r'tier';

  static const String modeKey_ = r'mode';

  static const String awardedAtKey_ = r'awarded_at';

  static const String metaKey_ = r'meta';
}
