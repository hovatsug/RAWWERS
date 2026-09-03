/// LocalePreferenceUpdateRequest
/// {
///     "properties": {
///         "locale": {
///             "type": "string",
///             "title": "Locale"
///         }
///     },
///     "type": "object",
///     "required": [
///         "locale"
///     ],
///     "title": "LocalePreferenceUpdateRequest"
/// }
library locale_preference_update_request;

import 'exports.dart';
part 'locale_preference_update_request.freezed.dart';
part 'locale_preference_update_request.g.dart'; // LocalePreferenceUpdateRequest

@freezed
abstract class LocalePreferenceUpdateRequest
    with _$LocalePreferenceUpdateRequest {
  const LocalePreferenceUpdateRequest._();

  @jsonSerializable
  const factory LocalePreferenceUpdateRequest({
    /// locale
    @JsonKey(name: LocalePreferenceUpdateRequest.localeKey_)
    required String locale,
  }) = _LocalePreferenceUpdateRequest;

  factory LocalePreferenceUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$LocalePreferenceUpdateRequestFromJson(json);

  static const String localeKey_ = r'locale';
}
