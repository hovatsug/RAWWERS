// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scheduling_slots_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SchedulingSlotsResponse _$SchedulingSlotsResponseFromJson(
  Map<String, dynamic> json,
) => _SchedulingSlotsResponse(
  slots: (json['slots'] as List<dynamic>?)
      ?.map((e) => SchedulingSlotView.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SchedulingSlotsResponseToJson(
  _SchedulingSlotsResponse instance,
) => <String, dynamic>{'slots': instance.slots};
