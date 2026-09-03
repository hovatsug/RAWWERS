// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dispute_message_create_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DisputeMessageCreateRequest _$DisputeMessageCreateRequestFromJson(
  Map<String, dynamic> json,
) => _DisputeMessageCreateRequest(
  message: json['message'] as String,
  evidenceMediaAssetIds: (json['evidence_media_asset_ids'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$DisputeMessageCreateRequestToJson(
  _DisputeMessageCreateRequest instance,
) => <String, dynamic>{
  'message': instance.message,
  'evidence_media_asset_ids': instance.evidenceMediaAssetIds,
};
