// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scheduling_policy_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SchedulingPolicyView _$SchedulingPolicyViewFromJson(
  Map<String, dynamic> json,
) => _SchedulingPolicyView(
  proUserId: json['pro_user_id'] as String,
  slotLengthMinutes: (json['slot_length_minutes'] as num).toInt(),
  bufferBeforeMinutes: (json['buffer_before_minutes'] as num).toInt(),
  bufferAfterMinutes: (json['buffer_after_minutes'] as num).toInt(),
  advanceNoticeHours: (json['advance_notice_hours'] as num).toInt(),
  maxBookingsPerDay: (json['max_bookings_per_day'] as num?)?.toInt(),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$SchedulingPolicyViewToJson(
  _SchedulingPolicyView instance,
) => <String, dynamic>{
  'pro_user_id': instance.proUserId,
  'slot_length_minutes': instance.slotLengthMinutes,
  'buffer_before_minutes': instance.bufferBeforeMinutes,
  'buffer_after_minutes': instance.bufferAfterMinutes,
  'advance_notice_hours': instance.advanceNoticeHours,
  'max_bookings_per_day': instance.maxBookingsPerDay,
  'updated_at': instance.updatedAt.toIso8601String(),
};
