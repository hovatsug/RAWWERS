// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_unread_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatUnreadResponse _$ChatUnreadResponseFromJson(Map<String, dynamic> json) =>
    _ChatUnreadResponse(
      threads: (json['threads'] as num).toInt(),
      messages: (json['messages'] as num).toInt(),
    );

Map<String, dynamic> _$ChatUnreadResponseToJson(_ChatUnreadResponse instance) =>
    <String, dynamic>{
      'threads': instance.threads,
      'messages': instance.messages,
    };
