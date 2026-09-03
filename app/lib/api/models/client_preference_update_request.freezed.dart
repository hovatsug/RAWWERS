// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_preference_update_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClientPreferenceUpdateRequest {

/// preferredNiches
@JsonKey(name: ClientPreferenceUpdateRequest.preferredNichesKey_) List<String>? get preferredNiches;/// budgetMin
@JsonKey(name: ClientPreferenceUpdateRequest.budgetMinKey_) dynamic? get budgetMin;/// budgetMax
@JsonKey(name: ClientPreferenceUpdateRequest.budgetMaxKey_) dynamic? get budgetMax;/// styleTags
@JsonKey(name: ClientPreferenceUpdateRequest.styleTagsKey_) List<String>? get styleTags;/// location
@JsonKey(name: ClientPreferenceUpdateRequest.locationKey_) Map<String, dynamic>? get location;/// consentDefault
@JsonKey(name: ClientPreferenceUpdateRequest.consentDefaultKey_) GigConsentLevel get consentDefault;
/// Create a copy of ClientPreferenceUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientPreferenceUpdateRequestCopyWith<ClientPreferenceUpdateRequest> get copyWith => _$ClientPreferenceUpdateRequestCopyWithImpl<ClientPreferenceUpdateRequest>(this as ClientPreferenceUpdateRequest, _$identity);

  /// Serializes this ClientPreferenceUpdateRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientPreferenceUpdateRequest&&const DeepCollectionEquality().equals(other.preferredNiches, preferredNiches)&&const DeepCollectionEquality().equals(other.budgetMin, budgetMin)&&const DeepCollectionEquality().equals(other.budgetMax, budgetMax)&&const DeepCollectionEquality().equals(other.styleTags, styleTags)&&const DeepCollectionEquality().equals(other.location, location)&&(identical(other.consentDefault, consentDefault) || other.consentDefault == consentDefault));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(preferredNiches),const DeepCollectionEquality().hash(budgetMin),const DeepCollectionEquality().hash(budgetMax),const DeepCollectionEquality().hash(styleTags),const DeepCollectionEquality().hash(location),consentDefault);

@override
String toString() {
  return 'ClientPreferenceUpdateRequest(preferredNiches: $preferredNiches, budgetMin: $budgetMin, budgetMax: $budgetMax, styleTags: $styleTags, location: $location, consentDefault: $consentDefault)';
}


}

/// @nodoc
abstract mixin class $ClientPreferenceUpdateRequestCopyWith<$Res>  {
  factory $ClientPreferenceUpdateRequestCopyWith(ClientPreferenceUpdateRequest value, $Res Function(ClientPreferenceUpdateRequest) _then) = _$ClientPreferenceUpdateRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ClientPreferenceUpdateRequest.preferredNichesKey_) List<String>? preferredNiches,@JsonKey(name: ClientPreferenceUpdateRequest.budgetMinKey_) dynamic? budgetMin,@JsonKey(name: ClientPreferenceUpdateRequest.budgetMaxKey_) dynamic? budgetMax,@JsonKey(name: ClientPreferenceUpdateRequest.styleTagsKey_) List<String>? styleTags,@JsonKey(name: ClientPreferenceUpdateRequest.locationKey_) Map<String, dynamic>? location,@JsonKey(name: ClientPreferenceUpdateRequest.consentDefaultKey_) GigConsentLevel consentDefault
});




}
/// @nodoc
class _$ClientPreferenceUpdateRequestCopyWithImpl<$Res>
    implements $ClientPreferenceUpdateRequestCopyWith<$Res> {
  _$ClientPreferenceUpdateRequestCopyWithImpl(this._self, this._then);

  final ClientPreferenceUpdateRequest _self;
  final $Res Function(ClientPreferenceUpdateRequest) _then;

/// Create a copy of ClientPreferenceUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? preferredNiches = freezed,Object? budgetMin = freezed,Object? budgetMax = freezed,Object? styleTags = freezed,Object? location = freezed,Object? consentDefault = null,}) {
  return _then(_self.copyWith(
preferredNiches: freezed == preferredNiches ? _self.preferredNiches : preferredNiches // ignore: cast_nullable_to_non_nullable
as List<String>?,budgetMin: freezed == budgetMin ? _self.budgetMin : budgetMin // ignore: cast_nullable_to_non_nullable
as dynamic?,budgetMax: freezed == budgetMax ? _self.budgetMax : budgetMax // ignore: cast_nullable_to_non_nullable
as dynamic?,styleTags: freezed == styleTags ? _self.styleTags : styleTags // ignore: cast_nullable_to_non_nullable
as List<String>?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,consentDefault: null == consentDefault ? _self.consentDefault : consentDefault // ignore: cast_nullable_to_non_nullable
as GigConsentLevel,
  ));
}

}


/// Adds pattern-matching-related methods to [ClientPreferenceUpdateRequest].
extension ClientPreferenceUpdateRequestPatterns on ClientPreferenceUpdateRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientPreferenceUpdateRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientPreferenceUpdateRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientPreferenceUpdateRequest value)  $default,){
final _that = this;
switch (_that) {
case _ClientPreferenceUpdateRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientPreferenceUpdateRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ClientPreferenceUpdateRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ClientPreferenceUpdateRequest.preferredNichesKey_)  List<String>? preferredNiches, @JsonKey(name: ClientPreferenceUpdateRequest.budgetMinKey_)  dynamic? budgetMin, @JsonKey(name: ClientPreferenceUpdateRequest.budgetMaxKey_)  dynamic? budgetMax, @JsonKey(name: ClientPreferenceUpdateRequest.styleTagsKey_)  List<String>? styleTags, @JsonKey(name: ClientPreferenceUpdateRequest.locationKey_)  Map<String, dynamic>? location, @JsonKey(name: ClientPreferenceUpdateRequest.consentDefaultKey_)  GigConsentLevel consentDefault)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientPreferenceUpdateRequest() when $default != null:
return $default(_that.preferredNiches,_that.budgetMin,_that.budgetMax,_that.styleTags,_that.location,_that.consentDefault);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ClientPreferenceUpdateRequest.preferredNichesKey_)  List<String>? preferredNiches, @JsonKey(name: ClientPreferenceUpdateRequest.budgetMinKey_)  dynamic? budgetMin, @JsonKey(name: ClientPreferenceUpdateRequest.budgetMaxKey_)  dynamic? budgetMax, @JsonKey(name: ClientPreferenceUpdateRequest.styleTagsKey_)  List<String>? styleTags, @JsonKey(name: ClientPreferenceUpdateRequest.locationKey_)  Map<String, dynamic>? location, @JsonKey(name: ClientPreferenceUpdateRequest.consentDefaultKey_)  GigConsentLevel consentDefault)  $default,) {final _that = this;
switch (_that) {
case _ClientPreferenceUpdateRequest():
return $default(_that.preferredNiches,_that.budgetMin,_that.budgetMax,_that.styleTags,_that.location,_that.consentDefault);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ClientPreferenceUpdateRequest.preferredNichesKey_)  List<String>? preferredNiches, @JsonKey(name: ClientPreferenceUpdateRequest.budgetMinKey_)  dynamic? budgetMin, @JsonKey(name: ClientPreferenceUpdateRequest.budgetMaxKey_)  dynamic? budgetMax, @JsonKey(name: ClientPreferenceUpdateRequest.styleTagsKey_)  List<String>? styleTags, @JsonKey(name: ClientPreferenceUpdateRequest.locationKey_)  Map<String, dynamic>? location, @JsonKey(name: ClientPreferenceUpdateRequest.consentDefaultKey_)  GigConsentLevel consentDefault)?  $default,) {final _that = this;
switch (_that) {
case _ClientPreferenceUpdateRequest() when $default != null:
return $default(_that.preferredNiches,_that.budgetMin,_that.budgetMax,_that.styleTags,_that.location,_that.consentDefault);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ClientPreferenceUpdateRequest extends ClientPreferenceUpdateRequest {
  const _ClientPreferenceUpdateRequest({@JsonKey(name: ClientPreferenceUpdateRequest.preferredNichesKey_) final  List<String>? preferredNiches, @JsonKey(name: ClientPreferenceUpdateRequest.budgetMinKey_) this.budgetMin, @JsonKey(name: ClientPreferenceUpdateRequest.budgetMaxKey_) this.budgetMax, @JsonKey(name: ClientPreferenceUpdateRequest.styleTagsKey_) final  List<String>? styleTags, @JsonKey(name: ClientPreferenceUpdateRequest.locationKey_) final  Map<String, dynamic>? location, @JsonKey(name: ClientPreferenceUpdateRequest.consentDefaultKey_) this.consentDefault = GigConsentLevel.none}): _preferredNiches = preferredNiches,_styleTags = styleTags,_location = location,super._();
  factory _ClientPreferenceUpdateRequest.fromJson(Map<String, dynamic> json) => _$ClientPreferenceUpdateRequestFromJson(json);

/// preferredNiches
 final  List<String>? _preferredNiches;
/// preferredNiches
@override@JsonKey(name: ClientPreferenceUpdateRequest.preferredNichesKey_) List<String>? get preferredNiches {
  final value = _preferredNiches;
  if (value == null) return null;
  if (_preferredNiches is EqualUnmodifiableListView) return _preferredNiches;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// budgetMin
@override@JsonKey(name: ClientPreferenceUpdateRequest.budgetMinKey_) final  dynamic? budgetMin;
/// budgetMax
@override@JsonKey(name: ClientPreferenceUpdateRequest.budgetMaxKey_) final  dynamic? budgetMax;
/// styleTags
 final  List<String>? _styleTags;
/// styleTags
@override@JsonKey(name: ClientPreferenceUpdateRequest.styleTagsKey_) List<String>? get styleTags {
  final value = _styleTags;
  if (value == null) return null;
  if (_styleTags is EqualUnmodifiableListView) return _styleTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// location
 final  Map<String, dynamic>? _location;
/// location
@override@JsonKey(name: ClientPreferenceUpdateRequest.locationKey_) Map<String, dynamic>? get location {
  final value = _location;
  if (value == null) return null;
  if (_location is EqualUnmodifiableMapView) return _location;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// consentDefault
@override@JsonKey(name: ClientPreferenceUpdateRequest.consentDefaultKey_) final  GigConsentLevel consentDefault;

/// Create a copy of ClientPreferenceUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientPreferenceUpdateRequestCopyWith<_ClientPreferenceUpdateRequest> get copyWith => __$ClientPreferenceUpdateRequestCopyWithImpl<_ClientPreferenceUpdateRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientPreferenceUpdateRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientPreferenceUpdateRequest&&const DeepCollectionEquality().equals(other._preferredNiches, _preferredNiches)&&const DeepCollectionEquality().equals(other.budgetMin, budgetMin)&&const DeepCollectionEquality().equals(other.budgetMax, budgetMax)&&const DeepCollectionEquality().equals(other._styleTags, _styleTags)&&const DeepCollectionEquality().equals(other._location, _location)&&(identical(other.consentDefault, consentDefault) || other.consentDefault == consentDefault));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_preferredNiches),const DeepCollectionEquality().hash(budgetMin),const DeepCollectionEquality().hash(budgetMax),const DeepCollectionEquality().hash(_styleTags),const DeepCollectionEquality().hash(_location),consentDefault);

@override
String toString() {
  return 'ClientPreferenceUpdateRequest(preferredNiches: $preferredNiches, budgetMin: $budgetMin, budgetMax: $budgetMax, styleTags: $styleTags, location: $location, consentDefault: $consentDefault)';
}


}

/// @nodoc
abstract mixin class _$ClientPreferenceUpdateRequestCopyWith<$Res> implements $ClientPreferenceUpdateRequestCopyWith<$Res> {
  factory _$ClientPreferenceUpdateRequestCopyWith(_ClientPreferenceUpdateRequest value, $Res Function(_ClientPreferenceUpdateRequest) _then) = __$ClientPreferenceUpdateRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ClientPreferenceUpdateRequest.preferredNichesKey_) List<String>? preferredNiches,@JsonKey(name: ClientPreferenceUpdateRequest.budgetMinKey_) dynamic? budgetMin,@JsonKey(name: ClientPreferenceUpdateRequest.budgetMaxKey_) dynamic? budgetMax,@JsonKey(name: ClientPreferenceUpdateRequest.styleTagsKey_) List<String>? styleTags,@JsonKey(name: ClientPreferenceUpdateRequest.locationKey_) Map<String, dynamic>? location,@JsonKey(name: ClientPreferenceUpdateRequest.consentDefaultKey_) GigConsentLevel consentDefault
});




}
/// @nodoc
class __$ClientPreferenceUpdateRequestCopyWithImpl<$Res>
    implements _$ClientPreferenceUpdateRequestCopyWith<$Res> {
  __$ClientPreferenceUpdateRequestCopyWithImpl(this._self, this._then);

  final _ClientPreferenceUpdateRequest _self;
  final $Res Function(_ClientPreferenceUpdateRequest) _then;

/// Create a copy of ClientPreferenceUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? preferredNiches = freezed,Object? budgetMin = freezed,Object? budgetMax = freezed,Object? styleTags = freezed,Object? location = freezed,Object? consentDefault = null,}) {
  return _then(_ClientPreferenceUpdateRequest(
preferredNiches: freezed == preferredNiches ? _self._preferredNiches : preferredNiches // ignore: cast_nullable_to_non_nullable
as List<String>?,budgetMin: freezed == budgetMin ? _self.budgetMin : budgetMin // ignore: cast_nullable_to_non_nullable
as dynamic?,budgetMax: freezed == budgetMax ? _self.budgetMax : budgetMax // ignore: cast_nullable_to_non_nullable
as dynamic?,styleTags: freezed == styleTags ? _self._styleTags : styleTags // ignore: cast_nullable_to_non_nullable
as List<String>?,location: freezed == location ? _self._location : location // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,consentDefault: null == consentDefault ? _self.consentDefault : consentDefault // ignore: cast_nullable_to_non_nullable
as GigConsentLevel,
  ));
}


}

// dart format on
