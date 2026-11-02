// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marketing_consent_offer_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MarketingConsentOfferResponse _$MarketingConsentOfferResponseFromJson(
  Map<String, dynamic> json,
) => _MarketingConsentOfferResponse(
  offered: json['offered'] as bool,
  reason: json['reason'] as String?,
  wordingVersion: json['wording_version'] as String?,
  wordingText: json['wording_text'] as String?,
  scope: json['scope'] as String? ?? 'rawwers_organic',
  terms: (json['terms'] as List<dynamic>?)
      ?.map((e) => MarketingTermView.fromJson(e as Map<String, dynamic>))
      .toList(),
  defaultTermMonths: (json['default_term_months'] as num?)?.toInt() ?? 12,
  photographerCredit: json['photographer_credit'] as String?,
  photos: (json['photos'] as List<dynamic>?)
      ?.map((e) => MarketingPhotoView.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MarketingConsentOfferResponseToJson(
  _MarketingConsentOfferResponse instance,
) => <String, dynamic>{
  'offered': instance.offered,
  'reason': instance.reason,
  'wording_version': instance.wordingVersion,
  'wording_text': instance.wordingText,
  'scope': instance.scope,
  'terms': instance.terms,
  'default_term_months': instance.defaultTermMonths,
  'photographer_credit': instance.photographerCredit,
  'photos': instance.photos,
};
