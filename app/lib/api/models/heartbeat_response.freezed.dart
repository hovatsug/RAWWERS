// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'heartbeat_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HeartbeatResponse {

/// recorded
@JsonKey(name: HeartbeatResponse.recordedKey_) bool get recorded;
/// Create a copy of HeartbeatResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HeartbeatResponseCopyWith<HeartbeatResponse> get copyWith => _$HeartbeatResponseCopyWithImpl<HeartbeatResponse>(this as HeartbeatResponse, _$identity);

  /// Serializes this HeartbeatResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HeartbeatResponse&&(identical(other.recorded, recorded) || other.recorded == recorded));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recorded);

@override
String toString() {
  return 'HeartbeatResponse(recorded: $recorded)';
}


}

/// @nodoc
abstract mixin class $HeartbeatResponseCopyWith<$Res>  {
  factory $HeartbeatResponseCopyWith(HeartbeatResponse value, $Res Function(HeartbeatResponse) _then) = _$HeartbeatResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: HeartbeatResponse.recordedKey_) bool recorded
});




}
/// @nodoc
class _$HeartbeatResponseCopyWithImpl<$Res>
    implements $HeartbeatResponseCopyWith<$Res> {
  _$HeartbeatResponseCopyWithImpl(this._self, this._then);

  final HeartbeatResponse _self;
  final $Res Function(HeartbeatResponse) _then;

/// Create a copy of HeartbeatResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? recorded = null,}) {
  return _then(_self.copyWith(
recorded: null == recorded ? _self.recorded : recorded // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [HeartbeatResponse].
extension HeartbeatResponsePatterns on HeartbeatResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HeartbeatResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HeartbeatResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HeartbeatResponse value)  $default,){
final _that = this;
switch (_that) {
case _HeartbeatResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HeartbeatResponse value)?  $default,){
final _that = this;
switch (_that) {
case _HeartbeatResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: HeartbeatResponse.recordedKey_)  bool recorded)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HeartbeatResponse() when $default != null:
return $default(_that.recorded);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: HeartbeatResponse.recordedKey_)  bool recorded)  $default,) {final _that = this;
switch (_that) {
case _HeartbeatResponse():
return $default(_that.recorded);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: HeartbeatResponse.recordedKey_)  bool recorded)?  $default,) {final _that = this;
switch (_that) {
case _HeartbeatResponse() when $default != null:
return $default(_that.recorded);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _HeartbeatResponse extends HeartbeatResponse {
  const _HeartbeatResponse({@JsonKey(name: HeartbeatResponse.recordedKey_) required this.recorded}): super._();
  factory _HeartbeatResponse.fromJson(Map<String, dynamic> json) => _$HeartbeatResponseFromJson(json);

/// recorded
@override@JsonKey(name: HeartbeatResponse.recordedKey_) final  bool recorded;

/// Create a copy of HeartbeatResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HeartbeatResponseCopyWith<_HeartbeatResponse> get copyWith => __$HeartbeatResponseCopyWithImpl<_HeartbeatResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HeartbeatResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HeartbeatResponse&&(identical(other.recorded, recorded) || other.recorded == recorded));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recorded);

@override
String toString() {
  return 'HeartbeatResponse(recorded: $recorded)';
}


}

/// @nodoc
abstract mixin class _$HeartbeatResponseCopyWith<$Res> implements $HeartbeatResponseCopyWith<$Res> {
  factory _$HeartbeatResponseCopyWith(_HeartbeatResponse value, $Res Function(_HeartbeatResponse) _then) = __$HeartbeatResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: HeartbeatResponse.recordedKey_) bool recorded
});




}
/// @nodoc
class __$HeartbeatResponseCopyWithImpl<$Res>
    implements _$HeartbeatResponseCopyWith<$Res> {
  __$HeartbeatResponseCopyWithImpl(this._self, this._then);

  final _HeartbeatResponse _self;
  final $Res Function(_HeartbeatResponse) _then;

/// Create a copy of HeartbeatResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recorded = null,}) {
  return _then(_HeartbeatResponse(
recorded: null == recorded ? _self.recorded : recorded // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
