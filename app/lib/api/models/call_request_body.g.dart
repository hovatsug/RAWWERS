// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CallRequestBody _$CallRequestBodyFromJson(Map<String, dynamic> json) =>
    _CallRequestBody(
      recipientUserId: json['recipient_user_id'] as String,
      proUserId: json['pro_user_id'] as String?,
      purpose: CallPurpose.fromJson(json['purpose'] as String),
      targetType: json['target_type'] as String?,
      targetId: json['target_id'] as String?,
      source: json['source'] as String? ?? 'in_app',
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$CallRequestBodyToJson(_CallRequestBody instance) =>
    <String, dynamic>{
      'recipient_user_id': instance.recipientUserId,
      'pro_user_id': instance.proUserId,
      'purpose': instance.purpose,
      'target_type': instance.targetType,
      'target_id': instance.targetId,
      'source': instance.source,
      'metadata': instance.metadata,
    };
