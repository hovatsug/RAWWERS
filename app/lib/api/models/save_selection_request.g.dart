// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_selection_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SaveSelectionRequest _$SaveSelectionRequestFromJson(
  Map<String, dynamic> json,
) => _SaveSelectionRequest(
  mediaAssetIds: (json['media_asset_ids'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$SaveSelectionRequestToJson(
  _SaveSelectionRequest instance,
) => <String, dynamic>{'media_asset_ids': instance.mediaAssetIds};
