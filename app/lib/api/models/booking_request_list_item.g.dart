// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_request_list_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BookingRequestListItem _$BookingRequestListItemFromJson(
  Map<String, dynamic> json,
) => _BookingRequestListItem(
  id: json['id'] as String,
  proUserId: json['pro_user_id'] as String,
  clientUserId: json['client_user_id'] as String,
  packageId: json['package_id'] as String,
  requestedStart: DateTime.parse(json['requested_start'] as String),
  requestedEnd: DateTime.parse(json['requested_end'] as String),
  locationText: json['location_text'] as String?,
  notes: json['notes'] as String?,
  status: BookingRequestStatus.fromJson(json['status'] as String),
  expiresAt: DateTime.parse(json['expires_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  secondsUntilExpiry: (json['seconds_until_expiry'] as num?)?.toInt(),
);

Map<String, dynamic> _$BookingRequestListItemToJson(
  _BookingRequestListItem instance,
) => <String, dynamic>{
  'id': instance.id,
  'pro_user_id': instance.proUserId,
  'client_user_id': instance.clientUserId,
  'package_id': instance.packageId,
  'requested_start': instance.requestedStart.toIso8601String(),
  'requested_end': instance.requestedEnd.toIso8601String(),
  'location_text': instance.locationText,
  'notes': instance.notes,
  'status': instance.status,
  'expires_at': instance.expiresAt.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
  'seconds_until_expiry': instance.secondsUntilExpiry,
};
