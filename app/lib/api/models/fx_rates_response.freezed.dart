// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fx_rates_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FxRatesResponse {

/// baseAA
@JsonKey(name: FxRatesResponse.baseAAKey_) String get baseAA;/// rates
@JsonKey(name: FxRatesResponse.ratesKey_) Map<String, dynamic> get rates;/// asOf
@JsonKey(name: FxRatesResponse.asOfKey_) DateTime? get asOf;
/// Create a copy of FxRatesResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FxRatesResponseCopyWith<FxRatesResponse> get copyWith => _$FxRatesResponseCopyWithImpl<FxRatesResponse>(this as FxRatesResponse, _$identity);

  /// Serializes this FxRatesResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FxRatesResponse&&(identical(other.baseAA, baseAA) || other.baseAA == baseAA)&&const DeepCollectionEquality().equals(other.rates, rates)&&(identical(other.asOf, asOf) || other.asOf == asOf));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,baseAA,const DeepCollectionEquality().hash(rates),asOf);

@override
String toString() {
  return 'FxRatesResponse(baseAA: $baseAA, rates: $rates, asOf: $asOf)';
}


}

/// @nodoc
abstract mixin class $FxRatesResponseCopyWith<$Res>  {
  factory $FxRatesResponseCopyWith(FxRatesResponse value, $Res Function(FxRatesResponse) _then) = _$FxRatesResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: FxRatesResponse.baseAAKey_) String baseAA,@JsonKey(name: FxRatesResponse.ratesKey_) Map<String, dynamic> rates,@JsonKey(name: FxRatesResponse.asOfKey_) DateTime? asOf
});




}
/// @nodoc
class _$FxRatesResponseCopyWithImpl<$Res>
    implements $FxRatesResponseCopyWith<$Res> {
  _$FxRatesResponseCopyWithImpl(this._self, this._then);

  final FxRatesResponse _self;
  final $Res Function(FxRatesResponse) _then;

/// Create a copy of FxRatesResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? baseAA = null,Object? rates = null,Object? asOf = freezed,}) {
  return _then(_self.copyWith(
baseAA: null == baseAA ? _self.baseAA : baseAA // ignore: cast_nullable_to_non_nullable
as String,rates: null == rates ? _self.rates : rates // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,asOf: freezed == asOf ? _self.asOf : asOf // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [FxRatesResponse].
extension FxRatesResponsePatterns on FxRatesResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FxRatesResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FxRatesResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FxRatesResponse value)  $default,){
final _that = this;
switch (_that) {
case _FxRatesResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FxRatesResponse value)?  $default,){
final _that = this;
switch (_that) {
case _FxRatesResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: FxRatesResponse.baseAAKey_)  String baseAA, @JsonKey(name: FxRatesResponse.ratesKey_)  Map<String, dynamic> rates, @JsonKey(name: FxRatesResponse.asOfKey_)  DateTime? asOf)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FxRatesResponse() when $default != null:
return $default(_that.baseAA,_that.rates,_that.asOf);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: FxRatesResponse.baseAAKey_)  String baseAA, @JsonKey(name: FxRatesResponse.ratesKey_)  Map<String, dynamic> rates, @JsonKey(name: FxRatesResponse.asOfKey_)  DateTime? asOf)  $default,) {final _that = this;
switch (_that) {
case _FxRatesResponse():
return $default(_that.baseAA,_that.rates,_that.asOf);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: FxRatesResponse.baseAAKey_)  String baseAA, @JsonKey(name: FxRatesResponse.ratesKey_)  Map<String, dynamic> rates, @JsonKey(name: FxRatesResponse.asOfKey_)  DateTime? asOf)?  $default,) {final _that = this;
switch (_that) {
case _FxRatesResponse() when $default != null:
return $default(_that.baseAA,_that.rates,_that.asOf);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _FxRatesResponse extends FxRatesResponse {
  const _FxRatesResponse({@JsonKey(name: FxRatesResponse.baseAAKey_) required this.baseAA, @JsonKey(name: FxRatesResponse.ratesKey_) required final  Map<String, dynamic> rates, @JsonKey(name: FxRatesResponse.asOfKey_) this.asOf}): _rates = rates,super._();
  factory _FxRatesResponse.fromJson(Map<String, dynamic> json) => _$FxRatesResponseFromJson(json);

/// baseAA
@override@JsonKey(name: FxRatesResponse.baseAAKey_) final  String baseAA;
/// rates
 final  Map<String, dynamic> _rates;
/// rates
@override@JsonKey(name: FxRatesResponse.ratesKey_) Map<String, dynamic> get rates {
  if (_rates is EqualUnmodifiableMapView) return _rates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_rates);
}

/// asOf
@override@JsonKey(name: FxRatesResponse.asOfKey_) final  DateTime? asOf;

/// Create a copy of FxRatesResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FxRatesResponseCopyWith<_FxRatesResponse> get copyWith => __$FxRatesResponseCopyWithImpl<_FxRatesResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FxRatesResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FxRatesResponse&&(identical(other.baseAA, baseAA) || other.baseAA == baseAA)&&const DeepCollectionEquality().equals(other._rates, _rates)&&(identical(other.asOf, asOf) || other.asOf == asOf));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,baseAA,const DeepCollectionEquality().hash(_rates),asOf);

@override
String toString() {
  return 'FxRatesResponse(baseAA: $baseAA, rates: $rates, asOf: $asOf)';
}


}

/// @nodoc
abstract mixin class _$FxRatesResponseCopyWith<$Res> implements $FxRatesResponseCopyWith<$Res> {
  factory _$FxRatesResponseCopyWith(_FxRatesResponse value, $Res Function(_FxRatesResponse) _then) = __$FxRatesResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: FxRatesResponse.baseAAKey_) String baseAA,@JsonKey(name: FxRatesResponse.ratesKey_) Map<String, dynamic> rates,@JsonKey(name: FxRatesResponse.asOfKey_) DateTime? asOf
});




}
/// @nodoc
class __$FxRatesResponseCopyWithImpl<$Res>
    implements _$FxRatesResponseCopyWith<$Res> {
  __$FxRatesResponseCopyWithImpl(this._self, this._then);

  final _FxRatesResponse _self;
  final $Res Function(_FxRatesResponse) _then;

/// Create a copy of FxRatesResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? baseAA = null,Object? rates = null,Object? asOf = freezed,}) {
  return _then(_FxRatesResponse(
baseAA: null == baseAA ? _self.baseAA : baseAA // ignore: cast_nullable_to_non_nullable
as String,rates: null == rates ? _self._rates : rates // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,asOf: freezed == asOf ? _self.asOf : asOf // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
