// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_payment_intent_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreatePaymentIntentRequest {

/// returnUrl
@JsonKey(name: CreatePaymentIntentRequest.returnUrlKey_) String? get returnUrl;/// pointsToSpend
@JsonKey(name: CreatePaymentIntentRequest.pointsToSpendKey_) int? get pointsToSpend;
/// Create a copy of CreatePaymentIntentRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreatePaymentIntentRequestCopyWith<CreatePaymentIntentRequest> get copyWith => _$CreatePaymentIntentRequestCopyWithImpl<CreatePaymentIntentRequest>(this as CreatePaymentIntentRequest, _$identity);

  /// Serializes this CreatePaymentIntentRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreatePaymentIntentRequest&&(identical(other.returnUrl, returnUrl) || other.returnUrl == returnUrl)&&(identical(other.pointsToSpend, pointsToSpend) || other.pointsToSpend == pointsToSpend));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,returnUrl,pointsToSpend);

@override
String toString() {
  return 'CreatePaymentIntentRequest(returnUrl: $returnUrl, pointsToSpend: $pointsToSpend)';
}


}

/// @nodoc
abstract mixin class $CreatePaymentIntentRequestCopyWith<$Res>  {
  factory $CreatePaymentIntentRequestCopyWith(CreatePaymentIntentRequest value, $Res Function(CreatePaymentIntentRequest) _then) = _$CreatePaymentIntentRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: CreatePaymentIntentRequest.returnUrlKey_) String? returnUrl,@JsonKey(name: CreatePaymentIntentRequest.pointsToSpendKey_) int? pointsToSpend
});




}
/// @nodoc
class _$CreatePaymentIntentRequestCopyWithImpl<$Res>
    implements $CreatePaymentIntentRequestCopyWith<$Res> {
  _$CreatePaymentIntentRequestCopyWithImpl(this._self, this._then);

  final CreatePaymentIntentRequest _self;
  final $Res Function(CreatePaymentIntentRequest) _then;

/// Create a copy of CreatePaymentIntentRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? returnUrl = freezed,Object? pointsToSpend = freezed,}) {
  return _then(_self.copyWith(
returnUrl: freezed == returnUrl ? _self.returnUrl : returnUrl // ignore: cast_nullable_to_non_nullable
as String?,pointsToSpend: freezed == pointsToSpend ? _self.pointsToSpend : pointsToSpend // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreatePaymentIntentRequest].
extension CreatePaymentIntentRequestPatterns on CreatePaymentIntentRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreatePaymentIntentRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreatePaymentIntentRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreatePaymentIntentRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreatePaymentIntentRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreatePaymentIntentRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreatePaymentIntentRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: CreatePaymentIntentRequest.returnUrlKey_)  String? returnUrl, @JsonKey(name: CreatePaymentIntentRequest.pointsToSpendKey_)  int? pointsToSpend)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreatePaymentIntentRequest() when $default != null:
return $default(_that.returnUrl,_that.pointsToSpend);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: CreatePaymentIntentRequest.returnUrlKey_)  String? returnUrl, @JsonKey(name: CreatePaymentIntentRequest.pointsToSpendKey_)  int? pointsToSpend)  $default,) {final _that = this;
switch (_that) {
case _CreatePaymentIntentRequest():
return $default(_that.returnUrl,_that.pointsToSpend);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: CreatePaymentIntentRequest.returnUrlKey_)  String? returnUrl, @JsonKey(name: CreatePaymentIntentRequest.pointsToSpendKey_)  int? pointsToSpend)?  $default,) {final _that = this;
switch (_that) {
case _CreatePaymentIntentRequest() when $default != null:
return $default(_that.returnUrl,_that.pointsToSpend);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _CreatePaymentIntentRequest extends CreatePaymentIntentRequest {
  const _CreatePaymentIntentRequest({@JsonKey(name: CreatePaymentIntentRequest.returnUrlKey_) this.returnUrl, @JsonKey(name: CreatePaymentIntentRequest.pointsToSpendKey_) this.pointsToSpend}): super._();
  factory _CreatePaymentIntentRequest.fromJson(Map<String, dynamic> json) => _$CreatePaymentIntentRequestFromJson(json);

/// returnUrl
@override@JsonKey(name: CreatePaymentIntentRequest.returnUrlKey_) final  String? returnUrl;
/// pointsToSpend
@override@JsonKey(name: CreatePaymentIntentRequest.pointsToSpendKey_) final  int? pointsToSpend;

/// Create a copy of CreatePaymentIntentRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreatePaymentIntentRequestCopyWith<_CreatePaymentIntentRequest> get copyWith => __$CreatePaymentIntentRequestCopyWithImpl<_CreatePaymentIntentRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreatePaymentIntentRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreatePaymentIntentRequest&&(identical(other.returnUrl, returnUrl) || other.returnUrl == returnUrl)&&(identical(other.pointsToSpend, pointsToSpend) || other.pointsToSpend == pointsToSpend));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,returnUrl,pointsToSpend);

@override
String toString() {
  return 'CreatePaymentIntentRequest(returnUrl: $returnUrl, pointsToSpend: $pointsToSpend)';
}


}

/// @nodoc
abstract mixin class _$CreatePaymentIntentRequestCopyWith<$Res> implements $CreatePaymentIntentRequestCopyWith<$Res> {
  factory _$CreatePaymentIntentRequestCopyWith(_CreatePaymentIntentRequest value, $Res Function(_CreatePaymentIntentRequest) _then) = __$CreatePaymentIntentRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: CreatePaymentIntentRequest.returnUrlKey_) String? returnUrl,@JsonKey(name: CreatePaymentIntentRequest.pointsToSpendKey_) int? pointsToSpend
});




}
/// @nodoc
class __$CreatePaymentIntentRequestCopyWithImpl<$Res>
    implements _$CreatePaymentIntentRequestCopyWith<$Res> {
  __$CreatePaymentIntentRequestCopyWithImpl(this._self, this._then);

  final _CreatePaymentIntentRequest _self;
  final $Res Function(_CreatePaymentIntentRequest) _then;

/// Create a copy of CreatePaymentIntentRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? returnUrl = freezed,Object? pointsToSpend = freezed,}) {
  return _then(_CreatePaymentIntentRequest(
returnUrl: freezed == returnUrl ? _self.returnUrl : returnUrl // ignore: cast_nullable_to_non_nullable
as String?,pointsToSpend: freezed == pointsToSpend ? _self.pointsToSpend : pointsToSpend // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
