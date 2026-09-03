// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pro_onboarding_start_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProOnboardingStartRequest {

/// city
@JsonKey(name: ProOnboardingStartRequest.cityKey_) String get city;/// country
@JsonKey(name: ProOnboardingStartRequest.countryKey_) String get country;/// inviteCode
@JsonKey(name: ProOnboardingStartRequest.inviteCodeKey_) String? get inviteCode;
/// Create a copy of ProOnboardingStartRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProOnboardingStartRequestCopyWith<ProOnboardingStartRequest> get copyWith => _$ProOnboardingStartRequestCopyWithImpl<ProOnboardingStartRequest>(this as ProOnboardingStartRequest, _$identity);

  /// Serializes this ProOnboardingStartRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProOnboardingStartRequest&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,city,country,inviteCode);

@override
String toString() {
  return 'ProOnboardingStartRequest(city: $city, country: $country, inviteCode: $inviteCode)';
}


}

/// @nodoc
abstract mixin class $ProOnboardingStartRequestCopyWith<$Res>  {
  factory $ProOnboardingStartRequestCopyWith(ProOnboardingStartRequest value, $Res Function(ProOnboardingStartRequest) _then) = _$ProOnboardingStartRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ProOnboardingStartRequest.cityKey_) String city,@JsonKey(name: ProOnboardingStartRequest.countryKey_) String country,@JsonKey(name: ProOnboardingStartRequest.inviteCodeKey_) String? inviteCode
});




}
/// @nodoc
class _$ProOnboardingStartRequestCopyWithImpl<$Res>
    implements $ProOnboardingStartRequestCopyWith<$Res> {
  _$ProOnboardingStartRequestCopyWithImpl(this._self, this._then);

  final ProOnboardingStartRequest _self;
  final $Res Function(ProOnboardingStartRequest) _then;

/// Create a copy of ProOnboardingStartRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? city = null,Object? country = null,Object? inviteCode = freezed,}) {
  return _then(_self.copyWith(
city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,inviteCode: freezed == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProOnboardingStartRequest].
extension ProOnboardingStartRequestPatterns on ProOnboardingStartRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProOnboardingStartRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProOnboardingStartRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProOnboardingStartRequest value)  $default,){
final _that = this;
switch (_that) {
case _ProOnboardingStartRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProOnboardingStartRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ProOnboardingStartRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ProOnboardingStartRequest.cityKey_)  String city, @JsonKey(name: ProOnboardingStartRequest.countryKey_)  String country, @JsonKey(name: ProOnboardingStartRequest.inviteCodeKey_)  String? inviteCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProOnboardingStartRequest() when $default != null:
return $default(_that.city,_that.country,_that.inviteCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ProOnboardingStartRequest.cityKey_)  String city, @JsonKey(name: ProOnboardingStartRequest.countryKey_)  String country, @JsonKey(name: ProOnboardingStartRequest.inviteCodeKey_)  String? inviteCode)  $default,) {final _that = this;
switch (_that) {
case _ProOnboardingStartRequest():
return $default(_that.city,_that.country,_that.inviteCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ProOnboardingStartRequest.cityKey_)  String city, @JsonKey(name: ProOnboardingStartRequest.countryKey_)  String country, @JsonKey(name: ProOnboardingStartRequest.inviteCodeKey_)  String? inviteCode)?  $default,) {final _that = this;
switch (_that) {
case _ProOnboardingStartRequest() when $default != null:
return $default(_that.city,_that.country,_that.inviteCode);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ProOnboardingStartRequest extends ProOnboardingStartRequest {
  const _ProOnboardingStartRequest({@JsonKey(name: ProOnboardingStartRequest.cityKey_) required this.city, @JsonKey(name: ProOnboardingStartRequest.countryKey_) required this.country, @JsonKey(name: ProOnboardingStartRequest.inviteCodeKey_) this.inviteCode}): super._();
  factory _ProOnboardingStartRequest.fromJson(Map<String, dynamic> json) => _$ProOnboardingStartRequestFromJson(json);

/// city
@override@JsonKey(name: ProOnboardingStartRequest.cityKey_) final  String city;
/// country
@override@JsonKey(name: ProOnboardingStartRequest.countryKey_) final  String country;
/// inviteCode
@override@JsonKey(name: ProOnboardingStartRequest.inviteCodeKey_) final  String? inviteCode;

/// Create a copy of ProOnboardingStartRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProOnboardingStartRequestCopyWith<_ProOnboardingStartRequest> get copyWith => __$ProOnboardingStartRequestCopyWithImpl<_ProOnboardingStartRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProOnboardingStartRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProOnboardingStartRequest&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,city,country,inviteCode);

@override
String toString() {
  return 'ProOnboardingStartRequest(city: $city, country: $country, inviteCode: $inviteCode)';
}


}

/// @nodoc
abstract mixin class _$ProOnboardingStartRequestCopyWith<$Res> implements $ProOnboardingStartRequestCopyWith<$Res> {
  factory _$ProOnboardingStartRequestCopyWith(_ProOnboardingStartRequest value, $Res Function(_ProOnboardingStartRequest) _then) = __$ProOnboardingStartRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ProOnboardingStartRequest.cityKey_) String city,@JsonKey(name: ProOnboardingStartRequest.countryKey_) String country,@JsonKey(name: ProOnboardingStartRequest.inviteCodeKey_) String? inviteCode
});




}
/// @nodoc
class __$ProOnboardingStartRequestCopyWithImpl<$Res>
    implements _$ProOnboardingStartRequestCopyWith<$Res> {
  __$ProOnboardingStartRequestCopyWithImpl(this._self, this._then);

  final _ProOnboardingStartRequest _self;
  final $Res Function(_ProOnboardingStartRequest) _then;

/// Create a copy of ProOnboardingStartRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? city = null,Object? country = null,Object? inviteCode = freezed,}) {
  return _then(_ProOnboardingStartRequest(
city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,inviteCode: freezed == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
