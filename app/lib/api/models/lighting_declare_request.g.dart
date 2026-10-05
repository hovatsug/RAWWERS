// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lighting_declare_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LightingDeclareRequest _$LightingDeclareRequestFromJson(
  Map<String, dynamic> json,
) => _LightingDeclareRequest(
  make: json['make'] as String?,
  model: json['model'] as String,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$LightingDeclareRequestToJson(
  _LightingDeclareRequest instance,
) => <String, dynamic>{
  'make': instance.make,
  'model': instance.model,
  'notes': instance.notes,
};
