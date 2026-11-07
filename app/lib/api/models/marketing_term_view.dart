/// MarketingTermView
/// {
///     "properties": {
///         "months": {
///             "type": "integer",
///             "title": "Months"
///         },
///         "credit": {
///             "type": "integer",
///             "title": "Credit"
///         },
///         "credit_eur": {
///             "type": "string",
///             "default": "0.00",
///             "title": "Credit Eur"
///         }
///     },
///     "type": "object",
///     "required": [
///         "months",
///         "credit"
///     ],
///     "title": "MarketingTermView"
/// }
library marketing_term_view;

import 'exports.dart';
part 'marketing_term_view.freezed.dart';
part 'marketing_term_view.g.dart'; // MarketingTermView

@freezed
abstract class MarketingTermView with _$MarketingTermView {
  const MarketingTermView._();

  @jsonSerializable
  const factory MarketingTermView({
    /// months
    @JsonKey(name: MarketingTermView.monthsKey_) required int months,

    /// credit
    @JsonKey(name: MarketingTermView.creditKey_) required int credit,

    /// creditEur
    @Default('0.00')
    @JsonKey(name: MarketingTermView.creditEurKey_)
    String creditEur,
  }) = _MarketingTermView;

  factory MarketingTermView.fromJson(Map<String, dynamic> json) =>
      _$MarketingTermViewFromJson(json);

  static const String monthsKey_ = r'months';

  static const String creditKey_ = r'credit';

  static const String creditEurKey_ = r'credit_eur';
}
