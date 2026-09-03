// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'logout_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LogoutRequest {

/// refreshToken
@JsonKey(name: LogoutRequest.refreshTokenKey_) String? get refreshToken;/// revokeFamily
@JsonKey(name: LogoutRequest.revokeFamilyKey_) bool get revokeFamily;
/// Create a copy of LogoutRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LogoutRequestCopyWith<LogoutRequest> get copyWith => _$LogoutRequestCopyWithImpl<LogoutRequest>(this as LogoutRequest, _$identity);

  /// Serializes this LogoutRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LogoutRequest&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.revokeFamily, revokeFamily) || other.revokeFamily == revokeFamily));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,refreshToken,revokeFamily);

@override
String toString() {
  return 'LogoutRequest(refreshToken: $refreshToken, revokeFamily: $revokeFamily)';
}


}

/// @nodoc
abstract mixin class $LogoutRequestCopyWith<$Res>  {
  factory $LogoutRequestCopyWith(LogoutRequest value, $Res Function(LogoutRequest) _then) = _$LogoutRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: LogoutRequest.refreshTokenKey_) String? refreshToken,@JsonKey(name: LogoutRequest.revokeFamilyKey_) bool revokeFamily
});




}
/// @nodoc
class _$LogoutRequestCopyWithImpl<$Res>
    implements $LogoutRequestCopyWith<$Res> {
  _$LogoutRequestCopyWithImpl(this._self, this._then);

  final LogoutRequest _self;
  final $Res Function(LogoutRequest) _then;

/// Create a copy of LogoutRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? refreshToken = freezed,Object? revokeFamily = null,}) {
  return _then(_self.copyWith(
refreshToken: freezed == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String?,revokeFamily: null == revokeFamily ? _self.revokeFamily : revokeFamily // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LogoutRequest].
extension LogoutRequestPatterns on LogoutRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LogoutRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LogoutRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LogoutRequest value)  $default,){
final _that = this;
switch (_that) {
case _LogoutRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LogoutRequest value)?  $default,){
final _that = this;
switch (_that) {
case _LogoutRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: LogoutRequest.refreshTokenKey_)  String? refreshToken, @JsonKey(name: LogoutRequest.revokeFamilyKey_)  bool revokeFamily)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LogoutRequest() when $default != null:
return $default(_that.refreshToken,_that.revokeFamily);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: LogoutRequest.refreshTokenKey_)  String? refreshToken, @JsonKey(name: LogoutRequest.revokeFamilyKey_)  bool revokeFamily)  $default,) {final _that = this;
switch (_that) {
case _LogoutRequest():
return $default(_that.refreshToken,_that.revokeFamily);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: LogoutRequest.refreshTokenKey_)  String? refreshToken, @JsonKey(name: LogoutRequest.revokeFamilyKey_)  bool revokeFamily)?  $default,) {final _that = this;
switch (_that) {
case _LogoutRequest() when $default != null:
return $default(_that.refreshToken,_that.revokeFamily);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _LogoutRequest extends LogoutRequest {
  const _LogoutRequest({@JsonKey(name: LogoutRequest.refreshTokenKey_) this.refreshToken, @JsonKey(name: LogoutRequest.revokeFamilyKey_) this.revokeFamily = false}): super._();
  factory _LogoutRequest.fromJson(Map<String, dynamic> json) => _$LogoutRequestFromJson(json);

/// refreshToken
@override@JsonKey(name: LogoutRequest.refreshTokenKey_) final  String? refreshToken;
/// revokeFamily
@override@JsonKey(name: LogoutRequest.revokeFamilyKey_) final  bool revokeFamily;

/// Create a copy of LogoutRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LogoutRequestCopyWith<_LogoutRequest> get copyWith => __$LogoutRequestCopyWithImpl<_LogoutRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LogoutRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LogoutRequest&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.revokeFamily, revokeFamily) || other.revokeFamily == revokeFamily));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,refreshToken,revokeFamily);

@override
String toString() {
  return 'LogoutRequest(refreshToken: $refreshToken, revokeFamily: $revokeFamily)';
}


}

/// @nodoc
abstract mixin class _$LogoutRequestCopyWith<$Res> implements $LogoutRequestCopyWith<$Res> {
  factory _$LogoutRequestCopyWith(_LogoutRequest value, $Res Function(_LogoutRequest) _then) = __$LogoutRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: LogoutRequest.refreshTokenKey_) String? refreshToken,@JsonKey(name: LogoutRequest.revokeFamilyKey_) bool revokeFamily
});




}
/// @nodoc
class __$LogoutRequestCopyWithImpl<$Res>
    implements _$LogoutRequestCopyWith<$Res> {
  __$LogoutRequestCopyWithImpl(this._self, this._then);

  final _LogoutRequest _self;
  final $Res Function(_LogoutRequest) _then;

/// Create a copy of LogoutRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? refreshToken = freezed,Object? revokeFamily = null,}) {
  return _then(_LogoutRequest(
refreshToken: freezed == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String?,revokeFamily: null == revokeFamily ? _self.revokeFamily : revokeFamily // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
