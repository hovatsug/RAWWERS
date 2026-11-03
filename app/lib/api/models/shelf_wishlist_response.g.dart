// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shelf_wishlist_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShelfWishlistResponse _$ShelfWishlistResponseFromJson(
  Map<String, dynamic> json,
) => _ShelfWishlistResponse(
  itemIds: (json['item_ids'] as List<dynamic>).map((e) => e as String).toList(),
  limit: (json['limit'] as num).toInt(),
);

Map<String, dynamic> _$ShelfWishlistResponseToJson(
  _ShelfWishlistResponse instance,
) => <String, dynamic>{'item_ids': instance.itemIds, 'limit': instance.limit};
