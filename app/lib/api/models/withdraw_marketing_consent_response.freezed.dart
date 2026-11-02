// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'withdraw_marketing_consent_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WithdrawMarketingConsentResponse {

/// withdrawn
@JsonKey(name: WithdrawMarketingConsentResponse.withdrawnKey_) int get withdrawn;
/// Create a copy of WithdrawMarketingConsentResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WithdrawMarketingConsentResponseCopyWith<WithdrawMarketingConsentResponse> get copyWith => _$WithdrawMarketingConsentResponseCopyWithImpl<WithdrawMarketingConsentResponse>(this as WithdrawMarketingConsentResponse, _$identity);

  /// Serializes this WithdrawMarketingConsentResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WithdrawMarketingConsentResponse&&(identical(other.withdrawn, withdrawn) || other.withdrawn == withdrawn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,withdrawn);

@override
String toString() {
  return 'WithdrawMarketingConsentResponse(withdrawn: $withdrawn)';
}


}

/// @nodoc
abstract mixin class $WithdrawMarketingConsentResponseCopyWith<$Res>  {
  factory $WithdrawMarketingConsentResponseCopyWith(WithdrawMarketingConsentResponse value, $Res Function(WithdrawMarketingConsentResponse) _then) = _$WithdrawMarketingConsentResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: WithdrawMarketingConsentResponse.withdrawnKey_) int withdrawn
});




}
/// @nodoc
class _$WithdrawMarketingConsentResponseCopyWithImpl<$Res>
    implements $WithdrawMarketingConsentResponseCopyWith<$Res> {
  _$WithdrawMarketingConsentResponseCopyWithImpl(this._self, this._then);

  final WithdrawMarketingConsentResponse _self;
  final $Res Function(WithdrawMarketingConsentResponse) _then;

/// Create a copy of WithdrawMarketingConsentResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? withdrawn = null,}) {
  return _then(_self.copyWith(
withdrawn: null == withdrawn ? _self.withdrawn : withdrawn // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [WithdrawMarketingConsentResponse].
extension WithdrawMarketingConsentResponsePatterns on WithdrawMarketingConsentResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WithdrawMarketingConsentResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WithdrawMarketingConsentResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WithdrawMarketingConsentResponse value)  $default,){
final _that = this;
switch (_that) {
case _WithdrawMarketingConsentResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WithdrawMarketingConsentResponse value)?  $default,){
final _that = this;
switch (_that) {
case _WithdrawMarketingConsentResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: WithdrawMarketingConsentResponse.withdrawnKey_)  int withdrawn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WithdrawMarketingConsentResponse() when $default != null:
return $default(_that.withdrawn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: WithdrawMarketingConsentResponse.withdrawnKey_)  int withdrawn)  $default,) {final _that = this;
switch (_that) {
case _WithdrawMarketingConsentResponse():
return $default(_that.withdrawn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: WithdrawMarketingConsentResponse.withdrawnKey_)  int withdrawn)?  $default,) {final _that = this;
switch (_that) {
case _WithdrawMarketingConsentResponse() when $default != null:
return $default(_that.withdrawn);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _WithdrawMarketingConsentResponse extends WithdrawMarketingConsentResponse {
  const _WithdrawMarketingConsentResponse({@JsonKey(name: WithdrawMarketingConsentResponse.withdrawnKey_) required this.withdrawn}): super._();
  factory _WithdrawMarketingConsentResponse.fromJson(Map<String, dynamic> json) => _$WithdrawMarketingConsentResponseFromJson(json);

/// withdrawn
@override@JsonKey(name: WithdrawMarketingConsentResponse.withdrawnKey_) final  int withdrawn;

/// Create a copy of WithdrawMarketingConsentResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WithdrawMarketingConsentResponseCopyWith<_WithdrawMarketingConsentResponse> get copyWith => __$WithdrawMarketingConsentResponseCopyWithImpl<_WithdrawMarketingConsentResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WithdrawMarketingConsentResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WithdrawMarketingConsentResponse&&(identical(other.withdrawn, withdrawn) || other.withdrawn == withdrawn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,withdrawn);

@override
String toString() {
  return 'WithdrawMarketingConsentResponse(withdrawn: $withdrawn)';
}


}

/// @nodoc
abstract mixin class _$WithdrawMarketingConsentResponseCopyWith<$Res> implements $WithdrawMarketingConsentResponseCopyWith<$Res> {
  factory _$WithdrawMarketingConsentResponseCopyWith(_WithdrawMarketingConsentResponse value, $Res Function(_WithdrawMarketingConsentResponse) _then) = __$WithdrawMarketingConsentResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: WithdrawMarketingConsentResponse.withdrawnKey_) int withdrawn
});




}
/// @nodoc
class __$WithdrawMarketingConsentResponseCopyWithImpl<$Res>
    implements _$WithdrawMarketingConsentResponseCopyWith<$Res> {
  __$WithdrawMarketingConsentResponseCopyWithImpl(this._self, this._then);

  final _WithdrawMarketingConsentResponse _self;
  final $Res Function(_WithdrawMarketingConsentResponse) _then;

/// Create a copy of WithdrawMarketingConsentResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? withdrawn = null,}) {
  return _then(_WithdrawMarketingConsentResponse(
withdrawn: null == withdrawn ? _self.withdrawn : withdrawn // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
