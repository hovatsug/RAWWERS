// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery_detail_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GalleryDetailResponse _$GalleryDetailResponseFromJson(
  Map<String, dynamic> json,
) => _GalleryDetailResponse(
  gallery: ProofGalleryResponse.fromJson(
    json['gallery'] as Map<String, dynamic>,
  ),
  items: (json['items'] as List<dynamic>)
      .map((e) => GalleryItemView.fromJson(e as Map<String, dynamic>))
      .toList(),
  addonWindowEndsAt: json['addon_window_ends_at'] == null
      ? null
      : DateTime.parse(json['addon_window_ends_at'] as String),
  addonOpen: json['addon_open'] as bool? ?? false,
  chosenMediaAssetIds: (json['chosen_media_asset_ids'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$GalleryDetailResponseToJson(
  _GalleryDetailResponse instance,
) => <String, dynamic>{
  'gallery': instance.gallery,
  'items': instance.items,
  'addon_window_ends_at': instance.addonWindowEndsAt?.toIso8601String(),
  'addon_open': instance.addonOpen,
  'chosen_media_asset_ids': instance.chosenMediaAssetIds,
};
