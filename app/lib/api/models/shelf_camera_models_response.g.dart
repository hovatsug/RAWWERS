// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shelf_camera_models_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShelfCameraModelsResponse _$ShelfCameraModelsResponseFromJson(
  Map<String, dynamic> json,
) => _ShelfCameraModelsResponse(
  items: (json['items'] as List<dynamic>)
      .map((e) => ShelfCameraModelView.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ShelfCameraModelsResponseToJson(
  _ShelfCameraModelsResponse instance,
) => <String, dynamic>{'items': instance.items};
