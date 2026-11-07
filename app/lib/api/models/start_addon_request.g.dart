// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'start_addon_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StartAddonRequest _$StartAddonRequestFromJson(Map<String, dynamic> json) =>
    _StartAddonRequest(
      mediaAssetIds: (json['media_asset_ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      clientRequestId: json['client_request_id'] as String,
    );

Map<String, dynamic> _$StartAddonRequestToJson(_StartAddonRequest instance) =>
    <String, dynamic>{
      'media_asset_ids': instance.mediaAssetIds,
      'client_request_id': instance.clientRequestId,
    };
