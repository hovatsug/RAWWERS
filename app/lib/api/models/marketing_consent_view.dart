/// MarketingConsentView
/// {
///     "properties": {
///         "id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Id"
///         },
///         "gig_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Gig Id"
///         },
///         "media_asset_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Media Asset Id"
///         },
///         "thumbnail_url": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Thumbnail Url"
///         },
///         "photographer_credit": {
///             "type": "string",
///             "title": "Photographer Credit"
///         },
///         "scope": {
///             "type": "string",
///             "title": "Scope"
///         },
///         "term_months": {
///             "type": "integer",
///             "title": "Term Months"
///         },
///         "granted_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Granted At"
///         },
///         "ends_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Ends At"
///         },
///         "status": {
///             "type": "string",
///             "title": "Status"
///         },
///         "withdrawn_at": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "date-time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Withdrawn At"
///         },
///         "renews_consent_id": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "uuid"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Renews Consent Id"
///         }
///     },
///     "type": "object",
///     "required": [
///         "id",
///         "gig_id",
///         "media_asset_id",
///         "photographer_credit",
///         "scope",
///         "term_months",
///         "granted_at",
///         "ends_at",
///         "status"
///     ],
///     "title": "MarketingConsentView"
/// }
library marketing_consent_view;

import 'exports.dart';
part 'marketing_consent_view.freezed.dart';
part 'marketing_consent_view.g.dart'; // MarketingConsentView

@freezed
abstract class MarketingConsentView with _$MarketingConsentView {
  const MarketingConsentView._();

  @jsonSerializable
  const factory MarketingConsentView({
    /// id
    @JsonKey(name: MarketingConsentView.idKey_) required String id,

    /// gigId
    @JsonKey(name: MarketingConsentView.gigIdKey_) required String gigId,

    /// mediaAssetId
    @JsonKey(name: MarketingConsentView.mediaAssetIdKey_)
    required String mediaAssetId,

    /// thumbnailUrl
    @JsonKey(name: MarketingConsentView.thumbnailUrlKey_) String? thumbnailUrl,

    /// photographerCredit
    @JsonKey(name: MarketingConsentView.photographerCreditKey_)
    required String photographerCredit,

    /// scope
    @JsonKey(name: MarketingConsentView.scopeKey_) required String scope,

    /// termMonths
    @JsonKey(name: MarketingConsentView.termMonthsKey_) required int termMonths,

    /// grantedAt
    @JsonKey(name: MarketingConsentView.grantedAtKey_)
    required DateTime grantedAt,

    /// endsAt
    @JsonKey(name: MarketingConsentView.endsAtKey_) required DateTime endsAt,

    /// status
    @JsonKey(name: MarketingConsentView.statusKey_) required String status,

    /// withdrawnAt
    @JsonKey(name: MarketingConsentView.withdrawnAtKey_) DateTime? withdrawnAt,

    /// renewsConsentId
    @JsonKey(name: MarketingConsentView.renewsConsentIdKey_)
    String? renewsConsentId,
  }) = _MarketingConsentView;

  factory MarketingConsentView.fromJson(Map<String, dynamic> json) =>
      _$MarketingConsentViewFromJson(json);

  static const String idKey_ = r'id';

  static const String gigIdKey_ = r'gig_id';

  static const String mediaAssetIdKey_ = r'media_asset_id';

  static const String thumbnailUrlKey_ = r'thumbnail_url';

  static const String photographerCreditKey_ = r'photographer_credit';

  static const String scopeKey_ = r'scope';

  static const String termMonthsKey_ = r'term_months';

  static const String grantedAtKey_ = r'granted_at';

  static const String endsAtKey_ = r'ends_at';

  static const String statusKey_ = r'status';

  static const String withdrawnAtKey_ = r'withdrawn_at';

  static const String renewsConsentIdKey_ = r'renews_consent_id';
}
