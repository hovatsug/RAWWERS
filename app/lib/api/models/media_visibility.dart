// MediaVisibility
// {
//     "type": "string",
//     "enum": [
//         "public",
//         "authenticated",
//         "owner_only",
//         "client_only",
//         "purchaser_only"
//     ],
//     "title": "MediaVisibility"
// }

library media_visibility;

import 'exports.dart';
part 'media_visibility.g.dart';

@JsonEnum(alwaysCreate: true)
enum MediaVisibility {
  @JsonValue("public")
  public,
  @JsonValue("authenticated")
  authenticated,
  @JsonValue("owner_only")
  ownerOnly,
  @JsonValue("client_only")
  clientOnly,
  @JsonValue("purchaser_only")
  purchaserOnly;

  factory MediaVisibility.fromJson(String json) =>
      MediaVisibility.values.firstWhere(
        (e) => e.toJson() == json,
        orElse: () => throw ArgumentError("Invalid MediaVisibility"),
      );

  String toJson() => _$MediaVisibilityEnumMap[this]!;
}
