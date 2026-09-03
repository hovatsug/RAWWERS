// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accept_booking_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AcceptBookingResponse _$AcceptBookingResponseFromJson(
  Map<String, dynamic> json,
) => _AcceptBookingResponse(
  bookingRequest: BookingRequestView.fromJson(
    json['booking_request'] as Map<String, dynamic>,
  ),
  gigId: json['gig_id'] as String,
  paymentIntentId: json['payment_intent_id'] as String,
  paymentIntentClientSecret: json['payment_intent_client_secret'] as String,
);

Map<String, dynamic> _$AcceptBookingResponseToJson(
  _AcceptBookingResponse instance,
) => <String, dynamic>{
  'booking_request': instance.bookingRequest,
  'gig_id': instance.gigId,
  'payment_intent_id': instance.paymentIntentId,
  'payment_intent_client_secret': instance.paymentIntentClientSecret,
};
