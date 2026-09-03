// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gig_media_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GigMediaListResponse _$GigMediaListResponseFromJson(
  Map<String, dynamic> json,
) => _GigMediaListResponse(
  gigId: json['gig_id'] as String,
  assets: (json['assets'] as List<dynamic>?)
      ?.map((e) => GigMediaAssetView.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GigMediaListResponseToJson(
  _GigMediaListResponse instance,
) => <String, dynamic>{'gig_id': instance.gigId, 'assets': instance.assets};
