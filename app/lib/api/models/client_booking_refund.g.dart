// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_booking_refund.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClientBookingRefund _$ClientBookingRefundFromJson(Map<String, dynamic> json) =>
    _ClientBookingRefund(
      amount: json['amount'] as String,
      currency: json['currency'] as String,
      reasons: (json['reasons'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      at: DateTime.parse(json['at'] as String),
    );

Map<String, dynamic> _$ClientBookingRefundToJson(
  _ClientBookingRefund instance,
) => <String, dynamic>{
  'amount': instance.amount,
  'currency': instance.currency,
  'reasons': instance.reasons,
  'at': instance.at.toIso8601String(),
};
