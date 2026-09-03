// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'password_reset_confirm_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PasswordResetConfirmRequest {

/// code
@JsonKey(name: PasswordResetConfirmRequest.codeKey_) String get code;/// newPassword
@JsonKey(name: PasswordResetConfirmRequest.newPasswordKey_) String get newPassword;
/// Create a copy of PasswordResetConfirmRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PasswordResetConfirmRequestCopyWith<PasswordResetConfirmRequest> get copyWith => _$PasswordResetConfirmRequestCopyWithImpl<PasswordResetConfirmRequest>(this as PasswordResetConfirmRequest, _$identity);

  /// Serializes this PasswordResetConfirmRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordResetConfirmRequest&&(identical(other.code, code) || other.code == code)&&(identical(other.newPassword, newPassword) || other.newPassword == newPassword));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,newPassword);

@override
String toString() {
  return 'PasswordResetConfirmRequest(code: $code, newPassword: $newPassword)';
}


}

/// @nodoc
abstract mixin class $PasswordResetConfirmRequestCopyWith<$Res>  {
  factory $PasswordResetConfirmRequestCopyWith(PasswordResetConfirmRequest value, $Res Function(PasswordResetConfirmRequest) _then) = _$PasswordResetConfirmRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: PasswordResetConfirmRequest.codeKey_) String code,@JsonKey(name: PasswordResetConfirmRequest.newPasswordKey_) String newPassword
});




}
/// @nodoc
class _$PasswordResetConfirmRequestCopyWithImpl<$Res>
    implements $PasswordResetConfirmRequestCopyWith<$Res> {
  _$PasswordResetConfirmRequestCopyWithImpl(this._self, this._then);

  final PasswordResetConfirmRequest _self;
  final $Res Function(PasswordResetConfirmRequest) _then;

/// Create a copy of PasswordResetConfirmRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? newPassword = null,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PasswordResetConfirmRequest].
extension PasswordResetConfirmRequestPatterns on PasswordResetConfirmRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PasswordResetConfirmRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PasswordResetConfirmRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PasswordResetConfirmRequest value)  $default,){
final _that = this;
switch (_that) {
case _PasswordResetConfirmRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PasswordResetConfirmRequest value)?  $default,){
final _that = this;
switch (_that) {
case _PasswordResetConfirmRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: PasswordResetConfirmRequest.codeKey_)  String code, @JsonKey(name: PasswordResetConfirmRequest.newPasswordKey_)  String newPassword)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PasswordResetConfirmRequest() when $default != null:
return $default(_that.code,_that.newPassword);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: PasswordResetConfirmRequest.codeKey_)  String code, @JsonKey(name: PasswordResetConfirmRequest.newPasswordKey_)  String newPassword)  $default,) {final _that = this;
switch (_that) {
case _PasswordResetConfirmRequest():
return $default(_that.code,_that.newPassword);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: PasswordResetConfirmRequest.codeKey_)  String code, @JsonKey(name: PasswordResetConfirmRequest.newPasswordKey_)  String newPassword)?  $default,) {final _that = this;
switch (_that) {
case _PasswordResetConfirmRequest() when $default != null:
return $default(_that.code,_that.newPassword);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _PasswordResetConfirmRequest extends PasswordResetConfirmRequest {
  const _PasswordResetConfirmRequest({@JsonKey(name: PasswordResetConfirmRequest.codeKey_) required this.code, @JsonKey(name: PasswordResetConfirmRequest.newPasswordKey_) required this.newPassword}): super._();
  factory _PasswordResetConfirmRequest.fromJson(Map<String, dynamic> json) => _$PasswordResetConfirmRequestFromJson(json);

/// code
@override@JsonKey(name: PasswordResetConfirmRequest.codeKey_) final  String code;
/// newPassword
@override@JsonKey(name: PasswordResetConfirmRequest.newPasswordKey_) final  String newPassword;

/// Create a copy of PasswordResetConfirmRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PasswordResetConfirmRequestCopyWith<_PasswordResetConfirmRequest> get copyWith => __$PasswordResetConfirmRequestCopyWithImpl<_PasswordResetConfirmRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PasswordResetConfirmRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PasswordResetConfirmRequest&&(identical(other.code, code) || other.code == code)&&(identical(other.newPassword, newPassword) || other.newPassword == newPassword));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,newPassword);

@override
String toString() {
  return 'PasswordResetConfirmRequest(code: $code, newPassword: $newPassword)';
}


}

/// @nodoc
abstract mixin class _$PasswordResetConfirmRequestCopyWith<$Res> implements $PasswordResetConfirmRequestCopyWith<$Res> {
  factory _$PasswordResetConfirmRequestCopyWith(_PasswordResetConfirmRequest value, $Res Function(_PasswordResetConfirmRequest) _then) = __$PasswordResetConfirmRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: PasswordResetConfirmRequest.codeKey_) String code,@JsonKey(name: PasswordResetConfirmRequest.newPasswordKey_) String newPassword
});




}
/// @nodoc
class __$PasswordResetConfirmRequestCopyWithImpl<$Res>
    implements _$PasswordResetConfirmRequestCopyWith<$Res> {
  __$PasswordResetConfirmRequestCopyWithImpl(this._self, this._then);

  final _PasswordResetConfirmRequest _self;
  final $Res Function(_PasswordResetConfirmRequest) _then;

/// Create a copy of PasswordResetConfirmRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? newPassword = null,}) {
  return _then(_PasswordResetConfirmRequest(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
