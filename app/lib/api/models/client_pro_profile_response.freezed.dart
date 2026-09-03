// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_pro_profile_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClientProProfileResponse {

/// proUserId
@JsonKey(name: ClientProProfileResponse.proUserIdKey_) String get proUserId;/// displayName
@JsonKey(name: ClientProProfileResponse.displayNameKey_) String? get displayName;/// headline
@JsonKey(name: ClientProProfileResponse.headlineKey_) String? get headline;/// coverMediaAssetId
@JsonKey(name: ClientProProfileResponse.coverMediaAssetIdKey_) String? get coverMediaAssetId;/// bio
@JsonKey(name: ClientProProfileResponse.bioKey_) String? get bio;/// city
@JsonKey(name: ClientProProfileResponse.cityKey_) String? get city;/// country
@JsonKey(name: ClientProProfileResponse.countryKey_) String? get country;/// styles
@JsonKey(name: ClientProProfileResponse.stylesKey_) List<String>? get styles;/// avgRating
@JsonKey(name: ClientProProfileResponse.avgRatingKey_) String get avgRating;/// reviewCount
@JsonKey(name: ClientProProfileResponse.reviewCountKey_) int get reviewCount;/// portfolioPhotoCount
@JsonKey(name: ClientProProfileResponse.portfolioPhotoCountKey_) int get portfolioPhotoCount;/// portfolioVideoCount
@JsonKey(name: ClientProProfileResponse.portfolioVideoCountKey_) int get portfolioVideoCount;/// packages
@JsonKey(name: ClientProProfileResponse.packagesKey_) List<ClientProfilePackage>? get packages;/// portfolioPreviewAssetIds
@JsonKey(name: ClientProProfileResponse.portfolioPreviewAssetIdsKey_) List<String>? get portfolioPreviewAssetIds;/// isGuestView
@JsonKey(name: ClientProProfileResponse.isGuestViewKey_) bool get isGuestView;
/// Create a copy of ClientProProfileResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientProProfileResponseCopyWith<ClientProProfileResponse> get copyWith => _$ClientProProfileResponseCopyWithImpl<ClientProProfileResponse>(this as ClientProProfileResponse, _$identity);

  /// Serializes this ClientProProfileResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientProProfileResponse&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.headline, headline) || other.headline == headline)&&(identical(other.coverMediaAssetId, coverMediaAssetId) || other.coverMediaAssetId == coverMediaAssetId)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&const DeepCollectionEquality().equals(other.styles, styles)&&(identical(other.avgRating, avgRating) || other.avgRating == avgRating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.portfolioPhotoCount, portfolioPhotoCount) || other.portfolioPhotoCount == portfolioPhotoCount)&&(identical(other.portfolioVideoCount, portfolioVideoCount) || other.portfolioVideoCount == portfolioVideoCount)&&const DeepCollectionEquality().equals(other.packages, packages)&&const DeepCollectionEquality().equals(other.portfolioPreviewAssetIds, portfolioPreviewAssetIds)&&(identical(other.isGuestView, isGuestView) || other.isGuestView == isGuestView));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,proUserId,displayName,headline,coverMediaAssetId,bio,city,country,const DeepCollectionEquality().hash(styles),avgRating,reviewCount,portfolioPhotoCount,portfolioVideoCount,const DeepCollectionEquality().hash(packages),const DeepCollectionEquality().hash(portfolioPreviewAssetIds),isGuestView);

@override
String toString() {
  return 'ClientProProfileResponse(proUserId: $proUserId, displayName: $displayName, headline: $headline, coverMediaAssetId: $coverMediaAssetId, bio: $bio, city: $city, country: $country, styles: $styles, avgRating: $avgRating, reviewCount: $reviewCount, portfolioPhotoCount: $portfolioPhotoCount, portfolioVideoCount: $portfolioVideoCount, packages: $packages, portfolioPreviewAssetIds: $portfolioPreviewAssetIds, isGuestView: $isGuestView)';
}


}

/// @nodoc
abstract mixin class $ClientProProfileResponseCopyWith<$Res>  {
  factory $ClientProProfileResponseCopyWith(ClientProProfileResponse value, $Res Function(ClientProProfileResponse) _then) = _$ClientProProfileResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ClientProProfileResponse.proUserIdKey_) String proUserId,@JsonKey(name: ClientProProfileResponse.displayNameKey_) String? displayName,@JsonKey(name: ClientProProfileResponse.headlineKey_) String? headline,@JsonKey(name: ClientProProfileResponse.coverMediaAssetIdKey_) String? coverMediaAssetId,@JsonKey(name: ClientProProfileResponse.bioKey_) String? bio,@JsonKey(name: ClientProProfileResponse.cityKey_) String? city,@JsonKey(name: ClientProProfileResponse.countryKey_) String? country,@JsonKey(name: ClientProProfileResponse.stylesKey_) List<String>? styles,@JsonKey(name: ClientProProfileResponse.avgRatingKey_) String avgRating,@JsonKey(name: ClientProProfileResponse.reviewCountKey_) int reviewCount,@JsonKey(name: ClientProProfileResponse.portfolioPhotoCountKey_) int portfolioPhotoCount,@JsonKey(name: ClientProProfileResponse.portfolioVideoCountKey_) int portfolioVideoCount,@JsonKey(name: ClientProProfileResponse.packagesKey_) List<ClientProfilePackage>? packages,@JsonKey(name: ClientProProfileResponse.portfolioPreviewAssetIdsKey_) List<String>? portfolioPreviewAssetIds,@JsonKey(name: ClientProProfileResponse.isGuestViewKey_) bool isGuestView
});




}
/// @nodoc
class _$ClientProProfileResponseCopyWithImpl<$Res>
    implements $ClientProProfileResponseCopyWith<$Res> {
  _$ClientProProfileResponseCopyWithImpl(this._self, this._then);

  final ClientProProfileResponse _self;
  final $Res Function(ClientProProfileResponse) _then;

/// Create a copy of ClientProProfileResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? proUserId = null,Object? displayName = freezed,Object? headline = freezed,Object? coverMediaAssetId = freezed,Object? bio = freezed,Object? city = freezed,Object? country = freezed,Object? styles = freezed,Object? avgRating = null,Object? reviewCount = null,Object? portfolioPhotoCount = null,Object? portfolioVideoCount = null,Object? packages = freezed,Object? portfolioPreviewAssetIds = freezed,Object? isGuestView = null,}) {
  return _then(_self.copyWith(
proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,headline: freezed == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String?,coverMediaAssetId: freezed == coverMediaAssetId ? _self.coverMediaAssetId : coverMediaAssetId // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,styles: freezed == styles ? _self.styles : styles // ignore: cast_nullable_to_non_nullable
as List<String>?,avgRating: null == avgRating ? _self.avgRating : avgRating // ignore: cast_nullable_to_non_nullable
as String,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,portfolioPhotoCount: null == portfolioPhotoCount ? _self.portfolioPhotoCount : portfolioPhotoCount // ignore: cast_nullable_to_non_nullable
as int,portfolioVideoCount: null == portfolioVideoCount ? _self.portfolioVideoCount : portfolioVideoCount // ignore: cast_nullable_to_non_nullable
as int,packages: freezed == packages ? _self.packages : packages // ignore: cast_nullable_to_non_nullable
as List<ClientProfilePackage>?,portfolioPreviewAssetIds: freezed == portfolioPreviewAssetIds ? _self.portfolioPreviewAssetIds : portfolioPreviewAssetIds // ignore: cast_nullable_to_non_nullable
as List<String>?,isGuestView: null == isGuestView ? _self.isGuestView : isGuestView // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ClientProProfileResponse].
extension ClientProProfileResponsePatterns on ClientProProfileResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientProProfileResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientProProfileResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientProProfileResponse value)  $default,){
final _that = this;
switch (_that) {
case _ClientProProfileResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientProProfileResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ClientProProfileResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ClientProProfileResponse.proUserIdKey_)  String proUserId, @JsonKey(name: ClientProProfileResponse.displayNameKey_)  String? displayName, @JsonKey(name: ClientProProfileResponse.headlineKey_)  String? headline, @JsonKey(name: ClientProProfileResponse.coverMediaAssetIdKey_)  String? coverMediaAssetId, @JsonKey(name: ClientProProfileResponse.bioKey_)  String? bio, @JsonKey(name: ClientProProfileResponse.cityKey_)  String? city, @JsonKey(name: ClientProProfileResponse.countryKey_)  String? country, @JsonKey(name: ClientProProfileResponse.stylesKey_)  List<String>? styles, @JsonKey(name: ClientProProfileResponse.avgRatingKey_)  String avgRating, @JsonKey(name: ClientProProfileResponse.reviewCountKey_)  int reviewCount, @JsonKey(name: ClientProProfileResponse.portfolioPhotoCountKey_)  int portfolioPhotoCount, @JsonKey(name: ClientProProfileResponse.portfolioVideoCountKey_)  int portfolioVideoCount, @JsonKey(name: ClientProProfileResponse.packagesKey_)  List<ClientProfilePackage>? packages, @JsonKey(name: ClientProProfileResponse.portfolioPreviewAssetIdsKey_)  List<String>? portfolioPreviewAssetIds, @JsonKey(name: ClientProProfileResponse.isGuestViewKey_)  bool isGuestView)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientProProfileResponse() when $default != null:
return $default(_that.proUserId,_that.displayName,_that.headline,_that.coverMediaAssetId,_that.bio,_that.city,_that.country,_that.styles,_that.avgRating,_that.reviewCount,_that.portfolioPhotoCount,_that.portfolioVideoCount,_that.packages,_that.portfolioPreviewAssetIds,_that.isGuestView);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ClientProProfileResponse.proUserIdKey_)  String proUserId, @JsonKey(name: ClientProProfileResponse.displayNameKey_)  String? displayName, @JsonKey(name: ClientProProfileResponse.headlineKey_)  String? headline, @JsonKey(name: ClientProProfileResponse.coverMediaAssetIdKey_)  String? coverMediaAssetId, @JsonKey(name: ClientProProfileResponse.bioKey_)  String? bio, @JsonKey(name: ClientProProfileResponse.cityKey_)  String? city, @JsonKey(name: ClientProProfileResponse.countryKey_)  String? country, @JsonKey(name: ClientProProfileResponse.stylesKey_)  List<String>? styles, @JsonKey(name: ClientProProfileResponse.avgRatingKey_)  String avgRating, @JsonKey(name: ClientProProfileResponse.reviewCountKey_)  int reviewCount, @JsonKey(name: ClientProProfileResponse.portfolioPhotoCountKey_)  int portfolioPhotoCount, @JsonKey(name: ClientProProfileResponse.portfolioVideoCountKey_)  int portfolioVideoCount, @JsonKey(name: ClientProProfileResponse.packagesKey_)  List<ClientProfilePackage>? packages, @JsonKey(name: ClientProProfileResponse.portfolioPreviewAssetIdsKey_)  List<String>? portfolioPreviewAssetIds, @JsonKey(name: ClientProProfileResponse.isGuestViewKey_)  bool isGuestView)  $default,) {final _that = this;
switch (_that) {
case _ClientProProfileResponse():
return $default(_that.proUserId,_that.displayName,_that.headline,_that.coverMediaAssetId,_that.bio,_that.city,_that.country,_that.styles,_that.avgRating,_that.reviewCount,_that.portfolioPhotoCount,_that.portfolioVideoCount,_that.packages,_that.portfolioPreviewAssetIds,_that.isGuestView);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ClientProProfileResponse.proUserIdKey_)  String proUserId, @JsonKey(name: ClientProProfileResponse.displayNameKey_)  String? displayName, @JsonKey(name: ClientProProfileResponse.headlineKey_)  String? headline, @JsonKey(name: ClientProProfileResponse.coverMediaAssetIdKey_)  String? coverMediaAssetId, @JsonKey(name: ClientProProfileResponse.bioKey_)  String? bio, @JsonKey(name: ClientProProfileResponse.cityKey_)  String? city, @JsonKey(name: ClientProProfileResponse.countryKey_)  String? country, @JsonKey(name: ClientProProfileResponse.stylesKey_)  List<String>? styles, @JsonKey(name: ClientProProfileResponse.avgRatingKey_)  String avgRating, @JsonKey(name: ClientProProfileResponse.reviewCountKey_)  int reviewCount, @JsonKey(name: ClientProProfileResponse.portfolioPhotoCountKey_)  int portfolioPhotoCount, @JsonKey(name: ClientProProfileResponse.portfolioVideoCountKey_)  int portfolioVideoCount, @JsonKey(name: ClientProProfileResponse.packagesKey_)  List<ClientProfilePackage>? packages, @JsonKey(name: ClientProProfileResponse.portfolioPreviewAssetIdsKey_)  List<String>? portfolioPreviewAssetIds, @JsonKey(name: ClientProProfileResponse.isGuestViewKey_)  bool isGuestView)?  $default,) {final _that = this;
switch (_that) {
case _ClientProProfileResponse() when $default != null:
return $default(_that.proUserId,_that.displayName,_that.headline,_that.coverMediaAssetId,_that.bio,_that.city,_that.country,_that.styles,_that.avgRating,_that.reviewCount,_that.portfolioPhotoCount,_that.portfolioVideoCount,_that.packages,_that.portfolioPreviewAssetIds,_that.isGuestView);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ClientProProfileResponse extends ClientProProfileResponse {
  const _ClientProProfileResponse({@JsonKey(name: ClientProProfileResponse.proUserIdKey_) required this.proUserId, @JsonKey(name: ClientProProfileResponse.displayNameKey_) this.displayName, @JsonKey(name: ClientProProfileResponse.headlineKey_) this.headline, @JsonKey(name: ClientProProfileResponse.coverMediaAssetIdKey_) this.coverMediaAssetId, @JsonKey(name: ClientProProfileResponse.bioKey_) this.bio, @JsonKey(name: ClientProProfileResponse.cityKey_) this.city, @JsonKey(name: ClientProProfileResponse.countryKey_) this.country, @JsonKey(name: ClientProProfileResponse.stylesKey_) final  List<String>? styles, @JsonKey(name: ClientProProfileResponse.avgRatingKey_) required this.avgRating, @JsonKey(name: ClientProProfileResponse.reviewCountKey_) required this.reviewCount, @JsonKey(name: ClientProProfileResponse.portfolioPhotoCountKey_) required this.portfolioPhotoCount, @JsonKey(name: ClientProProfileResponse.portfolioVideoCountKey_) required this.portfolioVideoCount, @JsonKey(name: ClientProProfileResponse.packagesKey_) final  List<ClientProfilePackage>? packages, @JsonKey(name: ClientProProfileResponse.portfolioPreviewAssetIdsKey_) final  List<String>? portfolioPreviewAssetIds, @JsonKey(name: ClientProProfileResponse.isGuestViewKey_) this.isGuestView = false}): _styles = styles,_packages = packages,_portfolioPreviewAssetIds = portfolioPreviewAssetIds,super._();
  factory _ClientProProfileResponse.fromJson(Map<String, dynamic> json) => _$ClientProProfileResponseFromJson(json);

/// proUserId
@override@JsonKey(name: ClientProProfileResponse.proUserIdKey_) final  String proUserId;
/// displayName
@override@JsonKey(name: ClientProProfileResponse.displayNameKey_) final  String? displayName;
/// headline
@override@JsonKey(name: ClientProProfileResponse.headlineKey_) final  String? headline;
/// coverMediaAssetId
@override@JsonKey(name: ClientProProfileResponse.coverMediaAssetIdKey_) final  String? coverMediaAssetId;
/// bio
@override@JsonKey(name: ClientProProfileResponse.bioKey_) final  String? bio;
/// city
@override@JsonKey(name: ClientProProfileResponse.cityKey_) final  String? city;
/// country
@override@JsonKey(name: ClientProProfileResponse.countryKey_) final  String? country;
/// styles
 final  List<String>? _styles;
/// styles
@override@JsonKey(name: ClientProProfileResponse.stylesKey_) List<String>? get styles {
  final value = _styles;
  if (value == null) return null;
  if (_styles is EqualUnmodifiableListView) return _styles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// avgRating
@override@JsonKey(name: ClientProProfileResponse.avgRatingKey_) final  String avgRating;
/// reviewCount
@override@JsonKey(name: ClientProProfileResponse.reviewCountKey_) final  int reviewCount;
/// portfolioPhotoCount
@override@JsonKey(name: ClientProProfileResponse.portfolioPhotoCountKey_) final  int portfolioPhotoCount;
/// portfolioVideoCount
@override@JsonKey(name: ClientProProfileResponse.portfolioVideoCountKey_) final  int portfolioVideoCount;
/// packages
 final  List<ClientProfilePackage>? _packages;
/// packages
@override@JsonKey(name: ClientProProfileResponse.packagesKey_) List<ClientProfilePackage>? get packages {
  final value = _packages;
  if (value == null) return null;
  if (_packages is EqualUnmodifiableListView) return _packages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// portfolioPreviewAssetIds
 final  List<String>? _portfolioPreviewAssetIds;
/// portfolioPreviewAssetIds
@override@JsonKey(name: ClientProProfileResponse.portfolioPreviewAssetIdsKey_) List<String>? get portfolioPreviewAssetIds {
  final value = _portfolioPreviewAssetIds;
  if (value == null) return null;
  if (_portfolioPreviewAssetIds is EqualUnmodifiableListView) return _portfolioPreviewAssetIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// isGuestView
@override@JsonKey(name: ClientProProfileResponse.isGuestViewKey_) final  bool isGuestView;

/// Create a copy of ClientProProfileResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientProProfileResponseCopyWith<_ClientProProfileResponse> get copyWith => __$ClientProProfileResponseCopyWithImpl<_ClientProProfileResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientProProfileResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientProProfileResponse&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.headline, headline) || other.headline == headline)&&(identical(other.coverMediaAssetId, coverMediaAssetId) || other.coverMediaAssetId == coverMediaAssetId)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&const DeepCollectionEquality().equals(other._styles, _styles)&&(identical(other.avgRating, avgRating) || other.avgRating == avgRating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.portfolioPhotoCount, portfolioPhotoCount) || other.portfolioPhotoCount == portfolioPhotoCount)&&(identical(other.portfolioVideoCount, portfolioVideoCount) || other.portfolioVideoCount == portfolioVideoCount)&&const DeepCollectionEquality().equals(other._packages, _packages)&&const DeepCollectionEquality().equals(other._portfolioPreviewAssetIds, _portfolioPreviewAssetIds)&&(identical(other.isGuestView, isGuestView) || other.isGuestView == isGuestView));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,proUserId,displayName,headline,coverMediaAssetId,bio,city,country,const DeepCollectionEquality().hash(_styles),avgRating,reviewCount,portfolioPhotoCount,portfolioVideoCount,const DeepCollectionEquality().hash(_packages),const DeepCollectionEquality().hash(_portfolioPreviewAssetIds),isGuestView);

@override
String toString() {
  return 'ClientProProfileResponse(proUserId: $proUserId, displayName: $displayName, headline: $headline, coverMediaAssetId: $coverMediaAssetId, bio: $bio, city: $city, country: $country, styles: $styles, avgRating: $avgRating, reviewCount: $reviewCount, portfolioPhotoCount: $portfolioPhotoCount, portfolioVideoCount: $portfolioVideoCount, packages: $packages, portfolioPreviewAssetIds: $portfolioPreviewAssetIds, isGuestView: $isGuestView)';
}


}

/// @nodoc
abstract mixin class _$ClientProProfileResponseCopyWith<$Res> implements $ClientProProfileResponseCopyWith<$Res> {
  factory _$ClientProProfileResponseCopyWith(_ClientProProfileResponse value, $Res Function(_ClientProProfileResponse) _then) = __$ClientProProfileResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ClientProProfileResponse.proUserIdKey_) String proUserId,@JsonKey(name: ClientProProfileResponse.displayNameKey_) String? displayName,@JsonKey(name: ClientProProfileResponse.headlineKey_) String? headline,@JsonKey(name: ClientProProfileResponse.coverMediaAssetIdKey_) String? coverMediaAssetId,@JsonKey(name: ClientProProfileResponse.bioKey_) String? bio,@JsonKey(name: ClientProProfileResponse.cityKey_) String? city,@JsonKey(name: ClientProProfileResponse.countryKey_) String? country,@JsonKey(name: ClientProProfileResponse.stylesKey_) List<String>? styles,@JsonKey(name: ClientProProfileResponse.avgRatingKey_) String avgRating,@JsonKey(name: ClientProProfileResponse.reviewCountKey_) int reviewCount,@JsonKey(name: ClientProProfileResponse.portfolioPhotoCountKey_) int portfolioPhotoCount,@JsonKey(name: ClientProProfileResponse.portfolioVideoCountKey_) int portfolioVideoCount,@JsonKey(name: ClientProProfileResponse.packagesKey_) List<ClientProfilePackage>? packages,@JsonKey(name: ClientProProfileResponse.portfolioPreviewAssetIdsKey_) List<String>? portfolioPreviewAssetIds,@JsonKey(name: ClientProProfileResponse.isGuestViewKey_) bool isGuestView
});




}
/// @nodoc
class __$ClientProProfileResponseCopyWithImpl<$Res>
    implements _$ClientProProfileResponseCopyWith<$Res> {
  __$ClientProProfileResponseCopyWithImpl(this._self, this._then);

  final _ClientProProfileResponse _self;
  final $Res Function(_ClientProProfileResponse) _then;

/// Create a copy of ClientProProfileResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? proUserId = null,Object? displayName = freezed,Object? headline = freezed,Object? coverMediaAssetId = freezed,Object? bio = freezed,Object? city = freezed,Object? country = freezed,Object? styles = freezed,Object? avgRating = null,Object? reviewCount = null,Object? portfolioPhotoCount = null,Object? portfolioVideoCount = null,Object? packages = freezed,Object? portfolioPreviewAssetIds = freezed,Object? isGuestView = null,}) {
  return _then(_ClientProProfileResponse(
proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,headline: freezed == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String?,coverMediaAssetId: freezed == coverMediaAssetId ? _self.coverMediaAssetId : coverMediaAssetId // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,styles: freezed == styles ? _self._styles : styles // ignore: cast_nullable_to_non_nullable
as List<String>?,avgRating: null == avgRating ? _self.avgRating : avgRating // ignore: cast_nullable_to_non_nullable
as String,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,portfolioPhotoCount: null == portfolioPhotoCount ? _self.portfolioPhotoCount : portfolioPhotoCount // ignore: cast_nullable_to_non_nullable
as int,portfolioVideoCount: null == portfolioVideoCount ? _self.portfolioVideoCount : portfolioVideoCount // ignore: cast_nullable_to_non_nullable
as int,packages: freezed == packages ? _self._packages : packages // ignore: cast_nullable_to_non_nullable
as List<ClientProfilePackage>?,portfolioPreviewAssetIds: freezed == portfolioPreviewAssetIds ? _self._portfolioPreviewAssetIds : portfolioPreviewAssetIds // ignore: cast_nullable_to_non_nullable
as List<String>?,isGuestView: null == isGuestView ? _self.isGuestView : isGuestView // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
