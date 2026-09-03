// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gig_consent_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GigConsentView _$GigConsentViewFromJson(Map<String, dynamic> json) =>
    _GigConsentView(
      gigId: json['gig_id'] as String,
      clientUserId: json['client_user_id'] as String,
      proUserId: json['pro_user_id'] as String,
      consentLevel: GigConsentLevel.fromJson(json['consent_level'] as String),
      scope: json['scope'] as Map<String, dynamic>?,
      incentive: json['incentive'] as Map<String, dynamic>?,
      snapshotAtBooking: json['snapshot_at_booking'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$GigConsentViewToJson(_GigConsentView instance) =>
    <String, dynamic>{
      'gig_id': instance.gigId,
      'client_user_id': instance.clientUserId,
      'pro_user_id': instance.proUserId,
      'consent_level': instance.consentLevel,
      'scope': instance.scope,
      'incentive': instance.incentive,
      'snapshot_at_booking': instance.snapshotAtBooking,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
