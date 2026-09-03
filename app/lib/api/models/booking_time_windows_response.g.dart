// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_time_windows_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BookingTimeWindowsResponse _$BookingTimeWindowsResponseFromJson(
  Map<String, dynamic> json,
) => _BookingTimeWindowsResponse(
  bookingRequestId: json['booking_request_id'] as String,
  id: json['id'] as String,
  clientTimezone: json['client_timezone'] as String,
  windows: (json['windows'] as List<dynamic>?)
      ?.map((e) => TimeWindowItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$BookingTimeWindowsResponseToJson(
  _BookingTimeWindowsResponse instance,
) => <String, dynamic>{
  'booking_request_id': instance.bookingRequestId,
  'id': instance.id,
  'client_timezone': instance.clientTimezone,
  'windows': instance.windows,
};
