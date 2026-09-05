// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portfolio_niche_tags_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PortfolioNicheTagsRequest _$PortfolioNicheTagsRequestFromJson(
  Map<String, dynamic> json,
) => _PortfolioNicheTagsRequest(
  nicheSlugs: (json['niche_slugs'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$PortfolioNicheTagsRequestToJson(
  _PortfolioNicheTagsRequest instance,
) => <String, dynamic>{'niche_slugs': instance.nicheSlugs};
