// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pro_profile_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProProfileView {

/// userId
@JsonKey(name: ProProfileView.userIdKey_) String get userId;/// displayName
@JsonKey(name: ProProfileView.displayNameKey_) String? get displayName;/// headline
@JsonKey(name: ProProfileView.headlineKey_) String? get headline;/// coverMediaAssetId
@JsonKey(name: ProProfileView.coverMediaAssetIdKey_) String? get coverMediaAssetId;/// bio
@JsonKey(name: ProProfileView.bioKey_) String? get bio;/// city
@JsonKey(name: ProProfileView.cityKey_) String? get city;/// country
@JsonKey(name: ProProfileView.countryKey_) String? get country;/// languages
@JsonKey(name: ProProfileView.languagesKey_) List<String>? get languages;/// styles
@JsonKey(name: ProProfileView.stylesKey_) List<String>? get styles;/// gear
@JsonKey(name: ProProfileView.gearKey_) Map<String, dynamic>? get gear;/// isAcceptingBookings
@JsonKey(name: ProProfileView.isAcceptingBookingsKey_) bool get isAcceptingBookings;/// completenessScore
@JsonKey(name: ProProfileView.completenessScoreKey_) int get completenessScore;/// kycStatus
@JsonKey(name: ProProfileView.kycStatusKey_) String get kycStatus;
/// Create a copy of ProProfileView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProProfileViewCopyWith<ProProfileView> get copyWith => _$ProProfileViewCopyWithImpl<ProProfileView>(this as ProProfileView, _$identity);

  /// Serializes this ProProfileView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProProfileView&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.headline, headline) || other.headline == headline)&&(identical(other.coverMediaAssetId, coverMediaAssetId) || other.coverMediaAssetId == coverMediaAssetId)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&const DeepCollectionEquality().equals(other.languages, languages)&&const DeepCollectionEquality().equals(other.styles, styles)&&const DeepCollectionEquality().equals(other.gear, gear)&&(identical(other.isAcceptingBookings, isAcceptingBookings) || other.isAcceptingBookings == isAcceptingBookings)&&(identical(other.completenessScore, completenessScore) || other.completenessScore == completenessScore)&&(identical(other.kycStatus, kycStatus) || other.kycStatus == kycStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,displayName,headline,coverMediaAssetId,bio,city,country,const DeepCollectionEquality().hash(languages),const DeepCollectionEquality().hash(styles),const DeepCollectionEquality().hash(gear),isAcceptingBookings,completenessScore,kycStatus);

@override
String toString() {
  return 'ProProfileView(userId: $userId, displayName: $displayName, headline: $headline, coverMediaAssetId: $coverMediaAssetId, bio: $bio, city: $city, country: $country, languages: $languages, styles: $styles, gear: $gear, isAcceptingBookings: $isAcceptingBookings, completenessScore: $completenessScore, kycStatus: $kycStatus)';
}


}

/// @nodoc
abstract mixin class $ProProfileViewCopyWith<$Res>  {
  factory $ProProfileViewCopyWith(ProProfileView value, $Res Function(ProProfileView) _then) = _$ProProfileViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ProProfileView.userIdKey_) String userId,@JsonKey(name: ProProfileView.displayNameKey_) String? displayName,@JsonKey(name: ProProfileView.headlineKey_) String? headline,@JsonKey(name: ProProfileView.coverMediaAssetIdKey_) String? coverMediaAssetId,@JsonKey(name: ProProfileView.bioKey_) String? bio,@JsonKey(name: ProProfileView.cityKey_) String? city,@JsonKey(name: ProProfileView.countryKey_) String? country,@JsonKey(name: ProProfileView.languagesKey_) List<String>? languages,@JsonKey(name: ProProfileView.stylesKey_) List<String>? styles,@JsonKey(name: ProProfileView.gearKey_) Map<String, dynamic>? gear,@JsonKey(name: ProProfileView.isAcceptingBookingsKey_) bool isAcceptingBookings,@JsonKey(name: ProProfileView.completenessScoreKey_) int completenessScore,@JsonKey(name: ProProfileView.kycStatusKey_) String kycStatus
});




}
/// @nodoc
class _$ProProfileViewCopyWithImpl<$Res>
    implements $ProProfileViewCopyWith<$Res> {
  _$ProProfileViewCopyWithImpl(this._self, this._then);

  final ProProfileView _self;
  final $Res Function(ProProfileView) _then;

/// Create a copy of ProProfileView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? displayName = freezed,Object? headline = freezed,Object? coverMediaAssetId = freezed,Object? bio = freezed,Object? city = freezed,Object? country = freezed,Object? languages = freezed,Object? styles = freezed,Object? gear = freezed,Object? isAcceptingBookings = null,Object? completenessScore = null,Object? kycStatus = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,headline: freezed == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String?,coverMediaAssetId: freezed == coverMediaAssetId ? _self.coverMediaAssetId : coverMediaAssetId // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,languages: freezed == languages ? _self.languages : languages // ignore: cast_nullable_to_non_nullable
as List<String>?,styles: freezed == styles ? _self.styles : styles // ignore: cast_nullable_to_non_nullable
as List<String>?,gear: freezed == gear ? _self.gear : gear // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,isAcceptingBookings: null == isAcceptingBookings ? _self.isAcceptingBookings : isAcceptingBookings // ignore: cast_nullable_to_non_nullable
as bool,completenessScore: null == completenessScore ? _self.completenessScore : completenessScore // ignore: cast_nullable_to_non_nullable
as int,kycStatus: null == kycStatus ? _self.kycStatus : kycStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ProProfileView].
extension ProProfileViewPatterns on ProProfileView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProProfileView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProProfileView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProProfileView value)  $default,){
final _that = this;
switch (_that) {
case _ProProfileView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProProfileView value)?  $default,){
final _that = this;
switch (_that) {
case _ProProfileView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ProProfileView.userIdKey_)  String userId, @JsonKey(name: ProProfileView.displayNameKey_)  String? displayName, @JsonKey(name: ProProfileView.headlineKey_)  String? headline, @JsonKey(name: ProProfileView.coverMediaAssetIdKey_)  String? coverMediaAssetId, @JsonKey(name: ProProfileView.bioKey_)  String? bio, @JsonKey(name: ProProfileView.cityKey_)  String? city, @JsonKey(name: ProProfileView.countryKey_)  String? country, @JsonKey(name: ProProfileView.languagesKey_)  List<String>? languages, @JsonKey(name: ProProfileView.stylesKey_)  List<String>? styles, @JsonKey(name: ProProfileView.gearKey_)  Map<String, dynamic>? gear, @JsonKey(name: ProProfileView.isAcceptingBookingsKey_)  bool isAcceptingBookings, @JsonKey(name: ProProfileView.completenessScoreKey_)  int completenessScore, @JsonKey(name: ProProfileView.kycStatusKey_)  String kycStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProProfileView() when $default != null:
return $default(_that.userId,_that.displayName,_that.headline,_that.coverMediaAssetId,_that.bio,_that.city,_that.country,_that.languages,_that.styles,_that.gear,_that.isAcceptingBookings,_that.completenessScore,_that.kycStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ProProfileView.userIdKey_)  String userId, @JsonKey(name: ProProfileView.displayNameKey_)  String? displayName, @JsonKey(name: ProProfileView.headlineKey_)  String? headline, @JsonKey(name: ProProfileView.coverMediaAssetIdKey_)  String? coverMediaAssetId, @JsonKey(name: ProProfileView.bioKey_)  String? bio, @JsonKey(name: ProProfileView.cityKey_)  String? city, @JsonKey(name: ProProfileView.countryKey_)  String? country, @JsonKey(name: ProProfileView.languagesKey_)  List<String>? languages, @JsonKey(name: ProProfileView.stylesKey_)  List<String>? styles, @JsonKey(name: ProProfileView.gearKey_)  Map<String, dynamic>? gear, @JsonKey(name: ProProfileView.isAcceptingBookingsKey_)  bool isAcceptingBookings, @JsonKey(name: ProProfileView.completenessScoreKey_)  int completenessScore, @JsonKey(name: ProProfileView.kycStatusKey_)  String kycStatus)  $default,) {final _that = this;
switch (_that) {
case _ProProfileView():
return $default(_that.userId,_that.displayName,_that.headline,_that.coverMediaAssetId,_that.bio,_that.city,_that.country,_that.languages,_that.styles,_that.gear,_that.isAcceptingBookings,_that.completenessScore,_that.kycStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ProProfileView.userIdKey_)  String userId, @JsonKey(name: ProProfileView.displayNameKey_)  String? displayName, @JsonKey(name: ProProfileView.headlineKey_)  String? headline, @JsonKey(name: ProProfileView.coverMediaAssetIdKey_)  String? coverMediaAssetId, @JsonKey(name: ProProfileView.bioKey_)  String? bio, @JsonKey(name: ProProfileView.cityKey_)  String? city, @JsonKey(name: ProProfileView.countryKey_)  String? country, @JsonKey(name: ProProfileView.languagesKey_)  List<String>? languages, @JsonKey(name: ProProfileView.stylesKey_)  List<String>? styles, @JsonKey(name: ProProfileView.gearKey_)  Map<String, dynamic>? gear, @JsonKey(name: ProProfileView.isAcceptingBookingsKey_)  bool isAcceptingBookings, @JsonKey(name: ProProfileView.completenessScoreKey_)  int completenessScore, @JsonKey(name: ProProfileView.kycStatusKey_)  String kycStatus)?  $default,) {final _that = this;
switch (_that) {
case _ProProfileView() when $default != null:
return $default(_that.userId,_that.displayName,_that.headline,_that.coverMediaAssetId,_that.bio,_that.city,_that.country,_that.languages,_that.styles,_that.gear,_that.isAcceptingBookings,_that.completenessScore,_that.kycStatus);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ProProfileView extends ProProfileView {
  const _ProProfileView({@JsonKey(name: ProProfileView.userIdKey_) required this.userId, @JsonKey(name: ProProfileView.displayNameKey_) this.displayName, @JsonKey(name: ProProfileView.headlineKey_) this.headline, @JsonKey(name: ProProfileView.coverMediaAssetIdKey_) this.coverMediaAssetId, @JsonKey(name: ProProfileView.bioKey_) this.bio, @JsonKey(name: ProProfileView.cityKey_) this.city, @JsonKey(name: ProProfileView.countryKey_) this.country, @JsonKey(name: ProProfileView.languagesKey_) final  List<String>? languages, @JsonKey(name: ProProfileView.stylesKey_) final  List<String>? styles, @JsonKey(name: ProProfileView.gearKey_) final  Map<String, dynamic>? gear, @JsonKey(name: ProProfileView.isAcceptingBookingsKey_) required this.isAcceptingBookings, @JsonKey(name: ProProfileView.completenessScoreKey_) required this.completenessScore, @JsonKey(name: ProProfileView.kycStatusKey_) required this.kycStatus}): _languages = languages,_styles = styles,_gear = gear,super._();
  factory _ProProfileView.fromJson(Map<String, dynamic> json) => _$ProProfileViewFromJson(json);

/// userId
@override@JsonKey(name: ProProfileView.userIdKey_) final  String userId;
/// displayName
@override@JsonKey(name: ProProfileView.displayNameKey_) final  String? displayName;
/// headline
@override@JsonKey(name: ProProfileView.headlineKey_) final  String? headline;
/// coverMediaAssetId
@override@JsonKey(name: ProProfileView.coverMediaAssetIdKey_) final  String? coverMediaAssetId;
/// bio
@override@JsonKey(name: ProProfileView.bioKey_) final  String? bio;
/// city
@override@JsonKey(name: ProProfileView.cityKey_) final  String? city;
/// country
@override@JsonKey(name: ProProfileView.countryKey_) final  String? country;
/// languages
 final  List<String>? _languages;
/// languages
@override@JsonKey(name: ProProfileView.languagesKey_) List<String>? get languages {
  final value = _languages;
  if (value == null) return null;
  if (_languages is EqualUnmodifiableListView) return _languages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// styles
 final  List<String>? _styles;
/// styles
@override@JsonKey(name: ProProfileView.stylesKey_) List<String>? get styles {
  final value = _styles;
  if (value == null) return null;
  if (_styles is EqualUnmodifiableListView) return _styles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// gear
 final  Map<String, dynamic>? _gear;
/// gear
@override@JsonKey(name: ProProfileView.gearKey_) Map<String, dynamic>? get gear {
  final value = _gear;
  if (value == null) return null;
  if (_gear is EqualUnmodifiableMapView) return _gear;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// isAcceptingBookings
@override@JsonKey(name: ProProfileView.isAcceptingBookingsKey_) final  bool isAcceptingBookings;
/// completenessScore
@override@JsonKey(name: ProProfileView.completenessScoreKey_) final  int completenessScore;
/// kycStatus
@override@JsonKey(name: ProProfileView.kycStatusKey_) final  String kycStatus;

/// Create a copy of ProProfileView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProProfileViewCopyWith<_ProProfileView> get copyWith => __$ProProfileViewCopyWithImpl<_ProProfileView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProProfileViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProProfileView&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.headline, headline) || other.headline == headline)&&(identical(other.coverMediaAssetId, coverMediaAssetId) || other.coverMediaAssetId == coverMediaAssetId)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&const DeepCollectionEquality().equals(other._languages, _languages)&&const DeepCollectionEquality().equals(other._styles, _styles)&&const DeepCollectionEquality().equals(other._gear, _gear)&&(identical(other.isAcceptingBookings, isAcceptingBookings) || other.isAcceptingBookings == isAcceptingBookings)&&(identical(other.completenessScore, completenessScore) || other.completenessScore == completenessScore)&&(identical(other.kycStatus, kycStatus) || other.kycStatus == kycStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,displayName,headline,coverMediaAssetId,bio,city,country,const DeepCollectionEquality().hash(_languages),const DeepCollectionEquality().hash(_styles),const DeepCollectionEquality().hash(_gear),isAcceptingBookings,completenessScore,kycStatus);

@override
String toString() {
  return 'ProProfileView(userId: $userId, displayName: $displayName, headline: $headline, coverMediaAssetId: $coverMediaAssetId, bio: $bio, city: $city, country: $country, languages: $languages, styles: $styles, gear: $gear, isAcceptingBookings: $isAcceptingBookings, completenessScore: $completenessScore, kycStatus: $kycStatus)';
}


}

/// @nodoc
abstract mixin class _$ProProfileViewCopyWith<$Res> implements $ProProfileViewCopyWith<$Res> {
  factory _$ProProfileViewCopyWith(_ProProfileView value, $Res Function(_ProProfileView) _then) = __$ProProfileViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ProProfileView.userIdKey_) String userId,@JsonKey(name: ProProfileView.displayNameKey_) String? displayName,@JsonKey(name: ProProfileView.headlineKey_) String? headline,@JsonKey(name: ProProfileView.coverMediaAssetIdKey_) String? coverMediaAssetId,@JsonKey(name: ProProfileView.bioKey_) String? bio,@JsonKey(name: ProProfileView.cityKey_) String? city,@JsonKey(name: ProProfileView.countryKey_) String? country,@JsonKey(name: ProProfileView.languagesKey_) List<String>? languages,@JsonKey(name: ProProfileView.stylesKey_) List<String>? styles,@JsonKey(name: ProProfileView.gearKey_) Map<String, dynamic>? gear,@JsonKey(name: ProProfileView.isAcceptingBookingsKey_) bool isAcceptingBookings,@JsonKey(name: ProProfileView.completenessScoreKey_) int completenessScore,@JsonKey(name: ProProfileView.kycStatusKey_) String kycStatus
});




}
/// @nodoc
class __$ProProfileViewCopyWithImpl<$Res>
    implements _$ProProfileViewCopyWith<$Res> {
  __$ProProfileViewCopyWithImpl(this._self, this._then);

  final _ProProfileView _self;
  final $Res Function(_ProProfileView) _then;

/// Create a copy of ProProfileView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? displayName = freezed,Object? headline = freezed,Object? coverMediaAssetId = freezed,Object? bio = freezed,Object? city = freezed,Object? country = freezed,Object? languages = freezed,Object? styles = freezed,Object? gear = freezed,Object? isAcceptingBookings = null,Object? completenessScore = null,Object? kycStatus = null,}) {
  return _then(_ProProfileView(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,headline: freezed == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String?,coverMediaAssetId: freezed == coverMediaAssetId ? _self.coverMediaAssetId : coverMediaAssetId // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,languages: freezed == languages ? _self._languages : languages // ignore: cast_nullable_to_non_nullable
as List<String>?,styles: freezed == styles ? _self._styles : styles // ignore: cast_nullable_to_non_nullable
as List<String>?,gear: freezed == gear ? _self._gear : gear // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,isAcceptingBookings: null == isAcceptingBookings ? _self.isAcceptingBookings : isAcceptingBookings // ignore: cast_nullable_to_non_nullable
as bool,completenessScore: null == completenessScore ? _self.completenessScore : completenessScore // ignore: cast_nullable_to_non_nullable
as int,kycStatus: null == kycStatus ? _self.kycStatus : kycStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
