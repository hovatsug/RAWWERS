// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'confirmed_slot_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ConfirmedSlotView _$ConfirmedSlotViewFromJson(Map<String, dynamic> json) =>
    _ConfirmedSlotView(
      id: json['id'] as String,
      gigId: json['gig_id'] as String,
      proUserId: json['pro_user_id'] as String,
      clientUserId: json['client_user_id'] as String,
      startAtUtc: DateTime.parse(json['start_at_utc'] as String),
      endAtUtc: DateTime.parse(json['end_at_utc'] as String),
      status: ConfirmedSlotStatus.fromJson(json['status'] as String),
      cancellationReason: json['cancellation_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ConfirmedSlotViewToJson(_ConfirmedSlotView instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gig_id': instance.gigId,
      'pro_user_id': instance.proUserId,
      'client_user_id': instance.clientUserId,
      'start_at_utc': instance.startAtUtc.toIso8601String(),
      'end_at_utc': instance.endAtUtc.toIso8601String(),
      'status': instance.status,
      'cancellation_reason': instance.cancellationReason,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
