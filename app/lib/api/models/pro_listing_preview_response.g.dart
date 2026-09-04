// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pro_listing_preview_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProListingPreviewResponse _$ProListingPreviewResponseFromJson(
  Map<String, dynamic> json,
) => _ProListingPreviewResponse(
  card: ClientDiscoverCard.fromJson(json['card'] as Map<String, dynamic>),
  isLive: json['is_live'] as bool,
  blockingReasons: (json['blocking_reasons'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  availableDaysNext14: (json['available_days_next_14'] as num?)?.toInt(),
);

Map<String, dynamic> _$ProListingPreviewResponseToJson(
  _ProListingPreviewResponse instance,
) => <String, dynamic>{
  'card': instance.card,
  'is_live': instance.isLive,
  'blocking_reasons': instance.blockingReasons,
  'available_days_next_14': instance.availableDaysNext14,
};
