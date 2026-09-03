// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_payment_intent_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreatePaymentIntentResponse _$CreatePaymentIntentResponseFromJson(
  Map<String, dynamic> json,
) => _CreatePaymentIntentResponse(
  paymentIntentClientSecret: json['payment_intent_client_secret'] as String,
  paymentIntentId: json['payment_intent_id'] as String,
  status: json['status'] as String,
  discountAmount: json['discount_amount'] as String?,
  pointsSpent: (json['points_spent'] as num?)?.toInt(),
);

Map<String, dynamic> _$CreatePaymentIntentResponseToJson(
  _CreatePaymentIntentResponse instance,
) => <String, dynamic>{
  'payment_intent_client_secret': instance.paymentIntentClientSecret,
  'payment_intent_id': instance.paymentIntentId,
  'status': instance.status,
  'discount_amount': instance.discountAmount,
  'points_spent': instance.pointsSpent,
};
