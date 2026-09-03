// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gig_media_asset_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GigMediaAssetView _$GigMediaAssetViewFromJson(Map<String, dynamic> json) =>
    _GigMediaAssetView(
      mediaAssetId: json['media_asset_id'] as String,
      kind: json['kind'] as String,
      purpose: json['purpose'] as String,
      derivatives: (json['derivatives'] as List<dynamic>?)
          ?.map((e) => MediaDerivativeView.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GigMediaAssetViewToJson(_GigMediaAssetView instance) =>
    <String, dynamic>{
      'media_asset_id': instance.mediaAssetId,
      'kind': instance.kind,
      'purpose': instance.purpose,
      'derivatives': instance.derivatives,
    };
