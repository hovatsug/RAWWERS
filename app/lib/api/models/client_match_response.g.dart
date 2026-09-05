// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_match_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClientMatchResponse _$ClientMatchResponseFromJson(Map<String, dynamic> json) =>
    _ClientMatchResponse(
      matchRequestId: json['match_request_id'] as String,
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => ClientMatchCard.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ClientMatchResponseToJson(
  _ClientMatchResponse instance,
) => <String, dynamic>{
  'match_request_id': instance.matchRequestId,
  'items': instance.items,
};
