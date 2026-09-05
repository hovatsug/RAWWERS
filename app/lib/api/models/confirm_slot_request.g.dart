// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'confirm_slot_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ConfirmSlotRequest _$ConfirmSlotRequestFromJson(Map<String, dynamic> json) =>
    _ConfirmSlotRequest(
      startAtUtc: DateTime.parse(json['start_at_utc'] as String),
      endAtUtc: DateTime.parse(json['end_at_utc'] as String),
    );

Map<String, dynamic> _$ConfirmSlotRequestToJson(_ConfirmSlotRequest instance) =>
    <String, dynamic>{
      'start_at_utc': instance.startAtUtc.toIso8601String(),
      'end_at_utc': instance.endAtUtc.toIso8601String(),
    };
