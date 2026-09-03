// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_time_windows_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BookingTimeWindowsRequest _$BookingTimeWindowsRequestFromJson(
  Map<String, dynamic> json,
) => _BookingTimeWindowsRequest(
  clientTimezone: json['client_timezone'] as String,
  windows: (json['windows'] as List<dynamic>?)
      ?.map((e) => TimeWindowItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$BookingTimeWindowsRequestToJson(
  _BookingTimeWindowsRequest instance,
) => <String, dynamic>{
  'client_timezone': instance.clientTimezone,
  'windows': instance.windows,
};
