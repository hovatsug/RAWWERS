// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'upgrade_to_pro_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpgradeToProResponse {

/// ok
@JsonKey(name: UpgradeToProResponse.okKey_) bool get ok;/// roleAdded
@JsonKey(name: UpgradeToProResponse.roleAddedKey_) bool get roleAdded;
/// Create a copy of UpgradeToProResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpgradeToProResponseCopyWith<UpgradeToProResponse> get copyWith => _$UpgradeToProResponseCopyWithImpl<UpgradeToProResponse>(this as UpgradeToProResponse, _$identity);

  /// Serializes this UpgradeToProResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpgradeToProResponse&&(identical(other.ok, ok) || other.ok == ok)&&(identical(other.roleAdded, roleAdded) || other.roleAdded == roleAdded));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ok,roleAdded);

@override
String toString() {
  return 'UpgradeToProResponse(ok: $ok, roleAdded: $roleAdded)';
}


}

/// @nodoc
abstract mixin class $UpgradeToProResponseCopyWith<$Res>  {
  factory $UpgradeToProResponseCopyWith(UpgradeToProResponse value, $Res Function(UpgradeToProResponse) _then) = _$UpgradeToProResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: UpgradeToProResponse.okKey_) bool ok,@JsonKey(name: UpgradeToProResponse.roleAddedKey_) bool roleAdded
});




}
/// @nodoc
class _$UpgradeToProResponseCopyWithImpl<$Res>
    implements $UpgradeToProResponseCopyWith<$Res> {
  _$UpgradeToProResponseCopyWithImpl(this._self, this._then);

  final UpgradeToProResponse _self;
  final $Res Function(UpgradeToProResponse) _then;

/// Create a copy of UpgradeToProResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ok = null,Object? roleAdded = null,}) {
  return _then(_self.copyWith(
ok: null == ok ? _self.ok : ok // ignore: cast_nullable_to_non_nullable
as bool,roleAdded: null == roleAdded ? _self.roleAdded : roleAdded // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [UpgradeToProResponse].
extension UpgradeToProResponsePatterns on UpgradeToProResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpgradeToProResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpgradeToProResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpgradeToProResponse value)  $default,){
final _that = this;
switch (_that) {
case _UpgradeToProResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpgradeToProResponse value)?  $default,){
final _that = this;
switch (_that) {
case _UpgradeToProResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: UpgradeToProResponse.okKey_)  bool ok, @JsonKey(name: UpgradeToProResponse.roleAddedKey_)  bool roleAdded)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpgradeToProResponse() when $default != null:
return $default(_that.ok,_that.roleAdded);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: UpgradeToProResponse.okKey_)  bool ok, @JsonKey(name: UpgradeToProResponse.roleAddedKey_)  bool roleAdded)  $default,) {final _that = this;
switch (_that) {
case _UpgradeToProResponse():
return $default(_that.ok,_that.roleAdded);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: UpgradeToProResponse.okKey_)  bool ok, @JsonKey(name: UpgradeToProResponse.roleAddedKey_)  bool roleAdded)?  $default,) {final _that = this;
switch (_that) {
case _UpgradeToProResponse() when $default != null:
return $default(_that.ok,_that.roleAdded);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _UpgradeToProResponse extends UpgradeToProResponse {
  const _UpgradeToProResponse({@JsonKey(name: UpgradeToProResponse.okKey_) required this.ok, @JsonKey(name: UpgradeToProResponse.roleAddedKey_) required this.roleAdded}): super._();
  factory _UpgradeToProResponse.fromJson(Map<String, dynamic> json) => _$UpgradeToProResponseFromJson(json);

/// ok
@override@JsonKey(name: UpgradeToProResponse.okKey_) final  bool ok;
/// roleAdded
@override@JsonKey(name: UpgradeToProResponse.roleAddedKey_) final  bool roleAdded;

/// Create a copy of UpgradeToProResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpgradeToProResponseCopyWith<_UpgradeToProResponse> get copyWith => __$UpgradeToProResponseCopyWithImpl<_UpgradeToProResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpgradeToProResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpgradeToProResponse&&(identical(other.ok, ok) || other.ok == ok)&&(identical(other.roleAdded, roleAdded) || other.roleAdded == roleAdded));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ok,roleAdded);

@override
String toString() {
  return 'UpgradeToProResponse(ok: $ok, roleAdded: $roleAdded)';
}


}

/// @nodoc
abstract mixin class _$UpgradeToProResponseCopyWith<$Res> implements $UpgradeToProResponseCopyWith<$Res> {
  factory _$UpgradeToProResponseCopyWith(_UpgradeToProResponse value, $Res Function(_UpgradeToProResponse) _then) = __$UpgradeToProResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: UpgradeToProResponse.okKey_) bool ok,@JsonKey(name: UpgradeToProResponse.roleAddedKey_) bool roleAdded
});




}
/// @nodoc
class __$UpgradeToProResponseCopyWithImpl<$Res>
    implements _$UpgradeToProResponseCopyWith<$Res> {
  __$UpgradeToProResponseCopyWithImpl(this._self, this._then);

  final _UpgradeToProResponse _self;
  final $Res Function(_UpgradeToProResponse) _then;

/// Create a copy of UpgradeToProResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ok = null,Object? roleAdded = null,}) {
  return _then(_UpgradeToProResponse(
ok: null == ok ? _self.ok : ok // ignore: cast_nullable_to_non_nullable
as bool,roleAdded: null == roleAdded ? _self.roleAdded : roleAdded // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
