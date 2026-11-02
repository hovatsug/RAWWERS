// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'withdraw_marketing_consent_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WithdrawMarketingConsentRequest _$WithdrawMarketingConsentRequestFromJson(
  Map<String, dynamic> json,
) => _WithdrawMarketingConsentRequest(
  consentIds: (json['consent_ids'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  all: json['all'] as bool? ?? false,
);

Map<String, dynamic> _$WithdrawMarketingConsentRequestToJson(
  _WithdrawMarketingConsentRequest instance,
) => <String, dynamic>{'consent_ids': instance.consentIds, 'all': instance.all};
