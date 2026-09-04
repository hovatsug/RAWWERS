// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pro_profile_update_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProProfileUpdateRequest {

/// displayName
@JsonKey(name: ProProfileUpdateRequest.displayNameKey_) String? get displayName;/// headline
@JsonKey(name: ProProfileUpdateRequest.headlineKey_) String? get headline;/// coverMediaAssetId
@JsonKey(name: ProProfileUpdateRequest.coverMediaAssetIdKey_) String? get coverMediaAssetId;/// bio
@JsonKey(name: ProProfileUpdateRequest.bioKey_) String? get bio;/// city
@JsonKey(name: ProProfileUpdateRequest.cityKey_) String? get city;/// country
@JsonKey(name: ProProfileUpdateRequest.countryKey_) String? get country;/// languages
@JsonKey(name: ProProfileUpdateRequest.languagesKey_) List<String>? get languages;/// styles
@JsonKey(name: ProProfileUpdateRequest.stylesKey_) List<String>? get styles;/// gear
@JsonKey(name: ProProfileUpdateRequest.gearKey_) Map<String, dynamic>? get gear;/// travelRadiusKm
@JsonKey(name: ProProfileUpdateRequest.travelRadiusKmKey_) int? get travelRadiusKm;
/// Create a copy of ProProfileUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProProfileUpdateRequestCopyWith<ProProfileUpdateRequest> get copyWith => _$ProProfileUpdateRequestCopyWithImpl<ProProfileUpdateRequest>(this as ProProfileUpdateRequest, _$identity);

  /// Serializes this ProProfileUpdateRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProProfileUpdateRequest&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.headline, headline) || other.headline == headline)&&(identical(other.coverMediaAssetId, coverMediaAssetId) || other.coverMediaAssetId == coverMediaAssetId)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&const DeepCollectionEquality().equals(other.languages, languages)&&const DeepCollectionEquality().equals(other.styles, styles)&&const DeepCollectionEquality().equals(other.gear, gear)&&(identical(other.travelRadiusKm, travelRadiusKm) || other.travelRadiusKm == travelRadiusKm));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,displayName,headline,coverMediaAssetId,bio,city,country,const DeepCollectionEquality().hash(languages),const DeepCollectionEquality().hash(styles),const DeepCollectionEquality().hash(gear),travelRadiusKm);

@override
String toString() {
  return 'ProProfileUpdateRequest(displayName: $displayName, headline: $headline, coverMediaAssetId: $coverMediaAssetId, bio: $bio, city: $city, country: $country, languages: $languages, styles: $styles, gear: $gear, travelRadiusKm: $travelRadiusKm)';
}


}

/// @nodoc
abstract mixin class $ProProfileUpdateRequestCopyWith<$Res>  {
  factory $ProProfileUpdateRequestCopyWith(ProProfileUpdateRequest value, $Res Function(ProProfileUpdateRequest) _then) = _$ProProfileUpdateRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ProProfileUpdateRequest.displayNameKey_) String? displayName,@JsonKey(name: ProProfileUpdateRequest.headlineKey_) String? headline,@JsonKey(name: ProProfileUpdateRequest.coverMediaAssetIdKey_) String? coverMediaAssetId,@JsonKey(name: ProProfileUpdateRequest.bioKey_) String? bio,@JsonKey(name: ProProfileUpdateRequest.cityKey_) String? city,@JsonKey(name: ProProfileUpdateRequest.countryKey_) String? country,@JsonKey(name: ProProfileUpdateRequest.languagesKey_) List<String>? languages,@JsonKey(name: ProProfileUpdateRequest.stylesKey_) List<String>? styles,@JsonKey(name: ProProfileUpdateRequest.gearKey_) Map<String, dynamic>? gear,@JsonKey(name: ProProfileUpdateRequest.travelRadiusKmKey_) int? travelRadiusKm
});




}
/// @nodoc
class _$ProProfileUpdateRequestCopyWithImpl<$Res>
    implements $ProProfileUpdateRequestCopyWith<$Res> {
  _$ProProfileUpdateRequestCopyWithImpl(this._self, this._then);

  final ProProfileUpdateRequest _self;
  final $Res Function(ProProfileUpdateRequest) _then;

/// Create a copy of ProProfileUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? displayName = freezed,Object? headline = freezed,Object? coverMediaAssetId = freezed,Object? bio = freezed,Object? city = freezed,Object? country = freezed,Object? languages = freezed,Object? styles = freezed,Object? gear = freezed,Object? travelRadiusKm = freezed,}) {
  return _then(_self.copyWith(
displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,headline: freezed == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String?,coverMediaAssetId: freezed == coverMediaAssetId ? _self.coverMediaAssetId : coverMediaAssetId // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,languages: freezed == languages ? _self.languages : languages // ignore: cast_nullable_to_non_nullable
as List<String>?,styles: freezed == styles ? _self.styles : styles // ignore: cast_nullable_to_non_nullable
as List<String>?,gear: freezed == gear ? _self.gear : gear // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,travelRadiusKm: freezed == travelRadiusKm ? _self.travelRadiusKm : travelRadiusKm // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProProfileUpdateRequest].
extension ProProfileUpdateRequestPatterns on ProProfileUpdateRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProProfileUpdateRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProProfileUpdateRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProProfileUpdateRequest value)  $default,){
final _that = this;
switch (_that) {
case _ProProfileUpdateRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProProfileUpdateRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ProProfileUpdateRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ProProfileUpdateRequest.displayNameKey_)  String? displayName, @JsonKey(name: ProProfileUpdateRequest.headlineKey_)  String? headline, @JsonKey(name: ProProfileUpdateRequest.coverMediaAssetIdKey_)  String? coverMediaAssetId, @JsonKey(name: ProProfileUpdateRequest.bioKey_)  String? bio, @JsonKey(name: ProProfileUpdateRequest.cityKey_)  String? city, @JsonKey(name: ProProfileUpdateRequest.countryKey_)  String? country, @JsonKey(name: ProProfileUpdateRequest.languagesKey_)  List<String>? languages, @JsonKey(name: ProProfileUpdateRequest.stylesKey_)  List<String>? styles, @JsonKey(name: ProProfileUpdateRequest.gearKey_)  Map<String, dynamic>? gear, @JsonKey(name: ProProfileUpdateRequest.travelRadiusKmKey_)  int? travelRadiusKm)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProProfileUpdateRequest() when $default != null:
return $default(_that.displayName,_that.headline,_that.coverMediaAssetId,_that.bio,_that.city,_that.country,_that.languages,_that.styles,_that.gear,_that.travelRadiusKm);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ProProfileUpdateRequest.displayNameKey_)  String? displayName, @JsonKey(name: ProProfileUpdateRequest.headlineKey_)  String? headline, @JsonKey(name: ProProfileUpdateRequest.coverMediaAssetIdKey_)  String? coverMediaAssetId, @JsonKey(name: ProProfileUpdateRequest.bioKey_)  String? bio, @JsonKey(name: ProProfileUpdateRequest.cityKey_)  String? city, @JsonKey(name: ProProfileUpdateRequest.countryKey_)  String? country, @JsonKey(name: ProProfileUpdateRequest.languagesKey_)  List<String>? languages, @JsonKey(name: ProProfileUpdateRequest.stylesKey_)  List<String>? styles, @JsonKey(name: ProProfileUpdateRequest.gearKey_)  Map<String, dynamic>? gear, @JsonKey(name: ProProfileUpdateRequest.travelRadiusKmKey_)  int? travelRadiusKm)  $default,) {final _that = this;
switch (_that) {
case _ProProfileUpdateRequest():
return $default(_that.displayName,_that.headline,_that.coverMediaAssetId,_that.bio,_that.city,_that.country,_that.languages,_that.styles,_that.gear,_that.travelRadiusKm);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ProProfileUpdateRequest.displayNameKey_)  String? displayName, @JsonKey(name: ProProfileUpdateRequest.headlineKey_)  String? headline, @JsonKey(name: ProProfileUpdateRequest.coverMediaAssetIdKey_)  String? coverMediaAssetId, @JsonKey(name: ProProfileUpdateRequest.bioKey_)  String? bio, @JsonKey(name: ProProfileUpdateRequest.cityKey_)  String? city, @JsonKey(name: ProProfileUpdateRequest.countryKey_)  String? country, @JsonKey(name: ProProfileUpdateRequest.languagesKey_)  List<String>? languages, @JsonKey(name: ProProfileUpdateRequest.stylesKey_)  List<String>? styles, @JsonKey(name: ProProfileUpdateRequest.gearKey_)  Map<String, dynamic>? gear, @JsonKey(name: ProProfileUpdateRequest.travelRadiusKmKey_)  int? travelRadiusKm)?  $default,) {final _that = this;
switch (_that) {
case _ProProfileUpdateRequest() when $default != null:
return $default(_that.displayName,_that.headline,_that.coverMediaAssetId,_that.bio,_that.city,_that.country,_that.languages,_that.styles,_that.gear,_that.travelRadiusKm);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ProProfileUpdateRequest extends ProProfileUpdateRequest {
  const _ProProfileUpdateRequest({@JsonKey(name: ProProfileUpdateRequest.displayNameKey_) this.displayName, @JsonKey(name: ProProfileUpdateRequest.headlineKey_) this.headline, @JsonKey(name: ProProfileUpdateRequest.coverMediaAssetIdKey_) this.coverMediaAssetId, @JsonKey(name: ProProfileUpdateRequest.bioKey_) this.bio, @JsonKey(name: ProProfileUpdateRequest.cityKey_) this.city, @JsonKey(name: ProProfileUpdateRequest.countryKey_) this.country, @JsonKey(name: ProProfileUpdateRequest.languagesKey_) final  List<String>? languages, @JsonKey(name: ProProfileUpdateRequest.stylesKey_) final  List<String>? styles, @JsonKey(name: ProProfileUpdateRequest.gearKey_) final  Map<String, dynamic>? gear, @JsonKey(name: ProProfileUpdateRequest.travelRadiusKmKey_) this.travelRadiusKm}): _languages = languages,_styles = styles,_gear = gear,super._();
  factory _ProProfileUpdateRequest.fromJson(Map<String, dynamic> json) => _$ProProfileUpdateRequestFromJson(json);

/// displayName
@override@JsonKey(name: ProProfileUpdateRequest.displayNameKey_) final  String? displayName;
/// headline
@override@JsonKey(name: ProProfileUpdateRequest.headlineKey_) final  String? headline;
/// coverMediaAssetId
@override@JsonKey(name: ProProfileUpdateRequest.coverMediaAssetIdKey_) final  String? coverMediaAssetId;
/// bio
@override@JsonKey(name: ProProfileUpdateRequest.bioKey_) final  String? bio;
/// city
@override@JsonKey(name: ProProfileUpdateRequest.cityKey_) final  String? city;
/// country
@override@JsonKey(name: ProProfileUpdateRequest.countryKey_) final  String? country;
/// languages
 final  List<String>? _languages;
/// languages
@override@JsonKey(name: ProProfileUpdateRequest.languagesKey_) List<String>? get languages {
  final value = _languages;
  if (value == null) return null;
  if (_languages is EqualUnmodifiableListView) return _languages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// styles
 final  List<String>? _styles;
/// styles
@override@JsonKey(name: ProProfileUpdateRequest.stylesKey_) List<String>? get styles {
  final value = _styles;
  if (value == null) return null;
  if (_styles is EqualUnmodifiableListView) return _styles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// gear
 final  Map<String, dynamic>? _gear;
/// gear
@override@JsonKey(name: ProProfileUpdateRequest.gearKey_) Map<String, dynamic>? get gear {
  final value = _gear;
  if (value == null) return null;
  if (_gear is EqualUnmodifiableMapView) return _gear;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// travelRadiusKm
@override@JsonKey(name: ProProfileUpdateRequest.travelRadiusKmKey_) final  int? travelRadiusKm;

/// Create a copy of ProProfileUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProProfileUpdateRequestCopyWith<_ProProfileUpdateRequest> get copyWith => __$ProProfileUpdateRequestCopyWithImpl<_ProProfileUpdateRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProProfileUpdateRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProProfileUpdateRequest&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.headline, headline) || other.headline == headline)&&(identical(other.coverMediaAssetId, coverMediaAssetId) || other.coverMediaAssetId == coverMediaAssetId)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&const DeepCollectionEquality().equals(other._languages, _languages)&&const DeepCollectionEquality().equals(other._styles, _styles)&&const DeepCollectionEquality().equals(other._gear, _gear)&&(identical(other.travelRadiusKm, travelRadiusKm) || other.travelRadiusKm == travelRadiusKm));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,displayName,headline,coverMediaAssetId,bio,city,country,const DeepCollectionEquality().hash(_languages),const DeepCollectionEquality().hash(_styles),const DeepCollectionEquality().hash(_gear),travelRadiusKm);

@override
String toString() {
  return 'ProProfileUpdateRequest(displayName: $displayName, headline: $headline, coverMediaAssetId: $coverMediaAssetId, bio: $bio, city: $city, country: $country, languages: $languages, styles: $styles, gear: $gear, travelRadiusKm: $travelRadiusKm)';
}


}

/// @nodoc
abstract mixin class _$ProProfileUpdateRequestCopyWith<$Res> implements $ProProfileUpdateRequestCopyWith<$Res> {
  factory _$ProProfileUpdateRequestCopyWith(_ProProfileUpdateRequest value, $Res Function(_ProProfileUpdateRequest) _then) = __$ProProfileUpdateRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ProProfileUpdateRequest.displayNameKey_) String? displayName,@JsonKey(name: ProProfileUpdateRequest.headlineKey_) String? headline,@JsonKey(name: ProProfileUpdateRequest.coverMediaAssetIdKey_) String? coverMediaAssetId,@JsonKey(name: ProProfileUpdateRequest.bioKey_) String? bio,@JsonKey(name: ProProfileUpdateRequest.cityKey_) String? city,@JsonKey(name: ProProfileUpdateRequest.countryKey_) String? country,@JsonKey(name: ProProfileUpdateRequest.languagesKey_) List<String>? languages,@JsonKey(name: ProProfileUpdateRequest.stylesKey_) List<String>? styles,@JsonKey(name: ProProfileUpdateRequest.gearKey_) Map<String, dynamic>? gear,@JsonKey(name: ProProfileUpdateRequest.travelRadiusKmKey_) int? travelRadiusKm
});




}
/// @nodoc
class __$ProProfileUpdateRequestCopyWithImpl<$Res>
    implements _$ProProfileUpdateRequestCopyWith<$Res> {
  __$ProProfileUpdateRequestCopyWithImpl(this._self, this._then);

  final _ProProfileUpdateRequest _self;
  final $Res Function(_ProProfileUpdateRequest) _then;

/// Create a copy of ProProfileUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? displayName = freezed,Object? headline = freezed,Object? coverMediaAssetId = freezed,Object? bio = freezed,Object? city = freezed,Object? country = freezed,Object? languages = freezed,Object? styles = freezed,Object? gear = freezed,Object? travelRadiusKm = freezed,}) {
  return _then(_ProProfileUpdateRequest(
displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,headline: freezed == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String?,coverMediaAssetId: freezed == coverMediaAssetId ? _self.coverMediaAssetId : coverMediaAssetId // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,languages: freezed == languages ? _self._languages : languages // ignore: cast_nullable_to_non_nullable
as List<String>?,styles: freezed == styles ? _self._styles : styles // ignore: cast_nullable_to_non_nullable
as List<String>?,gear: freezed == gear ? _self._gear : gear // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,travelRadiusKm: freezed == travelRadiusKm ? _self.travelRadiusKm : travelRadiusKm // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
