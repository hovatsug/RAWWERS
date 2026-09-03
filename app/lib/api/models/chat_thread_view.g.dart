// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_thread_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatThreadView _$ChatThreadViewFromJson(Map<String, dynamic> json) =>
    _ChatThreadView(
      id: json['id'] as String,
      proUserId: json['pro_user_id'] as String,
      clientUserId: json['client_user_id'] as String,
      status: ChatThreadStatus.fromJson(json['status'] as String),
      contextSnapshot: json['context_snapshot'] as Map<String, dynamic>,
      tokenBudgetUsed: (json['token_budget_used'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      messages: (json['messages'] as List<dynamic>?)
          ?.map((e) => ChatMessageView.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ChatThreadViewToJson(_ChatThreadView instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pro_user_id': instance.proUserId,
      'client_user_id': instance.clientUserId,
      'status': instance.status,
      'context_snapshot': instance.contextSnapshot,
      'token_budget_used': instance.tokenBudgetUsed,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'messages': instance.messages,
    };
