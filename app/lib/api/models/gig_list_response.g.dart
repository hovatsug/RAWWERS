// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gig_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GigListResponse _$GigListResponseFromJson(Map<String, dynamic> json) =>
    _GigListResponse(
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => GigResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['next_cursor'] as String?,
    );

Map<String, dynamic> _$GigListResponseToJson(_GigListResponse instance) =>
    <String, dynamic>{
      'items': instance.items,
      'next_cursor': instance.nextCursor,
    };
