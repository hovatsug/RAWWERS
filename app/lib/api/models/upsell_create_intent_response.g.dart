// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upsell_create_intent_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpsellCreateIntentResponse _$UpsellCreateIntentResponseFromJson(
  Map<String, dynamic> json,
) => _UpsellCreateIntentResponse(
  purchaseId: json['purchase_id'] as String,
  paymentIntentId: json['payment_intent_id'] as String,
  paymentIntentClientSecret: json['payment_intent_client_secret'] as String,
  status: UpsellPurchaseStatus.fromJson(json['status'] as String),
  discountAmount: json['discount_amount'] as String?,
  pointsSpent: (json['points_spent'] as num?)?.toInt(),
);

Map<String, dynamic> _$UpsellCreateIntentResponseToJson(
  _UpsellCreateIntentResponse instance,
) => <String, dynamic>{
  'purchase_id': instance.purchaseId,
  'payment_intent_id': instance.paymentIntentId,
  'payment_intent_client_secret': instance.paymentIntentClientSecret,
  'status': instance.status,
  'discount_amount': instance.discountAmount,
  'points_spent': instance.pointsSpent,
};
