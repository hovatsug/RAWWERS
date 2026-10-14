// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'available_now_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AvailableNowUpdate _$AvailableNowUpdateFromJson(Map<String, dynamic> json) =>
    _AvailableNowUpdate(
      switchedOn: json['switched_on'] as bool,
      prepMinutes: (json['prep_minutes'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AvailableNowUpdateToJson(_AvailableNowUpdate instance) =>
    <String, dynamic>{
      'switched_on': instance.switchedOn,
      'prep_minutes': instance.prepMinutes,
    };
