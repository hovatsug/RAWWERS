// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pairing_code_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PairingCodeResponse {

/// code
@JsonKey(name: PairingCodeResponse.codeKey_) String get code;/// expiresAt
@JsonKey(name: PairingCodeResponse.expiresAtKey_) DateTime get expiresAt;/// validMinutes
@JsonKey(name: PairingCodeResponse.validMinutesKey_) int get validMinutes;
/// Create a copy of PairingCodeResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PairingCodeResponseCopyWith<PairingCodeResponse> get copyWith => _$PairingCodeResponseCopyWithImpl<PairingCodeResponse>(this as PairingCodeResponse, _$identity);

  /// Serializes this PairingCodeResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PairingCodeResponse&&(identical(other.code, code) || other.code == code)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.validMinutes, validMinutes) || other.validMinutes == validMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,expiresAt,validMinutes);

@override
String toString() {
  return 'PairingCodeResponse(code: $code, expiresAt: $expiresAt, validMinutes: $validMinutes)';
}


}

/// @nodoc
abstract mixin class $PairingCodeResponseCopyWith<$Res>  {
  factory $PairingCodeResponseCopyWith(PairingCodeResponse value, $Res Function(PairingCodeResponse) _then) = _$PairingCodeResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: PairingCodeResponse.codeKey_) String code,@JsonKey(name: PairingCodeResponse.expiresAtKey_) DateTime expiresAt,@JsonKey(name: PairingCodeResponse.validMinutesKey_) int validMinutes
});




}
/// @nodoc
class _$PairingCodeResponseCopyWithImpl<$Res>
    implements $PairingCodeResponseCopyWith<$Res> {
  _$PairingCodeResponseCopyWithImpl(this._self, this._then);

  final PairingCodeResponse _self;
  final $Res Function(PairingCodeResponse) _then;

/// Create a copy of PairingCodeResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? expiresAt = null,Object? validMinutes = null,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,validMinutes: null == validMinutes ? _self.validMinutes : validMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PairingCodeResponse].
extension PairingCodeResponsePatterns on PairingCodeResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PairingCodeResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PairingCodeResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PairingCodeResponse value)  $default,){
final _that = this;
switch (_that) {
case _PairingCodeResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PairingCodeResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PairingCodeResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: PairingCodeResponse.codeKey_)  String code, @JsonKey(name: PairingCodeResponse.expiresAtKey_)  DateTime expiresAt, @JsonKey(name: PairingCodeResponse.validMinutesKey_)  int validMinutes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PairingCodeResponse() when $default != null:
return $default(_that.code,_that.expiresAt,_that.validMinutes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: PairingCodeResponse.codeKey_)  String code, @JsonKey(name: PairingCodeResponse.expiresAtKey_)  DateTime expiresAt, @JsonKey(name: PairingCodeResponse.validMinutesKey_)  int validMinutes)  $default,) {final _that = this;
switch (_that) {
case _PairingCodeResponse():
return $default(_that.code,_that.expiresAt,_that.validMinutes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: PairingCodeResponse.codeKey_)  String code, @JsonKey(name: PairingCodeResponse.expiresAtKey_)  DateTime expiresAt, @JsonKey(name: PairingCodeResponse.validMinutesKey_)  int validMinutes)?  $default,) {final _that = this;
switch (_that) {
case _PairingCodeResponse() when $default != null:
return $default(_that.code,_that.expiresAt,_that.validMinutes);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _PairingCodeResponse extends PairingCodeResponse {
  const _PairingCodeResponse({@JsonKey(name: PairingCodeResponse.codeKey_) required this.code, @JsonKey(name: PairingCodeResponse.expiresAtKey_) required this.expiresAt, @JsonKey(name: PairingCodeResponse.validMinutesKey_) required this.validMinutes}): super._();
  factory _PairingCodeResponse.fromJson(Map<String, dynamic> json) => _$PairingCodeResponseFromJson(json);

/// code
@override@JsonKey(name: PairingCodeResponse.codeKey_) final  String code;
/// expiresAt
@override@JsonKey(name: PairingCodeResponse.expiresAtKey_) final  DateTime expiresAt;
/// validMinutes
@override@JsonKey(name: PairingCodeResponse.validMinutesKey_) final  int validMinutes;

/// Create a copy of PairingCodeResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PairingCodeResponseCopyWith<_PairingCodeResponse> get copyWith => __$PairingCodeResponseCopyWithImpl<_PairingCodeResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PairingCodeResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PairingCodeResponse&&(identical(other.code, code) || other.code == code)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.validMinutes, validMinutes) || other.validMinutes == validMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,expiresAt,validMinutes);

@override
String toString() {
  return 'PairingCodeResponse(code: $code, expiresAt: $expiresAt, validMinutes: $validMinutes)';
}


}

/// @nodoc
abstract mixin class _$PairingCodeResponseCopyWith<$Res> implements $PairingCodeResponseCopyWith<$Res> {
  factory _$PairingCodeResponseCopyWith(_PairingCodeResponse value, $Res Function(_PairingCodeResponse) _then) = __$PairingCodeResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: PairingCodeResponse.codeKey_) String code,@JsonKey(name: PairingCodeResponse.expiresAtKey_) DateTime expiresAt,@JsonKey(name: PairingCodeResponse.validMinutesKey_) int validMinutes
});




}
/// @nodoc
class __$PairingCodeResponseCopyWithImpl<$Res>
    implements _$PairingCodeResponseCopyWith<$Res> {
  __$PairingCodeResponseCopyWithImpl(this._self, this._then);

  final _PairingCodeResponse _self;
  final $Res Function(_PairingCodeResponse) _then;

/// Create a copy of PairingCodeResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? expiresAt = null,Object? validMinutes = null,}) {
  return _then(_PairingCodeResponse(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,validMinutes: null == validMinutes ? _self.validMinutes : validMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
