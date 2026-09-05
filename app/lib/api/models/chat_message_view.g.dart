// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatMessageView _$ChatMessageViewFromJson(Map<String, dynamic> json) =>
    _ChatMessageView(
      id: json['id'] as String,
      threadId: json['thread_id'] as String,
      senderType: ChatSenderType.fromJson(json['sender_type'] as String),
      senderUserId: json['sender_user_id'] as String?,
      content: json['content'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$ChatMessageViewToJson(_ChatMessageView instance) =>
    <String, dynamic>{
      'id': instance.id,
      'thread_id': instance.threadId,
      'sender_type': instance.senderType,
      'sender_user_id': instance.senderUserId,
      'content': instance.content,
      'metadata': instance.metadata,
      'created_at': instance.createdAt.toIso8601String(),
    };
