// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selection_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SelectionResponse _$SelectionResponseFromJson(Map<String, dynamic> json) =>
    _SelectionResponse(
      selectionId: json['selection_id'] as String,
      version: (json['version'] as num).toInt(),
      status: SelectionStatus.fromJson(json['status'] as String),
      selectedCount: (json['selected_count'] as num).toInt(),
    );

Map<String, dynamic> _$SelectionResponseToJson(_SelectionResponse instance) =>
    <String, dynamic>{
      'selection_id': instance.selectionId,
      'version': instance.version,
      'status': instance.status,
      'selected_count': instance.selectedCount,
    };
