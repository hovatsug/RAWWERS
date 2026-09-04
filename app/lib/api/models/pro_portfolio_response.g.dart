// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pro_portfolio_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProPortfolioResponse _$ProPortfolioResponseFromJson(
  Map<String, dynamic> json,
) => _ProPortfolioResponse(
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => ProPortfolioItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  photoCount: (json['photo_count'] as num).toInt(),
  videoCount: (json['video_count'] as num).toInt(),
  photoMinimum: (json['photo_minimum'] as num).toInt(),
);

Map<String, dynamic> _$ProPortfolioResponseToJson(
  _ProPortfolioResponse instance,
) => <String, dynamic>{
  'items': instance.items,
  'photo_count': instance.photoCount,
  'video_count': instance.videoCount,
  'photo_minimum': instance.photoMinimum,
};
