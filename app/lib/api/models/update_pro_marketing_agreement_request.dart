/// UpdateProMarketingAgreementRequest
/// {
///     "properties": {
///         "opted_in": {
///             "type": "boolean",
///             "title": "Opted In"
///         }
///     },
///     "type": "object",
///     "required": [
///         "opted_in"
///     ],
///     "title": "UpdateProMarketingAgreementRequest"
/// }
library update_pro_marketing_agreement_request;

import 'exports.dart';
part 'update_pro_marketing_agreement_request.freezed.dart';
part 'update_pro_marketing_agreement_request.g.dart'; // UpdateProMarketingAgreementRequest

@freezed
abstract class UpdateProMarketingAgreementRequest
    with _$UpdateProMarketingAgreementRequest {
  const UpdateProMarketingAgreementRequest._();

  @jsonSerializable
  const factory UpdateProMarketingAgreementRequest({
    /// optedIn
    @JsonKey(name: UpdateProMarketingAgreementRequest.optedInKey_)
    required bool optedIn,
  }) = _UpdateProMarketingAgreementRequest;

  factory UpdateProMarketingAgreementRequest.fromJson(
    Map<String, dynamic> json,
  ) => _$UpdateProMarketingAgreementRequestFromJson(json);

  static const String optedInKey_ = r'opted_in';
}
