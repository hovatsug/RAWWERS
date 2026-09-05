// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_review_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateReviewRequest _$CreateReviewRequestFromJson(Map<String, dynamic> json) =>
    _CreateReviewRequest(
      rating: (json['rating'] as num).toInt(),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      text: json['text'] as String?,
      wouldBookAgain: json['would_book_again'] as bool? ?? true,
      videoMediaAssetId: json['video_media_asset_id'] as String?,
    );

Map<String, dynamic> _$CreateReviewRequestToJson(
  _CreateReviewRequest instance,
) => <String, dynamic>{
  'rating': instance.rating,
  'tags': instance.tags,
  'text': instance.text,
  'would_book_again': instance.wouldBookAgain,
  'video_media_asset_id': instance.videoMediaAssetId,
};
