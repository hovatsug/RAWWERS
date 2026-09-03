/// ClientMatchResponse
/// {
///     "properties": {
///         "match_request_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Match Request Id"
///         },
///         "items": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/ClientMatchCard"
///             },
///             "title": "Items"
///         }
///     },
///     "type": "object",
///     "required": [
///         "match_request_id"
///     ],
///     "title": "ClientMatchResponse"
/// }
library client_match_response;

import 'exports.dart';
part 'client_match_response.freezed.dart';
part 'client_match_response.g.dart'; // ClientMatchResponse

@freezed
abstract class ClientMatchResponse with _$ClientMatchResponse {
  const ClientMatchResponse._();

  @jsonSerializable
  const factory ClientMatchResponse({
    /// matchRequestId
    @JsonKey(name: ClientMatchResponse.matchRequestIdKey_)
    required String matchRequestId,

    /// items
    @JsonKey(name: ClientMatchResponse.itemsKey_) List<ClientMatchCard>? items,
  }) = _ClientMatchResponse;

  factory ClientMatchResponse.fromJson(Map<String, dynamic> json) =>
      _$ClientMatchResponseFromJson(json);

  static const String matchRequestIdKey_ = r'match_request_id';

  static const String itemsKey_ = r'items';
}
