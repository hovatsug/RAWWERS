// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shelf_browse_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShelfBrowseResponse _$ShelfBrowseResponseFromJson(Map<String, dynamic> json) =>
    _ShelfBrowseResponse(
      tier: json['tier'] as String,
      maxLevel: (json['max_level'] as num).toInt(),
      spendable: (json['spendable'] as num).toInt(),
      hasCamera: json['has_camera'] as bool,
      wishlistMax: (json['wishlist_max'] as num).toInt(),
      termsText: json['terms_text'] as String,
      termsDraft: json['terms_draft'] as bool,
      levels: (json['levels'] as List<dynamic>)
          .map((e) => ShelfBrowseLevel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ShelfBrowseResponseToJson(
  _ShelfBrowseResponse instance,
) => <String, dynamic>{
  'tier': instance.tier,
  'max_level': instance.maxLevel,
  'spendable': instance.spendable,
  'has_camera': instance.hasCamera,
  'wishlist_max': instance.wishlistMax,
  'terms_text': instance.termsText,
  'terms_draft': instance.termsDraft,
  'levels': instance.levels,
};
