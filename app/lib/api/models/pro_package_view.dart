/// ProPackageView
/// {
///     "properties": {
///         "id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Id"
///         },
///         "pro_user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Pro User Id"
///         },
///         "niche_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Niche Id"
///         },
///         "title": {
///             "type": "string",
///             "title": "Title"
///         },
///         "description": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Description"
///         },
///         "duration_minutes": {
///             "type": "integer",
///             "title": "Duration Minutes"
///         },
///         "price": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Price"
///         },
///         "currency": {
///             "type": "string",
///             "title": "Currency"
///         },
///         "included_photos": {
///             "type": "integer",
///             "title": "Included Photos"
///         },
///         "extra_photo_price": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Extra Photo Price"
///         },
///         "proofs_sla_days": {
///             "type": "integer",
///             "title": "Proofs Sla Days"
///         },
///         "finals_sla_days": {
///             "type": "integer",
///             "title": "Finals Sla Days"
///         },
///         "addons": {
///             "type": "array",
///             "items": {
///                 "type": "object"
///             },
///             "title": "Addons"
///         },
///         "is_active": {
///             "type": "boolean",
///             "title": "Is Active"
///         },
///         "scheduling_preset": {
///             "$ref": "#/components/schemas/SchedulingPreset",
///             "default": "interval"
///         },
///         "interval_minutes": {
///             "anyOf": [
///                 {
///                     "type": "integer"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Interval Minutes"
///         },
///         "session_blocks": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/SessionBlockInput"
///             },
///             "title": "Session Blocks"
///         },
///         "short_notice_ok": {
///             "type": "boolean",
///             "default": false,
///             "title": "Short Notice Ok"
///         }
///     },
///     "type": "object",
///     "required": [
///         "id",
///         "pro_user_id",
///         "niche_id",
///         "title",
///         "duration_minutes",
///         "price",
///         "currency",
///         "included_photos",
///         "extra_photo_price",
///         "proofs_sla_days",
///         "finals_sla_days",
///         "addons",
///         "is_active"
///     ],
///     "title": "ProPackageView"
/// }
library pro_package_view;

import 'exports.dart';
part 'pro_package_view.freezed.dart';
part 'pro_package_view.g.dart'; // ProPackageView

@freezed
abstract class ProPackageView with _$ProPackageView {
  const ProPackageView._();

  @jsonSerializable
  const factory ProPackageView({
    /// id
    @JsonKey(name: ProPackageView.idKey_) required String id,

    /// proUserId
    @JsonKey(name: ProPackageView.proUserIdKey_) required String proUserId,

    /// nicheId
    @JsonKey(name: ProPackageView.nicheIdKey_) required String nicheId,

    /// title
    @JsonKey(name: ProPackageView.titleKey_) required String title,

    /// description
    @JsonKey(name: ProPackageView.descriptionKey_) String? description,

    /// durationMinutes
    @JsonKey(name: ProPackageView.durationMinutesKey_)
    required int durationMinutes,

    /// price
    @JsonKey(name: ProPackageView.priceKey_) required String price,

    /// currency
    @JsonKey(name: ProPackageView.currencyKey_) required String currency,

    /// includedPhotos
    @JsonKey(name: ProPackageView.includedPhotosKey_)
    required int includedPhotos,

    /// extraPhotoPrice
    @JsonKey(name: ProPackageView.extraPhotoPriceKey_)
    required String extraPhotoPrice,

    /// proofsSlaDays
    @JsonKey(name: ProPackageView.proofsSlaDaysKey_) required int proofsSlaDays,

    /// finalsSlaDays
    @JsonKey(name: ProPackageView.finalsSlaDaysKey_) required int finalsSlaDays,

    /// addons
    @JsonKey(name: ProPackageView.addonsKey_)
    required List<Map<String, dynamic>> addons,

    /// isActive
    @JsonKey(name: ProPackageView.isActiveKey_) required bool isActive,

    /// schedulingPreset
    @Default(SchedulingPreset.interval)
    @JsonKey(name: ProPackageView.schedulingPresetKey_)
    SchedulingPreset schedulingPreset,

    /// intervalMinutes
    @JsonKey(name: ProPackageView.intervalMinutesKey_) int? intervalMinutes,

    /// sessionBlocks
    @JsonKey(name: ProPackageView.sessionBlocksKey_)
    List<SessionBlockInput>? sessionBlocks,

    /// shortNoticeOk
    @Default(false)
    @JsonKey(name: ProPackageView.shortNoticeOkKey_)
    bool shortNoticeOk,
  }) = _ProPackageView;

  factory ProPackageView.fromJson(Map<String, dynamic> json) =>
      _$ProPackageViewFromJson(json);

  static const String idKey_ = r'id';

  static const String proUserIdKey_ = r'pro_user_id';

  static const String nicheIdKey_ = r'niche_id';

  static const String titleKey_ = r'title';

  static const String descriptionKey_ = r'description';

  static const String durationMinutesKey_ = r'duration_minutes';

  static const String priceKey_ = r'price';

  static const String currencyKey_ = r'currency';

  static const String includedPhotosKey_ = r'included_photos';

  static const String extraPhotoPriceKey_ = r'extra_photo_price';

  static const String proofsSlaDaysKey_ = r'proofs_sla_days';

  static const String finalsSlaDaysKey_ = r'finals_sla_days';

  static const String addonsKey_ = r'addons';

  static const String isActiveKey_ = r'is_active';

  static const String schedulingPresetKey_ = r'scheduling_preset';

  static const String intervalMinutesKey_ = r'interval_minutes';

  static const String sessionBlocksKey_ = r'session_blocks';

  static const String shortNoticeOkKey_ = r'short_notice_ok';
}
