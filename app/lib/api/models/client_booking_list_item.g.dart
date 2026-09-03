// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_booking_list_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClientBookingListItem _$ClientBookingListItemFromJson(
  Map<String, dynamic> json,
) => _ClientBookingListItem(
  bookingId: json['booking_id'] as String,
  bookingStatus: json['booking_status'] as String,
  gigId: json['gig_id'] as String?,
  gigStatus: json['gig_status'] as String?,
  paymentStatus: json['payment_status'] as String?,
  requestedStart: DateTime.parse(json['requested_start'] as String),
  requestedEnd: DateTime.parse(json['requested_end'] as String),
  locationText: json['location_text'] as String?,
  expiresAt: DateTime.parse(json['expires_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$ClientBookingListItemToJson(
  _ClientBookingListItem instance,
) => <String, dynamic>{
  'booking_id': instance.bookingId,
  'booking_status': instance.bookingStatus,
  'gig_id': instance.gigId,
  'gig_status': instance.gigStatus,
  'payment_status': instance.paymentStatus,
  'requested_start': instance.requestedStart.toIso8601String(),
  'requested_end': instance.requestedEnd.toIso8601String(),
  'location_text': instance.locationText,
  'expires_at': instance.expiresAt.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
};
