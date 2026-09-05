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
);

Map<String, dynamic> _$GalleryDetailResponseToJson(
  _GalleryDetailResponse instance,
) => <String, dynamic>{'gallery': instance.gallery, 'items': instance.items};
