// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verify_email_confirm_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VerifyEmailConfirmRequest {

/// code
@JsonKey(name: VerifyEmailConfirmRequest.codeKey_) String get code;
/// Create a copy of VerifyEmailConfirmRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerifyEmailConfirmRequestCopyWith<VerifyEmailConfirmRequest> get copyWith => _$VerifyEmailConfirmRequestCopyWithImpl<VerifyEmailConfirmRequest>(this as VerifyEmailConfirmRequest, _$identity);

  /// Serializes this VerifyEmailConfirmRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerifyEmailConfirmRequest&&(identical(other.code, code) || other.code == code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code);

@override
String toString() {
  return 'VerifyEmailConfirmRequest(code: $code)';
}


}

/// @nodoc
abstract mixin class $VerifyEmailConfirmRequestCopyWith<$Res>  {
  factory $VerifyEmailConfirmRequestCopyWith(VerifyEmailConfirmRequest value, $Res Function(VerifyEmailConfirmRequest) _then) = _$VerifyEmailConfirmRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: VerifyEmailConfirmRequest.codeKey_) String code
});




}
/// @nodoc
class _$VerifyEmailConfirmRequestCopyWithImpl<$Res>
    implements $VerifyEmailConfirmRequestCopyWith<$Res> {
  _$VerifyEmailConfirmRequestCopyWithImpl(this._self, this._then);

  final VerifyEmailConfirmRequest _self;
  final $Res Function(VerifyEmailConfirmRequest) _then;

/// Create a copy of VerifyEmailConfirmRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [VerifyEmailConfirmRequest].
extension VerifyEmailConfirmRequestPatterns on VerifyEmailConfirmRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VerifyEmailConfirmRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VerifyEmailConfirmRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VerifyEmailConfirmRequest value)  $default,){
final _that = this;
switch (_that) {
case _VerifyEmailConfirmRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VerifyEmailConfirmRequest value)?  $default,){
final _that = this;
switch (_that) {
case _VerifyEmailConfirmRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: VerifyEmailConfirmRequest.codeKey_)  String code)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VerifyEmailConfirmRequest() when $default != null:
return $default(_that.code);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: VerifyEmailConfirmRequest.codeKey_)  String code)  $default,) {final _that = this;
switch (_that) {
case _VerifyEmailConfirmRequest():
return $default(_that.code);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: VerifyEmailConfirmRequest.codeKey_)  String code)?  $default,) {final _that = this;
switch (_that) {
case _VerifyEmailConfirmRequest() when $default != null:
return $default(_that.code);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _VerifyEmailConfirmRequest extends VerifyEmailConfirmRequest {
  const _VerifyEmailConfirmRequest({@JsonKey(name: VerifyEmailConfirmRequest.codeKey_) required this.code}): super._();
  factory _VerifyEmailConfirmRequest.fromJson(Map<String, dynamic> json) => _$VerifyEmailConfirmRequestFromJson(json);

/// code
@override@JsonKey(name: VerifyEmailConfirmRequest.codeKey_) final  String code;

/// Create a copy of VerifyEmailConfirmRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerifyEmailConfirmRequestCopyWith<_VerifyEmailConfirmRequest> get copyWith => __$VerifyEmailConfirmRequestCopyWithImpl<_VerifyEmailConfirmRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VerifyEmailConfirmRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerifyEmailConfirmRequest&&(identical(other.code, code) || other.code == code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code);

@override
String toString() {
  return 'VerifyEmailConfirmRequest(code: $code)';
}


}

/// @nodoc
abstract mixin class _$VerifyEmailConfirmRequestCopyWith<$Res> implements $VerifyEmailConfirmRequestCopyWith<$Res> {
  factory _$VerifyEmailConfirmRequestCopyWith(_VerifyEmailConfirmRequest value, $Res Function(_VerifyEmailConfirmRequest) _then) = __$VerifyEmailConfirmRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: VerifyEmailConfirmRequest.codeKey_) String code
});




}
/// @nodoc
class __$VerifyEmailConfirmRequestCopyWithImpl<$Res>
    implements _$VerifyEmailConfirmRequestCopyWith<$Res> {
  __$VerifyEmailConfirmRequestCopyWithImpl(this._self, this._then);

  final _VerifyEmailConfirmRequest _self;
  final $Res Function(_VerifyEmailConfirmRequest) _then;

/// Create a copy of VerifyEmailConfirmRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,}) {
  return _then(_VerifyEmailConfirmRequest(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
