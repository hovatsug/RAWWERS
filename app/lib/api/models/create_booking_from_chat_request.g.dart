// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_booking_from_chat_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateBookingFromChatRequest _$CreateBookingFromChatRequestFromJson(
  Map<String, dynamic> json,
) => _CreateBookingFromChatRequest(
  packageId: json['package_id'] as String,
  requestedStart: DateTime.parse(json['requested_start'] as String),
  requestedEnd: DateTime.parse(json['requested_end'] as String),
  locationText: json['location_text'] as String?,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$CreateBookingFromChatRequestToJson(
  _CreateBookingFromChatRequest instance,
) => <String, dynamic>{
  'package_id': instance.packageId,
  'requested_start': instance.requestedStart.toIso8601String(),
  'requested_end': instance.requestedEnd.toIso8601String(),
  'location_text': instance.locationText,
  'notes': instance.notes,
};
