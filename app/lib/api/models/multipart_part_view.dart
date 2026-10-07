/// MultipartPartView
/// {
///     "properties": {
///         "part_number": {
///             "type": "integer",
///             "title": "Part Number"
///         },
///         "size": {
///             "type": "integer",
///             "title": "Size"
///         }
///     },
///     "type": "object",
///     "required": [
///         "part_number",
///         "size"
///     ],
///     "title": "MultipartPartView"
/// }
library multipart_part_view;

import 'exports.dart';
part 'multipart_part_view.freezed.dart';
part 'multipart_part_view.g.dart'; // MultipartPartView

@freezed
abstract class MultipartPartView with _$MultipartPartView {
  const MultipartPartView._();

  @jsonSerializable
  const factory MultipartPartView({
    /// partNumber
    @JsonKey(name: MultipartPartView.partNumberKey_) required int partNumber,

    /// size
    @JsonKey(name: MultipartPartView.sizeKey_) required int size,
  }) = _MultipartPartView;

  factory MultipartPartView.fromJson(Map<String, dynamic> json) =>
      _$MultipartPartViewFromJson(json);

  static const String partNumberKey_ = r'part_number';

  static const String sizeKey_ = r'size';
}
