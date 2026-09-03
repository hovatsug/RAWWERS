// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_thread_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatThreadSummary _$ChatThreadSummaryFromJson(Map<String, dynamic> json) =>
    _ChatThreadSummary(
      id: json['id'] as String,
      proUserId: json['pro_user_id'] as String,
      clientUserId: json['client_user_id'] as String?,
      sessionId: json['session_id'] as String?,
      status: ChatThreadStatus.fromJson(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ChatThreadSummaryToJson(_ChatThreadSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pro_user_id': instance.proUserId,
      'client_user_id': instance.clientUserId,
      'session_id': instance.sessionId,
      'status': instance.status,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
