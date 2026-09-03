/// MyMilestonesResponse
/// {
///     "properties": {
///         "total": {
///             "type": "integer",
///             "title": "Total"
///         },
///         "items": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/MyMilestoneItem"
///             },
///             "title": "Items"
///         }
///     },
///     "type": "object",
///     "required": [
///         "total",
///         "items"
///     ],
///     "title": "MyMilestonesResponse"
/// }
library my_milestones_response;

import 'exports.dart';
part 'my_milestones_response.freezed.dart';
part 'my_milestones_response.g.dart'; // MyMilestonesResponse

@freezed
abstract class MyMilestonesResponse with _$MyMilestonesResponse {
  const MyMilestonesResponse._();

  @jsonSerializable
  const factory MyMilestonesResponse({
    /// total
    @JsonKey(name: MyMilestonesResponse.totalKey_) required int total,

    /// items
    @JsonKey(name: MyMilestonesResponse.itemsKey_)
    required List<MyMilestoneItem> items,
  }) = _MyMilestonesResponse;

  factory MyMilestonesResponse.fromJson(Map<String, dynamic> json) =>
      _$MyMilestonesResponseFromJson(json);

  static const String totalKey_ = r'total';

  static const String itemsKey_ = r'items';
}
