// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MatchResponse _$MatchResponseFromJson(Map<String, dynamic> json) =>
    _MatchResponse(
      items: (json['items'] as List<dynamic>)
          .map((e) => MatchCandidate.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MatchResponseToJson(_MatchResponse instance) =>
    <String, dynamic>{'items': instance.items};
