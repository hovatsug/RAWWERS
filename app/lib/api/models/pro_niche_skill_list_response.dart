/// ProNicheSkillListResponse
/// {
///     "properties": {
///         "pro_user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Pro User Id"
///         },
///         "items": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/ProNicheSkillView"
///             },
///             "title": "Items"
///         }
///     },
///     "type": "object",
///     "required": [
///         "pro_user_id"
///     ],
///     "title": "ProNicheSkillListResponse"
/// }
library pro_niche_skill_list_response;

import 'exports.dart';
part 'pro_niche_skill_list_response.freezed.dart';
part 'pro_niche_skill_list_response.g.dart'; // ProNicheSkillListResponse

@freezed
abstract class ProNicheSkillListResponse with _$ProNicheSkillListResponse {
  const ProNicheSkillListResponse._();

  @jsonSerializable
  const factory ProNicheSkillListResponse({
    /// proUserId
    @JsonKey(name: ProNicheSkillListResponse.proUserIdKey_)
    required String proUserId,

    /// items
    @JsonKey(name: ProNicheSkillListResponse.itemsKey_)
    List<ProNicheSkillView>? items,
  }) = _ProNicheSkillListResponse;

  factory ProNicheSkillListResponse.fromJson(Map<String, dynamic> json) =>
      _$ProNicheSkillListResponseFromJson(json);

  static const String proUserIdKey_ = r'pro_user_id';

  static const String itemsKey_ = r'items';
}
