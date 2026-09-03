// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_thread_detail_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatThreadDetailResponse _$ChatThreadDetailResponseFromJson(
  Map<String, dynamic> json,
) => _ChatThreadDetailResponse(
  thread: ChatThreadSummary.fromJson(json['thread'] as Map<String, dynamic>),
  messages: (json['messages'] as List<dynamic>?)
      ?.map((e) => ChatMessageV1View.fromJson(e as Map<String, dynamic>))
      .toList(),
  leadProfile: json['lead_profile'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ChatThreadDetailResponseToJson(
  _ChatThreadDetailResponse instance,
) => <String, dynamic>{
  'thread': instance.thread,
  'messages': instance.messages,
  'lead_profile': instance.leadProfile,
};
