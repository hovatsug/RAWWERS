// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marketing_consent_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MarketingConsentView _$MarketingConsentViewFromJson(
  Map<String, dynamic> json,
) => _MarketingConsentView(
  id: json['id'] as String,
  gigId: json['gig_id'] as String,
  mediaAssetId: json['media_asset_id'] as String,
  thumbnailUrl: json['thumbnail_url'] as String?,
  photographerCredit: json['photographer_credit'] as String,
  scope: json['scope'] as String,
  termMonths: (json['term_months'] as num).toInt(),
  grantedAt: DateTime.parse(json['granted_at'] as String),
  endsAt: DateTime.parse(json['ends_at'] as String),
  status: json['status'] as String,
  withdrawnAt: json['withdrawn_at'] == null
      ? null
      : DateTime.parse(json['withdrawn_at'] as String),
  renewsConsentId: json['renews_consent_id'] as String?,
);

Map<String, dynamic> _$MarketingConsentViewToJson(
  _MarketingConsentView instance,
) => <String, dynamic>{
  'id': instance.id,
  'gig_id': instance.gigId,
  'media_asset_id': instance.mediaAssetId,
  'thumbnail_url': instance.thumbnailUrl,
  'photographer_credit': instance.photographerCredit,
  'scope': instance.scope,
  'term_months': instance.termMonths,
  'granted_at': instance.grantedAt.toIso8601String(),
  'ends_at': instance.endsAt.toIso8601String(),
  'status': instance.status,
  'withdrawn_at': instance.withdrawnAt?.toIso8601String(),
  'renews_consent_id': instance.renewsConsentId,
};
