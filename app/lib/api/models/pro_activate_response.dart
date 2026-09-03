/// ProActivateResponse
/// {
///     "properties": {
///         "is_accepting_bookings": {
///             "type": "boolean",
///             "title": "Is Accepting Bookings"
///         },
///         "completeness_score": {
///             "type": "integer",
///             "title": "Completeness Score"
///         },
///         "kyc_status": {
///             "type": "string",
///             "title": "Kyc Status"
///         }
///     },
///     "type": "object",
///     "required": [
///         "is_accepting_bookings",
///         "completeness_score",
///         "kyc_status"
///     ],
///     "title": "ProActivateResponse"
/// }
library pro_activate_response;

import 'exports.dart';
part 'pro_activate_response.freezed.dart';
part 'pro_activate_response.g.dart'; // ProActivateResponse

@freezed
abstract class ProActivateResponse with _$ProActivateResponse {
  const ProActivateResponse._();

  @jsonSerializable
  const factory ProActivateResponse({
    /// isAcceptingBookings
    @JsonKey(name: ProActivateResponse.isAcceptingBookingsKey_)
    required bool isAcceptingBookings,

    /// completenessScore
    @JsonKey(name: ProActivateResponse.completenessScoreKey_)
    required int completenessScore,

    /// kycStatus
    @JsonKey(name: ProActivateResponse.kycStatusKey_) required String kycStatus,
  }) = _ProActivateResponse;

  factory ProActivateResponse.fromJson(Map<String, dynamic> json) =>
      _$ProActivateResponseFromJson(json);

  static const String isAcceptingBookingsKey_ = r'is_accepting_bookings';

  static const String completenessScoreKey_ = r'completeness_score';

  static const String kycStatusKey_ = r'kyc_status';
}
