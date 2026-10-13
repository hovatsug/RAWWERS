// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'clear_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClearResponse {

/// cleared
@JsonKey(name: ClearResponse.clearedKey_) bool get cleared;
/// Create a copy of ClearResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClearResponseCopyWith<ClearResponse> get copyWith => _$ClearResponseCopyWithImpl<ClearResponse>(this as ClearResponse, _$identity);

  /// Serializes this ClearResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClearResponse&&(identical(other.cleared, cleared) || other.cleared == cleared));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cleared);

@override
String toString() {
  return 'ClearResponse(cleared: $cleared)';
}


}

/// @nodoc
abstract mixin class $ClearResponseCopyWith<$Res>  {
  factory $ClearResponseCopyWith(ClearResponse value, $Res Function(ClearResponse) _then) = _$ClearResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ClearResponse.clearedKey_) bool cleared
});




}
/// @nodoc
class _$ClearResponseCopyWithImpl<$Res>
    implements $ClearResponseCopyWith<$Res> {
  _$ClearResponseCopyWithImpl(this._self, this._then);

  final ClearResponse _self;
  final $Res Function(ClearResponse) _then;

/// Create a copy of ClearResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cleared = null,}) {
  return _then(_self.copyWith(
cleared: null == cleared ? _self.cleared : cleared // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ClearResponse].
extension ClearResponsePatterns on ClearResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClearResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClearResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClearResponse value)  $default,){
final _that = this;
switch (_that) {
case _ClearResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClearResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ClearResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ClearResponse.clearedKey_)  bool cleared)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClearResponse() when $default != null:
return $default(_that.cleared);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ClearResponse.clearedKey_)  bool cleared)  $default,) {final _that = this;
switch (_that) {
case _ClearResponse():
return $default(_that.cleared);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ClearResponse.clearedKey_)  bool cleared)?  $default,) {final _that = this;
switch (_that) {
case _ClearResponse() when $default != null:
return $default(_that.cleared);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ClearResponse extends ClearResponse {
  const _ClearResponse({@JsonKey(name: ClearResponse.clearedKey_) this.cleared = true}): super._();
  factory _ClearResponse.fromJson(Map<String, dynamic> json) => _$ClearResponseFromJson(json);

/// cleared
@override@JsonKey(name: ClearResponse.clearedKey_) final  bool cleared;

/// Create a copy of ClearResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClearResponseCopyWith<_ClearResponse> get copyWith => __$ClearResponseCopyWithImpl<_ClearResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClearResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClearResponse&&(identical(other.cleared, cleared) || other.cleared == cleared));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cleared);

@override
String toString() {
  return 'ClearResponse(cleared: $cleared)';
}


}

/// @nodoc
abstract mixin class _$ClearResponseCopyWith<$Res> implements $ClearResponseCopyWith<$Res> {
  factory _$ClearResponseCopyWith(_ClearResponse value, $Res Function(_ClearResponse) _then) = __$ClearResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ClearResponse.clearedKey_) bool cleared
});




}
/// @nodoc
class __$ClearResponseCopyWithImpl<$Res>
    implements _$ClearResponseCopyWith<$Res> {
  __$ClearResponseCopyWithImpl(this._self, this._then);

  final _ClearResponse _self;
  final $Res Function(_ClearResponse) _then;

/// Create a copy of ClearResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cleared = null,}) {
  return _then(_ClearResponse(
cleared: null == cleared ? _self.cleared : cleared // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
