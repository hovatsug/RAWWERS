/// GigConsentView
/// {
///     "properties": {
///         "gig_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Gig Id"
///         },
///         "client_user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Client User Id"
///         },
///         "pro_user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Pro User Id"
///         },
///         "consent_level": {
///             "$ref": "#/components/schemas/GigConsentLevel"
///         },
///         "scope": {
///             "type": "object",
///             "title": "Scope"
///         },
///         "incentive": {
///             "type": "object",
///             "title": "Incentive"
///         },
///         "snapshot_at_booking": {
///             "type": "boolean",
///             "title": "Snapshot At Booking"
///         },
///         "created_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Created At"
///         },
///         "updated_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Updated At"
///         }
///     },
///     "type": "object",
///     "required": [
///         "gig_id",
///         "client_user_id",
///         "pro_user_id",
///         "consent_level",
///         "snapshot_at_booking",
///         "created_at",
///         "updated_at"
///     ],
///     "title": "GigConsentView"
/// }
library gig_consent_view;

import 'exports.dart';
part 'gig_consent_view.freezed.dart';
part 'gig_consent_view.g.dart'; // GigConsentView

@freezed
abstract class GigConsentView with _$GigConsentView {
  const GigConsentView._();

  @jsonSerializable
  const factory GigConsentView({
    /// gigId
    @JsonKey(name: GigConsentView.gigIdKey_) required String gigId,

    /// clientUserId
    @JsonKey(name: GigConsentView.clientUserIdKey_)
    required String clientUserId,

    /// proUserId
    @JsonKey(name: GigConsentView.proUserIdKey_) required String proUserId,

    /// consentLevel
    @JsonKey(name: GigConsentView.consentLevelKey_)
    required GigConsentLevel consentLevel,

    /// scope
    @JsonKey(name: GigConsentView.scopeKey_) Map<String, dynamic>? scope,

    /// incentive
    @JsonKey(name: GigConsentView.incentiveKey_)
    Map<String, dynamic>? incentive,

    /// snapshotAtBooking
    @JsonKey(name: GigConsentView.snapshotAtBookingKey_)
    required bool snapshotAtBooking,

    /// createdAt
    @JsonKey(name: GigConsentView.createdAtKey_) required DateTime createdAt,

    /// updatedAt
    @JsonKey(name: GigConsentView.updatedAtKey_) required DateTime updatedAt,
  }) = _GigConsentView;

  factory GigConsentView.fromJson(Map<String, dynamic> json) =>
      _$GigConsentViewFromJson(json);

  static const String gigIdKey_ = r'gig_id';

  static const String clientUserIdKey_ = r'client_user_id';

  static const String proUserIdKey_ = r'pro_user_id';

  static const String consentLevelKey_ = r'consent_level';

  static const String scopeKey_ = r'scope';

  static const String incentiveKey_ = r'incentive';

  static const String snapshotAtBookingKey_ = r'snapshot_at_booking';

  static const String createdAtKey_ = r'created_at';

  static const String updatedAtKey_ = r'updated_at';
}
