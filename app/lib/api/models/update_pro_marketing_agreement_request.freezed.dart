// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_pro_marketing_agreement_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdateProMarketingAgreementRequest {

/// optedIn
@JsonKey(name: UpdateProMarketingAgreementRequest.optedInKey_) bool get optedIn;
/// Create a copy of UpdateProMarketingAgreementRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateProMarketingAgreementRequestCopyWith<UpdateProMarketingAgreementRequest> get copyWith => _$UpdateProMarketingAgreementRequestCopyWithImpl<UpdateProMarketingAgreementRequest>(this as UpdateProMarketingAgreementRequest, _$identity);

  /// Serializes this UpdateProMarketingAgreementRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateProMarketingAgreementRequest&&(identical(other.optedIn, optedIn) || other.optedIn == optedIn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,optedIn);

@override
String toString() {
  return 'UpdateProMarketingAgreementRequest(optedIn: $optedIn)';
}


}

/// @nodoc
abstract mixin class $UpdateProMarketingAgreementRequestCopyWith<$Res>  {
  factory $UpdateProMarketingAgreementRequestCopyWith(UpdateProMarketingAgreementRequest value, $Res Function(UpdateProMarketingAgreementRequest) _then) = _$UpdateProMarketingAgreementRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: UpdateProMarketingAgreementRequest.optedInKey_) bool optedIn
});




}
/// @nodoc
class _$UpdateProMarketingAgreementRequestCopyWithImpl<$Res>
    implements $UpdateProMarketingAgreementRequestCopyWith<$Res> {
  _$UpdateProMarketingAgreementRequestCopyWithImpl(this._self, this._then);

  final UpdateProMarketingAgreementRequest _self;
  final $Res Function(UpdateProMarketingAgreementRequest) _then;

/// Create a copy of UpdateProMarketingAgreementRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? optedIn = null,}) {
  return _then(_self.copyWith(
optedIn: null == optedIn ? _self.optedIn : optedIn // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateProMarketingAgreementRequest].
extension UpdateProMarketingAgreementRequestPatterns on UpdateProMarketingAgreementRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateProMarketingAgreementRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateProMarketingAgreementRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateProMarketingAgreementRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateProMarketingAgreementRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateProMarketingAgreementRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateProMarketingAgreementRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: UpdateProMarketingAgreementRequest.optedInKey_)  bool optedIn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateProMarketingAgreementRequest() when $default != null:
return $default(_that.optedIn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: UpdateProMarketingAgreementRequest.optedInKey_)  bool optedIn)  $default,) {final _that = this;
switch (_that) {
case _UpdateProMarketingAgreementRequest():
return $default(_that.optedIn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: UpdateProMarketingAgreementRequest.optedInKey_)  bool optedIn)?  $default,) {final _that = this;
switch (_that) {
case _UpdateProMarketingAgreementRequest() when $default != null:
return $default(_that.optedIn);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _UpdateProMarketingAgreementRequest extends UpdateProMarketingAgreementRequest {
  const _UpdateProMarketingAgreementRequest({@JsonKey(name: UpdateProMarketingAgreementRequest.optedInKey_) required this.optedIn}): super._();
  factory _UpdateProMarketingAgreementRequest.fromJson(Map<String, dynamic> json) => _$UpdateProMarketingAgreementRequestFromJson(json);

/// optedIn
@override@JsonKey(name: UpdateProMarketingAgreementRequest.optedInKey_) final  bool optedIn;

/// Create a copy of UpdateProMarketingAgreementRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateProMarketingAgreementRequestCopyWith<_UpdateProMarketingAgreementRequest> get copyWith => __$UpdateProMarketingAgreementRequestCopyWithImpl<_UpdateProMarketingAgreementRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateProMarketingAgreementRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateProMarketingAgreementRequest&&(identical(other.optedIn, optedIn) || other.optedIn == optedIn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,optedIn);

@override
String toString() {
  return 'UpdateProMarketingAgreementRequest(optedIn: $optedIn)';
}


}

/// @nodoc
abstract mixin class _$UpdateProMarketingAgreementRequestCopyWith<$Res> implements $UpdateProMarketingAgreementRequestCopyWith<$Res> {
  factory _$UpdateProMarketingAgreementRequestCopyWith(_UpdateProMarketingAgreementRequest value, $Res Function(_UpdateProMarketingAgreementRequest) _then) = __$UpdateProMarketingAgreementRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: UpdateProMarketingAgreementRequest.optedInKey_) bool optedIn
});




}
/// @nodoc
class __$UpdateProMarketingAgreementRequestCopyWithImpl<$Res>
    implements _$UpdateProMarketingAgreementRequestCopyWith<$Res> {
  __$UpdateProMarketingAgreementRequestCopyWithImpl(this._self, this._then);

  final _UpdateProMarketingAgreementRequest _self;
  final $Res Function(_UpdateProMarketingAgreementRequest) _then;

/// Create a copy of UpdateProMarketingAgreementRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? optedIn = null,}) {
  return _then(_UpdateProMarketingAgreementRequest(
optedIn: null == optedIn ? _self.optedIn : optedIn // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
