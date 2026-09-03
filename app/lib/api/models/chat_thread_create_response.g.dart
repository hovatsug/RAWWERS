// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_thread_create_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatThreadCreateResponse _$ChatThreadCreateResponseFromJson(
  Map<String, dynamic> json,
) => _ChatThreadCreateResponse(
  threadId: json['thread_id'] as String,
  status: ChatThreadStatus.fromJson(json['status'] as String),
);

Map<String, dynamic> _$ChatThreadCreateResponseToJson(
  _ChatThreadCreateResponse instance,
) => <String, dynamic>{
  'thread_id': instance.threadId,
  'status': instance.status,
};
