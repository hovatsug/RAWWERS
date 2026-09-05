// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_payment_intent_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreatePaymentIntentRequest _$CreatePaymentIntentRequestFromJson(
  Map<String, dynamic> json,
) => _CreatePaymentIntentRequest(
  returnUrl: json['return_url'] as String?,
  pointsToSpend: (json['points_to_spend'] as num?)?.toInt(),
);

Map<String, dynamic> _$CreatePaymentIntentRequestToJson(
  _CreatePaymentIntentRequest instance,
) => <String, dynamic>{
  'return_url': instance.returnUrl,
  'points_to_spend': instance.pointsToSpend,
};
