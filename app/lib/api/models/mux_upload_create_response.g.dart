// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mux_upload_create_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MuxUploadCreateResponse _$MuxUploadCreateResponseFromJson(
  Map<String, dynamic> json,
) => _MuxUploadCreateResponse(
  mediaAssetId: json['media_asset_id'] as String,
  mux: MuxPayload.fromJson(json['mux'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MuxUploadCreateResponseToJson(
  _MuxUploadCreateResponse instance,
) => <String, dynamic>{
  'media_asset_id': instance.mediaAssetId,
  'mux': instance.mux,
};
