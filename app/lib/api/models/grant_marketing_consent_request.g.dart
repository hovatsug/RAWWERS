// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grant_marketing_consent_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GrantMarketingConsentRequest _$GrantMarketingConsentRequestFromJson(
  Map<String, dynamic> json,
) => _GrantMarketingConsentRequest(
  mediaAssetIds: (json['media_asset_ids'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  termMonths: (json['term_months'] as num?)?.toInt() ?? 12,
  peopleConfirmed: json['people_confirmed'] as bool? ?? false,
);

Map<String, dynamic> _$GrantMarketingConsentRequestToJson(
  _GrantMarketingConsentRequest instance,
) => <String, dynamic>{
  'media_asset_ids': instance.mediaAssetIds,
  'term_months': instance.termMonths,
  'people_confirmed': instance.peopleConfirmed,
};
