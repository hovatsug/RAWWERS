// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_marketing_consents_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MyMarketingConsentsResponse _$MyMarketingConsentsResponseFromJson(
  Map<String, dynamic> json,
) => _MyMarketingConsentsResponse(
  items: (json['items'] as List<dynamic>)
      .map((e) => MarketingConsentView.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MyMarketingConsentsResponseToJson(
  _MyMarketingConsentsResponse instance,
) => <String, dynamic>{'items': instance.items};
