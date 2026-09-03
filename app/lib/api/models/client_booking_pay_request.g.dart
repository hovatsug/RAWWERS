// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_booking_pay_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClientBookingPayRequest _$ClientBookingPayRequestFromJson(
  Map<String, dynamic> json,
) => _ClientBookingPayRequest(
  paymentMode: json['payment_mode'] as String,
  pointsToSpend: (json['points_to_spend'] as num?)?.toInt(),
);

Map<String, dynamic> _$ClientBookingPayRequestToJson(
  _ClientBookingPayRequest instance,
) => <String, dynamic>{
  'payment_mode': instance.paymentMode,
  'points_to_spend': instance.pointsToSpend,
};
