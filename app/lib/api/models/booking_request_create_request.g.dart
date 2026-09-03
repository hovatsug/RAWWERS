// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_request_create_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BookingRequestCreateRequest _$BookingRequestCreateRequestFromJson(
  Map<String, dynamic> json,
) => _BookingRequestCreateRequest(
  packageId: json['package_id'] as String,
  requestedStart: DateTime.parse(json['requested_start'] as String),
  requestedEnd: DateTime.parse(json['requested_end'] as String),
  locationText: json['location_text'] as String?,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$BookingRequestCreateRequestToJson(
  _BookingRequestCreateRequest instance,
) => <String, dynamic>{
  'package_id': instance.packageId,
  'requested_start': instance.requestedStart.toIso8601String(),
  'requested_end': instance.requestedEnd.toIso8601String(),
  'location_text': instance.locationText,
  'notes': instance.notes,
};
