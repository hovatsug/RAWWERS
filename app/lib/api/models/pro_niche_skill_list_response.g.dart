// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pro_niche_skill_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProNicheSkillListResponse _$ProNicheSkillListResponseFromJson(
  Map<String, dynamic> json,
) => _ProNicheSkillListResponse(
  proUserId: json['pro_user_id'] as String,
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => ProNicheSkillView.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ProNicheSkillListResponseToJson(
  _ProNicheSkillListResponse instance,
) => <String, dynamic>{
  'pro_user_id': instance.proUserId,
  'items': instance.items,
};
