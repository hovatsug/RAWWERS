// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_thread_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatThreadListResponse _$ChatThreadListResponseFromJson(
  Map<String, dynamic> json,
) => _ChatThreadListResponse(
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => ChatThreadSummary.fromJson(e as Map<String, dynamic>))
      .toList(),
  nextCursor: json['next_cursor'] as String?,
);

Map<String, dynamic> _$ChatThreadListResponseToJson(
  _ChatThreadListResponse instance,
) => <String, dynamic>{
  'items': instance.items,
  'next_cursor': instance.nextCursor,
};
