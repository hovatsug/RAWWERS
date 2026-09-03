// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_booking_from_chat_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateBookingFromChatResponse _$CreateBookingFromChatResponseFromJson(
  Map<String, dynamic> json,
) => _CreateBookingFromChatResponse(
  bookingRequest: BookingRequestView.fromJson(
    json['booking_request'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$CreateBookingFromChatResponseToJson(
  _CreateBookingFromChatResponse instance,
) => <String, dynamic>{'booking_request': instance.bookingRequest};
