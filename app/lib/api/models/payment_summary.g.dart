// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaymentSummary _$PaymentSummaryFromJson(Map<String, dynamic> json) =>
    _PaymentSummary(
      status: PaymentStatus.fromJson(json['status'] as String),
      stripePaymentIntentId: json['stripe_payment_intent_id'] as String,
      amount: json['amount'] as String,
      currency: json['currency'] as String,
      lastError: json['last_error'] as String?,
    );

Map<String, dynamic> _$PaymentSummaryToJson(_PaymentSummary instance) =>
    <String, dynamic>{
      'status': instance.status,
      'stripe_payment_intent_id': instance.stripePaymentIntentId,
      'amount': instance.amount,
      'currency': instance.currency,
      'last_error': instance.lastError,
    };
