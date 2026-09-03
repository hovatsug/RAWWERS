// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_booking_request_create_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClientBookingRequestCreateRequest _$ClientBookingRequestCreateRequestFromJson(
  Map<String, dynamic> json,
) => _ClientBookingRequestCreateRequest(
  proUserId: json['pro_user_id'] as String,
  nicheSlug: json['niche_slug'] as String,
  dateWindow: BookingDateWindow.fromJson(
    json['date_window'] as Map<String, dynamic>,
  ),
  location: json['location'] as String?,
  packageId: json['package_id'] as String,
  notes: json['notes'] as String?,
  consentLevel: json['consent_level'] == null
      ? null
      : GigConsentLevel.fromJson(json['consent_level'] as String),
);

Map<String, dynamic> _$ClientBookingRequestCreateRequestToJson(
  _ClientBookingRequestCreateRequest instance,
) => <String, dynamic>{
  'pro_user_id': instance.proUserId,
  'niche_slug': instance.nicheSlug,
  'date_window': instance.dateWindow,
  'location': instance.location,
  'package_id': instance.packageId,
  'notes': instance.notes,
  'consent_level': instance.consentLevel,
};
