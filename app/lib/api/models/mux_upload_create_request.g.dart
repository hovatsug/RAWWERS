// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mux_upload_create_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MuxUploadCreateRequest _$MuxUploadCreateRequestFromJson(
  Map<String, dynamic> json,
) => _MuxUploadCreateRequest(
  purpose: MediaPurpose.fromJson(json['purpose'] as String),
  visibility: json['visibility'] == null
      ? null
      : MediaVisibility.fromJson(json['visibility'] as String),
);

Map<String, dynamic> _$MuxUploadCreateRequestToJson(
  _MuxUploadCreateRequest instance,
) => <String, dynamic>{
  'purpose': instance.purpose,
  'visibility': instance.visibility,
};
