// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connect_onboarding_link_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ConnectOnboardingLinkResponse _$ConnectOnboardingLinkResponseFromJson(
  Map<String, dynamic> json,
) => _ConnectOnboardingLinkResponse(
  url: json['url'] as String,
  stripeAccountId: json['stripe_account_id'] as String,
);

Map<String, dynamic> _$ConnectOnboardingLinkResponseToJson(
  _ConnectOnboardingLinkResponse instance,
) => <String, dynamic>{
  'url': instance.url,
  'stripe_account_id': instance.stripeAccountId,
};
