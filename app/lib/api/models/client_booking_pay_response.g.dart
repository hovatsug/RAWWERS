// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_booking_pay_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClientBookingPayResponse _$ClientBookingPayResponseFromJson(
  Map<String, dynamic> json,
) => _ClientBookingPayResponse(
  bookingId: json['booking_id'] as String,
  gigId: json['gig_id'] as String,
  paymentIntentId: json['payment_intent_id'] as String,
  paymentIntentClientSecret: json['payment_intent_client_secret'] as String,
  mode: json['mode'] as String,
);

Map<String, dynamic> _$ClientBookingPayResponseToJson(
  _ClientBookingPayResponse instance,
) => <String, dynamic>{
  'booking_id': instance.bookingId,
  'gig_id': instance.gigId,
  'payment_intent_id': instance.paymentIntentId,
  'payment_intent_client_secret': instance.paymentIntentClientSecret,
  'mode': instance.mode,
};
