// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'i18n_bundle_fetch_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_I18nBundleFetchResponse _$I18nBundleFetchResponseFromJson(
  Map<String, dynamic> json,
) => _I18nBundleFetchResponse(
  locale: json['locale'] as String,
  namespace: json['namespace'] as String,
  version: (json['version'] as num).toInt(),
  content: json['content'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$I18nBundleFetchResponseToJson(
  _I18nBundleFetchResponse instance,
) => <String, dynamic>{
  'locale': instance.locale,
  'namespace': instance.namespace,
  'version': instance.version,
  'content': instance.content,
};
