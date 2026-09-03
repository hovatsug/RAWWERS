/// ConsentView
/// {
///     "properties": {
///         "id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Id"
///         },
///         "user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "User Id"
///         },
///         "channel": {
///             "$ref": "#/components/schemas/ConsentChannel"
///         },
///         "scope": {
///             "$ref": "#/components/schemas/ConsentScope"
///         },
///         "granted": {
///             "type": "boolean",
///             "title": "Granted"
///         },
///         "granted_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Granted At"
///         },
///         "revoked_at": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "date-time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Revoked At"
///         },
///         "source": {
///             "type": "string",
///             "title": "Source"
///         },
///         "metadata": {
///             "type": "object",
///             "title": "Metadata"
///         }
///     },
///     "type": "object",
///     "required": [
///         "id",
///         "user_id",
///         "channel",
///         "scope",
///         "granted",
///         "granted_at",
///         "source"
///     ],
///     "title": "ConsentView"
/// }
library consent_view;

import 'exports.dart';
part 'consent_view.freezed.dart';
part 'consent_view.g.dart'; // ConsentView

@freezed
abstract class ConsentView with _$ConsentView {
  const ConsentView._();

  @jsonSerializable
  const factory ConsentView({
    /// id
    @JsonKey(name: ConsentView.idKey_) required String id,

    /// userId
    @JsonKey(name: ConsentView.userIdKey_) required String userId,

    /// channel
    @JsonKey(name: ConsentView.channelKey_) required ConsentChannel channel,

    /// scope
    @JsonKey(name: ConsentView.scopeKey_) required ConsentScope scope,

    /// granted
    @JsonKey(name: ConsentView.grantedKey_) required bool granted,

    /// grantedAt
    @JsonKey(name: ConsentView.grantedAtKey_) required DateTime grantedAt,

    /// revokedAt
    @JsonKey(name: ConsentView.revokedAtKey_) DateTime? revokedAt,

    /// source
    @JsonKey(name: ConsentView.sourceKey_) required String source,

    /// metadata
    @JsonKey(name: ConsentView.metadataKey_) Map<String, dynamic>? metadata,
  }) = _ConsentView;

  factory ConsentView.fromJson(Map<String, dynamic> json) =>
      _$ConsentViewFromJson(json);

  static const String idKey_ = r'id';

  static const String userIdKey_ = r'user_id';

  static const String channelKey_ = r'channel';

  static const String scopeKey_ = r'scope';

  static const String grantedKey_ = r'granted';

  static const String grantedAtKey_ = r'granted_at';

  static const String revokedAtKey_ = r'revoked_at';

  static const String sourceKey_ = r'source';

  static const String metadataKey_ = r'metadata';
}
