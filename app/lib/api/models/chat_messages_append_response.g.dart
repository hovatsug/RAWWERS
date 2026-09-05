// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_messages_append_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatMessagesAppendResponse _$ChatMessagesAppendResponseFromJson(
  Map<String, dynamic> json,
) => _ChatMessagesAppendResponse(
  threadId: json['thread_id'] as String,
  status: ChatThreadStatus.fromJson(json['status'] as String),
  appended: (json['appended'] as List<dynamic>)
      .map((e) => ChatMessageView.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ChatMessagesAppendResponseToJson(
  _ChatMessagesAppendResponse instance,
) => <String, dynamic>{
  'thread_id': instance.threadId,
  'status': instance.status,
  'appended': instance.appended,
};
