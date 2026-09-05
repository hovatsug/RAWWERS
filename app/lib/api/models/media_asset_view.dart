/// MediaAssetView
/// {
///     "properties": {
///         "id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Id"
///         },
///         "owner_user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Owner User Id"
///         },
///         "kind": {
///             "type": "string",
///             "title": "Kind"
///         },
///         "purpose": {
///             "type": "string",
///             "title": "Purpose"
///         },
///         "provider": {
///             "type": "string",
///             "title": "Provider"
///         },
///         "status": {
///             "type": "string",
///             "title": "Status"
///         },
///         "visibility": {
///             "type": "string",
///             "title": "Visibility"
///         },
///         "content_type": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Content Type"
///         },
///         "byte_size": {
///             "anyOf": [
///                 {
///                     "type": "integer"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Byte Size"
///         },
///         "meta": {
///             "type": "object",
///             "title": "Meta"
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
///         },
///         "variants": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/MediaObjectView"
///             },
///             "title": "Variants"
///         },
///         "playback_id": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Playback Id"
///         },
///         "is_public": {
///             "type": "boolean",
///             "default": false,
///             "title": "Is Public"
///         },
///         "niche_tags": {
///             "type": "array",
///             "items": {
///                 "type": "string"
///             },
///             "title": "Niche Tags"
///         }
///     },
///     "type": "object",
///     "required": [
///         "id",
///         "owner_user_id",
///         "kind",
///         "purpose",
///         "provider",
///         "status",
///         "visibility",
///         "created_at",
///         "updated_at"
///     ],
///     "title": "MediaAssetView"
/// }
library media_asset_view;

import 'exports.dart';
part 'media_asset_view.freezed.dart';
part 'media_asset_view.g.dart'; // MediaAssetView

@freezed
abstract class MediaAssetView with _$MediaAssetView {
  const MediaAssetView._();

  @jsonSerializable
  const factory MediaAssetView({
    /// id
    @JsonKey(name: MediaAssetView.idKey_) required String id,

    /// ownerUserId
    @JsonKey(name: MediaAssetView.ownerUserIdKey_) required String ownerUserId,

    /// kind
    @JsonKey(name: MediaAssetView.kindKey_) required String kind,

    /// purpose
    @JsonKey(name: MediaAssetView.purposeKey_) required String purpose,

    /// provider
    @JsonKey(name: MediaAssetView.providerKey_) required String provider,

    /// status
    @JsonKey(name: MediaAssetView.statusKey_) required String status,

    /// visibility
    @JsonKey(name: MediaAssetView.visibilityKey_) required String visibility,

    /// contentType
    @JsonKey(name: MediaAssetView.contentTypeKey_) String? contentType,

    /// byteSize
    @JsonKey(name: MediaAssetView.byteSizeKey_) int? byteSize,

    /// meta
    @JsonKey(name: MediaAssetView.metaKey_) Map<String, dynamic>? meta,

    /// createdAt
    @JsonKey(name: MediaAssetView.createdAtKey_) required DateTime createdAt,

    /// updatedAt
    @JsonKey(name: MediaAssetView.updatedAtKey_) required DateTime updatedAt,

    /// variants
    @JsonKey(name: MediaAssetView.variantsKey_) List<MediaObjectView>? variants,

    /// playbackId
    @JsonKey(name: MediaAssetView.playbackIdKey_) String? playbackId,

    /// isPublic
    @Default(false) @JsonKey(name: MediaAssetView.isPublicKey_) bool isPublic,

    /// nicheTags
    @JsonKey(name: MediaAssetView.nicheTagsKey_) List<String>? nicheTags,
  }) = _MediaAssetView;

  factory MediaAssetView.fromJson(Map<String, dynamic> json) =>
      _$MediaAssetViewFromJson(json);

  static const String idKey_ = r'id';

  static const String ownerUserIdKey_ = r'owner_user_id';

  static const String kindKey_ = r'kind';

  static const String purposeKey_ = r'purpose';

  static const String providerKey_ = r'provider';

  static const String statusKey_ = r'status';

  static const String visibilityKey_ = r'visibility';

  static const String contentTypeKey_ = r'content_type';

  static const String byteSizeKey_ = r'byte_size';

  static const String metaKey_ = r'meta';

  static const String createdAtKey_ = r'created_at';

  static const String updatedAtKey_ = r'updated_at';

  static const String variantsKey_ = r'variants';

  static const String playbackIdKey_ = r'playback_id';

  static const String isPublicKey_ = r'is_public';

  static const String nicheTagsKey_ = r'niche_tags';
}
