// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_match_create_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClientMatchCreateRequest {

/// country
@JsonKey(name: ClientMatchCreateRequest.countryKey_) String get country;/// city
@JsonKey(name: ClientMatchCreateRequest.cityKey_) String get city;/// nicheSlug
@JsonKey(name: ClientMatchCreateRequest.nicheSlugKey_) String get nicheSlug;/// budgetMin
@JsonKey(name: ClientMatchCreateRequest.budgetMinKey_) dynamic? get budgetMin;/// budgetMax
@JsonKey(name: ClientMatchCreateRequest.budgetMaxKey_) dynamic? get budgetMax;/// styleTags
@JsonKey(name: ClientMatchCreateRequest.styleTagsKey_) List<String>? get styleTags;
/// Create a copy of ClientMatchCreateRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientMatchCreateRequestCopyWith<ClientMatchCreateRequest> get copyWith => _$ClientMatchCreateRequestCopyWithImpl<ClientMatchCreateRequest>(this as ClientMatchCreateRequest, _$identity);

  /// Serializes this ClientMatchCreateRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientMatchCreateRequest&&(identical(other.country, country) || other.country == country)&&(identical(other.city, city) || other.city == city)&&(identical(other.nicheSlug, nicheSlug) || other.nicheSlug == nicheSlug)&&const DeepCollectionEquality().equals(other.budgetMin, budgetMin)&&const DeepCollectionEquality().equals(other.budgetMax, budgetMax)&&const DeepCollectionEquality().equals(other.styleTags, styleTags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,country,city,nicheSlug,const DeepCollectionEquality().hash(budgetMin),const DeepCollectionEquality().hash(budgetMax),const DeepCollectionEquality().hash(styleTags));

@override
String toString() {
  return 'ClientMatchCreateRequest(country: $country, city: $city, nicheSlug: $nicheSlug, budgetMin: $budgetMin, budgetMax: $budgetMax, styleTags: $styleTags)';
}


}

/// @nodoc
abstract mixin class $ClientMatchCreateRequestCopyWith<$Res>  {
  factory $ClientMatchCreateRequestCopyWith(ClientMatchCreateRequest value, $Res Function(ClientMatchCreateRequest) _then) = _$ClientMatchCreateRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ClientMatchCreateRequest.countryKey_) String country,@JsonKey(name: ClientMatchCreateRequest.cityKey_) String city,@JsonKey(name: ClientMatchCreateRequest.nicheSlugKey_) String nicheSlug,@JsonKey(name: ClientMatchCreateRequest.budgetMinKey_) dynamic? budgetMin,@JsonKey(name: ClientMatchCreateRequest.budgetMaxKey_) dynamic? budgetMax,@JsonKey(name: ClientMatchCreateRequest.styleTagsKey_) List<String>? styleTags
});




}
/// @nodoc
class _$ClientMatchCreateRequestCopyWithImpl<$Res>
    implements $ClientMatchCreateRequestCopyWith<$Res> {
  _$ClientMatchCreateRequestCopyWithImpl(this._self, this._then);

  final ClientMatchCreateRequest _self;
  final $Res Function(ClientMatchCreateRequest) _then;

/// Create a copy of ClientMatchCreateRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? country = null,Object? city = null,Object? nicheSlug = null,Object? budgetMin = freezed,Object? budgetMax = freezed,Object? styleTags = freezed,}) {
  return _then(_self.copyWith(
country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,nicheSlug: null == nicheSlug ? _self.nicheSlug : nicheSlug // ignore: cast_nullable_to_non_nullable
as String,budgetMin: freezed == budgetMin ? _self.budgetMin : budgetMin // ignore: cast_nullable_to_non_nullable
as dynamic?,budgetMax: freezed == budgetMax ? _self.budgetMax : budgetMax // ignore: cast_nullable_to_non_nullable
as dynamic?,styleTags: freezed == styleTags ? _self.styleTags : styleTags // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ClientMatchCreateRequest].
extension ClientMatchCreateRequestPatterns on ClientMatchCreateRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientMatchCreateRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientMatchCreateRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientMatchCreateRequest value)  $default,){
final _that = this;
switch (_that) {
case _ClientMatchCreateRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientMatchCreateRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ClientMatchCreateRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ClientMatchCreateRequest.countryKey_)  String country, @JsonKey(name: ClientMatchCreateRequest.cityKey_)  String city, @JsonKey(name: ClientMatchCreateRequest.nicheSlugKey_)  String nicheSlug, @JsonKey(name: ClientMatchCreateRequest.budgetMinKey_)  dynamic? budgetMin, @JsonKey(name: ClientMatchCreateRequest.budgetMaxKey_)  dynamic? budgetMax, @JsonKey(name: ClientMatchCreateRequest.styleTagsKey_)  List<String>? styleTags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientMatchCreateRequest() when $default != null:
return $default(_that.country,_that.city,_that.nicheSlug,_that.budgetMin,_that.budgetMax,_that.styleTags);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ClientMatchCreateRequest.countryKey_)  String country, @JsonKey(name: ClientMatchCreateRequest.cityKey_)  String city, @JsonKey(name: ClientMatchCreateRequest.nicheSlugKey_)  String nicheSlug, @JsonKey(name: ClientMatchCreateRequest.budgetMinKey_)  dynamic? budgetMin, @JsonKey(name: ClientMatchCreateRequest.budgetMaxKey_)  dynamic? budgetMax, @JsonKey(name: ClientMatchCreateRequest.styleTagsKey_)  List<String>? styleTags)  $default,) {final _that = this;
switch (_that) {
case _ClientMatchCreateRequest():
return $default(_that.country,_that.city,_that.nicheSlug,_that.budgetMin,_that.budgetMax,_that.styleTags);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ClientMatchCreateRequest.countryKey_)  String country, @JsonKey(name: ClientMatchCreateRequest.cityKey_)  String city, @JsonKey(name: ClientMatchCreateRequest.nicheSlugKey_)  String nicheSlug, @JsonKey(name: ClientMatchCreateRequest.budgetMinKey_)  dynamic? budgetMin, @JsonKey(name: ClientMatchCreateRequest.budgetMaxKey_)  dynamic? budgetMax, @JsonKey(name: ClientMatchCreateRequest.styleTagsKey_)  List<String>? styleTags)?  $default,) {final _that = this;
switch (_that) {
case _ClientMatchCreateRequest() when $default != null:
return $default(_that.country,_that.city,_that.nicheSlug,_that.budgetMin,_that.budgetMax,_that.styleTags);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ClientMatchCreateRequest extends ClientMatchCreateRequest {
  const _ClientMatchCreateRequest({@JsonKey(name: ClientMatchCreateRequest.countryKey_) required this.country, @JsonKey(name: ClientMatchCreateRequest.cityKey_) required this.city, @JsonKey(name: ClientMatchCreateRequest.nicheSlugKey_) required this.nicheSlug, @JsonKey(name: ClientMatchCreateRequest.budgetMinKey_) this.budgetMin, @JsonKey(name: ClientMatchCreateRequest.budgetMaxKey_) this.budgetMax, @JsonKey(name: ClientMatchCreateRequest.styleTagsKey_) final  List<String>? styleTags}): _styleTags = styleTags,super._();
  factory _ClientMatchCreateRequest.fromJson(Map<String, dynamic> json) => _$ClientMatchCreateRequestFromJson(json);

/// country
@override@JsonKey(name: ClientMatchCreateRequest.countryKey_) final  String country;
/// city
@override@JsonKey(name: ClientMatchCreateRequest.cityKey_) final  String city;
/// nicheSlug
@override@JsonKey(name: ClientMatchCreateRequest.nicheSlugKey_) final  String nicheSlug;
/// budgetMin
@override@JsonKey(name: ClientMatchCreateRequest.budgetMinKey_) final  dynamic? budgetMin;
/// budgetMax
@override@JsonKey(name: ClientMatchCreateRequest.budgetMaxKey_) final  dynamic? budgetMax;
/// styleTags
 final  List<String>? _styleTags;
/// styleTags
@override@JsonKey(name: ClientMatchCreateRequest.styleTagsKey_) List<String>? get styleTags {
  final value = _styleTags;
  if (value == null) return null;
  if (_styleTags is EqualUnmodifiableListView) return _styleTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ClientMatchCreateRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientMatchCreateRequestCopyWith<_ClientMatchCreateRequest> get copyWith => __$ClientMatchCreateRequestCopyWithImpl<_ClientMatchCreateRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientMatchCreateRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientMatchCreateRequest&&(identical(other.country, country) || other.country == country)&&(identical(other.city, city) || other.city == city)&&(identical(other.nicheSlug, nicheSlug) || other.nicheSlug == nicheSlug)&&const DeepCollectionEquality().equals(other.budgetMin, budgetMin)&&const DeepCollectionEquality().equals(other.budgetMax, budgetMax)&&const DeepCollectionEquality().equals(other._styleTags, _styleTags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,country,city,nicheSlug,const DeepCollectionEquality().hash(budgetMin),const DeepCollectionEquality().hash(budgetMax),const DeepCollectionEquality().hash(_styleTags));

@override
String toString() {
  return 'ClientMatchCreateRequest(country: $country, city: $city, nicheSlug: $nicheSlug, budgetMin: $budgetMin, budgetMax: $budgetMax, styleTags: $styleTags)';
}


}

/// @nodoc
abstract mixin class _$ClientMatchCreateRequestCopyWith<$Res> implements $ClientMatchCreateRequestCopyWith<$Res> {
  factory _$ClientMatchCreateRequestCopyWith(_ClientMatchCreateRequest value, $Res Function(_ClientMatchCreateRequest) _then) = __$ClientMatchCreateRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ClientMatchCreateRequest.countryKey_) String country,@JsonKey(name: ClientMatchCreateRequest.cityKey_) String city,@JsonKey(name: ClientMatchCreateRequest.nicheSlugKey_) String nicheSlug,@JsonKey(name: ClientMatchCreateRequest.budgetMinKey_) dynamic? budgetMin,@JsonKey(name: ClientMatchCreateRequest.budgetMaxKey_) dynamic? budgetMax,@JsonKey(name: ClientMatchCreateRequest.styleTagsKey_) List<String>? styleTags
});




}
/// @nodoc
class __$ClientMatchCreateRequestCopyWithImpl<$Res>
    implements _$ClientMatchCreateRequestCopyWith<$Res> {
  __$ClientMatchCreateRequestCopyWithImpl(this._self, this._then);

  final _ClientMatchCreateRequest _self;
  final $Res Function(_ClientMatchCreateRequest) _then;

/// Create a copy of ClientMatchCreateRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? country = null,Object? city = null,Object? nicheSlug = null,Object? budgetMin = freezed,Object? budgetMax = freezed,Object? styleTags = freezed,}) {
  return _then(_ClientMatchCreateRequest(
country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,nicheSlug: null == nicheSlug ? _self.nicheSlug : nicheSlug // ignore: cast_nullable_to_non_nullable
as String,budgetMin: freezed == budgetMin ? _self.budgetMin : budgetMin // ignore: cast_nullable_to_non_nullable
as dynamic?,budgetMax: freezed == budgetMax ? _self.budgetMax : budgetMax // ignore: cast_nullable_to_non_nullable
as dynamic?,styleTags: freezed == styleTags ? _self._styleTags : styleTags // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
