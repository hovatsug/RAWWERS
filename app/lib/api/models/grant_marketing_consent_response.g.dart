// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grant_marketing_consent_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GrantMarketingConsentResponse _$GrantMarketingConsentResponseFromJson(
  Map<String, dynamic> json,
) => _GrantMarketingConsentResponse(
  items: (json['items'] as List<dynamic>)
      .map((e) => MarketingConsentView.fromJson(e as Map<String, dynamic>))
      .toList(),
  credit: (json['credit'] as num).toInt(),
  creditEur: json['credit_eur'] as String? ?? '0.00',
);

Map<String, dynamic> _$GrantMarketingConsentResponseToJson(
  _GrantMarketingConsentResponse instance,
) => <String, dynamic>{
  'items': instance.items,
  'credit': instance.credit,
  'credit_eur': instance.creditEur,
};
