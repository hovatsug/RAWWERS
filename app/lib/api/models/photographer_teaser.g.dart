// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photographer_teaser.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PhotographerTeaser _$PhotographerTeaserFromJson(Map<String, dynamic> json) =>
    _PhotographerTeaser(
      kind: TeaserKind.fromJson(json['kind'] as String),
      line: json['line'] as String?,
    );

Map<String, dynamic> _$PhotographerTeaserToJson(_PhotographerTeaser instance) =>
    <String, dynamic>{'kind': instance.kind, 'line': instance.line};
