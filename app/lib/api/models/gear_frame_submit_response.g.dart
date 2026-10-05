// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gear_frame_submit_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GearFrameSubmitResponse _$GearFrameSubmitResponseFromJson(
  Map<String, dynamic> json,
) => _GearFrameSubmitResponse(
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => GearVerificationView.fromJson(e as Map<String, dynamic>))
      .toList(),
  notes: (json['notes'] as List<dynamic>?)?.map((e) => e as String).toList(),
  floor: GearFloorView.fromJson(json['floor'] as Map<String, dynamic>),
);

Map<String, dynamic> _$GearFrameSubmitResponseToJson(
  _GearFrameSubmitResponse instance,
) => <String, dynamic>{
  'items': instance.items,
  'notes': instance.notes,
  'floor': instance.floor,
};
