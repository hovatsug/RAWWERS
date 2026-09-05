// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pro_reviews_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProReviewsResponse _$ProReviewsResponseFromJson(Map<String, dynamic> json) =>
    _ProReviewsResponse(
      total: (json['total'] as num).toInt(),
      items: (json['items'] as List<dynamic>)
          .map((e) => ReviewView.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ProReviewsResponseToJson(_ProReviewsResponse instance) =>
    <String, dynamic>{'total': instance.total, 'items': instance.items};
