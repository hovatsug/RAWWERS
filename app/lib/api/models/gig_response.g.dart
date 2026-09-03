// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gig_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GigResponse _$GigResponseFromJson(Map<String, dynamic> json) => _GigResponse(
  id: json['id'] as String,
  clientUserId: json['client_user_id'] as String,
  proUserId: json['pro_user_id'] as String,
  nicheId: json['niche_id'] as String?,
  status: GigStatus.fromJson(json['status'] as String),
  currency: json['currency'] as String,
  amountMinimum: json['amount_minimum'] as String,
  amountFinal: json['amount_final'] as String?,
  amountPlatformFee: json['amount_platform_fee'] as String,
  amountProGross: json['amount_pro_gross'] as String,
  locationText: json['location_text'] as String?,
  scheduledStart: json['scheduled_start'] == null
      ? null
      : DateTime.parse(json['scheduled_start'] as String),
  scheduledEnd: json['scheduled_end'] == null
      ? null
      : DateTime.parse(json['scheduled_end'] as String),
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$GigResponseToJson(_GigResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'client_user_id': instance.clientUserId,
      'pro_user_id': instance.proUserId,
      'niche_id': instance.nicheId,
      'status': instance.status,
      'currency': instance.currency,
      'amount_minimum': instance.amountMinimum,
      'amount_final': instance.amountFinal,
      'amount_platform_fee': instance.amountPlatformFee,
      'amount_pro_gross': instance.amountProGross,
      'location_text': instance.locationText,
      'scheduled_start': instance.scheduledStart?.toIso8601String(),
      'scheduled_end': instance.scheduledEnd?.toIso8601String(),
      'metadata': instance.metadata,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
