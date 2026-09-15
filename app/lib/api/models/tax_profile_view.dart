/// TaxProfileView
/// {
///     "properties": {
///         "vat_status": {
///             "type": "string",
///             "title": "Vat Status"
///         },
///         "vat_number": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Vat Number"
///         },
///         "country": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Country"
///         },
///         "tax_name": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Tax Name"
///         },
///         "standard_rate_percent": {
///             "anyOf": [
///                 {
///                     "type": "integer"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Standard Rate Percent"
///         },
///         "registration_threshold": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Registration Threshold"
///         },
///         "threshold_currency": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Threshold Currency"
///         },
///         "vat_number_format": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Vat Number Format"
///         }
///     },
///     "type": "object",
///     "required": [
///         "vat_status"
///     ],
///     "title": "TaxProfileView",
///     "description": "What a photographer has told us about their own tax position."
/// }
library tax_profile_view;

import 'exports.dart';
part 'tax_profile_view.freezed.dart';
part 'tax_profile_view.g.dart'; // TaxProfileView

@freezed
abstract class TaxProfileView with _$TaxProfileView {
  const TaxProfileView._();

  @jsonSerializable
  const factory TaxProfileView({
    /// vatStatus
    @JsonKey(name: TaxProfileView.vatStatusKey_) required String vatStatus,

    /// vatNumber
    @JsonKey(name: TaxProfileView.vatNumberKey_) String? vatNumber,

    /// country
    @JsonKey(name: TaxProfileView.countryKey_) String? country,

    /// taxName
    @JsonKey(name: TaxProfileView.taxNameKey_) String? taxName,

    /// standardRatePercent
    @JsonKey(name: TaxProfileView.standardRatePercentKey_)
    int? standardRatePercent,

    /// registrationThreshold
    @JsonKey(name: TaxProfileView.registrationThresholdKey_)
    String? registrationThreshold,

    /// thresholdCurrency
    @JsonKey(name: TaxProfileView.thresholdCurrencyKey_)
    String? thresholdCurrency,

    /// vatNumberFormat
    @JsonKey(name: TaxProfileView.vatNumberFormatKey_) String? vatNumberFormat,
  }) = _TaxProfileView;

  factory TaxProfileView.fromJson(Map<String, dynamic> json) =>
      _$TaxProfileViewFromJson(json);

  static const String vatStatusKey_ = r'vat_status';

  static const String vatNumberKey_ = r'vat_number';

  static const String countryKey_ = r'country';

  static const String taxNameKey_ = r'tax_name';

  static const String standardRatePercentKey_ = r'standard_rate_percent';

  static const String registrationThresholdKey_ = r'registration_threshold';

  static const String thresholdCurrencyKey_ = r'threshold_currency';

  static const String vatNumberFormatKey_ = r'vat_number_format';
}
