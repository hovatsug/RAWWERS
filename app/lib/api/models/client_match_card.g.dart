// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_match_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClientMatchCard _$ClientMatchCardFromJson(Map<String, dynamic> json) =>
    _ClientMatchCard(
      proUserId: json['pro_user_id'] as String,
      rank: (json['rank'] as num).toInt(),
      score: json['score'] as String,
      card: ClientDiscoverCard.fromJson(json['card'] as Map<String, dynamic>),
      scoreBreakdown: json['score_breakdown'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ClientMatchCardToJson(_ClientMatchCard instance) =>
    <String, dynamic>{
      'pro_user_id': instance.proUserId,
      'rank': instance.rank,
      'score': instance.score,
      'card': instance.card,
      'score_breakdown': instance.scoreBreakdown,
    };
