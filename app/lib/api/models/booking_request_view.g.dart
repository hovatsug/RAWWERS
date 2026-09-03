// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_request_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BookingRequestView _$BookingRequestViewFromJson(Map<String, dynamic> json) =>
    _BookingRequestView(
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
    );

Map<String, dynamic> _$BookingRequestViewToJson(_BookingRequestView instance) =>
    <String, dynamic>{
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
    };
