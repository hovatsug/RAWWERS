// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'raww_pending_booking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RawwPendingBooking {

/// gigId
@JsonKey(name: RawwPendingBooking.gigIdKey_) String get gigId;/// amount
@JsonKey(name: RawwPendingBooking.amountKey_) int get amount;/// held
@JsonKey(name: RawwPendingBooking.heldKey_) bool get held;/// expectedAt
@JsonKey(name: RawwPendingBooking.expectedAtKey_) DateTime? get expectedAt;
/// Create a copy of RawwPendingBooking
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RawwPendingBookingCopyWith<RawwPendingBooking> get copyWith => _$RawwPendingBookingCopyWithImpl<RawwPendingBooking>(this as RawwPendingBooking, _$identity);

  /// Serializes this RawwPendingBooking to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RawwPendingBooking&&(identical(other.gigId, gigId) || other.gigId == gigId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.held, held) || other.held == held)&&(identical(other.expectedAt, expectedAt) || other.expectedAt == expectedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,gigId,amount,held,expectedAt);

@override
String toString() {
  return 'RawwPendingBooking(gigId: $gigId, amount: $amount, held: $held, expectedAt: $expectedAt)';
}


}

/// @nodoc
abstract mixin class $RawwPendingBookingCopyWith<$Res>  {
  factory $RawwPendingBookingCopyWith(RawwPendingBooking value, $Res Function(RawwPendingBooking) _then) = _$RawwPendingBookingCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: RawwPendingBooking.gigIdKey_) String gigId,@JsonKey(name: RawwPendingBooking.amountKey_) int amount,@JsonKey(name: RawwPendingBooking.heldKey_) bool held,@JsonKey(name: RawwPendingBooking.expectedAtKey_) DateTime? expectedAt
});




}
/// @nodoc
class _$RawwPendingBookingCopyWithImpl<$Res>
    implements $RawwPendingBookingCopyWith<$Res> {
  _$RawwPendingBookingCopyWithImpl(this._self, this._then);

  final RawwPendingBooking _self;
  final $Res Function(RawwPendingBooking) _then;

/// Create a copy of RawwPendingBooking
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? gigId = null,Object? amount = null,Object? held = null,Object? expectedAt = freezed,}) {
  return _then(_self.copyWith(
gigId: null == gigId ? _self.gigId : gigId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,held: null == held ? _self.held : held // ignore: cast_nullable_to_non_nullable
as bool,expectedAt: freezed == expectedAt ? _self.expectedAt : expectedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RawwPendingBooking].
extension RawwPendingBookingPatterns on RawwPendingBooking {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RawwPendingBooking value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RawwPendingBooking() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RawwPendingBooking value)  $default,){
final _that = this;
switch (_that) {
case _RawwPendingBooking():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RawwPendingBooking value)?  $default,){
final _that = this;
switch (_that) {
case _RawwPendingBooking() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: RawwPendingBooking.gigIdKey_)  String gigId, @JsonKey(name: RawwPendingBooking.amountKey_)  int amount, @JsonKey(name: RawwPendingBooking.heldKey_)  bool held, @JsonKey(name: RawwPendingBooking.expectedAtKey_)  DateTime? expectedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RawwPendingBooking() when $default != null:
return $default(_that.gigId,_that.amount,_that.held,_that.expectedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: RawwPendingBooking.gigIdKey_)  String gigId, @JsonKey(name: RawwPendingBooking.amountKey_)  int amount, @JsonKey(name: RawwPendingBooking.heldKey_)  bool held, @JsonKey(name: RawwPendingBooking.expectedAtKey_)  DateTime? expectedAt)  $default,) {final _that = this;
switch (_that) {
case _RawwPendingBooking():
return $default(_that.gigId,_that.amount,_that.held,_that.expectedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: RawwPendingBooking.gigIdKey_)  String gigId, @JsonKey(name: RawwPendingBooking.amountKey_)  int amount, @JsonKey(name: RawwPendingBooking.heldKey_)  bool held, @JsonKey(name: RawwPendingBooking.expectedAtKey_)  DateTime? expectedAt)?  $default,) {final _that = this;
switch (_that) {
case _RawwPendingBooking() when $default != null:
return $default(_that.gigId,_that.amount,_that.held,_that.expectedAt);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _RawwPendingBooking extends RawwPendingBooking {
  const _RawwPendingBooking({@JsonKey(name: RawwPendingBooking.gigIdKey_) required this.gigId, @JsonKey(name: RawwPendingBooking.amountKey_) required this.amount, @JsonKey(name: RawwPendingBooking.heldKey_) required this.held, @JsonKey(name: RawwPendingBooking.expectedAtKey_) this.expectedAt}): super._();
  factory _RawwPendingBooking.fromJson(Map<String, dynamic> json) => _$RawwPendingBookingFromJson(json);

/// gigId
@override@JsonKey(name: RawwPendingBooking.gigIdKey_) final  String gigId;
/// amount
@override@JsonKey(name: RawwPendingBooking.amountKey_) final  int amount;
/// held
@override@JsonKey(name: RawwPendingBooking.heldKey_) final  bool held;
/// expectedAt
@override@JsonKey(name: RawwPendingBooking.expectedAtKey_) final  DateTime? expectedAt;

/// Create a copy of RawwPendingBooking
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RawwPendingBookingCopyWith<_RawwPendingBooking> get copyWith => __$RawwPendingBookingCopyWithImpl<_RawwPendingBooking>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RawwPendingBookingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RawwPendingBooking&&(identical(other.gigId, gigId) || other.gigId == gigId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.held, held) || other.held == held)&&(identical(other.expectedAt, expectedAt) || other.expectedAt == expectedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,gigId,amount,held,expectedAt);

@override
String toString() {
  return 'RawwPendingBooking(gigId: $gigId, amount: $amount, held: $held, expectedAt: $expectedAt)';
}


}

/// @nodoc
abstract mixin class _$RawwPendingBookingCopyWith<$Res> implements $RawwPendingBookingCopyWith<$Res> {
  factory _$RawwPendingBookingCopyWith(_RawwPendingBooking value, $Res Function(_RawwPendingBooking) _then) = __$RawwPendingBookingCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: RawwPendingBooking.gigIdKey_) String gigId,@JsonKey(name: RawwPendingBooking.amountKey_) int amount,@JsonKey(name: RawwPendingBooking.heldKey_) bool held,@JsonKey(name: RawwPendingBooking.expectedAtKey_) DateTime? expectedAt
});




}
/// @nodoc
class __$RawwPendingBookingCopyWithImpl<$Res>
    implements _$RawwPendingBookingCopyWith<$Res> {
  __$RawwPendingBookingCopyWithImpl(this._self, this._then);

  final _RawwPendingBooking _self;
  final $Res Function(_RawwPendingBooking) _then;

/// Create a copy of RawwPendingBooking
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? gigId = null,Object? amount = null,Object? held = null,Object? expectedAt = freezed,}) {
  return _then(_RawwPendingBooking(
gigId: null == gigId ? _self.gigId : gigId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,held: null == held ? _self.held : held // ignore: cast_nullable_to_non_nullable
as bool,expectedAt: freezed == expectedAt ? _self.expectedAt : expectedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
