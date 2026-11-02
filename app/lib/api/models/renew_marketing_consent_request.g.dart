// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'renew_marketing_consent_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RenewMarketingConsentRequest _$RenewMarketingConsentRequestFromJson(
  Map<String, dynamic> json,
) => _RenewMarketingConsentRequest(
  consentIds: (json['consent_ids'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  termMonths: (json['term_months'] as num?)?.toInt() ?? 12,
);

Map<String, dynamic> _$RenewMarketingConsentRequestToJson(
  _RenewMarketingConsentRequest instance,
) => <String, dynamic>{
  'consent_ids': instance.consentIds,
  'term_months': instance.termMonths,
};
