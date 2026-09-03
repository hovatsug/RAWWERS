// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_booking_request_create_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClientBookingRequestCreateResponse
_$ClientBookingRequestCreateResponseFromJson(Map<String, dynamic> json) =>
    _ClientBookingRequestCreateResponse(
      bookingId: json['booking_id'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$ClientBookingRequestCreateResponseToJson(
  _ClientBookingRequestCreateResponse instance,
) => <String, dynamic>{
  'booking_id': instance.bookingId,
  'status': instance.status,
};
