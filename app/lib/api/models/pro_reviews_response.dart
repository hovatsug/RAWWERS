/// ProReviewsResponse
/// {
///     "properties": {
///         "total": {
///             "type": "integer",
///             "title": "Total"
///         },
///         "items": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/ReviewView"
///             },
///             "title": "Items"
///         }
///     },
///     "type": "object",
///     "required": [
///         "total",
///         "items"
///     ],
///     "title": "ProReviewsResponse"
/// }
library pro_reviews_response;

import 'exports.dart';
part 'pro_reviews_response.freezed.dart';
part 'pro_reviews_response.g.dart'; // ProReviewsResponse

@freezed
abstract class ProReviewsResponse with _$ProReviewsResponse {
  const ProReviewsResponse._();

  @jsonSerializable
  const factory ProReviewsResponse({
    /// total
    @JsonKey(name: ProReviewsResponse.totalKey_) required int total,

    /// items
    @JsonKey(name: ProReviewsResponse.itemsKey_)
    required List<ReviewView> items,
  }) = _ProReviewsResponse;

  factory ProReviewsResponse.fromJson(Map<String, dynamic> json) =>
      _$ProReviewsResponseFromJson(json);

  static const String totalKey_ = r'total';

  static const String itemsKey_ = r'items';
}
