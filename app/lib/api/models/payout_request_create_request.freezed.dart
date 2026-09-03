// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payout_request_create_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PayoutRequestCreateRequest {

/// amountEur
@JsonKey(name: PayoutRequestCreateRequest.amountEurKey_) dynamic get amountEur;
/// Create a copy of PayoutRequestCreateRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PayoutRequestCreateRequestCopyWith<PayoutRequestCreateRequest> get copyWith => _$PayoutRequestCreateRequestCopyWithImpl<PayoutRequestCreateRequest>(this as PayoutRequestCreateRequest, _$identity);

  /// Serializes this PayoutRequestCreateRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PayoutRequestCreateRequest&&const DeepCollectionEquality().equals(other.amountEur, amountEur));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(amountEur));

@override
String toString() {
  return 'PayoutRequestCreateRequest(amountEur: $amountEur)';
}


}

/// @nodoc
abstract mixin class $PayoutRequestCreateRequestCopyWith<$Res>  {
  factory $PayoutRequestCreateRequestCopyWith(PayoutRequestCreateRequest value, $Res Function(PayoutRequestCreateRequest) _then) = _$PayoutRequestCreateRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: PayoutRequestCreateRequest.amountEurKey_) dynamic amountEur
});




}
/// @nodoc
class _$PayoutRequestCreateRequestCopyWithImpl<$Res>
    implements $PayoutRequestCreateRequestCopyWith<$Res> {
  _$PayoutRequestCreateRequestCopyWithImpl(this._self, this._then);

  final PayoutRequestCreateRequest _self;
  final $Res Function(PayoutRequestCreateRequest) _then;

/// Create a copy of PayoutRequestCreateRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? amountEur = freezed,}) {
  return _then(_self.copyWith(
amountEur: freezed == amountEur ? _self.amountEur : amountEur // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}

}


/// Adds pattern-matching-related methods to [PayoutRequestCreateRequest].
extension PayoutRequestCreateRequestPatterns on PayoutRequestCreateRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PayoutRequestCreateRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PayoutRequestCreateRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PayoutRequestCreateRequest value)  $default,){
final _that = this;
switch (_that) {
case _PayoutRequestCreateRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PayoutRequestCreateRequest value)?  $default,){
final _that = this;
switch (_that) {
case _PayoutRequestCreateRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: PayoutRequestCreateRequest.amountEurKey_)  dynamic amountEur)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PayoutRequestCreateRequest() when $default != null:
return $default(_that.amountEur);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: PayoutRequestCreateRequest.amountEurKey_)  dynamic amountEur)  $default,) {final _that = this;
switch (_that) {
case _PayoutRequestCreateRequest():
return $default(_that.amountEur);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: PayoutRequestCreateRequest.amountEurKey_)  dynamic amountEur)?  $default,) {final _that = this;
switch (_that) {
case _PayoutRequestCreateRequest() when $default != null:
return $default(_that.amountEur);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _PayoutRequestCreateRequest extends PayoutRequestCreateRequest {
  const _PayoutRequestCreateRequest({@JsonKey(name: PayoutRequestCreateRequest.amountEurKey_) required this.amountEur}): super._();
  factory _PayoutRequestCreateRequest.fromJson(Map<String, dynamic> json) => _$PayoutRequestCreateRequestFromJson(json);

/// amountEur
@override@JsonKey(name: PayoutRequestCreateRequest.amountEurKey_) final  dynamic amountEur;

/// Create a copy of PayoutRequestCreateRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PayoutRequestCreateRequestCopyWith<_PayoutRequestCreateRequest> get copyWith => __$PayoutRequestCreateRequestCopyWithImpl<_PayoutRequestCreateRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PayoutRequestCreateRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PayoutRequestCreateRequest&&const DeepCollectionEquality().equals(other.amountEur, amountEur));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(amountEur));

@override
String toString() {
  return 'PayoutRequestCreateRequest(amountEur: $amountEur)';
}


}

/// @nodoc
abstract mixin class _$PayoutRequestCreateRequestCopyWith<$Res> implements $PayoutRequestCreateRequestCopyWith<$Res> {
  factory _$PayoutRequestCreateRequestCopyWith(_PayoutRequestCreateRequest value, $Res Function(_PayoutRequestCreateRequest) _then) = __$PayoutRequestCreateRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: PayoutRequestCreateRequest.amountEurKey_) dynamic amountEur
});




}
/// @nodoc
class __$PayoutRequestCreateRequestCopyWithImpl<$Res>
    implements _$PayoutRequestCreateRequestCopyWith<$Res> {
  __$PayoutRequestCreateRequestCopyWithImpl(this._self, this._then);

  final _PayoutRequestCreateRequest _self;
  final $Res Function(_PayoutRequestCreateRequest) _then;

/// Create a copy of PayoutRequestCreateRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? amountEur = freezed,}) {
  return _then(_PayoutRequestCreateRequest(
amountEur: freezed == amountEur ? _self.amountEur : amountEur // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}

// dart format on
