// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_thread_create_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatThreadCreateRequest _$ChatThreadCreateRequestFromJson(
  Map<String, dynamic> json,
) => _ChatThreadCreateRequest(
  proUserId: json['pro_user_id'] as String,
  sessionId: json['session_id'] as String?,
);

Map<String, dynamic> _$ChatThreadCreateRequestToJson(
  _ChatThreadCreateRequest instance,
) => <String, dynamic>{
  'pro_user_id': instance.proUserId,
  'session_id': instance.sessionId,
};
