// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_date_window.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BookingDateWindow _$BookingDateWindowFromJson(Map<String, dynamic> json) =>
    _BookingDateWindow(
      startAt: DateTime.parse(json['start_at'] as String),
      endAt: DateTime.parse(json['end_at'] as String),
    );

Map<String, dynamic> _$BookingDateWindowToJson(_BookingDateWindow instance) =>
    <String, dynamic>{
      'start_at': instance.startAt.toIso8601String(),
      'end_at': instance.endAt.toIso8601String(),
    };
