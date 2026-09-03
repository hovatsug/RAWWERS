// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_create_booking_request_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatCreateBookingRequestResponse _$ChatCreateBookingRequestResponseFromJson(
  Map<String, dynamic> json,
) => _ChatCreateBookingRequestResponse(
  bookingRequest: BookingRequestView.fromJson(
    json['booking_request'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$ChatCreateBookingRequestResponseToJson(
  _ChatCreateBookingRequestResponse instance,
) => <String, dynamic>{'booking_request': instance.bookingRequest};
