// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shelf_camera_model_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShelfCameraModelView _$ShelfCameraModelViewFromJson(
  Map<String, dynamic> json,
) => _ShelfCameraModelView(
  normalisedModel: json['normalised_model'] as String,
  make: json['make'] as String?,
  displayName: json['display_name'] as String,
);

Map<String, dynamic> _$ShelfCameraModelViewToJson(
  _ShelfCameraModelView instance,
) => <String, dynamic>{
  'normalised_model': instance.normalisedModel,
  'make': instance.make,
  'display_name': instance.displayName,
};
