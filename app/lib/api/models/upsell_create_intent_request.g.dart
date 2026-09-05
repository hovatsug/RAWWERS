// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upsell_create_intent_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpsellCreateIntentRequest _$UpsellCreateIntentRequestFromJson(
  Map<String, dynamic> json,
) => _UpsellCreateIntentRequest(
  pointsToSpend: (json['points_to_spend'] as num?)?.toInt(),
  shareLinkId: json['share_link_id'] as String?,
);

Map<String, dynamic> _$UpsellCreateIntentRequestToJson(
  _UpsellCreateIntentRequest instance,
) => <String, dynamic>{
  'points_to_spend': instance.pointsToSpend,
  'share_link_id': instance.shareLinkId,
};
