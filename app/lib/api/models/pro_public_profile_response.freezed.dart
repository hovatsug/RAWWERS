// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pro_public_profile_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProPublicProfileResponse {

/// proUserId
@JsonKey(name: ProPublicProfileResponse.proUserIdKey_) String get proUserId;/// displayName
@JsonKey(name: ProPublicProfileResponse.displayNameKey_) String? get displayName;/// headline
@JsonKey(name: ProPublicProfileResponse.headlineKey_) String? get headline;/// coverMediaAssetId
@JsonKey(name: ProPublicProfileResponse.coverMediaAssetIdKey_) String? get coverMediaAssetId;/// bio
@JsonKey(name: ProPublicProfileResponse.bioKey_) String? get bio;/// city
@JsonKey(name: ProPublicProfileResponse.cityKey_) String? get city;/// country
@JsonKey(name: ProPublicProfileResponse.countryKey_) String? get country;/// styles
@JsonKey(name: ProPublicProfileResponse.stylesKey_) List<String>? get styles;/// packages
@JsonKey(name: ProPublicProfileResponse.packagesKey_) List<PublicProPackageView> get packages;/// portfolioPhotos
@JsonKey(name: ProPublicProfileResponse.portfolioPhotosKey_) List<PublicPortfolioPhoto> get portfolioPhotos;/// portfolioVideos
@JsonKey(name: ProPublicProfileResponse.portfolioVideosKey_) List<PublicPortfolioVideo> get portfolioVideos;/// gigsCompleted
@JsonKey(name: ProPublicProfileResponse.gigsCompletedKey_) int get gigsCompleted;/// gigsCancelled
@JsonKey(name: ProPublicProfileResponse.gigsCancelledKey_) int get gigsCancelled;/// disputesCount
@JsonKey(name: ProPublicProfileResponse.disputesCountKey_) int get disputesCount;/// avgResponseMinutes
@JsonKey(name: ProPublicProfileResponse.avgResponseMinutesKey_) int? get avgResponseMinutes;/// avgRating
@JsonKey(name: ProPublicProfileResponse.avgRatingKey_) String get avgRating;/// reviewCount
@JsonKey(name: ProPublicProfileResponse.reviewCountKey_) int get reviewCount;/// rankingScore
@JsonKey(name: ProPublicProfileResponse.rankingScoreKey_) String get rankingScore;
/// Create a copy of ProPublicProfileResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProPublicProfileResponseCopyWith<ProPublicProfileResponse> get copyWith => _$ProPublicProfileResponseCopyWithImpl<ProPublicProfileResponse>(this as ProPublicProfileResponse, _$identity);

  /// Serializes this ProPublicProfileResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProPublicProfileResponse&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.headline, headline) || other.headline == headline)&&(identical(other.coverMediaAssetId, coverMediaAssetId) || other.coverMediaAssetId == coverMediaAssetId)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&const DeepCollectionEquality().equals(other.styles, styles)&&const DeepCollectionEquality().equals(other.packages, packages)&&const DeepCollectionEquality().equals(other.portfolioPhotos, portfolioPhotos)&&const DeepCollectionEquality().equals(other.portfolioVideos, portfolioVideos)&&(identical(other.gigsCompleted, gigsCompleted) || other.gigsCompleted == gigsCompleted)&&(identical(other.gigsCancelled, gigsCancelled) || other.gigsCancelled == gigsCancelled)&&(identical(other.disputesCount, disputesCount) || other.disputesCount == disputesCount)&&(identical(other.avgResponseMinutes, avgResponseMinutes) || other.avgResponseMinutes == avgResponseMinutes)&&(identical(other.avgRating, avgRating) || other.avgRating == avgRating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.rankingScore, rankingScore) || other.rankingScore == rankingScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,proUserId,displayName,headline,coverMediaAssetId,bio,city,country,const DeepCollectionEquality().hash(styles),const DeepCollectionEquality().hash(packages),const DeepCollectionEquality().hash(portfolioPhotos),const DeepCollectionEquality().hash(portfolioVideos),gigsCompleted,gigsCancelled,disputesCount,avgResponseMinutes,avgRating,reviewCount,rankingScore);

@override
String toString() {
  return 'ProPublicProfileResponse(proUserId: $proUserId, displayName: $displayName, headline: $headline, coverMediaAssetId: $coverMediaAssetId, bio: $bio, city: $city, country: $country, styles: $styles, packages: $packages, portfolioPhotos: $portfolioPhotos, portfolioVideos: $portfolioVideos, gigsCompleted: $gigsCompleted, gigsCancelled: $gigsCancelled, disputesCount: $disputesCount, avgResponseMinutes: $avgResponseMinutes, avgRating: $avgRating, reviewCount: $reviewCount, rankingScore: $rankingScore)';
}


}

/// @nodoc
abstract mixin class $ProPublicProfileResponseCopyWith<$Res>  {
  factory $ProPublicProfileResponseCopyWith(ProPublicProfileResponse value, $Res Function(ProPublicProfileResponse) _then) = _$ProPublicProfileResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ProPublicProfileResponse.proUserIdKey_) String proUserId,@JsonKey(name: ProPublicProfileResponse.displayNameKey_) String? displayName,@JsonKey(name: ProPublicProfileResponse.headlineKey_) String? headline,@JsonKey(name: ProPublicProfileResponse.coverMediaAssetIdKey_) String? coverMediaAssetId,@JsonKey(name: ProPublicProfileResponse.bioKey_) String? bio,@JsonKey(name: ProPublicProfileResponse.cityKey_) String? city,@JsonKey(name: ProPublicProfileResponse.countryKey_) String? country,@JsonKey(name: ProPublicProfileResponse.stylesKey_) List<String>? styles,@JsonKey(name: ProPublicProfileResponse.packagesKey_) List<PublicProPackageView> packages,@JsonKey(name: ProPublicProfileResponse.portfolioPhotosKey_) List<PublicPortfolioPhoto> portfolioPhotos,@JsonKey(name: ProPublicProfileResponse.portfolioVideosKey_) List<PublicPortfolioVideo> portfolioVideos,@JsonKey(name: ProPublicProfileResponse.gigsCompletedKey_) int gigsCompleted,@JsonKey(name: ProPublicProfileResponse.gigsCancelledKey_) int gigsCancelled,@JsonKey(name: ProPublicProfileResponse.disputesCountKey_) int disputesCount,@JsonKey(name: ProPublicProfileResponse.avgResponseMinutesKey_) int? avgResponseMinutes,@JsonKey(name: ProPublicProfileResponse.avgRatingKey_) String avgRating,@JsonKey(name: ProPublicProfileResponse.reviewCountKey_) int reviewCount,@JsonKey(name: ProPublicProfileResponse.rankingScoreKey_) String rankingScore
});




}
/// @nodoc
class _$ProPublicProfileResponseCopyWithImpl<$Res>
    implements $ProPublicProfileResponseCopyWith<$Res> {
  _$ProPublicProfileResponseCopyWithImpl(this._self, this._then);

  final ProPublicProfileResponse _self;
  final $Res Function(ProPublicProfileResponse) _then;

/// Create a copy of ProPublicProfileResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? proUserId = null,Object? displayName = freezed,Object? headline = freezed,Object? coverMediaAssetId = freezed,Object? bio = freezed,Object? city = freezed,Object? country = freezed,Object? styles = freezed,Object? packages = null,Object? portfolioPhotos = null,Object? portfolioVideos = null,Object? gigsCompleted = null,Object? gigsCancelled = null,Object? disputesCount = null,Object? avgResponseMinutes = freezed,Object? avgRating = null,Object? reviewCount = null,Object? rankingScore = null,}) {
  return _then(_self.copyWith(
proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,headline: freezed == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String?,coverMediaAssetId: freezed == coverMediaAssetId ? _self.coverMediaAssetId : coverMediaAssetId // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,styles: freezed == styles ? _self.styles : styles // ignore: cast_nullable_to_non_nullable
as List<String>?,packages: null == packages ? _self.packages : packages // ignore: cast_nullable_to_non_nullable
as List<PublicProPackageView>,portfolioPhotos: null == portfolioPhotos ? _self.portfolioPhotos : portfolioPhotos // ignore: cast_nullable_to_non_nullable
as List<PublicPortfolioPhoto>,portfolioVideos: null == portfolioVideos ? _self.portfolioVideos : portfolioVideos // ignore: cast_nullable_to_non_nullable
as List<PublicPortfolioVideo>,gigsCompleted: null == gigsCompleted ? _self.gigsCompleted : gigsCompleted // ignore: cast_nullable_to_non_nullable
as int,gigsCancelled: null == gigsCancelled ? _self.gigsCancelled : gigsCancelled // ignore: cast_nullable_to_non_nullable
as int,disputesCount: null == disputesCount ? _self.disputesCount : disputesCount // ignore: cast_nullable_to_non_nullable
as int,avgResponseMinutes: freezed == avgResponseMinutes ? _self.avgResponseMinutes : avgResponseMinutes // ignore: cast_nullable_to_non_nullable
as int?,avgRating: null == avgRating ? _self.avgRating : avgRating // ignore: cast_nullable_to_non_nullable
as String,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,rankingScore: null == rankingScore ? _self.rankingScore : rankingScore // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ProPublicProfileResponse].
extension ProPublicProfileResponsePatterns on ProPublicProfileResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProPublicProfileResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProPublicProfileResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProPublicProfileResponse value)  $default,){
final _that = this;
switch (_that) {
case _ProPublicProfileResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProPublicProfileResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ProPublicProfileResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ProPublicProfileResponse.proUserIdKey_)  String proUserId, @JsonKey(name: ProPublicProfileResponse.displayNameKey_)  String? displayName, @JsonKey(name: ProPublicProfileResponse.headlineKey_)  String? headline, @JsonKey(name: ProPublicProfileResponse.coverMediaAssetIdKey_)  String? coverMediaAssetId, @JsonKey(name: ProPublicProfileResponse.bioKey_)  String? bio, @JsonKey(name: ProPublicProfileResponse.cityKey_)  String? city, @JsonKey(name: ProPublicProfileResponse.countryKey_)  String? country, @JsonKey(name: ProPublicProfileResponse.stylesKey_)  List<String>? styles, @JsonKey(name: ProPublicProfileResponse.packagesKey_)  List<PublicProPackageView> packages, @JsonKey(name: ProPublicProfileResponse.portfolioPhotosKey_)  List<PublicPortfolioPhoto> portfolioPhotos, @JsonKey(name: ProPublicProfileResponse.portfolioVideosKey_)  List<PublicPortfolioVideo> portfolioVideos, @JsonKey(name: ProPublicProfileResponse.gigsCompletedKey_)  int gigsCompleted, @JsonKey(name: ProPublicProfileResponse.gigsCancelledKey_)  int gigsCancelled, @JsonKey(name: ProPublicProfileResponse.disputesCountKey_)  int disputesCount, @JsonKey(name: ProPublicProfileResponse.avgResponseMinutesKey_)  int? avgResponseMinutes, @JsonKey(name: ProPublicProfileResponse.avgRatingKey_)  String avgRating, @JsonKey(name: ProPublicProfileResponse.reviewCountKey_)  int reviewCount, @JsonKey(name: ProPublicProfileResponse.rankingScoreKey_)  String rankingScore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProPublicProfileResponse() when $default != null:
return $default(_that.proUserId,_that.displayName,_that.headline,_that.coverMediaAssetId,_that.bio,_that.city,_that.country,_that.styles,_that.packages,_that.portfolioPhotos,_that.portfolioVideos,_that.gigsCompleted,_that.gigsCancelled,_that.disputesCount,_that.avgResponseMinutes,_that.avgRating,_that.reviewCount,_that.rankingScore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ProPublicProfileResponse.proUserIdKey_)  String proUserId, @JsonKey(name: ProPublicProfileResponse.displayNameKey_)  String? displayName, @JsonKey(name: ProPublicProfileResponse.headlineKey_)  String? headline, @JsonKey(name: ProPublicProfileResponse.coverMediaAssetIdKey_)  String? coverMediaAssetId, @JsonKey(name: ProPublicProfileResponse.bioKey_)  String? bio, @JsonKey(name: ProPublicProfileResponse.cityKey_)  String? city, @JsonKey(name: ProPublicProfileResponse.countryKey_)  String? country, @JsonKey(name: ProPublicProfileResponse.stylesKey_)  List<String>? styles, @JsonKey(name: ProPublicProfileResponse.packagesKey_)  List<PublicProPackageView> packages, @JsonKey(name: ProPublicProfileResponse.portfolioPhotosKey_)  List<PublicPortfolioPhoto> portfolioPhotos, @JsonKey(name: ProPublicProfileResponse.portfolioVideosKey_)  List<PublicPortfolioVideo> portfolioVideos, @JsonKey(name: ProPublicProfileResponse.gigsCompletedKey_)  int gigsCompleted, @JsonKey(name: ProPublicProfileResponse.gigsCancelledKey_)  int gigsCancelled, @JsonKey(name: ProPublicProfileResponse.disputesCountKey_)  int disputesCount, @JsonKey(name: ProPublicProfileResponse.avgResponseMinutesKey_)  int? avgResponseMinutes, @JsonKey(name: ProPublicProfileResponse.avgRatingKey_)  String avgRating, @JsonKey(name: ProPublicProfileResponse.reviewCountKey_)  int reviewCount, @JsonKey(name: ProPublicProfileResponse.rankingScoreKey_)  String rankingScore)  $default,) {final _that = this;
switch (_that) {
case _ProPublicProfileResponse():
return $default(_that.proUserId,_that.displayName,_that.headline,_that.coverMediaAssetId,_that.bio,_that.city,_that.country,_that.styles,_that.packages,_that.portfolioPhotos,_that.portfolioVideos,_that.gigsCompleted,_that.gigsCancelled,_that.disputesCount,_that.avgResponseMinutes,_that.avgRating,_that.reviewCount,_that.rankingScore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ProPublicProfileResponse.proUserIdKey_)  String proUserId, @JsonKey(name: ProPublicProfileResponse.displayNameKey_)  String? displayName, @JsonKey(name: ProPublicProfileResponse.headlineKey_)  String? headline, @JsonKey(name: ProPublicProfileResponse.coverMediaAssetIdKey_)  String? coverMediaAssetId, @JsonKey(name: ProPublicProfileResponse.bioKey_)  String? bio, @JsonKey(name: ProPublicProfileResponse.cityKey_)  String? city, @JsonKey(name: ProPublicProfileResponse.countryKey_)  String? country, @JsonKey(name: ProPublicProfileResponse.stylesKey_)  List<String>? styles, @JsonKey(name: ProPublicProfileResponse.packagesKey_)  List<PublicProPackageView> packages, @JsonKey(name: ProPublicProfileResponse.portfolioPhotosKey_)  List<PublicPortfolioPhoto> portfolioPhotos, @JsonKey(name: ProPublicProfileResponse.portfolioVideosKey_)  List<PublicPortfolioVideo> portfolioVideos, @JsonKey(name: ProPublicProfileResponse.gigsCompletedKey_)  int gigsCompleted, @JsonKey(name: ProPublicProfileResponse.gigsCancelledKey_)  int gigsCancelled, @JsonKey(name: ProPublicProfileResponse.disputesCountKey_)  int disputesCount, @JsonKey(name: ProPublicProfileResponse.avgResponseMinutesKey_)  int? avgResponseMinutes, @JsonKey(name: ProPublicProfileResponse.avgRatingKey_)  String avgRating, @JsonKey(name: ProPublicProfileResponse.reviewCountKey_)  int reviewCount, @JsonKey(name: ProPublicProfileResponse.rankingScoreKey_)  String rankingScore)?  $default,) {final _that = this;
switch (_that) {
case _ProPublicProfileResponse() when $default != null:
return $default(_that.proUserId,_that.displayName,_that.headline,_that.coverMediaAssetId,_that.bio,_that.city,_that.country,_that.styles,_that.packages,_that.portfolioPhotos,_that.portfolioVideos,_that.gigsCompleted,_that.gigsCancelled,_that.disputesCount,_that.avgResponseMinutes,_that.avgRating,_that.reviewCount,_that.rankingScore);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ProPublicProfileResponse extends ProPublicProfileResponse {
  const _ProPublicProfileResponse({@JsonKey(name: ProPublicProfileResponse.proUserIdKey_) required this.proUserId, @JsonKey(name: ProPublicProfileResponse.displayNameKey_) this.displayName, @JsonKey(name: ProPublicProfileResponse.headlineKey_) this.headline, @JsonKey(name: ProPublicProfileResponse.coverMediaAssetIdKey_) this.coverMediaAssetId, @JsonKey(name: ProPublicProfileResponse.bioKey_) this.bio, @JsonKey(name: ProPublicProfileResponse.cityKey_) this.city, @JsonKey(name: ProPublicProfileResponse.countryKey_) this.country, @JsonKey(name: ProPublicProfileResponse.stylesKey_) final  List<String>? styles, @JsonKey(name: ProPublicProfileResponse.packagesKey_) required final  List<PublicProPackageView> packages, @JsonKey(name: ProPublicProfileResponse.portfolioPhotosKey_) required final  List<PublicPortfolioPhoto> portfolioPhotos, @JsonKey(name: ProPublicProfileResponse.portfolioVideosKey_) required final  List<PublicPortfolioVideo> portfolioVideos, @JsonKey(name: ProPublicProfileResponse.gigsCompletedKey_) required this.gigsCompleted, @JsonKey(name: ProPublicProfileResponse.gigsCancelledKey_) required this.gigsCancelled, @JsonKey(name: ProPublicProfileResponse.disputesCountKey_) required this.disputesCount, @JsonKey(name: ProPublicProfileResponse.avgResponseMinutesKey_) this.avgResponseMinutes, @JsonKey(name: ProPublicProfileResponse.avgRatingKey_) required this.avgRating, @JsonKey(name: ProPublicProfileResponse.reviewCountKey_) required this.reviewCount, @JsonKey(name: ProPublicProfileResponse.rankingScoreKey_) required this.rankingScore}): _styles = styles,_packages = packages,_portfolioPhotos = portfolioPhotos,_portfolioVideos = portfolioVideos,super._();
  factory _ProPublicProfileResponse.fromJson(Map<String, dynamic> json) => _$ProPublicProfileResponseFromJson(json);

/// proUserId
@override@JsonKey(name: ProPublicProfileResponse.proUserIdKey_) final  String proUserId;
/// displayName
@override@JsonKey(name: ProPublicProfileResponse.displayNameKey_) final  String? displayName;
/// headline
@override@JsonKey(name: ProPublicProfileResponse.headlineKey_) final  String? headline;
/// coverMediaAssetId
@override@JsonKey(name: ProPublicProfileResponse.coverMediaAssetIdKey_) final  String? coverMediaAssetId;
/// bio
@override@JsonKey(name: ProPublicProfileResponse.bioKey_) final  String? bio;
/// city
@override@JsonKey(name: ProPublicProfileResponse.cityKey_) final  String? city;
/// country
@override@JsonKey(name: ProPublicProfileResponse.countryKey_) final  String? country;
/// styles
 final  List<String>? _styles;
/// styles
@override@JsonKey(name: ProPublicProfileResponse.stylesKey_) List<String>? get styles {
  final value = _styles;
  if (value == null) return null;
  if (_styles is EqualUnmodifiableListView) return _styles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// packages
 final  List<PublicProPackageView> _packages;
/// packages
@override@JsonKey(name: ProPublicProfileResponse.packagesKey_) List<PublicProPackageView> get packages {
  if (_packages is EqualUnmodifiableListView) return _packages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_packages);
}

/// portfolioPhotos
 final  List<PublicPortfolioPhoto> _portfolioPhotos;
/// portfolioPhotos
@override@JsonKey(name: ProPublicProfileResponse.portfolioPhotosKey_) List<PublicPortfolioPhoto> get portfolioPhotos {
  if (_portfolioPhotos is EqualUnmodifiableListView) return _portfolioPhotos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_portfolioPhotos);
}

/// portfolioVideos
 final  List<PublicPortfolioVideo> _portfolioVideos;
/// portfolioVideos
@override@JsonKey(name: ProPublicProfileResponse.portfolioVideosKey_) List<PublicPortfolioVideo> get portfolioVideos {
  if (_portfolioVideos is EqualUnmodifiableListView) return _portfolioVideos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_portfolioVideos);
}

/// gigsCompleted
@override@JsonKey(name: ProPublicProfileResponse.gigsCompletedKey_) final  int gigsCompleted;
/// gigsCancelled
@override@JsonKey(name: ProPublicProfileResponse.gigsCancelledKey_) final  int gigsCancelled;
/// disputesCount
@override@JsonKey(name: ProPublicProfileResponse.disputesCountKey_) final  int disputesCount;
/// avgResponseMinutes
@override@JsonKey(name: ProPublicProfileResponse.avgResponseMinutesKey_) final  int? avgResponseMinutes;
/// avgRating
@override@JsonKey(name: ProPublicProfileResponse.avgRatingKey_) final  String avgRating;
/// reviewCount
@override@JsonKey(name: ProPublicProfileResponse.reviewCountKey_) final  int reviewCount;
/// rankingScore
@override@JsonKey(name: ProPublicProfileResponse.rankingScoreKey_) final  String rankingScore;

/// Create a copy of ProPublicProfileResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProPublicProfileResponseCopyWith<_ProPublicProfileResponse> get copyWith => __$ProPublicProfileResponseCopyWithImpl<_ProPublicProfileResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProPublicProfileResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProPublicProfileResponse&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.headline, headline) || other.headline == headline)&&(identical(other.coverMediaAssetId, coverMediaAssetId) || other.coverMediaAssetId == coverMediaAssetId)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&const DeepCollectionEquality().equals(other._styles, _styles)&&const DeepCollectionEquality().equals(other._packages, _packages)&&const DeepCollectionEquality().equals(other._portfolioPhotos, _portfolioPhotos)&&const DeepCollectionEquality().equals(other._portfolioVideos, _portfolioVideos)&&(identical(other.gigsCompleted, gigsCompleted) || other.gigsCompleted == gigsCompleted)&&(identical(other.gigsCancelled, gigsCancelled) || other.gigsCancelled == gigsCancelled)&&(identical(other.disputesCount, disputesCount) || other.disputesCount == disputesCount)&&(identical(other.avgResponseMinutes, avgResponseMinutes) || other.avgResponseMinutes == avgResponseMinutes)&&(identical(other.avgRating, avgRating) || other.avgRating == avgRating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.rankingScore, rankingScore) || other.rankingScore == rankingScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,proUserId,displayName,headline,coverMediaAssetId,bio,city,country,const DeepCollectionEquality().hash(_styles),const DeepCollectionEquality().hash(_packages),const DeepCollectionEquality().hash(_portfolioPhotos),const DeepCollectionEquality().hash(_portfolioVideos),gigsCompleted,gigsCancelled,disputesCount,avgResponseMinutes,avgRating,reviewCount,rankingScore);

@override
String toString() {
  return 'ProPublicProfileResponse(proUserId: $proUserId, displayName: $displayName, headline: $headline, coverMediaAssetId: $coverMediaAssetId, bio: $bio, city: $city, country: $country, styles: $styles, packages: $packages, portfolioPhotos: $portfolioPhotos, portfolioVideos: $portfolioVideos, gigsCompleted: $gigsCompleted, gigsCancelled: $gigsCancelled, disputesCount: $disputesCount, avgResponseMinutes: $avgResponseMinutes, avgRating: $avgRating, reviewCount: $reviewCount, rankingScore: $rankingScore)';
}


}

/// @nodoc
abstract mixin class _$ProPublicProfileResponseCopyWith<$Res> implements $ProPublicProfileResponseCopyWith<$Res> {
  factory _$ProPublicProfileResponseCopyWith(_ProPublicProfileResponse value, $Res Function(_ProPublicProfileResponse) _then) = __$ProPublicProfileResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ProPublicProfileResponse.proUserIdKey_) String proUserId,@JsonKey(name: ProPublicProfileResponse.displayNameKey_) String? displayName,@JsonKey(name: ProPublicProfileResponse.headlineKey_) String? headline,@JsonKey(name: ProPublicProfileResponse.coverMediaAssetIdKey_) String? coverMediaAssetId,@JsonKey(name: ProPublicProfileResponse.bioKey_) String? bio,@JsonKey(name: ProPublicProfileResponse.cityKey_) String? city,@JsonKey(name: ProPublicProfileResponse.countryKey_) String? country,@JsonKey(name: ProPublicProfileResponse.stylesKey_) List<String>? styles,@JsonKey(name: ProPublicProfileResponse.packagesKey_) List<PublicProPackageView> packages,@JsonKey(name: ProPublicProfileResponse.portfolioPhotosKey_) List<PublicPortfolioPhoto> portfolioPhotos,@JsonKey(name: ProPublicProfileResponse.portfolioVideosKey_) List<PublicPortfolioVideo> portfolioVideos,@JsonKey(name: ProPublicProfileResponse.gigsCompletedKey_) int gigsCompleted,@JsonKey(name: ProPublicProfileResponse.gigsCancelledKey_) int gigsCancelled,@JsonKey(name: ProPublicProfileResponse.disputesCountKey_) int disputesCount,@JsonKey(name: ProPublicProfileResponse.avgResponseMinutesKey_) int? avgResponseMinutes,@JsonKey(name: ProPublicProfileResponse.avgRatingKey_) String avgRating,@JsonKey(name: ProPublicProfileResponse.reviewCountKey_) int reviewCount,@JsonKey(name: ProPublicProfileResponse.rankingScoreKey_) String rankingScore
});




}
/// @nodoc
class __$ProPublicProfileResponseCopyWithImpl<$Res>
    implements _$ProPublicProfileResponseCopyWith<$Res> {
  __$ProPublicProfileResponseCopyWithImpl(this._self, this._then);

  final _ProPublicProfileResponse _self;
  final $Res Function(_ProPublicProfileResponse) _then;

/// Create a copy of ProPublicProfileResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? proUserId = null,Object? displayName = freezed,Object? headline = freezed,Object? coverMediaAssetId = freezed,Object? bio = freezed,Object? city = freezed,Object? country = freezed,Object? styles = freezed,Object? packages = null,Object? portfolioPhotos = null,Object? portfolioVideos = null,Object? gigsCompleted = null,Object? gigsCancelled = null,Object? disputesCount = null,Object? avgResponseMinutes = freezed,Object? avgRating = null,Object? reviewCount = null,Object? rankingScore = null,}) {
  return _then(_ProPublicProfileResponse(
proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,headline: freezed == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String?,coverMediaAssetId: freezed == coverMediaAssetId ? _self.coverMediaAssetId : coverMediaAssetId // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,styles: freezed == styles ? _self._styles : styles // ignore: cast_nullable_to_non_nullable
as List<String>?,packages: null == packages ? _self._packages : packages // ignore: cast_nullable_to_non_nullable
as List<PublicProPackageView>,portfolioPhotos: null == portfolioPhotos ? _self._portfolioPhotos : portfolioPhotos // ignore: cast_nullable_to_non_nullable
as List<PublicPortfolioPhoto>,portfolioVideos: null == portfolioVideos ? _self._portfolioVideos : portfolioVideos // ignore: cast_nullable_to_non_nullable
as List<PublicPortfolioVideo>,gigsCompleted: null == gigsCompleted ? _self.gigsCompleted : gigsCompleted // ignore: cast_nullable_to_non_nullable
as int,gigsCancelled: null == gigsCancelled ? _self.gigsCancelled : gigsCancelled // ignore: cast_nullable_to_non_nullable
as int,disputesCount: null == disputesCount ? _self.disputesCount : disputesCount // ignore: cast_nullable_to_non_nullable
as int,avgResponseMinutes: freezed == avgResponseMinutes ? _self.avgResponseMinutes : avgResponseMinutes // ignore: cast_nullable_to_non_nullable
as int?,avgRating: null == avgRating ? _self.avgRating : avgRating // ignore: cast_nullable_to_non_nullable
as String,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,rankingScore: null == rankingScore ? _self.rankingScore : rankingScore // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
