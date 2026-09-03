// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_draft_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AIDraftResponse _$AIDraftResponseFromJson(Map<String, dynamic> json) =>
    _AIDraftResponse(
      content: json['content'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$AIDraftResponseToJson(_AIDraftResponse instance) =>
    <String, dynamic>{
      'content': instance.content,
      'metadata': instance.metadata,
    };
