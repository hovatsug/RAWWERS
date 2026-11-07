// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shelf_browse_level.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShelfBrowseLevel _$ShelfBrowseLevelFromJson(Map<String, dynamic> json) =>
    _ShelfBrowseLevel(
      level: (json['level'] as num).toInt(),
      bandRaww: (json['band_raww'] as num).toInt(),
      bandEur: json['band_eur'] as String? ?? '0.00',
      locked: json['locked'] as bool,
      unlocksAtTier: json['unlocks_at_tier'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((e) => ShelfBrowseItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ShelfBrowseLevelToJson(_ShelfBrowseLevel instance) =>
    <String, dynamic>{
      'level': instance.level,
      'band_raww': instance.bandRaww,
      'band_eur': instance.bandEur,
      'locked': instance.locked,
      'unlocks_at_tier': instance.unlocksAtTier,
      'items': instance.items,
    };
