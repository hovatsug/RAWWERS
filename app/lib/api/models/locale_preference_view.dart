/// LocalePreferenceView
/// {
///     "properties": {
///         "user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "User Id"
///         },
///         "locale": {
///             "type": "string",
///             "title": "Locale"
///         }
///     },
///     "type": "object",
///     "required": [
///         "user_id",
///         "locale"
///     ],
///     "title": "LocalePreferenceView"
/// }
library locale_preference_view;

import 'exports.dart';
part 'locale_preference_view.freezed.dart';
part 'locale_preference_view.g.dart'; // LocalePreferenceView

@freezed
abstract class LocalePreferenceView with _$LocalePreferenceView {
  const LocalePreferenceView._();

  @jsonSerializable
  const factory LocalePreferenceView({
    /// userId
    @JsonKey(name: LocalePreferenceView.userIdKey_) required String userId,

    /// locale
    @JsonKey(name: LocalePreferenceView.localeKey_) required String locale,
  }) = _LocalePreferenceView;

  factory LocalePreferenceView.fromJson(Map<String, dynamic> json) =>
      _$LocalePreferenceViewFromJson(json);

  static const String userIdKey_ = r'user_id';

  static const String localeKey_ = r'locale';
}
