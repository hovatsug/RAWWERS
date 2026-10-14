// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'available_now_update.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AvailableNowUpdate {

/// switchedOn
@JsonKey(name: AvailableNowUpdate.switchedOnKey_) bool get switchedOn;/// prepMinutes
@JsonKey(name: AvailableNowUpdate.prepMinutesKey_) int? get prepMinutes;
/// Create a copy of AvailableNowUpdate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AvailableNowUpdateCopyWith<AvailableNowUpdate> get copyWith => _$AvailableNowUpdateCopyWithImpl<AvailableNowUpdate>(this as AvailableNowUpdate, _$identity);

  /// Serializes this AvailableNowUpdate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AvailableNowUpdate&&(identical(other.switchedOn, switchedOn) || other.switchedOn == switchedOn)&&(identical(other.prepMinutes, prepMinutes) || other.prepMinutes == prepMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,switchedOn,prepMinutes);

@override
String toString() {
  return 'AvailableNowUpdate(switchedOn: $switchedOn, prepMinutes: $prepMinutes)';
}


}

/// @nodoc
abstract mixin class $AvailableNowUpdateCopyWith<$Res>  {
  factory $AvailableNowUpdateCopyWith(AvailableNowUpdate value, $Res Function(AvailableNowUpdate) _then) = _$AvailableNowUpdateCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: AvailableNowUpdate.switchedOnKey_) bool switchedOn,@JsonKey(name: AvailableNowUpdate.prepMinutesKey_) int? prepMinutes
});




}
/// @nodoc
class _$AvailableNowUpdateCopyWithImpl<$Res>
    implements $AvailableNowUpdateCopyWith<$Res> {
  _$AvailableNowUpdateCopyWithImpl(this._self, this._then);

  final AvailableNowUpdate _self;
  final $Res Function(AvailableNowUpdate) _then;

/// Create a copy of AvailableNowUpdate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? switchedOn = null,Object? prepMinutes = freezed,}) {
  return _then(_self.copyWith(
switchedOn: null == switchedOn ? _self.switchedOn : switchedOn // ignore: cast_nullable_to_non_nullable
as bool,prepMinutes: freezed == prepMinutes ? _self.prepMinutes : prepMinutes // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [AvailableNowUpdate].
extension AvailableNowUpdatePatterns on AvailableNowUpdate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AvailableNowUpdate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AvailableNowUpdate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AvailableNowUpdate value)  $default,){
final _that = this;
switch (_that) {
case _AvailableNowUpdate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AvailableNowUpdate value)?  $default,){
final _that = this;
switch (_that) {
case _AvailableNowUpdate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: AvailableNowUpdate.switchedOnKey_)  bool switchedOn, @JsonKey(name: AvailableNowUpdate.prepMinutesKey_)  int? prepMinutes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AvailableNowUpdate() when $default != null:
return $default(_that.switchedOn,_that.prepMinutes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: AvailableNowUpdate.switchedOnKey_)  bool switchedOn, @JsonKey(name: AvailableNowUpdate.prepMinutesKey_)  int? prepMinutes)  $default,) {final _that = this;
switch (_that) {
case _AvailableNowUpdate():
return $default(_that.switchedOn,_that.prepMinutes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: AvailableNowUpdate.switchedOnKey_)  bool switchedOn, @JsonKey(name: AvailableNowUpdate.prepMinutesKey_)  int? prepMinutes)?  $default,) {final _that = this;
switch (_that) {
case _AvailableNowUpdate() when $default != null:
return $default(_that.switchedOn,_that.prepMinutes);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _AvailableNowUpdate extends AvailableNowUpdate {
  const _AvailableNowUpdate({@JsonKey(name: AvailableNowUpdate.switchedOnKey_) required this.switchedOn, @JsonKey(name: AvailableNowUpdate.prepMinutesKey_) this.prepMinutes}): super._();
  factory _AvailableNowUpdate.fromJson(Map<String, dynamic> json) => _$AvailableNowUpdateFromJson(json);

/// switchedOn
@override@JsonKey(name: AvailableNowUpdate.switchedOnKey_) final  bool switchedOn;
/// prepMinutes
@override@JsonKey(name: AvailableNowUpdate.prepMinutesKey_) final  int? prepMinutes;

/// Create a copy of AvailableNowUpdate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AvailableNowUpdateCopyWith<_AvailableNowUpdate> get copyWith => __$AvailableNowUpdateCopyWithImpl<_AvailableNowUpdate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AvailableNowUpdateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AvailableNowUpdate&&(identical(other.switchedOn, switchedOn) || other.switchedOn == switchedOn)&&(identical(other.prepMinutes, prepMinutes) || other.prepMinutes == prepMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,switchedOn,prepMinutes);

@override
String toString() {
  return 'AvailableNowUpdate(switchedOn: $switchedOn, prepMinutes: $prepMinutes)';
}


}

/// @nodoc
abstract mixin class _$AvailableNowUpdateCopyWith<$Res> implements $AvailableNowUpdateCopyWith<$Res> {
  factory _$AvailableNowUpdateCopyWith(_AvailableNowUpdate value, $Res Function(_AvailableNowUpdate) _then) = __$AvailableNowUpdateCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: AvailableNowUpdate.switchedOnKey_) bool switchedOn,@JsonKey(name: AvailableNowUpdate.prepMinutesKey_) int? prepMinutes
});




}
/// @nodoc
class __$AvailableNowUpdateCopyWithImpl<$Res>
    implements _$AvailableNowUpdateCopyWith<$Res> {
  __$AvailableNowUpdateCopyWithImpl(this._self, this._then);

  final _AvailableNowUpdate _self;
  final $Res Function(_AvailableNowUpdate) _then;

/// Create a copy of AvailableNowUpdate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? switchedOn = null,Object? prepMinutes = freezed,}) {
  return _then(_AvailableNowUpdate(
switchedOn: null == switchedOn ? _self.switchedOn : switchedOn // ignore: cast_nullable_to_non_nullable
as bool,prepMinutes: freezed == prepMinutes ? _self.prepMinutes : prepMinutes // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
