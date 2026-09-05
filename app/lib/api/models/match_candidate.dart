/// MatchCandidate
/// {
///     "properties": {
///         "pro_user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Pro User Id"
///         },
///         "ranking_score": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Ranking Score"
///         },
///         "reasons": {
///             "type": "array",
///             "items": {
///                 "type": "string"
///             },
///             "title": "Reasons"
///         }
///     },
///     "type": "object",
///     "required": [
///         "pro_user_id",
///         "ranking_score",
///         "reasons"
///     ],
///     "title": "MatchCandidate"
/// }
library match_candidate;

import 'exports.dart';
part 'match_candidate.freezed.dart';
part 'match_candidate.g.dart'; // MatchCandidate

@freezed
abstract class MatchCandidate with _$MatchCandidate {
  const MatchCandidate._();

  @jsonSerializable
  const factory MatchCandidate({
    /// proUserId
    @JsonKey(name: MatchCandidate.proUserIdKey_) required String proUserId,

    /// rankingScore
    @JsonKey(name: MatchCandidate.rankingScoreKey_)
    required String rankingScore,

    /// reasons
    @JsonKey(name: MatchCandidate.reasonsKey_) required List<String> reasons,
  }) = _MatchCandidate;

  factory MatchCandidate.fromJson(Map<String, dynamic> json) =>
      _$MatchCandidateFromJson(json);

  static const String proUserIdKey_ = r'pro_user_id';

  static const String rankingScoreKey_ = r'ranking_score';

  static const String reasonsKey_ = r'reasons';
}
