/// ResponseIn
/// {
///     "properties": {
///         "text": {
///             "type": "string",
///             "maxLength": 4000,
///             "minLength": 1,
///             "title": "Text"
///         }
///     },
///     "type": "object",
///     "required": [
///         "text"
///     ],
///     "title": "ResponseIn"
/// }
library response_in;

import 'exports.dart';
part 'response_in.freezed.dart';
part 'response_in.g.dart'; // ResponseIn

@freezed
abstract class ResponseIn with _$ResponseIn {
  const ResponseIn._();

  @jsonSerializable
  const factory ResponseIn({
    /// text
    @JsonKey(name: ResponseIn.textKey_) required String text,
  }) = _ResponseIn;

  factory ResponseIn.fromJson(Map<String, dynamic> json) =>
      _$ResponseInFromJson(json);

  static const String textKey_ = r'text';
}
