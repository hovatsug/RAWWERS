/// AnalyticsCreateRequest
/// {
///     "properties": {
///         "event_name": {
///             "type": "string",
///             "title": "Event Name"
///         },
///         "properties": {
///             "type": "object",
///             "title": "Properties"
///         },
///         "session_id": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Session Id"
///         }
///     },
///     "type": "object",
///     "required": [
///         "event_name"
///     ],
///     "title": "AnalyticsCreateRequest"
/// }
library analytics_create_request;

import 'exports.dart';
part 'analytics_create_request.freezed.dart';
part 'analytics_create_request.g.dart'; // AnalyticsCreateRequest

@freezed
abstract class AnalyticsCreateRequest with _$AnalyticsCreateRequest {
  const AnalyticsCreateRequest._();

  @jsonSerializable
  const factory AnalyticsCreateRequest({
    /// eventName
    @JsonKey(name: AnalyticsCreateRequest.eventNameKey_)
    required String eventName,

    /// properties
    @JsonKey(name: AnalyticsCreateRequest.propertiesKey_)
    Map<String, dynamic>? properties,

    /// sessionId
    @JsonKey(name: AnalyticsCreateRequest.sessionIdKey_) String? sessionId,
  }) = _AnalyticsCreateRequest;

  factory AnalyticsCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsCreateRequestFromJson(json);

  static const String eventNameKey_ = r'event_name';

  static const String propertiesKey_ = r'properties';

  static const String sessionIdKey_ = r'session_id';
}
