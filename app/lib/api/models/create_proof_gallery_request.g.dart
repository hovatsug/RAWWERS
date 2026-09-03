// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_proof_gallery_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateProofGalleryRequest _$CreateProofGalleryRequestFromJson(
  Map<String, dynamic> json,
) => _CreateProofGalleryRequest(
  includedPhotos: (json['included_photos'] as num).toInt(),
  extraPhotoPrice: json['extra_photo_price'],
);

Map<String, dynamic> _$CreateProofGalleryRequestToJson(
  _CreateProofGalleryRequest instance,
) => <String, dynamic>{
  'included_photos': instance.includedPhotos,
  'extra_photo_price': instance.extraPhotoPrice,
};
