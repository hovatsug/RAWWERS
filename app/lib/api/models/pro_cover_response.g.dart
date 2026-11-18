// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pro_cover_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProCoverResponse _$ProCoverResponseFromJson(Map<String, dynamic> json) =>
    _ProCoverResponse(
      coverMediaAssetId: json['cover_media_asset_id'] as String,
      changed: json['changed'] as bool,
    );

Map<String, dynamic> _$ProCoverResponseToJson(_ProCoverResponse instance) =>
    <String, dynamic>{
      'cover_media_asset_id': instance.coverMediaAssetId,
      'changed': instance.changed,
    };
