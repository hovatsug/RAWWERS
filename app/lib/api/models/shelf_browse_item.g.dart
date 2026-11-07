// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shelf_browse_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShelfBrowseItem _$ShelfBrowseItemFromJson(Map<String, dynamic> json) =>
    _ShelfBrowseItem(
      id: json['id'] as String,
      title: json['title'] as String,
      brand: json['brand'] as String?,
      category: json['category'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      level: (json['level'] as num).toInt(),
      priceRaww: (json['price_raww'] as num).toInt(),
      inStock: json['in_stock'] as bool,
      fitsYourGear: json['fits_your_gear'] as bool,
      wished: json['wished'] as bool,
      affordable: json['affordable'] as bool,
      locked: json['locked'] as bool,
      coverUrl: json['cover_url'] as String?,
      imageUrls: (json['image_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      cameraNames: (json['camera_names'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ShelfBrowseItemToJson(_ShelfBrowseItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'brand': instance.brand,
      'category': instance.category,
      'description': instance.description,
      'image_url': instance.imageUrl,
      'level': instance.level,
      'price_raww': instance.priceRaww,
      'in_stock': instance.inStock,
      'fits_your_gear': instance.fitsYourGear,
      'wished': instance.wished,
      'affordable': instance.affordable,
      'locked': instance.locked,
      'cover_url': instance.coverUrl,
      'image_urls': instance.imageUrls,
      'camera_names': instance.cameraNames,
    };
