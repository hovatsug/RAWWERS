/// UpgradeToProResponse
/// {
///     "properties": {
///         "ok": {
///             "type": "boolean",
///             "title": "Ok"
///         },
///         "role_added": {
///             "type": "boolean",
///             "title": "Role Added"
///         }
///     },
///     "type": "object",
///     "required": [
///         "ok",
///         "role_added"
///     ],
///     "title": "UpgradeToProResponse"
/// }
library upgrade_to_pro_response;

import 'exports.dart';
part 'upgrade_to_pro_response.freezed.dart';
part 'upgrade_to_pro_response.g.dart'; // UpgradeToProResponse

@freezed
abstract class UpgradeToProResponse with _$UpgradeToProResponse {
  const UpgradeToProResponse._();

  @jsonSerializable
  const factory UpgradeToProResponse({
    /// ok
    @JsonKey(name: UpgradeToProResponse.okKey_) required bool ok,

    /// roleAdded
    @JsonKey(name: UpgradeToProResponse.roleAddedKey_) required bool roleAdded,
  }) = _UpgradeToProResponse;

  factory UpgradeToProResponse.fromJson(Map<String, dynamic> json) =>
      _$UpgradeToProResponseFromJson(json);

  static const String okKey_ = r'ok';

  static const String roleAddedKey_ = r'role_added';
}
