/// SubmitSelectionResponse
/// {
///     "properties": {
///         "selection_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Selection Id"
///         },
///         "selected_count": {
///             "type": "integer",
///             "title": "Selected Count"
///         },
///         "included_photos": {
///             "type": "integer",
///             "title": "Included Photos"
///         },
///         "extras_count": {
///             "type": "integer",
///             "title": "Extras Count"
///         },
///         "gallery_status": {
///             "$ref": "#/components/schemas/ProofGalleryStatus"
///         },
///         "upsell_required": {
///             "type": "boolean",
///             "title": "Upsell Required"
///         },
///         "payment_intent_id": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Payment Intent Id"
///         },
///         "payment_intent_client_secret": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Payment Intent Client Secret"
///         },
///         "difference_required": {
///             "type": "boolean",
///             "default": false,
///             "title": "Difference Required"
///         },
///         "difference_amount": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Difference Amount"
///         },
///         "difference_payment_intent_id": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Difference Payment Intent Id"
///         },
///         "difference_payment_intent_client_secret": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Difference Payment Intent Client Secret"
///         }
///     },
///     "type": "object",
///     "required": [
///         "selection_id",
///         "selected_count",
///         "included_photos",
///         "extras_count",
///         "gallery_status",
///         "upsell_required"
///     ],
///     "title": "SubmitSelectionResponse"
/// }
library submit_selection_response;

import 'exports.dart';
part 'submit_selection_response.freezed.dart';
part 'submit_selection_response.g.dart'; // SubmitSelectionResponse

@freezed
abstract class SubmitSelectionResponse with _$SubmitSelectionResponse {
  const SubmitSelectionResponse._();

  @jsonSerializable
  const factory SubmitSelectionResponse({
    /// selectionId
    @JsonKey(name: SubmitSelectionResponse.selectionIdKey_)
    required String selectionId,

    /// selectedCount
    @JsonKey(name: SubmitSelectionResponse.selectedCountKey_)
    required int selectedCount,

    /// includedPhotos
    @JsonKey(name: SubmitSelectionResponse.includedPhotosKey_)
    required int includedPhotos,

    /// extrasCount
    @JsonKey(name: SubmitSelectionResponse.extrasCountKey_)
    required int extrasCount,

    /// galleryStatus
    @JsonKey(name: SubmitSelectionResponse.galleryStatusKey_)
    required ProofGalleryStatus galleryStatus,

    /// upsellRequired
    @JsonKey(name: SubmitSelectionResponse.upsellRequiredKey_)
    required bool upsellRequired,

    /// paymentIntentId
    @JsonKey(name: SubmitSelectionResponse.paymentIntentIdKey_)
    String? paymentIntentId,

    /// paymentIntentClientSecret
    @JsonKey(name: SubmitSelectionResponse.paymentIntentClientSecretKey_)
    String? paymentIntentClientSecret,

    /// differenceRequired
    @Default(false)
    @JsonKey(name: SubmitSelectionResponse.differenceRequiredKey_)
    bool differenceRequired,

    /// differenceAmount
    @JsonKey(name: SubmitSelectionResponse.differenceAmountKey_)
    String? differenceAmount,

    /// differencePaymentIntentId
    @JsonKey(name: SubmitSelectionResponse.differencePaymentIntentIdKey_)
    String? differencePaymentIntentId,

    /// differencePaymentIntentClientSecret
    @JsonKey(
      name: SubmitSelectionResponse.differencePaymentIntentClientSecretKey_,
    )
    String? differencePaymentIntentClientSecret,
  }) = _SubmitSelectionResponse;

  factory SubmitSelectionResponse.fromJson(Map<String, dynamic> json) =>
      _$SubmitSelectionResponseFromJson(json);

  static const String selectionIdKey_ = r'selection_id';

  static const String selectedCountKey_ = r'selected_count';

  static const String includedPhotosKey_ = r'included_photos';

  static const String extrasCountKey_ = r'extras_count';

  static const String galleryStatusKey_ = r'gallery_status';

  static const String upsellRequiredKey_ = r'upsell_required';

  static const String paymentIntentIdKey_ = r'payment_intent_id';

  static const String paymentIntentClientSecretKey_ =
      r'payment_intent_client_secret';

  static const String differenceRequiredKey_ = r'difference_required';

  static const String differenceAmountKey_ = r'difference_amount';

  static const String differencePaymentIntentIdKey_ =
      r'difference_payment_intent_id';

  static const String differencePaymentIntentClientSecretKey_ =
      r'difference_payment_intent_client_secret';
}
