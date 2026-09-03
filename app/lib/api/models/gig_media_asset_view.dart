/// GigMediaAssetView
/// {
///     "properties": {
///         "media_asset_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Media Asset Id"
///         },
///         "kind": {
///             "type": "string",
///             "title": "Kind"
///         },
///         "purpose": {
///             "type": "string",
///             "title": "Purpose"
///         },
///         "derivatives": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/MediaDerivativeView"
///             },
///             "title": "Derivatives"
///         }
///     },
///     "type": "object",
///     "required": [
///         "media_asset_id",
///         "kind",
///         "purpose"
///     ],
///     "title": "GigMediaAssetView"
/// }
library gig_media_asset_view;

import 'exports.dart';
part 'gig_media_asset_view.freezed.dart';
part 'gig_media_asset_view.g.dart'; // GigMediaAssetView

@freezed
abstract class GigMediaAssetView with _$GigMediaAssetView {
  const GigMediaAssetView._();

  @jsonSerializable
  const factory GigMediaAssetView({
    /// mediaAssetId
    @JsonKey(name: GigMediaAssetView.mediaAssetIdKey_)
    required String mediaAssetId,

    /// kind
    @JsonKey(name: GigMediaAssetView.kindKey_) required String kind,

    /// purpose
    @JsonKey(name: GigMediaAssetView.purposeKey_) required String purpose,

    /// derivatives
    @JsonKey(name: GigMediaAssetView.derivativesKey_)
    List<MediaDerivativeView>? derivatives,
  }) = _GigMediaAssetView;

  factory GigMediaAssetView.fromJson(Map<String, dynamic> json) =>
      _$GigMediaAssetViewFromJson(json);

  static const String mediaAssetIdKey_ = r'media_asset_id';

  static const String kindKey_ = r'kind';

  static const String purposeKey_ = r'purpose';

  static const String derivativesKey_ = r'derivatives';
}
