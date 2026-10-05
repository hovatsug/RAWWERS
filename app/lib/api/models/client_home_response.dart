/// ClientHomeResponse
/// {
///     "properties": {
///         "rows": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/ClientHomeRow"
///             },
///             "title": "Rows"
///         },
///         "guest_limited": {
///             "type": "boolean",
///             "default": false,
///             "title": "Guest Limited"
///         },
///         "niche": {
///             "anyOf": [
///                 {
///                     "$ref": "#/components/schemas/ClientHomeNiche"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ]
///         }
///     },
///     "type": "object",
///     "title": "ClientHomeResponse"
/// }
library client_home_response;

import 'exports.dart';
part 'client_home_response.freezed.dart';
part 'client_home_response.g.dart'; // ClientHomeResponse

@freezed
abstract class ClientHomeResponse with _$ClientHomeResponse {
  const ClientHomeResponse._();

  @jsonSerializable
  const factory ClientHomeResponse({
    /// rows
    @JsonKey(name: ClientHomeResponse.rowsKey_) List<ClientHomeRow>? rows,

    /// guestLimited
    @Default(false)
    @JsonKey(name: ClientHomeResponse.guestLimitedKey_)
    bool guestLimited,

    /// niche
    @JsonKey(name: ClientHomeResponse.nicheKey_) ClientHomeNiche? niche,
  }) = _ClientHomeResponse;

  factory ClientHomeResponse.fromJson(Map<String, dynamic> json) =>
      _$ClientHomeResponseFromJson(json);

  static const String rowsKey_ = r'rows';

  static const String guestLimitedKey_ = r'guest_limited';

  static const String nicheKey_ = r'niche';
}
