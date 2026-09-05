// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_waitlist_create_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClientWaitlistCreateRequest _$ClientWaitlistCreateRequestFromJson(
  Map<String, dynamic> json,
) => _ClientWaitlistCreateRequest(
  email: json['email'] as String,
  country: json['country'] as String,
  city: json['city'] as String,
  nicheSlug: json['niche_slug'] as String?,
);

Map<String, dynamic> _$ClientWaitlistCreateRequestToJson(
  _ClientWaitlistCreateRequest instance,
) => <String, dynamic>{
  'email': instance.email,
  'country': instance.country,
  'city': instance.city,
  'niche_slug': instance.nicheSlug,
};
