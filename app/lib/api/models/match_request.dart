/// MatchRequest
/// {
///     "properties": {
///         "city": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "City"
///         },
///         "styles": {
///             "type": "array",
///             "items": {
///                 "type": "string"
///             },
///             "title": "Styles"
///         },
///         "budget": {
///             "anyOf": [
///                 {
///                     "type": "number"
///                 },
///                 {
///                     "type": "string",
///                     "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Budget"
///         },
///         "date_range": {
///             "anyOf": [
///                 {
///                     "type": "object"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Date Range"
///         },
///         "purpose": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Purpose"
///         },
///         "limit": {
///             "type": "integer",
///             "default": 10,
///             "title": "Limit"
///         }
///     },
///     "type": "object",
///     "title": "MatchRequest"
/// }
library match_request;

import 'exports.dart';
part 'match_request.freezed.dart';
part 'match_request.g.dart'; // MatchRequest

@freezed
abstract class MatchRequest with _$MatchRequest {
  const MatchRequest._();

  @jsonSerializable
  const factory MatchRequest({
    /// city
    @JsonKey(name: MatchRequest.cityKey_) String? city,

    /// styles
    @JsonKey(name: MatchRequest.stylesKey_) List<String>? styles,

    /// budget
    @JsonKey(name: MatchRequest.budgetKey_) dynamic? budget,

    /// dateRange
    @JsonKey(name: MatchRequest.dateRangeKey_) Map<String, dynamic>? dateRange,

    /// purpose
    @JsonKey(name: MatchRequest.purposeKey_) String? purpose,

    /// limit
    @Default(10) @JsonKey(name: MatchRequest.limitKey_) int limit,
  }) = _MatchRequest;

  factory MatchRequest.fromJson(Map<String, dynamic> json) =>
      _$MatchRequestFromJson(json);

  static const String cityKey_ = r'city';

  static const String stylesKey_ = r'styles';

  static const String budgetKey_ = r'budget';

  static const String dateRangeKey_ = r'date_range';

  static const String purposeKey_ = r'purpose';

  static const String limitKey_ = r'limit';
}
