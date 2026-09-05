// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proof_gallery_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProofGalleryResponse _$ProofGalleryResponseFromJson(
  Map<String, dynamic> json,
) => _ProofGalleryResponse(
  id: json['id'] as String,
  gigId: json['gig_id'] as String,
  proUserId: json['pro_user_id'] as String,
  clientUserId: json['client_user_id'] as String,
  includedPhotos: (json['included_photos'] as num).toInt(),
  extraPhotoPrice: json['extra_photo_price'] as String,
  currency: json['currency'] as String,
  status: ProofGalleryStatus.fromJson(json['status'] as String),
  publishedAt: json['published_at'] == null
      ? null
      : DateTime.parse(json['published_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ProofGalleryResponseToJson(
  _ProofGalleryResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'gig_id': instance.gigId,
  'pro_user_id': instance.proUserId,
  'client_user_id': instance.clientUserId,
  'included_photos': instance.includedPhotos,
  'extra_photo_price': instance.extraPhotoPrice,
  'currency': instance.currency,
  'status': instance.status,
  'published_at': instance.publishedAt?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
