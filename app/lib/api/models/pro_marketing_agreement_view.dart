/// ProMarketingAgreementView
/// {
///     "properties": {
///         "opted_in": {
///             "type": "boolean",
///             "title": "Opted In"
///         },
///         "wording_version": {
///             "type": "string",
///             "title": "Wording Version"
///         },
///         "wording_text": {
///             "type": "string",
///             "title": "Wording Text"
///         },
///         "recorded_at": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "date-time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Recorded At"
///         }
///     },
///     "type": "object",
///     "required": [
///         "opted_in",
///         "wording_version",
///         "wording_text"
///     ],
///     "title": "ProMarketingAgreementView"
/// }
library pro_marketing_agreement_view;

import 'exports.dart';
part 'pro_marketing_agreement_view.freezed.dart';
part 'pro_marketing_agreement_view.g.dart'; // ProMarketingAgreementView

@freezed
abstract class ProMarketingAgreementView with _$ProMarketingAgreementView {
  const ProMarketingAgreementView._();

  @jsonSerializable
  const factory ProMarketingAgreementView({
    /// optedIn
    @JsonKey(name: ProMarketingAgreementView.optedInKey_) required bool optedIn,

    /// wordingVersion
    @JsonKey(name: ProMarketingAgreementView.wordingVersionKey_)
    required String wordingVersion,

    /// wordingText
    @JsonKey(name: ProMarketingAgreementView.wordingTextKey_)
    required String wordingText,

    /// recordedAt
    @JsonKey(name: ProMarketingAgreementView.recordedAtKey_)
    DateTime? recordedAt,
  }) = _ProMarketingAgreementView;

  factory ProMarketingAgreementView.fromJson(Map<String, dynamic> json) =>
      _$ProMarketingAgreementViewFromJson(json);

  static const String optedInKey_ = r'opted_in';

  static const String wordingVersionKey_ = r'wording_version';

  static const String wordingTextKey_ = r'wording_text';

  static const String recordedAtKey_ = r'recorded_at';
}
