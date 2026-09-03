/// ClientMatchCard
/// {
///     "properties": {
///         "pro_user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Pro User Id"
///         },
///         "rank": {
///             "type": "integer",
///             "title": "Rank"
///         },
///         "score": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Score"
///         },
///         "card": {
///             "$ref": "#/components/schemas/ClientDiscoverCard"
///         },
///         "score_breakdown": {
///             "anyOf": [
///                 {
///                     "type": "object"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Score Breakdown"
///         }
///     },
///     "type": "object",
///     "required": [
///         "pro_user_id",
///         "rank",
///         "score",
///         "card"
///     ],
///     "title": "ClientMatchCard"
/// }
library client_match_card;

import 'exports.dart';
part 'client_match_card.freezed.dart';
part 'client_match_card.g.dart'; // ClientMatchCard

@freezed
abstract class ClientMatchCard with _$ClientMatchCard {
  const ClientMatchCard._();

  @jsonSerializable
  const factory ClientMatchCard({
    /// proUserId
    @JsonKey(name: ClientMatchCard.proUserIdKey_) required String proUserId,

    /// rank
    @JsonKey(name: ClientMatchCard.rankKey_) required int rank,

    /// score
    @JsonKey(name: ClientMatchCard.scoreKey_) required String score,

    /// card
    @JsonKey(name: ClientMatchCard.cardKey_) required ClientDiscoverCard card,

    /// scoreBreakdown
    @JsonKey(name: ClientMatchCard.scoreBreakdownKey_)
    Map<String, dynamic>? scoreBreakdown,
  }) = _ClientMatchCard;

  factory ClientMatchCard.fromJson(Map<String, dynamic> json) =>
      _$ClientMatchCardFromJson(json);

  static const String proUserIdKey_ = r'pro_user_id';

  static const String rankKey_ = r'rank';

  static const String scoreKey_ = r'score';

  static const String cardKey_ = r'card';

  static const String scoreBreakdownKey_ = r'score_breakdown';
}
