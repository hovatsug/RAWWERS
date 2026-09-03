// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'time_window_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TimeWindowItem {

/// startAtUtc
@JsonKey(name: TimeWindowItem.startAtUtcKey_) DateTime get startAtUtc;/// endAtUtc
@JsonKey(name: TimeWindowItem.endAtUtcKey_) DateTime get endAtUtc;
/// Create a copy of TimeWindowItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimeWindowItemCopyWith<TimeWindowItem> get copyWith => _$TimeWindowItemCopyWithImpl<TimeWindowItem>(this as TimeWindowItem, _$identity);

  /// Serializes this TimeWindowItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimeWindowItem&&(identical(other.startAtUtc, startAtUtc) || other.startAtUtc == startAtUtc)&&(identical(other.endAtUtc, endAtUtc) || other.endAtUtc == endAtUtc));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startAtUtc,endAtUtc);

@override
String toString() {
  return 'TimeWindowItem(startAtUtc: $startAtUtc, endAtUtc: $endAtUtc)';
}


}

/// @nodoc
abstract mixin class $TimeWindowItemCopyWith<$Res>  {
  factory $TimeWindowItemCopyWith(TimeWindowItem value, $Res Function(TimeWindowItem) _then) = _$TimeWindowItemCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: TimeWindowItem.startAtUtcKey_) DateTime startAtUtc,@JsonKey(name: TimeWindowItem.endAtUtcKey_) DateTime endAtUtc
});




}
/// @nodoc
class _$TimeWindowItemCopyWithImpl<$Res>
    implements $TimeWindowItemCopyWith<$Res> {
  _$TimeWindowItemCopyWithImpl(this._self, this._then);

  final TimeWindowItem _self;
  final $Res Function(TimeWindowItem) _then;

/// Create a copy of TimeWindowItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? startAtUtc = null,Object? endAtUtc = null,}) {
  return _then(_self.copyWith(
startAtUtc: null == startAtUtc ? _self.startAtUtc : startAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,endAtUtc: null == endAtUtc ? _self.endAtUtc : endAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [TimeWindowItem].
extension TimeWindowItemPatterns on TimeWindowItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimeWindowItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimeWindowItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimeWindowItem value)  $default,){
final _that = this;
switch (_that) {
case _TimeWindowItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimeWindowItem value)?  $default,){
final _that = this;
switch (_that) {
case _TimeWindowItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: TimeWindowItem.startAtUtcKey_)  DateTime startAtUtc, @JsonKey(name: TimeWindowItem.endAtUtcKey_)  DateTime endAtUtc)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimeWindowItem() when $default != null:
return $default(_that.startAtUtc,_that.endAtUtc);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: TimeWindowItem.startAtUtcKey_)  DateTime startAtUtc, @JsonKey(name: TimeWindowItem.endAtUtcKey_)  DateTime endAtUtc)  $default,) {final _that = this;
switch (_that) {
case _TimeWindowItem():
return $default(_that.startAtUtc,_that.endAtUtc);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: TimeWindowItem.startAtUtcKey_)  DateTime startAtUtc, @JsonKey(name: TimeWindowItem.endAtUtcKey_)  DateTime endAtUtc)?  $default,) {final _that = this;
switch (_that) {
case _TimeWindowItem() when $default != null:
return $default(_that.startAtUtc,_that.endAtUtc);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _TimeWindowItem extends TimeWindowItem {
  const _TimeWindowItem({@JsonKey(name: TimeWindowItem.startAtUtcKey_) required this.startAtUtc, @JsonKey(name: TimeWindowItem.endAtUtcKey_) required this.endAtUtc}): super._();
  factory _TimeWindowItem.fromJson(Map<String, dynamic> json) => _$TimeWindowItemFromJson(json);

/// startAtUtc
@override@JsonKey(name: TimeWindowItem.startAtUtcKey_) final  DateTime startAtUtc;
/// endAtUtc
@override@JsonKey(name: TimeWindowItem.endAtUtcKey_) final  DateTime endAtUtc;

/// Create a copy of TimeWindowItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimeWindowItemCopyWith<_TimeWindowItem> get copyWith => __$TimeWindowItemCopyWithImpl<_TimeWindowItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TimeWindowItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimeWindowItem&&(identical(other.startAtUtc, startAtUtc) || other.startAtUtc == startAtUtc)&&(identical(other.endAtUtc, endAtUtc) || other.endAtUtc == endAtUtc));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startAtUtc,endAtUtc);

@override
String toString() {
  return 'TimeWindowItem(startAtUtc: $startAtUtc, endAtUtc: $endAtUtc)';
}


}

/// @nodoc
abstract mixin class _$TimeWindowItemCopyWith<$Res> implements $TimeWindowItemCopyWith<$Res> {
  factory _$TimeWindowItemCopyWith(_TimeWindowItem value, $Res Function(_TimeWindowItem) _then) = __$TimeWindowItemCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: TimeWindowItem.startAtUtcKey_) DateTime startAtUtc,@JsonKey(name: TimeWindowItem.endAtUtcKey_) DateTime endAtUtc
});




}
/// @nodoc
class __$TimeWindowItemCopyWithImpl<$Res>
    implements _$TimeWindowItemCopyWith<$Res> {
  __$TimeWindowItemCopyWithImpl(this._self, this._then);

  final _TimeWindowItem _self;
  final $Res Function(_TimeWindowItem) _then;

/// Create a copy of TimeWindowItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? startAtUtc = null,Object? endAtUtc = null,}) {
  return _then(_TimeWindowItem(
startAtUtc: null == startAtUtc ? _self.startAtUtc : startAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,endAtUtc: null == endAtUtc ? _self.endAtUtc : endAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
