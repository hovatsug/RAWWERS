// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_booking_status_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClientBookingStatusResponse _$ClientBookingStatusResponseFromJson(
  Map<String, dynamic> json,
) => _ClientBookingStatusResponse(
  bookingId: json['booking_id'] as String,
  bookingStatus: json['booking_status'] as String,
  gigId: json['gig_id'] as String?,
  gigStatus: json['gig_status'] as String?,
  paymentStatus: json['payment_status'] as String?,
  timeline: (json['timeline'] as List<dynamic>?)
      ?.map((e) => e as Map<String, dynamic>)
      .toList(),
  nextActions: (json['next_actions'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$ClientBookingStatusResponseToJson(
  _ClientBookingStatusResponse instance,
) => <String, dynamic>{
  'booking_id': instance.bookingId,
  'booking_status': instance.bookingStatus,
  'gig_id': instance.gigId,
  'gig_status': instance.gigStatus,
  'payment_status': instance.paymentStatus,
  'timeline': instance.timeline,
  'next_actions': instance.nextActions,
};
