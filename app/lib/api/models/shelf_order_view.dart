/// ShelfOrderView
/// {
///     "properties": {
///         "id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Id"
///         },
///         "item_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Item Id"
///         },
///         "title": {
///             "type": "string",
///             "title": "Title"
///         },
///         "price_raww": {
///             "type": "integer",
///             "title": "Price Raww"
///         },
///         "status": {
///             "type": "string",
///             "title": "Status"
///         },
///         "placed_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Placed At"
///         },
///         "ordered_at": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "date-time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Ordered At"
///         },
///         "shipped_at": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "date-time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Shipped At"
///         },
///         "delivered_at": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "date-time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Delivered At"
///         },
///         "cancelled_at": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "date-time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Cancelled At"
///         },
///         "refunded_at": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "date-time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Refunded At"
///         },
///         "tracking_code": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Tracking Code"
///         },
///         "tracking_url": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Tracking Url"
///         },
///         "cancel_reason": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Cancel Reason"
///         },
///         "can_cancel": {
///             "type": "boolean",
///             "title": "Can Cancel"
///         }
///     },
///     "type": "object",
///     "required": [
///         "id",
///         "item_id",
///         "title",
///         "price_raww",
///         "status",
///         "placed_at",
///         "can_cancel"
///     ],
///     "title": "ShelfOrderView"
/// }
library shelf_order_view;

import 'exports.dart';
part 'shelf_order_view.freezed.dart';
part 'shelf_order_view.g.dart'; // ShelfOrderView

@freezed
abstract class ShelfOrderView with _$ShelfOrderView {
  const ShelfOrderView._();

  @jsonSerializable
  const factory ShelfOrderView({
    /// id
    @JsonKey(name: ShelfOrderView.idKey_) required String id,

    /// itemId
    @JsonKey(name: ShelfOrderView.itemIdKey_) required String itemId,

    /// title
    @JsonKey(name: ShelfOrderView.titleKey_) required String title,

    /// priceRaww
    @JsonKey(name: ShelfOrderView.priceRawwKey_) required int priceRaww,

    /// status
    @JsonKey(name: ShelfOrderView.statusKey_) required String status,

    /// placedAt
    @JsonKey(name: ShelfOrderView.placedAtKey_) required DateTime placedAt,

    /// orderedAt
    @JsonKey(name: ShelfOrderView.orderedAtKey_) DateTime? orderedAt,

    /// shippedAt
    @JsonKey(name: ShelfOrderView.shippedAtKey_) DateTime? shippedAt,

    /// deliveredAt
    @JsonKey(name: ShelfOrderView.deliveredAtKey_) DateTime? deliveredAt,

    /// cancelledAt
    @JsonKey(name: ShelfOrderView.cancelledAtKey_) DateTime? cancelledAt,

    /// refundedAt
    @JsonKey(name: ShelfOrderView.refundedAtKey_) DateTime? refundedAt,

    /// trackingCode
    @JsonKey(name: ShelfOrderView.trackingCodeKey_) String? trackingCode,

    /// trackingUrl
    @JsonKey(name: ShelfOrderView.trackingUrlKey_) String? trackingUrl,

    /// cancelReason
    @JsonKey(name: ShelfOrderView.cancelReasonKey_) String? cancelReason,

    /// canCancel
    @JsonKey(name: ShelfOrderView.canCancelKey_) required bool canCancel,
  }) = _ShelfOrderView;

  factory ShelfOrderView.fromJson(Map<String, dynamic> json) =>
      _$ShelfOrderViewFromJson(json);

  static const String idKey_ = r'id';

  static const String itemIdKey_ = r'item_id';

  static const String titleKey_ = r'title';

  static const String priceRawwKey_ = r'price_raww';

  static const String statusKey_ = r'status';

  static const String placedAtKey_ = r'placed_at';

  static const String orderedAtKey_ = r'ordered_at';

  static const String shippedAtKey_ = r'shipped_at';

  static const String deliveredAtKey_ = r'delivered_at';

  static const String cancelledAtKey_ = r'cancelled_at';

  static const String refundedAtKey_ = r'refunded_at';

  static const String trackingCodeKey_ = r'tracking_code';

  static const String trackingUrlKey_ = r'tracking_url';

  static const String cancelReasonKey_ = r'cancel_reason';

  static const String canCancelKey_ = r'can_cancel';
}
