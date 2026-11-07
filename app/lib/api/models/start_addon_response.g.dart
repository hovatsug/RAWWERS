// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'start_addon_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StartAddonResponse _$StartAddonResponseFromJson(Map<String, dynamic> json) =>
    _StartAddonResponse(
      addonId: json['addon_id'] as String,
      amount: json['amount'] as String,
      currency: json['currency'] as String,
      paymentIntentClientSecret:
          json['payment_intent_client_secret'] as String?,
      status: json['status'] as String,
    );

Map<String, dynamic> _$StartAddonResponseToJson(_StartAddonResponse instance) =>
    <String, dynamic>{
      'addon_id': instance.addonId,
      'amount': instance.amount,
      'currency': instance.currency,
      'payment_intent_client_secret': instance.paymentIntentClientSecret,
      'status': instance.status,
    };
