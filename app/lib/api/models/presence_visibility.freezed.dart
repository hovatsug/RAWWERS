// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'presence_visibility.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PresenceVisibility {

/// visible
@JsonKey(name: PresenceVisibility.visibleKey_) bool get visible;
/// Create a copy of PresenceVisibility
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PresenceVisibilityCopyWith<PresenceVisibility> get copyWith => _$PresenceVisibilityCopyWithImpl<PresenceVisibility>(this as PresenceVisibility, _$identity);

  /// Serializes this PresenceVisibility to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PresenceVisibility&&(identical(other.visible, visible) || other.visible == visible));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,visible);

@override
String toString() {
  return 'PresenceVisibility(visible: $visible)';
}


}

/// @nodoc
abstract mixin class $PresenceVisibilityCopyWith<$Res>  {
  factory $PresenceVisibilityCopyWith(PresenceVisibility value, $Res Function(PresenceVisibility) _then) = _$PresenceVisibilityCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: PresenceVisibility.visibleKey_) bool visible
});




}
/// @nodoc
class _$PresenceVisibilityCopyWithImpl<$Res>
    implements $PresenceVisibilityCopyWith<$Res> {
  _$PresenceVisibilityCopyWithImpl(this._self, this._then);

  final PresenceVisibility _self;
  final $Res Function(PresenceVisibility) _then;

/// Create a copy of PresenceVisibility
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? visible = null,}) {
  return _then(_self.copyWith(
visible: null == visible ? _self.visible : visible // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PresenceVisibility].
extension PresenceVisibilityPatterns on PresenceVisibility {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PresenceVisibility value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PresenceVisibility() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PresenceVisibility value)  $default,){
final _that = this;
switch (_that) {
case _PresenceVisibility():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PresenceVisibility value)?  $default,){
final _that = this;
switch (_that) {
case _PresenceVisibility() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: PresenceVisibility.visibleKey_)  bool visible)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PresenceVisibility() when $default != null:
return $default(_that.visible);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: PresenceVisibility.visibleKey_)  bool visible)  $default,) {final _that = this;
switch (_that) {
case _PresenceVisibility():
return $default(_that.visible);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: PresenceVisibility.visibleKey_)  bool visible)?  $default,) {final _that = this;
switch (_that) {
case _PresenceVisibility() when $default != null:
return $default(_that.visible);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _PresenceVisibility extends PresenceVisibility {
  const _PresenceVisibility({@JsonKey(name: PresenceVisibility.visibleKey_) required this.visible}): super._();
  factory _PresenceVisibility.fromJson(Map<String, dynamic> json) => _$PresenceVisibilityFromJson(json);

/// visible
@override@JsonKey(name: PresenceVisibility.visibleKey_) final  bool visible;

/// Create a copy of PresenceVisibility
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PresenceVisibilityCopyWith<_PresenceVisibility> get copyWith => __$PresenceVisibilityCopyWithImpl<_PresenceVisibility>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PresenceVisibilityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PresenceVisibility&&(identical(other.visible, visible) || other.visible == visible));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,visible);

@override
String toString() {
  return 'PresenceVisibility(visible: $visible)';
}


}

/// @nodoc
abstract mixin class _$PresenceVisibilityCopyWith<$Res> implements $PresenceVisibilityCopyWith<$Res> {
  factory _$PresenceVisibilityCopyWith(_PresenceVisibility value, $Res Function(_PresenceVisibility) _then) = __$PresenceVisibilityCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: PresenceVisibility.visibleKey_) bool visible
});




}
/// @nodoc
class __$PresenceVisibilityCopyWithImpl<$Res>
    implements _$PresenceVisibilityCopyWith<$Res> {
  __$PresenceVisibilityCopyWithImpl(this._self, this._then);

  final _PresenceVisibility _self;
  final $Res Function(_PresenceVisibility) _then;

/// Create a copy of PresenceVisibility
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? visible = null,}) {
  return _then(_PresenceVisibility(
visible: null == visible ? _self.visible : visible // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
