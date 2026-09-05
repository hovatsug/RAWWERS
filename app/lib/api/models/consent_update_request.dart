/// ConsentUpdateRequest
/// {
///     "properties": {
///         "channel": {
///             "$ref": "#/components/schemas/ConsentChannel"
///         },
///         "scope": {
///             "$ref": "#/components/schemas/ConsentScope"
///         },
///         "granted": {
///             "type": "boolean",
///             "title": "Granted"
///         },
///         "source": {
///             "type": "string",
///             "default": "in_app_toggle",
///             "title": "Source"
///         },
///         "metadata": {
///             "type": "object",
///             "title": "Metadata"
///         }
///     },
///     "type": "object",
///     "required": [
///         "channel",
///         "scope",
///         "granted"
///     ],
///     "title": "ConsentUpdateRequest"
/// }
library consent_update_request;

import 'exports.dart';
part 'consent_update_request.freezed.dart';
part 'consent_update_request.g.dart'; // ConsentUpdateRequest

@freezed
abstract class ConsentUpdateRequest with _$ConsentUpdateRequest {
  const ConsentUpdateRequest._();

  @jsonSerializable
  const factory ConsentUpdateRequest({
    /// channel
    @JsonKey(name: ConsentUpdateRequest.channelKey_)
    required ConsentChannel channel,

    /// scope
    @JsonKey(name: ConsentUpdateRequest.scopeKey_) required ConsentScope scope,

    /// granted
    @JsonKey(name: ConsentUpdateRequest.grantedKey_) required bool granted,

    /// source
    @Default('in_app_toggle')
    @JsonKey(name: ConsentUpdateRequest.sourceKey_)
    String source,

    /// metadata
    @JsonKey(name: ConsentUpdateRequest.metadataKey_)
    Map<String, dynamic>? metadata,
  }) = _ConsentUpdateRequest;

  factory ConsentUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$ConsentUpdateRequestFromJson(json);

  static const String channelKey_ = r'channel';

  static const String scopeKey_ = r'scope';

  static const String grantedKey_ = r'granted';

  static const String sourceKey_ = r'source';

  static const String metadataKey_ = r'metadata';
}
