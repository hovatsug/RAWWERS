// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_candidate.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MatchCandidate _$MatchCandidateFromJson(Map<String, dynamic> json) =>
    _MatchCandidate(
      proUserId: json['pro_user_id'] as String,
      rankingScore: json['ranking_score'] as String,
      reasons: (json['reasons'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$MatchCandidateToJson(_MatchCandidate instance) =>
    <String, dynamic>{
      'pro_user_id': instance.proUserId,
      'ranking_score': instance.rankingScore,
      'reasons': instance.reasons,
    };
