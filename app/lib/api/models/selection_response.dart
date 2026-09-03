/// SelectionResponse
/// {
///     "properties": {
///         "selection_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Selection Id"
///         },
///         "version": {
///             "type": "integer",
///             "title": "Version"
///         },
///         "status": {
///             "$ref": "#/components/schemas/SelectionStatus"
///         },
///         "selected_count": {
///             "type": "integer",
///             "title": "Selected Count"
///         }
///     },
///     "type": "object",
///     "required": [
///         "selection_id",
///         "version",
///         "status",
///         "selected_count"
///     ],
///     "title": "SelectionResponse"
/// }
library selection_response;

import 'exports.dart';
part 'selection_response.freezed.dart';
part 'selection_response.g.dart'; // SelectionResponse

@freezed
abstract class SelectionResponse with _$SelectionResponse {
  const SelectionResponse._();

  @jsonSerializable
  const factory SelectionResponse({
    /// selectionId
    @JsonKey(name: SelectionResponse.selectionIdKey_)
    required String selectionId,

    /// version
    @JsonKey(name: SelectionResponse.versionKey_) required int version,

    /// status
    @JsonKey(name: SelectionResponse.statusKey_)
    required SelectionStatus status,

    /// selectedCount
    @JsonKey(name: SelectionResponse.selectedCountKey_)
    required int selectedCount,
  }) = _SelectionResponse;

  factory SelectionResponse.fromJson(Map<String, dynamic> json) =>
      _$SelectionResponseFromJson(json);

  static const String selectionIdKey_ = r'selection_id';

  static const String versionKey_ = r'version';

  static const String statusKey_ = r'status';

  static const String selectedCountKey_ = r'selected_count';
}
