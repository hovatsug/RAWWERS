/// GigListResponse
/// {
///     "properties": {
///         "items": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/GigResponse"
///             },
///             "title": "Items"
///         },
///         "next_cursor": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Next Cursor"
///         }
///     },
///     "type": "object",
///     "title": "GigListResponse",
///     "description": "Deliberately GigResponse rows, not GigDetailResponse rows.\n\nThe detail view attaches a payment summary and a ledger aggregate, both\nof which are per-gig queries; returning them for a page of gigs would be\nan N+1 on the most-hit screen in the pro app. A list row carries what a\nlist actually renders - status, schedule, money - and the detail route\nstays the way to get the rest."
/// }
library gig_list_response;

import 'exports.dart';
part 'gig_list_response.freezed.dart';
part 'gig_list_response.g.dart'; // GigListResponse

@freezed
abstract class GigListResponse with _$GigListResponse {
  const GigListResponse._();

  @jsonSerializable
  const factory GigListResponse({
    /// items
    @JsonKey(name: GigListResponse.itemsKey_) List<GigResponse>? items,

    /// nextCursor
    @JsonKey(name: GigListResponse.nextCursorKey_) String? nextCursor,
  }) = _GigListResponse;

  factory GigListResponse.fromJson(Map<String, dynamic> json) =>
      _$GigListResponseFromJson(json);

  static const String itemsKey_ = r'items';

  static const String nextCursorKey_ = r'next_cursor';
}
