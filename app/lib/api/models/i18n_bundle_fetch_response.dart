/// I18nBundleFetchResponse
/// {
///     "properties": {
///         "locale": {
///             "type": "string",
///             "title": "Locale"
///         },
///         "namespace": {
///             "type": "string",
///             "title": "Namespace"
///         },
///         "version": {
///             "type": "integer",
///             "title": "Version"
///         },
///         "content": {
///             "type": "object",
///             "title": "Content"
///         }
///     },
///     "type": "object",
///     "required": [
///         "locale",
///         "namespace",
///         "version"
///     ],
///     "title": "I18nBundleFetchResponse"
/// }
library i18n_bundle_fetch_response;

import 'exports.dart';
part 'i18n_bundle_fetch_response.freezed.dart';
part 'i18n_bundle_fetch_response.g.dart'; // I18nBundleFetchResponse

@freezed
abstract class I18nBundleFetchResponse with _$I18nBundleFetchResponse {
  const I18nBundleFetchResponse._();

  @jsonSerializable
  const factory I18nBundleFetchResponse({
    /// locale
    @JsonKey(name: I18nBundleFetchResponse.localeKey_) required String locale,

    /// namespace
    @JsonKey(name: I18nBundleFetchResponse.namespaceKey_)
    required String namespace,

    /// version
    @JsonKey(name: I18nBundleFetchResponse.versionKey_) required int version,

    /// content
    @JsonKey(name: I18nBundleFetchResponse.contentKey_)
    Map<String, dynamic>? content,
  }) = _I18nBundleFetchResponse;

  factory I18nBundleFetchResponse.fromJson(Map<String, dynamic> json) =>
      _$I18nBundleFetchResponseFromJson(json);

  static const String localeKey_ = r'locale';

  static const String namespaceKey_ = r'namespace';

  static const String versionKey_ = r'version';

  static const String contentKey_ = r'content';
}
