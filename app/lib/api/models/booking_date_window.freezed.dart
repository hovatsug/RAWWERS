// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_date_window.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BookingDateWindow {

/// startAt
@JsonKey(name: BookingDateWindow.startAtKey_) DateTime get startAt;/// endAt
@JsonKey(name: BookingDateWindow.endAtKey_) DateTime get endAt;
/// Create a copy of BookingDateWindow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingDateWindowCopyWith<BookingDateWindow> get copyWith => _$BookingDateWindowCopyWithImpl<BookingDateWindow>(this as BookingDateWindow, _$identity);

  /// Serializes this BookingDateWindow to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookingDateWindow&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startAt,endAt);

@override
String toString() {
  return 'BookingDateWindow(startAt: $startAt, endAt: $endAt)';
}


}

/// @nodoc
abstract mixin class $BookingDateWindowCopyWith<$Res>  {
  factory $BookingDateWindowCopyWith(BookingDateWindow value, $Res Function(BookingDateWindow) _then) = _$BookingDateWindowCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: BookingDateWindow.startAtKey_) DateTime startAt,@JsonKey(name: BookingDateWindow.endAtKey_) DateTime endAt
});




}
/// @nodoc
class _$BookingDateWindowCopyWithImpl<$Res>
    implements $BookingDateWindowCopyWith<$Res> {
  _$BookingDateWindowCopyWithImpl(this._self, this._then);

  final BookingDateWindow _self;
  final $Res Function(BookingDateWindow) _then;

/// Create a copy of BookingDateWindow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? startAt = null,Object? endAt = null,}) {
  return _then(_self.copyWith(
startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [BookingDateWindow].
extension BookingDateWindowPatterns on BookingDateWindow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookingDateWindow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookingDateWindow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookingDateWindow value)  $default,){
final _that = this;
switch (_that) {
case _BookingDateWindow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookingDateWindow value)?  $default,){
final _that = this;
switch (_that) {
case _BookingDateWindow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: BookingDateWindow.startAtKey_)  DateTime startAt, @JsonKey(name: BookingDateWindow.endAtKey_)  DateTime endAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookingDateWindow() when $default != null:
return $default(_that.startAt,_that.endAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: BookingDateWindow.startAtKey_)  DateTime startAt, @JsonKey(name: BookingDateWindow.endAtKey_)  DateTime endAt)  $default,) {final _that = this;
switch (_that) {
case _BookingDateWindow():
return $default(_that.startAt,_that.endAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: BookingDateWindow.startAtKey_)  DateTime startAt, @JsonKey(name: BookingDateWindow.endAtKey_)  DateTime endAt)?  $default,) {final _that = this;
switch (_that) {
case _BookingDateWindow() when $default != null:
return $default(_that.startAt,_that.endAt);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _BookingDateWindow extends BookingDateWindow {
  const _BookingDateWindow({@JsonKey(name: BookingDateWindow.startAtKey_) required this.startAt, @JsonKey(name: BookingDateWindow.endAtKey_) required this.endAt}): super._();
  factory _BookingDateWindow.fromJson(Map<String, dynamic> json) => _$BookingDateWindowFromJson(json);

/// startAt
@override@JsonKey(name: BookingDateWindow.startAtKey_) final  DateTime startAt;
/// endAt
@override@JsonKey(name: BookingDateWindow.endAtKey_) final  DateTime endAt;

/// Create a copy of BookingDateWindow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingDateWindowCopyWith<_BookingDateWindow> get copyWith => __$BookingDateWindowCopyWithImpl<_BookingDateWindow>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingDateWindowToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookingDateWindow&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startAt,endAt);

@override
String toString() {
  return 'BookingDateWindow(startAt: $startAt, endAt: $endAt)';
}


}

/// @nodoc
abstract mixin class _$BookingDateWindowCopyWith<$Res> implements $BookingDateWindowCopyWith<$Res> {
  factory _$BookingDateWindowCopyWith(_BookingDateWindow value, $Res Function(_BookingDateWindow) _then) = __$BookingDateWindowCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: BookingDateWindow.startAtKey_) DateTime startAt,@JsonKey(name: BookingDateWindow.endAtKey_) DateTime endAt
});




}
/// @nodoc
class __$BookingDateWindowCopyWithImpl<$Res>
    implements _$BookingDateWindowCopyWith<$Res> {
  __$BookingDateWindowCopyWithImpl(this._self, this._then);

  final _BookingDateWindow _self;
  final $Res Function(_BookingDateWindow) _then;

/// Create a copy of BookingDateWindow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? startAt = null,Object? endAt = null,}) {
  return _then(_BookingDateWindow(
startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
