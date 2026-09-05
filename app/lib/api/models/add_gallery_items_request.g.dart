// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_gallery_items_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AddGalleryItemsRequest _$AddGalleryItemsRequestFromJson(
  Map<String, dynamic> json,
) => _AddGalleryItemsRequest(
  mediaAssetIds: (json['media_asset_ids'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  sortOrderOptional: (json['sort_order_optional'] as num?)?.toInt(),
);

Map<String, dynamic> _$AddGalleryItemsRequestToJson(
  _AddGalleryItemsRequest instance,
) => <String, dynamic>{
  'media_asset_ids': instance.mediaAssetIds,
  'sort_order_optional': instance.sortOrderOptional,
};
