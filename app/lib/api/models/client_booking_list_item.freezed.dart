// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_booking_list_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClientBookingListItem {

/// bookingId
@JsonKey(name: ClientBookingListItem.bookingIdKey_) String get bookingId;/// bookingStatus
@JsonKey(name: ClientBookingListItem.bookingStatusKey_) String get bookingStatus;/// gigId
@JsonKey(name: ClientBookingListItem.gigIdKey_) String? get gigId;/// gigStatus
@JsonKey(name: ClientBookingListItem.gigStatusKey_) String? get gigStatus;/// paymentStatus
@JsonKey(name: ClientBookingListItem.paymentStatusKey_) String? get paymentStatus;/// requestedStart
@JsonKey(name: ClientBookingListItem.requestedStartKey_) DateTime get requestedStart;/// requestedEnd
@JsonKey(name: ClientBookingListItem.requestedEndKey_) DateTime get requestedEnd;/// locationText
@JsonKey(name: ClientBookingListItem.locationTextKey_) String? get locationText;/// expiresAt
@JsonKey(name: ClientBookingListItem.expiresAtKey_) DateTime get expiresAt;/// createdAt
@JsonKey(name: ClientBookingListItem.createdAtKey_) DateTime get createdAt;
/// Create a copy of ClientBookingListItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientBookingListItemCopyWith<ClientBookingListItem> get copyWith => _$ClientBookingListItemCopyWithImpl<ClientBookingListItem>(this as ClientBookingListItem, _$identity);

  /// Serializes this ClientBookingListItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientBookingListItem&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.bookingStatus, bookingStatus) || other.bookingStatus == bookingStatus)&&(identical(other.gigId, gigId) || other.gigId == gigId)&&(identical(other.gigStatus, gigStatus) || other.gigStatus == gigStatus)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.requestedStart, requestedStart) || other.requestedStart == requestedStart)&&(identical(other.requestedEnd, requestedEnd) || other.requestedEnd == requestedEnd)&&(identical(other.locationText, locationText) || other.locationText == locationText)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bookingId,bookingStatus,gigId,gigStatus,paymentStatus,requestedStart,requestedEnd,locationText,expiresAt,createdAt);

@override
String toString() {
  return 'ClientBookingListItem(bookingId: $bookingId, bookingStatus: $bookingStatus, gigId: $gigId, gigStatus: $gigStatus, paymentStatus: $paymentStatus, requestedStart: $requestedStart, requestedEnd: $requestedEnd, locationText: $locationText, expiresAt: $expiresAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ClientBookingListItemCopyWith<$Res>  {
  factory $ClientBookingListItemCopyWith(ClientBookingListItem value, $Res Function(ClientBookingListItem) _then) = _$ClientBookingListItemCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ClientBookingListItem.bookingIdKey_) String bookingId,@JsonKey(name: ClientBookingListItem.bookingStatusKey_) String bookingStatus,@JsonKey(name: ClientBookingListItem.gigIdKey_) String? gigId,@JsonKey(name: ClientBookingListItem.gigStatusKey_) String? gigStatus,@JsonKey(name: ClientBookingListItem.paymentStatusKey_) String? paymentStatus,@JsonKey(name: ClientBookingListItem.requestedStartKey_) DateTime requestedStart,@JsonKey(name: ClientBookingListItem.requestedEndKey_) DateTime requestedEnd,@JsonKey(name: ClientBookingListItem.locationTextKey_) String? locationText,@JsonKey(name: ClientBookingListItem.expiresAtKey_) DateTime expiresAt,@JsonKey(name: ClientBookingListItem.createdAtKey_) DateTime createdAt
});




}
/// @nodoc
class _$ClientBookingListItemCopyWithImpl<$Res>
    implements $ClientBookingListItemCopyWith<$Res> {
  _$ClientBookingListItemCopyWithImpl(this._self, this._then);

  final ClientBookingListItem _self;
  final $Res Function(ClientBookingListItem) _then;

/// Create a copy of ClientBookingListItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bookingId = null,Object? bookingStatus = null,Object? gigId = freezed,Object? gigStatus = freezed,Object? paymentStatus = freezed,Object? requestedStart = null,Object? requestedEnd = null,Object? locationText = freezed,Object? expiresAt = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
bookingId: null == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String,bookingStatus: null == bookingStatus ? _self.bookingStatus : bookingStatus // ignore: cast_nullable_to_non_nullable
as String,gigId: freezed == gigId ? _self.gigId : gigId // ignore: cast_nullable_to_non_nullable
as String?,gigStatus: freezed == gigStatus ? _self.gigStatus : gigStatus // ignore: cast_nullable_to_non_nullable
as String?,paymentStatus: freezed == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as String?,requestedStart: null == requestedStart ? _self.requestedStart : requestedStart // ignore: cast_nullable_to_non_nullable
as DateTime,requestedEnd: null == requestedEnd ? _self.requestedEnd : requestedEnd // ignore: cast_nullable_to_non_nullable
as DateTime,locationText: freezed == locationText ? _self.locationText : locationText // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ClientBookingListItem].
extension ClientBookingListItemPatterns on ClientBookingListItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientBookingListItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientBookingListItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientBookingListItem value)  $default,){
final _that = this;
switch (_that) {
case _ClientBookingListItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientBookingListItem value)?  $default,){
final _that = this;
switch (_that) {
case _ClientBookingListItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ClientBookingListItem.bookingIdKey_)  String bookingId, @JsonKey(name: ClientBookingListItem.bookingStatusKey_)  String bookingStatus, @JsonKey(name: ClientBookingListItem.gigIdKey_)  String? gigId, @JsonKey(name: ClientBookingListItem.gigStatusKey_)  String? gigStatus, @JsonKey(name: ClientBookingListItem.paymentStatusKey_)  String? paymentStatus, @JsonKey(name: ClientBookingListItem.requestedStartKey_)  DateTime requestedStart, @JsonKey(name: ClientBookingListItem.requestedEndKey_)  DateTime requestedEnd, @JsonKey(name: ClientBookingListItem.locationTextKey_)  String? locationText, @JsonKey(name: ClientBookingListItem.expiresAtKey_)  DateTime expiresAt, @JsonKey(name: ClientBookingListItem.createdAtKey_)  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientBookingListItem() when $default != null:
return $default(_that.bookingId,_that.bookingStatus,_that.gigId,_that.gigStatus,_that.paymentStatus,_that.requestedStart,_that.requestedEnd,_that.locationText,_that.expiresAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ClientBookingListItem.bookingIdKey_)  String bookingId, @JsonKey(name: ClientBookingListItem.bookingStatusKey_)  String bookingStatus, @JsonKey(name: ClientBookingListItem.gigIdKey_)  String? gigId, @JsonKey(name: ClientBookingListItem.gigStatusKey_)  String? gigStatus, @JsonKey(name: ClientBookingListItem.paymentStatusKey_)  String? paymentStatus, @JsonKey(name: ClientBookingListItem.requestedStartKey_)  DateTime requestedStart, @JsonKey(name: ClientBookingListItem.requestedEndKey_)  DateTime requestedEnd, @JsonKey(name: ClientBookingListItem.locationTextKey_)  String? locationText, @JsonKey(name: ClientBookingListItem.expiresAtKey_)  DateTime expiresAt, @JsonKey(name: ClientBookingListItem.createdAtKey_)  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _ClientBookingListItem():
return $default(_that.bookingId,_that.bookingStatus,_that.gigId,_that.gigStatus,_that.paymentStatus,_that.requestedStart,_that.requestedEnd,_that.locationText,_that.expiresAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ClientBookingListItem.bookingIdKey_)  String bookingId, @JsonKey(name: ClientBookingListItem.bookingStatusKey_)  String bookingStatus, @JsonKey(name: ClientBookingListItem.gigIdKey_)  String? gigId, @JsonKey(name: ClientBookingListItem.gigStatusKey_)  String? gigStatus, @JsonKey(name: ClientBookingListItem.paymentStatusKey_)  String? paymentStatus, @JsonKey(name: ClientBookingListItem.requestedStartKey_)  DateTime requestedStart, @JsonKey(name: ClientBookingListItem.requestedEndKey_)  DateTime requestedEnd, @JsonKey(name: ClientBookingListItem.locationTextKey_)  String? locationText, @JsonKey(name: ClientBookingListItem.expiresAtKey_)  DateTime expiresAt, @JsonKey(name: ClientBookingListItem.createdAtKey_)  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ClientBookingListItem() when $default != null:
return $default(_that.bookingId,_that.bookingStatus,_that.gigId,_that.gigStatus,_that.paymentStatus,_that.requestedStart,_that.requestedEnd,_that.locationText,_that.expiresAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ClientBookingListItem extends ClientBookingListItem {
  const _ClientBookingListItem({@JsonKey(name: ClientBookingListItem.bookingIdKey_) required this.bookingId, @JsonKey(name: ClientBookingListItem.bookingStatusKey_) required this.bookingStatus, @JsonKey(name: ClientBookingListItem.gigIdKey_) this.gigId, @JsonKey(name: ClientBookingListItem.gigStatusKey_) this.gigStatus, @JsonKey(name: ClientBookingListItem.paymentStatusKey_) this.paymentStatus, @JsonKey(name: ClientBookingListItem.requestedStartKey_) required this.requestedStart, @JsonKey(name: ClientBookingListItem.requestedEndKey_) required this.requestedEnd, @JsonKey(name: ClientBookingListItem.locationTextKey_) this.locationText, @JsonKey(name: ClientBookingListItem.expiresAtKey_) required this.expiresAt, @JsonKey(name: ClientBookingListItem.createdAtKey_) required this.createdAt}): super._();
  factory _ClientBookingListItem.fromJson(Map<String, dynamic> json) => _$ClientBookingListItemFromJson(json);

/// bookingId
@override@JsonKey(name: ClientBookingListItem.bookingIdKey_) final  String bookingId;
/// bookingStatus
@override@JsonKey(name: ClientBookingListItem.bookingStatusKey_) final  String bookingStatus;
/// gigId
@override@JsonKey(name: ClientBookingListItem.gigIdKey_) final  String? gigId;
/// gigStatus
@override@JsonKey(name: ClientBookingListItem.gigStatusKey_) final  String? gigStatus;
/// paymentStatus
@override@JsonKey(name: ClientBookingListItem.paymentStatusKey_) final  String? paymentStatus;
/// requestedStart
@override@JsonKey(name: ClientBookingListItem.requestedStartKey_) final  DateTime requestedStart;
/// requestedEnd
@override@JsonKey(name: ClientBookingListItem.requestedEndKey_) final  DateTime requestedEnd;
/// locationText
@override@JsonKey(name: ClientBookingListItem.locationTextKey_) final  String? locationText;
/// expiresAt
@override@JsonKey(name: ClientBookingListItem.expiresAtKey_) final  DateTime expiresAt;
/// createdAt
@override@JsonKey(name: ClientBookingListItem.createdAtKey_) final  DateTime createdAt;

/// Create a copy of ClientBookingListItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientBookingListItemCopyWith<_ClientBookingListItem> get copyWith => __$ClientBookingListItemCopyWithImpl<_ClientBookingListItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientBookingListItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientBookingListItem&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.bookingStatus, bookingStatus) || other.bookingStatus == bookingStatus)&&(identical(other.gigId, gigId) || other.gigId == gigId)&&(identical(other.gigStatus, gigStatus) || other.gigStatus == gigStatus)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.requestedStart, requestedStart) || other.requestedStart == requestedStart)&&(identical(other.requestedEnd, requestedEnd) || other.requestedEnd == requestedEnd)&&(identical(other.locationText, locationText) || other.locationText == locationText)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bookingId,bookingStatus,gigId,gigStatus,paymentStatus,requestedStart,requestedEnd,locationText,expiresAt,createdAt);

@override
String toString() {
  return 'ClientBookingListItem(bookingId: $bookingId, bookingStatus: $bookingStatus, gigId: $gigId, gigStatus: $gigStatus, paymentStatus: $paymentStatus, requestedStart: $requestedStart, requestedEnd: $requestedEnd, locationText: $locationText, expiresAt: $expiresAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ClientBookingListItemCopyWith<$Res> implements $ClientBookingListItemCopyWith<$Res> {
  factory _$ClientBookingListItemCopyWith(_ClientBookingListItem value, $Res Function(_ClientBookingListItem) _then) = __$ClientBookingListItemCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ClientBookingListItem.bookingIdKey_) String bookingId,@JsonKey(name: ClientBookingListItem.bookingStatusKey_) String bookingStatus,@JsonKey(name: ClientBookingListItem.gigIdKey_) String? gigId,@JsonKey(name: ClientBookingListItem.gigStatusKey_) String? gigStatus,@JsonKey(name: ClientBookingListItem.paymentStatusKey_) String? paymentStatus,@JsonKey(name: ClientBookingListItem.requestedStartKey_) DateTime requestedStart,@JsonKey(name: ClientBookingListItem.requestedEndKey_) DateTime requestedEnd,@JsonKey(name: ClientBookingListItem.locationTextKey_) String? locationText,@JsonKey(name: ClientBookingListItem.expiresAtKey_) DateTime expiresAt,@JsonKey(name: ClientBookingListItem.createdAtKey_) DateTime createdAt
});




}
/// @nodoc
class __$ClientBookingListItemCopyWithImpl<$Res>
    implements _$ClientBookingListItemCopyWith<$Res> {
  __$ClientBookingListItemCopyWithImpl(this._self, this._then);

  final _ClientBookingListItem _self;
  final $Res Function(_ClientBookingListItem) _then;

/// Create a copy of ClientBookingListItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bookingId = null,Object? bookingStatus = null,Object? gigId = freezed,Object? gigStatus = freezed,Object? paymentStatus = freezed,Object? requestedStart = null,Object? requestedEnd = null,Object? locationText = freezed,Object? expiresAt = null,Object? createdAt = null,}) {
  return _then(_ClientBookingListItem(
bookingId: null == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String,bookingStatus: null == bookingStatus ? _self.bookingStatus : bookingStatus // ignore: cast_nullable_to_non_nullable
as String,gigId: freezed == gigId ? _self.gigId : gigId // ignore: cast_nullable_to_non_nullable
as String?,gigStatus: freezed == gigStatus ? _self.gigStatus : gigStatus // ignore: cast_nullable_to_non_nullable
as String?,paymentStatus: freezed == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as String?,requestedStart: null == requestedStart ? _self.requestedStart : requestedStart // ignore: cast_nullable_to_non_nullable
as DateTime,requestedEnd: null == requestedEnd ? _self.requestedEnd : requestedEnd // ignore: cast_nullable_to_non_nullable
as DateTime,locationText: freezed == locationText ? _self.locationText : locationText // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
