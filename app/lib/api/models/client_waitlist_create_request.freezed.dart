// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_waitlist_create_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClientWaitlistCreateRequest {

/// email
@JsonKey(name: ClientWaitlistCreateRequest.emailKey_) String get email;/// country
@JsonKey(name: ClientWaitlistCreateRequest.countryKey_) String get country;/// city
@JsonKey(name: ClientWaitlistCreateRequest.cityKey_) String get city;/// nicheSlug
@JsonKey(name: ClientWaitlistCreateRequest.nicheSlugKey_) String? get nicheSlug;
/// Create a copy of ClientWaitlistCreateRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientWaitlistCreateRequestCopyWith<ClientWaitlistCreateRequest> get copyWith => _$ClientWaitlistCreateRequestCopyWithImpl<ClientWaitlistCreateRequest>(this as ClientWaitlistCreateRequest, _$identity);

  /// Serializes this ClientWaitlistCreateRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientWaitlistCreateRequest&&(identical(other.email, email) || other.email == email)&&(identical(other.country, country) || other.country == country)&&(identical(other.city, city) || other.city == city)&&(identical(other.nicheSlug, nicheSlug) || other.nicheSlug == nicheSlug));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,country,city,nicheSlug);

@override
String toString() {
  return 'ClientWaitlistCreateRequest(email: $email, country: $country, city: $city, nicheSlug: $nicheSlug)';
}


}

/// @nodoc
abstract mixin class $ClientWaitlistCreateRequestCopyWith<$Res>  {
  factory $ClientWaitlistCreateRequestCopyWith(ClientWaitlistCreateRequest value, $Res Function(ClientWaitlistCreateRequest) _then) = _$ClientWaitlistCreateRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ClientWaitlistCreateRequest.emailKey_) String email,@JsonKey(name: ClientWaitlistCreateRequest.countryKey_) String country,@JsonKey(name: ClientWaitlistCreateRequest.cityKey_) String city,@JsonKey(name: ClientWaitlistCreateRequest.nicheSlugKey_) String? nicheSlug
});




}
/// @nodoc
class _$ClientWaitlistCreateRequestCopyWithImpl<$Res>
    implements $ClientWaitlistCreateRequestCopyWith<$Res> {
  _$ClientWaitlistCreateRequestCopyWithImpl(this._self, this._then);

  final ClientWaitlistCreateRequest _self;
  final $Res Function(ClientWaitlistCreateRequest) _then;

/// Create a copy of ClientWaitlistCreateRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? country = null,Object? city = null,Object? nicheSlug = freezed,}) {
  return _then(_self.copyWith(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,nicheSlug: freezed == nicheSlug ? _self.nicheSlug : nicheSlug // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ClientWaitlistCreateRequest].
extension ClientWaitlistCreateRequestPatterns on ClientWaitlistCreateRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientWaitlistCreateRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientWaitlistCreateRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientWaitlistCreateRequest value)  $default,){
final _that = this;
switch (_that) {
case _ClientWaitlistCreateRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientWaitlistCreateRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ClientWaitlistCreateRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ClientWaitlistCreateRequest.emailKey_)  String email, @JsonKey(name: ClientWaitlistCreateRequest.countryKey_)  String country, @JsonKey(name: ClientWaitlistCreateRequest.cityKey_)  String city, @JsonKey(name: ClientWaitlistCreateRequest.nicheSlugKey_)  String? nicheSlug)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientWaitlistCreateRequest() when $default != null:
return $default(_that.email,_that.country,_that.city,_that.nicheSlug);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ClientWaitlistCreateRequest.emailKey_)  String email, @JsonKey(name: ClientWaitlistCreateRequest.countryKey_)  String country, @JsonKey(name: ClientWaitlistCreateRequest.cityKey_)  String city, @JsonKey(name: ClientWaitlistCreateRequest.nicheSlugKey_)  String? nicheSlug)  $default,) {final _that = this;
switch (_that) {
case _ClientWaitlistCreateRequest():
return $default(_that.email,_that.country,_that.city,_that.nicheSlug);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ClientWaitlistCreateRequest.emailKey_)  String email, @JsonKey(name: ClientWaitlistCreateRequest.countryKey_)  String country, @JsonKey(name: ClientWaitlistCreateRequest.cityKey_)  String city, @JsonKey(name: ClientWaitlistCreateRequest.nicheSlugKey_)  String? nicheSlug)?  $default,) {final _that = this;
switch (_that) {
case _ClientWaitlistCreateRequest() when $default != null:
return $default(_that.email,_that.country,_that.city,_that.nicheSlug);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ClientWaitlistCreateRequest extends ClientWaitlistCreateRequest {
  const _ClientWaitlistCreateRequest({@JsonKey(name: ClientWaitlistCreateRequest.emailKey_) required this.email, @JsonKey(name: ClientWaitlistCreateRequest.countryKey_) required this.country, @JsonKey(name: ClientWaitlistCreateRequest.cityKey_) required this.city, @JsonKey(name: ClientWaitlistCreateRequest.nicheSlugKey_) this.nicheSlug}): super._();
  factory _ClientWaitlistCreateRequest.fromJson(Map<String, dynamic> json) => _$ClientWaitlistCreateRequestFromJson(json);

/// email
@override@JsonKey(name: ClientWaitlistCreateRequest.emailKey_) final  String email;
/// country
@override@JsonKey(name: ClientWaitlistCreateRequest.countryKey_) final  String country;
/// city
@override@JsonKey(name: ClientWaitlistCreateRequest.cityKey_) final  String city;
/// nicheSlug
@override@JsonKey(name: ClientWaitlistCreateRequest.nicheSlugKey_) final  String? nicheSlug;

/// Create a copy of ClientWaitlistCreateRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientWaitlistCreateRequestCopyWith<_ClientWaitlistCreateRequest> get copyWith => __$ClientWaitlistCreateRequestCopyWithImpl<_ClientWaitlistCreateRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientWaitlistCreateRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientWaitlistCreateRequest&&(identical(other.email, email) || other.email == email)&&(identical(other.country, country) || other.country == country)&&(identical(other.city, city) || other.city == city)&&(identical(other.nicheSlug, nicheSlug) || other.nicheSlug == nicheSlug));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,country,city,nicheSlug);

@override
String toString() {
  return 'ClientWaitlistCreateRequest(email: $email, country: $country, city: $city, nicheSlug: $nicheSlug)';
}


}

/// @nodoc
abstract mixin class _$ClientWaitlistCreateRequestCopyWith<$Res> implements $ClientWaitlistCreateRequestCopyWith<$Res> {
  factory _$ClientWaitlistCreateRequestCopyWith(_ClientWaitlistCreateRequest value, $Res Function(_ClientWaitlistCreateRequest) _then) = __$ClientWaitlistCreateRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ClientWaitlistCreateRequest.emailKey_) String email,@JsonKey(name: ClientWaitlistCreateRequest.countryKey_) String country,@JsonKey(name: ClientWaitlistCreateRequest.cityKey_) String city,@JsonKey(name: ClientWaitlistCreateRequest.nicheSlugKey_) String? nicheSlug
});




}
/// @nodoc
class __$ClientWaitlistCreateRequestCopyWithImpl<$Res>
    implements _$ClientWaitlistCreateRequestCopyWith<$Res> {
  __$ClientWaitlistCreateRequestCopyWithImpl(this._self, this._then);

  final _ClientWaitlistCreateRequest _self;
  final $Res Function(_ClientWaitlistCreateRequest) _then;

/// Create a copy of ClientWaitlistCreateRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? country = null,Object? city = null,Object? nicheSlug = freezed,}) {
  return _then(_ClientWaitlistCreateRequest(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,nicheSlug: freezed == nicheSlug ? _self.nicheSlug : nicheSlug // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
