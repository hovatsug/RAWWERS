/// MediaDerivativeView
/// {
///     "properties": {
///         "kind": {
///             "type": "string",
///             "title": "Kind"
///         }
///     },
///     "type": "object",
///     "required": [
///         "kind"
///     ],
///     "title": "MediaDerivativeView"
/// }
library media_derivative_view;

import 'exports.dart';
part 'media_derivative_view.freezed.dart';
part 'media_derivative_view.g.dart'; // MediaDerivativeView

@freezed
abstract class MediaDerivativeView with _$MediaDerivativeView {
  const MediaDerivativeView._();

  @jsonSerializable
  const factory MediaDerivativeView({
    /// kind
    @JsonKey(name: MediaDerivativeView.kindKey_) required String kind,
  }) = _MediaDerivativeView;

  factory MediaDerivativeView.fromJson(Map<String, dynamic> json) =>
      _$MediaDerivativeViewFromJson(json);

  static const String kindKey_ = r'kind';
}
