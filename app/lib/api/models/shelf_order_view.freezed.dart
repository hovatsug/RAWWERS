// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shelf_order_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ShelfOrderView {

/// id
@JsonKey(name: ShelfOrderView.idKey_) String get id;/// itemId
@JsonKey(name: ShelfOrderView.itemIdKey_) String get itemId;/// title
@JsonKey(name: ShelfOrderView.titleKey_) String get title;/// priceRaww
@JsonKey(name: ShelfOrderView.priceRawwKey_) int get priceRaww;/// status
@JsonKey(name: ShelfOrderView.statusKey_) String get status;/// placedAt
@JsonKey(name: ShelfOrderView.placedAtKey_) DateTime get placedAt;/// orderedAt
@JsonKey(name: ShelfOrderView.orderedAtKey_) DateTime? get orderedAt;/// shippedAt
@JsonKey(name: ShelfOrderView.shippedAtKey_) DateTime? get shippedAt;/// deliveredAt
@JsonKey(name: ShelfOrderView.deliveredAtKey_) DateTime? get deliveredAt;/// cancelledAt
@JsonKey(name: ShelfOrderView.cancelledAtKey_) DateTime? get cancelledAt;/// refundedAt
@JsonKey(name: ShelfOrderView.refundedAtKey_) DateTime? get refundedAt;/// trackingCode
@JsonKey(name: ShelfOrderView.trackingCodeKey_) String? get trackingCode;/// trackingUrl
@JsonKey(name: ShelfOrderView.trackingUrlKey_) String? get trackingUrl;/// cancelReason
@JsonKey(name: ShelfOrderView.cancelReasonKey_) String? get cancelReason;/// canCancel
@JsonKey(name: ShelfOrderView.canCancelKey_) bool get canCancel;
/// Create a copy of ShelfOrderView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShelfOrderViewCopyWith<ShelfOrderView> get copyWith => _$ShelfOrderViewCopyWithImpl<ShelfOrderView>(this as ShelfOrderView, _$identity);

  /// Serializes this ShelfOrderView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShelfOrderView&&(identical(other.id, id) || other.id == id)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.title, title) || other.title == title)&&(identical(other.priceRaww, priceRaww) || other.priceRaww == priceRaww)&&(identical(other.status, status) || other.status == status)&&(identical(other.placedAt, placedAt) || other.placedAt == placedAt)&&(identical(other.orderedAt, orderedAt) || other.orderedAt == orderedAt)&&(identical(other.shippedAt, shippedAt) || other.shippedAt == shippedAt)&&(identical(other.deliveredAt, deliveredAt) || other.deliveredAt == deliveredAt)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.refundedAt, refundedAt) || other.refundedAt == refundedAt)&&(identical(other.trackingCode, trackingCode) || other.trackingCode == trackingCode)&&(identical(other.trackingUrl, trackingUrl) || other.trackingUrl == trackingUrl)&&(identical(other.cancelReason, cancelReason) || other.cancelReason == cancelReason)&&(identical(other.canCancel, canCancel) || other.canCancel == canCancel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,itemId,title,priceRaww,status,placedAt,orderedAt,shippedAt,deliveredAt,cancelledAt,refundedAt,trackingCode,trackingUrl,cancelReason,canCancel);

@override
String toString() {
  return 'ShelfOrderView(id: $id, itemId: $itemId, title: $title, priceRaww: $priceRaww, status: $status, placedAt: $placedAt, orderedAt: $orderedAt, shippedAt: $shippedAt, deliveredAt: $deliveredAt, cancelledAt: $cancelledAt, refundedAt: $refundedAt, trackingCode: $trackingCode, trackingUrl: $trackingUrl, cancelReason: $cancelReason, canCancel: $canCancel)';
}


}

/// @nodoc
abstract mixin class $ShelfOrderViewCopyWith<$Res>  {
  factory $ShelfOrderViewCopyWith(ShelfOrderView value, $Res Function(ShelfOrderView) _then) = _$ShelfOrderViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ShelfOrderView.idKey_) String id,@JsonKey(name: ShelfOrderView.itemIdKey_) String itemId,@JsonKey(name: ShelfOrderView.titleKey_) String title,@JsonKey(name: ShelfOrderView.priceRawwKey_) int priceRaww,@JsonKey(name: ShelfOrderView.statusKey_) String status,@JsonKey(name: ShelfOrderView.placedAtKey_) DateTime placedAt,@JsonKey(name: ShelfOrderView.orderedAtKey_) DateTime? orderedAt,@JsonKey(name: ShelfOrderView.shippedAtKey_) DateTime? shippedAt,@JsonKey(name: ShelfOrderView.deliveredAtKey_) DateTime? deliveredAt,@JsonKey(name: ShelfOrderView.cancelledAtKey_) DateTime? cancelledAt,@JsonKey(name: ShelfOrderView.refundedAtKey_) DateTime? refundedAt,@JsonKey(name: ShelfOrderView.trackingCodeKey_) String? trackingCode,@JsonKey(name: ShelfOrderView.trackingUrlKey_) String? trackingUrl,@JsonKey(name: ShelfOrderView.cancelReasonKey_) String? cancelReason,@JsonKey(name: ShelfOrderView.canCancelKey_) bool canCancel
});




}
/// @nodoc
class _$ShelfOrderViewCopyWithImpl<$Res>
    implements $ShelfOrderViewCopyWith<$Res> {
  _$ShelfOrderViewCopyWithImpl(this._self, this._then);

  final ShelfOrderView _self;
  final $Res Function(ShelfOrderView) _then;

/// Create a copy of ShelfOrderView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? itemId = null,Object? title = null,Object? priceRaww = null,Object? status = null,Object? placedAt = null,Object? orderedAt = freezed,Object? shippedAt = freezed,Object? deliveredAt = freezed,Object? cancelledAt = freezed,Object? refundedAt = freezed,Object? trackingCode = freezed,Object? trackingUrl = freezed,Object? cancelReason = freezed,Object? canCancel = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,priceRaww: null == priceRaww ? _self.priceRaww : priceRaww // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,placedAt: null == placedAt ? _self.placedAt : placedAt // ignore: cast_nullable_to_non_nullable
as DateTime,orderedAt: freezed == orderedAt ? _self.orderedAt : orderedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,shippedAt: freezed == shippedAt ? _self.shippedAt : shippedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deliveredAt: freezed == deliveredAt ? _self.deliveredAt : deliveredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,refundedAt: freezed == refundedAt ? _self.refundedAt : refundedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,trackingCode: freezed == trackingCode ? _self.trackingCode : trackingCode // ignore: cast_nullable_to_non_nullable
as String?,trackingUrl: freezed == trackingUrl ? _self.trackingUrl : trackingUrl // ignore: cast_nullable_to_non_nullable
as String?,cancelReason: freezed == cancelReason ? _self.cancelReason : cancelReason // ignore: cast_nullable_to_non_nullable
as String?,canCancel: null == canCancel ? _self.canCancel : canCancel // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ShelfOrderView].
extension ShelfOrderViewPatterns on ShelfOrderView {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShelfOrderView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShelfOrderView() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShelfOrderView value)  $default,){
final _that = this;
switch (_that) {
case _ShelfOrderView():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShelfOrderView value)?  $default,){
final _that = this;
switch (_that) {
case _ShelfOrderView() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ShelfOrderView.idKey_)  String id, @JsonKey(name: ShelfOrderView.itemIdKey_)  String itemId, @JsonKey(name: ShelfOrderView.titleKey_)  String title, @JsonKey(name: ShelfOrderView.priceRawwKey_)  int priceRaww, @JsonKey(name: ShelfOrderView.statusKey_)  String status, @JsonKey(name: ShelfOrderView.placedAtKey_)  DateTime placedAt, @JsonKey(name: ShelfOrderView.orderedAtKey_)  DateTime? orderedAt, @JsonKey(name: ShelfOrderView.shippedAtKey_)  DateTime? shippedAt, @JsonKey(name: ShelfOrderView.deliveredAtKey_)  DateTime? deliveredAt, @JsonKey(name: ShelfOrderView.cancelledAtKey_)  DateTime? cancelledAt, @JsonKey(name: ShelfOrderView.refundedAtKey_)  DateTime? refundedAt, @JsonKey(name: ShelfOrderView.trackingCodeKey_)  String? trackingCode, @JsonKey(name: ShelfOrderView.trackingUrlKey_)  String? trackingUrl, @JsonKey(name: ShelfOrderView.cancelReasonKey_)  String? cancelReason, @JsonKey(name: ShelfOrderView.canCancelKey_)  bool canCancel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShelfOrderView() when $default != null:
return $default(_that.id,_that.itemId,_that.title,_that.priceRaww,_that.status,_that.placedAt,_that.orderedAt,_that.shippedAt,_that.deliveredAt,_that.cancelledAt,_that.refundedAt,_that.trackingCode,_that.trackingUrl,_that.cancelReason,_that.canCancel);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ShelfOrderView.idKey_)  String id, @JsonKey(name: ShelfOrderView.itemIdKey_)  String itemId, @JsonKey(name: ShelfOrderView.titleKey_)  String title, @JsonKey(name: ShelfOrderView.priceRawwKey_)  int priceRaww, @JsonKey(name: ShelfOrderView.statusKey_)  String status, @JsonKey(name: ShelfOrderView.placedAtKey_)  DateTime placedAt, @JsonKey(name: ShelfOrderView.orderedAtKey_)  DateTime? orderedAt, @JsonKey(name: ShelfOrderView.shippedAtKey_)  DateTime? shippedAt, @JsonKey(name: ShelfOrderView.deliveredAtKey_)  DateTime? deliveredAt, @JsonKey(name: ShelfOrderView.cancelledAtKey_)  DateTime? cancelledAt, @JsonKey(name: ShelfOrderView.refundedAtKey_)  DateTime? refundedAt, @JsonKey(name: ShelfOrderView.trackingCodeKey_)  String? trackingCode, @JsonKey(name: ShelfOrderView.trackingUrlKey_)  String? trackingUrl, @JsonKey(name: ShelfOrderView.cancelReasonKey_)  String? cancelReason, @JsonKey(name: ShelfOrderView.canCancelKey_)  bool canCancel)  $default,) {final _that = this;
switch (_that) {
case _ShelfOrderView():
return $default(_that.id,_that.itemId,_that.title,_that.priceRaww,_that.status,_that.placedAt,_that.orderedAt,_that.shippedAt,_that.deliveredAt,_that.cancelledAt,_that.refundedAt,_that.trackingCode,_that.trackingUrl,_that.cancelReason,_that.canCancel);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ShelfOrderView.idKey_)  String id, @JsonKey(name: ShelfOrderView.itemIdKey_)  String itemId, @JsonKey(name: ShelfOrderView.titleKey_)  String title, @JsonKey(name: ShelfOrderView.priceRawwKey_)  int priceRaww, @JsonKey(name: ShelfOrderView.statusKey_)  String status, @JsonKey(name: ShelfOrderView.placedAtKey_)  DateTime placedAt, @JsonKey(name: ShelfOrderView.orderedAtKey_)  DateTime? orderedAt, @JsonKey(name: ShelfOrderView.shippedAtKey_)  DateTime? shippedAt, @JsonKey(name: ShelfOrderView.deliveredAtKey_)  DateTime? deliveredAt, @JsonKey(name: ShelfOrderView.cancelledAtKey_)  DateTime? cancelledAt, @JsonKey(name: ShelfOrderView.refundedAtKey_)  DateTime? refundedAt, @JsonKey(name: ShelfOrderView.trackingCodeKey_)  String? trackingCode, @JsonKey(name: ShelfOrderView.trackingUrlKey_)  String? trackingUrl, @JsonKey(name: ShelfOrderView.cancelReasonKey_)  String? cancelReason, @JsonKey(name: ShelfOrderView.canCancelKey_)  bool canCancel)?  $default,) {final _that = this;
switch (_that) {
case _ShelfOrderView() when $default != null:
return $default(_that.id,_that.itemId,_that.title,_that.priceRaww,_that.status,_that.placedAt,_that.orderedAt,_that.shippedAt,_that.deliveredAt,_that.cancelledAt,_that.refundedAt,_that.trackingCode,_that.trackingUrl,_that.cancelReason,_that.canCancel);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ShelfOrderView extends ShelfOrderView {
  const _ShelfOrderView({@JsonKey(name: ShelfOrderView.idKey_) required this.id, @JsonKey(name: ShelfOrderView.itemIdKey_) required this.itemId, @JsonKey(name: ShelfOrderView.titleKey_) required this.title, @JsonKey(name: ShelfOrderView.priceRawwKey_) required this.priceRaww, @JsonKey(name: ShelfOrderView.statusKey_) required this.status, @JsonKey(name: ShelfOrderView.placedAtKey_) required this.placedAt, @JsonKey(name: ShelfOrderView.orderedAtKey_) this.orderedAt, @JsonKey(name: ShelfOrderView.shippedAtKey_) this.shippedAt, @JsonKey(name: ShelfOrderView.deliveredAtKey_) this.deliveredAt, @JsonKey(name: ShelfOrderView.cancelledAtKey_) this.cancelledAt, @JsonKey(name: ShelfOrderView.refundedAtKey_) this.refundedAt, @JsonKey(name: ShelfOrderView.trackingCodeKey_) this.trackingCode, @JsonKey(name: ShelfOrderView.trackingUrlKey_) this.trackingUrl, @JsonKey(name: ShelfOrderView.cancelReasonKey_) this.cancelReason, @JsonKey(name: ShelfOrderView.canCancelKey_) required this.canCancel}): super._();
  factory _ShelfOrderView.fromJson(Map<String, dynamic> json) => _$ShelfOrderViewFromJson(json);

/// id
@override@JsonKey(name: ShelfOrderView.idKey_) final  String id;
/// itemId
@override@JsonKey(name: ShelfOrderView.itemIdKey_) final  String itemId;
/// title
@override@JsonKey(name: ShelfOrderView.titleKey_) final  String title;
/// priceRaww
@override@JsonKey(name: ShelfOrderView.priceRawwKey_) final  int priceRaww;
/// status
@override@JsonKey(name: ShelfOrderView.statusKey_) final  String status;
/// placedAt
@override@JsonKey(name: ShelfOrderView.placedAtKey_) final  DateTime placedAt;
/// orderedAt
@override@JsonKey(name: ShelfOrderView.orderedAtKey_) final  DateTime? orderedAt;
/// shippedAt
@override@JsonKey(name: ShelfOrderView.shippedAtKey_) final  DateTime? shippedAt;
/// deliveredAt
@override@JsonKey(name: ShelfOrderView.deliveredAtKey_) final  DateTime? deliveredAt;
/// cancelledAt
@override@JsonKey(name: ShelfOrderView.cancelledAtKey_) final  DateTime? cancelledAt;
/// refundedAt
@override@JsonKey(name: ShelfOrderView.refundedAtKey_) final  DateTime? refundedAt;
/// trackingCode
@override@JsonKey(name: ShelfOrderView.trackingCodeKey_) final  String? trackingCode;
/// trackingUrl
@override@JsonKey(name: ShelfOrderView.trackingUrlKey_) final  String? trackingUrl;
/// cancelReason
@override@JsonKey(name: ShelfOrderView.cancelReasonKey_) final  String? cancelReason;
/// canCancel
@override@JsonKey(name: ShelfOrderView.canCancelKey_) final  bool canCancel;

/// Create a copy of ShelfOrderView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShelfOrderViewCopyWith<_ShelfOrderView> get copyWith => __$ShelfOrderViewCopyWithImpl<_ShelfOrderView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShelfOrderViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShelfOrderView&&(identical(other.id, id) || other.id == id)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.title, title) || other.title == title)&&(identical(other.priceRaww, priceRaww) || other.priceRaww == priceRaww)&&(identical(other.status, status) || other.status == status)&&(identical(other.placedAt, placedAt) || other.placedAt == placedAt)&&(identical(other.orderedAt, orderedAt) || other.orderedAt == orderedAt)&&(identical(other.shippedAt, shippedAt) || other.shippedAt == shippedAt)&&(identical(other.deliveredAt, deliveredAt) || other.deliveredAt == deliveredAt)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.refundedAt, refundedAt) || other.refundedAt == refundedAt)&&(identical(other.trackingCode, trackingCode) || other.trackingCode == trackingCode)&&(identical(other.trackingUrl, trackingUrl) || other.trackingUrl == trackingUrl)&&(identical(other.cancelReason, cancelReason) || other.cancelReason == cancelReason)&&(identical(other.canCancel, canCancel) || other.canCancel == canCancel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,itemId,title,priceRaww,status,placedAt,orderedAt,shippedAt,deliveredAt,cancelledAt,refundedAt,trackingCode,trackingUrl,cancelReason,canCancel);

@override
String toString() {
  return 'ShelfOrderView(id: $id, itemId: $itemId, title: $title, priceRaww: $priceRaww, status: $status, placedAt: $placedAt, orderedAt: $orderedAt, shippedAt: $shippedAt, deliveredAt: $deliveredAt, cancelledAt: $cancelledAt, refundedAt: $refundedAt, trackingCode: $trackingCode, trackingUrl: $trackingUrl, cancelReason: $cancelReason, canCancel: $canCancel)';
}


}

/// @nodoc
abstract mixin class _$ShelfOrderViewCopyWith<$Res> implements $ShelfOrderViewCopyWith<$Res> {
  factory _$ShelfOrderViewCopyWith(_ShelfOrderView value, $Res Function(_ShelfOrderView) _then) = __$ShelfOrderViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ShelfOrderView.idKey_) String id,@JsonKey(name: ShelfOrderView.itemIdKey_) String itemId,@JsonKey(name: ShelfOrderView.titleKey_) String title,@JsonKey(name: ShelfOrderView.priceRawwKey_) int priceRaww,@JsonKey(name: ShelfOrderView.statusKey_) String status,@JsonKey(name: ShelfOrderView.placedAtKey_) DateTime placedAt,@JsonKey(name: ShelfOrderView.orderedAtKey_) DateTime? orderedAt,@JsonKey(name: ShelfOrderView.shippedAtKey_) DateTime? shippedAt,@JsonKey(name: ShelfOrderView.deliveredAtKey_) DateTime? deliveredAt,@JsonKey(name: ShelfOrderView.cancelledAtKey_) DateTime? cancelledAt,@JsonKey(name: ShelfOrderView.refundedAtKey_) DateTime? refundedAt,@JsonKey(name: ShelfOrderView.trackingCodeKey_) String? trackingCode,@JsonKey(name: ShelfOrderView.trackingUrlKey_) String? trackingUrl,@JsonKey(name: ShelfOrderView.cancelReasonKey_) String? cancelReason,@JsonKey(name: ShelfOrderView.canCancelKey_) bool canCancel
});




}
/// @nodoc
class __$ShelfOrderViewCopyWithImpl<$Res>
    implements _$ShelfOrderViewCopyWith<$Res> {
  __$ShelfOrderViewCopyWithImpl(this._self, this._then);

  final _ShelfOrderView _self;
  final $Res Function(_ShelfOrderView) _then;

/// Create a copy of ShelfOrderView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? itemId = null,Object? title = null,Object? priceRaww = null,Object? status = null,Object? placedAt = null,Object? orderedAt = freezed,Object? shippedAt = freezed,Object? deliveredAt = freezed,Object? cancelledAt = freezed,Object? refundedAt = freezed,Object? trackingCode = freezed,Object? trackingUrl = freezed,Object? cancelReason = freezed,Object? canCancel = null,}) {
  return _then(_ShelfOrderView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,priceRaww: null == priceRaww ? _self.priceRaww : priceRaww // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,placedAt: null == placedAt ? _self.placedAt : placedAt // ignore: cast_nullable_to_non_nullable
as DateTime,orderedAt: freezed == orderedAt ? _self.orderedAt : orderedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,shippedAt: freezed == shippedAt ? _self.shippedAt : shippedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deliveredAt: freezed == deliveredAt ? _self.deliveredAt : deliveredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,refundedAt: freezed == refundedAt ? _self.refundedAt : refundedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,trackingCode: freezed == trackingCode ? _self.trackingCode : trackingCode // ignore: cast_nullable_to_non_nullable
as String?,trackingUrl: freezed == trackingUrl ? _self.trackingUrl : trackingUrl // ignore: cast_nullable_to_non_nullable
as String?,cancelReason: freezed == cancelReason ? _self.cancelReason : cancelReason // ignore: cast_nullable_to_non_nullable
as String?,canCancel: null == canCancel ? _self.canCancel : canCancel // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
