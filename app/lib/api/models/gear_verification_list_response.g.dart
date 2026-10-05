// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gear_verification_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GearVerificationListResponse _$GearVerificationListResponseFromJson(
  Map<String, dynamic> json,
) => _GearVerificationListResponse(
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => GearVerificationView.fromJson(e as Map<String, dynamic>))
      .toList(),
  floor: GearFloorView.fromJson(json['floor'] as Map<String, dynamic>),
);

Map<String, dynamic> _$GearVerificationListResponseToJson(
  _GearVerificationListResponse instance,
) => <String, dynamic>{'items': instance.items, 'floor': instance.floor};
