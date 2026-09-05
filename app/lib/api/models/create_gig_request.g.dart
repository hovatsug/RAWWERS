// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_gig_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateGigRequest _$CreateGigRequestFromJson(Map<String, dynamic> json) =>
    _CreateGigRequest(
      proUserId: json['pro_user_id'] as String,
      nicheId: json['niche_id'] as String?,
      amountTotal: json['amount_total'],
      currency: json['currency'] as String? ?? 'EUR',
      locationText: json['location_text'] as String?,
      scheduledStart: json['scheduled_start'] == null
          ? null
          : DateTime.parse(json['scheduled_start'] as String),
      scheduledEnd: json['scheduled_end'] == null
          ? null
          : DateTime.parse(json['scheduled_end'] as String),
    );

Map<String, dynamic> _$CreateGigRequestToJson(_CreateGigRequest instance) =>
    <String, dynamic>{
      'pro_user_id': instance.proUserId,
      'niche_id': instance.nicheId,
      'amount_total': instance.amountTotal,
      'currency': instance.currency,
      'location_text': instance.locationText,
      'scheduled_start': instance.scheduledStart?.toIso8601String(),
      'scheduled_end': instance.scheduledEnd?.toIso8601String(),
    };
