// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scheduling_policy_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SchedulingPolicyUpdateRequest _$SchedulingPolicyUpdateRequestFromJson(
  Map<String, dynamic> json,
) => _SchedulingPolicyUpdateRequest(
  slotLengthMinutes: (json['slot_length_minutes'] as num?)?.toInt() ?? 60,
  bufferBeforeMinutes: (json['buffer_before_minutes'] as num?)?.toInt() ?? 15,
  bufferAfterMinutes: (json['buffer_after_minutes'] as num?)?.toInt() ?? 15,
  advanceNoticeHours: (json['advance_notice_hours'] as num?)?.toInt() ?? 24,
  maxBookingsPerDay: (json['max_bookings_per_day'] as num?)?.toInt(),
);

Map<String, dynamic> _$SchedulingPolicyUpdateRequestToJson(
  _SchedulingPolicyUpdateRequest instance,
) => <String, dynamic>{
  'slot_length_minutes': instance.slotLengthMinutes,
  'buffer_before_minutes': instance.bufferBeforeMinutes,
  'buffer_after_minutes': instance.bufferAfterMinutes,
  'advance_notice_hours': instance.advanceNoticeHours,
  'max_bookings_per_day': instance.maxBookingsPerDay,
};
