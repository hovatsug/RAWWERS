// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pro_card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProCard {

/// proUserId
@JsonKey(name: ProCard.proUserIdKey_) String get proUserId;/// displayName
@JsonKey(name: ProCard.displayNameKey_) String? get displayName;/// city
@JsonKey(name: ProCard.cityKey_) String? get city;/// styles
@JsonKey(name: ProCard.stylesKey_) List<String>? get styles;/// minPrice
@JsonKey(name: ProCard.minPriceKey_) String? get minPrice;/// currency
@JsonKey(name: ProCard.currencyKey_) String get currency;/// portfolioPhotoCount
@JsonKey(name: ProCard.portfolioPhotoCountKey_) int get portfolioPhotoCount;/// portfolioVideoCount
@JsonKey(name: ProCard.portfolioVideoCountKey_) int get portfolioVideoCount;/// avgRating
@JsonKey(name: ProCard.avgRatingKey_) String get avgRating;/// reviewCount
@JsonKey(name: ProCard.reviewCountKey_) int get reviewCount;/// rankingScore
@JsonKey(name: ProCard.rankingScoreKey_) String get rankingScore;/// primaryNicheId
@JsonKey(name: ProCard.primaryNicheIdKey_) String? get primaryNicheId;/// topNiches
@JsonKey(name: ProCard.topNichesKey_) List<Map<String, dynamic>>? get topNiches;
/// Create a copy of ProCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProCardCopyWith<ProCard> get copyWith => _$ProCardCopyWithImpl<ProCard>(this as ProCard, _$identity);

  /// Serializes this ProCard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProCard&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.city, city) || other.city == city)&&const DeepCollectionEquality().equals(other.styles, styles)&&(identical(other.minPrice, minPrice) || other.minPrice == minPrice)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.portfolioPhotoCount, portfolioPhotoCount) || other.portfolioPhotoCount == portfolioPhotoCount)&&(identical(other.portfolioVideoCount, portfolioVideoCount) || other.portfolioVideoCount == portfolioVideoCount)&&(identical(other.avgRating, avgRating) || other.avgRating == avgRating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.rankingScore, rankingScore) || other.rankingScore == rankingScore)&&(identical(other.primaryNicheId, primaryNicheId) || other.primaryNicheId == primaryNicheId)&&const DeepCollectionEquality().equals(other.topNiches, topNiches));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,proUserId,displayName,city,const DeepCollectionEquality().hash(styles),minPrice,currency,portfolioPhotoCount,portfolioVideoCount,avgRating,reviewCount,rankingScore,primaryNicheId,const DeepCollectionEquality().hash(topNiches));

@override
String toString() {
  return 'ProCard(proUserId: $proUserId, displayName: $displayName, city: $city, styles: $styles, minPrice: $minPrice, currency: $currency, portfolioPhotoCount: $portfolioPhotoCount, portfolioVideoCount: $portfolioVideoCount, avgRating: $avgRating, reviewCount: $reviewCount, rankingScore: $rankingScore, primaryNicheId: $primaryNicheId, topNiches: $topNiches)';
}


}

/// @nodoc
abstract mixin class $ProCardCopyWith<$Res>  {
  factory $ProCardCopyWith(ProCard value, $Res Function(ProCard) _then) = _$ProCardCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ProCard.proUserIdKey_) String proUserId,@JsonKey(name: ProCard.displayNameKey_) String? displayName,@JsonKey(name: ProCard.cityKey_) String? city,@JsonKey(name: ProCard.stylesKey_) List<String>? styles,@JsonKey(name: ProCard.minPriceKey_) String? minPrice,@JsonKey(name: ProCard.currencyKey_) String currency,@JsonKey(name: ProCard.portfolioPhotoCountKey_) int portfolioPhotoCount,@JsonKey(name: ProCard.portfolioVideoCountKey_) int portfolioVideoCount,@JsonKey(name: ProCard.avgRatingKey_) String avgRating,@JsonKey(name: ProCard.reviewCountKey_) int reviewCount,@JsonKey(name: ProCard.rankingScoreKey_) String rankingScore,@JsonKey(name: ProCard.primaryNicheIdKey_) String? primaryNicheId,@JsonKey(name: ProCard.topNichesKey_) List<Map<String, dynamic>>? topNiches
});




}
/// @nodoc
class _$ProCardCopyWithImpl<$Res>
    implements $ProCardCopyWith<$Res> {
  _$ProCardCopyWithImpl(this._self, this._then);

  final ProCard _self;
  final $Res Function(ProCard) _then;

/// Create a copy of ProCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? proUserId = null,Object? displayName = freezed,Object? city = freezed,Object? styles = freezed,Object? minPrice = freezed,Object? currency = null,Object? portfolioPhotoCount = null,Object? portfolioVideoCount = null,Object? avgRating = null,Object? reviewCount = null,Object? rankingScore = null,Object? primaryNicheId = freezed,Object? topNiches = freezed,}) {
  return _then(_self.copyWith(
proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,styles: freezed == styles ? _self.styles : styles // ignore: cast_nullable_to_non_nullable
as List<String>?,minPrice: freezed == minPrice ? _self.minPrice : minPrice // ignore: cast_nullable_to_non_nullable
as String?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,portfolioPhotoCount: null == portfolioPhotoCount ? _self.portfolioPhotoCount : portfolioPhotoCount // ignore: cast_nullable_to_non_nullable
as int,portfolioVideoCount: null == portfolioVideoCount ? _self.portfolioVideoCount : portfolioVideoCount // ignore: cast_nullable_to_non_nullable
as int,avgRating: null == avgRating ? _self.avgRating : avgRating // ignore: cast_nullable_to_non_nullable
as String,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,rankingScore: null == rankingScore ? _self.rankingScore : rankingScore // ignore: cast_nullable_to_non_nullable
as String,primaryNicheId: freezed == primaryNicheId ? _self.primaryNicheId : primaryNicheId // ignore: cast_nullable_to_non_nullable
as String?,topNiches: freezed == topNiches ? _self.topNiches : topNiches // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProCard].
extension ProCardPatterns on ProCard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProCard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProCard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProCard value)  $default,){
final _that = this;
switch (_that) {
case _ProCard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProCard value)?  $default,){
final _that = this;
switch (_that) {
case _ProCard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ProCard.proUserIdKey_)  String proUserId, @JsonKey(name: ProCard.displayNameKey_)  String? displayName, @JsonKey(name: ProCard.cityKey_)  String? city, @JsonKey(name: ProCard.stylesKey_)  List<String>? styles, @JsonKey(name: ProCard.minPriceKey_)  String? minPrice, @JsonKey(name: ProCard.currencyKey_)  String currency, @JsonKey(name: ProCard.portfolioPhotoCountKey_)  int portfolioPhotoCount, @JsonKey(name: ProCard.portfolioVideoCountKey_)  int portfolioVideoCount, @JsonKey(name: ProCard.avgRatingKey_)  String avgRating, @JsonKey(name: ProCard.reviewCountKey_)  int reviewCount, @JsonKey(name: ProCard.rankingScoreKey_)  String rankingScore, @JsonKey(name: ProCard.primaryNicheIdKey_)  String? primaryNicheId, @JsonKey(name: ProCard.topNichesKey_)  List<Map<String, dynamic>>? topNiches)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProCard() when $default != null:
return $default(_that.proUserId,_that.displayName,_that.city,_that.styles,_that.minPrice,_that.currency,_that.portfolioPhotoCount,_that.portfolioVideoCount,_that.avgRating,_that.reviewCount,_that.rankingScore,_that.primaryNicheId,_that.topNiches);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ProCard.proUserIdKey_)  String proUserId, @JsonKey(name: ProCard.displayNameKey_)  String? displayName, @JsonKey(name: ProCard.cityKey_)  String? city, @JsonKey(name: ProCard.stylesKey_)  List<String>? styles, @JsonKey(name: ProCard.minPriceKey_)  String? minPrice, @JsonKey(name: ProCard.currencyKey_)  String currency, @JsonKey(name: ProCard.portfolioPhotoCountKey_)  int portfolioPhotoCount, @JsonKey(name: ProCard.portfolioVideoCountKey_)  int portfolioVideoCount, @JsonKey(name: ProCard.avgRatingKey_)  String avgRating, @JsonKey(name: ProCard.reviewCountKey_)  int reviewCount, @JsonKey(name: ProCard.rankingScoreKey_)  String rankingScore, @JsonKey(name: ProCard.primaryNicheIdKey_)  String? primaryNicheId, @JsonKey(name: ProCard.topNichesKey_)  List<Map<String, dynamic>>? topNiches)  $default,) {final _that = this;
switch (_that) {
case _ProCard():
return $default(_that.proUserId,_that.displayName,_that.city,_that.styles,_that.minPrice,_that.currency,_that.portfolioPhotoCount,_that.portfolioVideoCount,_that.avgRating,_that.reviewCount,_that.rankingScore,_that.primaryNicheId,_that.topNiches);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ProCard.proUserIdKey_)  String proUserId, @JsonKey(name: ProCard.displayNameKey_)  String? displayName, @JsonKey(name: ProCard.cityKey_)  String? city, @JsonKey(name: ProCard.stylesKey_)  List<String>? styles, @JsonKey(name: ProCard.minPriceKey_)  String? minPrice, @JsonKey(name: ProCard.currencyKey_)  String currency, @JsonKey(name: ProCard.portfolioPhotoCountKey_)  int portfolioPhotoCount, @JsonKey(name: ProCard.portfolioVideoCountKey_)  int portfolioVideoCount, @JsonKey(name: ProCard.avgRatingKey_)  String avgRating, @JsonKey(name: ProCard.reviewCountKey_)  int reviewCount, @JsonKey(name: ProCard.rankingScoreKey_)  String rankingScore, @JsonKey(name: ProCard.primaryNicheIdKey_)  String? primaryNicheId, @JsonKey(name: ProCard.topNichesKey_)  List<Map<String, dynamic>>? topNiches)?  $default,) {final _that = this;
switch (_that) {
case _ProCard() when $default != null:
return $default(_that.proUserId,_that.displayName,_that.city,_that.styles,_that.minPrice,_that.currency,_that.portfolioPhotoCount,_that.portfolioVideoCount,_that.avgRating,_that.reviewCount,_that.rankingScore,_that.primaryNicheId,_that.topNiches);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ProCard extends ProCard {
  const _ProCard({@JsonKey(name: ProCard.proUserIdKey_) required this.proUserId, @JsonKey(name: ProCard.displayNameKey_) this.displayName, @JsonKey(name: ProCard.cityKey_) this.city, @JsonKey(name: ProCard.stylesKey_) final  List<String>? styles, @JsonKey(name: ProCard.minPriceKey_) this.minPrice, @JsonKey(name: ProCard.currencyKey_) required this.currency, @JsonKey(name: ProCard.portfolioPhotoCountKey_) required this.portfolioPhotoCount, @JsonKey(name: ProCard.portfolioVideoCountKey_) required this.portfolioVideoCount, @JsonKey(name: ProCard.avgRatingKey_) required this.avgRating, @JsonKey(name: ProCard.reviewCountKey_) required this.reviewCount, @JsonKey(name: ProCard.rankingScoreKey_) required this.rankingScore, @JsonKey(name: ProCard.primaryNicheIdKey_) this.primaryNicheId, @JsonKey(name: ProCard.topNichesKey_) final  List<Map<String, dynamic>>? topNiches}): _styles = styles,_topNiches = topNiches,super._();
  factory _ProCard.fromJson(Map<String, dynamic> json) => _$ProCardFromJson(json);

/// proUserId
@override@JsonKey(name: ProCard.proUserIdKey_) final  String proUserId;
/// displayName
@override@JsonKey(name: ProCard.displayNameKey_) final  String? displayName;
/// city
@override@JsonKey(name: ProCard.cityKey_) final  String? city;
/// styles
 final  List<String>? _styles;
/// styles
@override@JsonKey(name: ProCard.stylesKey_) List<String>? get styles {
  final value = _styles;
  if (value == null) return null;
  if (_styles is EqualUnmodifiableListView) return _styles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// minPrice
@override@JsonKey(name: ProCard.minPriceKey_) final  String? minPrice;
/// currency
@override@JsonKey(name: ProCard.currencyKey_) final  String currency;
/// portfolioPhotoCount
@override@JsonKey(name: ProCard.portfolioPhotoCountKey_) final  int portfolioPhotoCount;
/// portfolioVideoCount
@override@JsonKey(name: ProCard.portfolioVideoCountKey_) final  int portfolioVideoCount;
/// avgRating
@override@JsonKey(name: ProCard.avgRatingKey_) final  String avgRating;
/// reviewCount
@override@JsonKey(name: ProCard.reviewCountKey_) final  int reviewCount;
/// rankingScore
@override@JsonKey(name: ProCard.rankingScoreKey_) final  String rankingScore;
/// primaryNicheId
@override@JsonKey(name: ProCard.primaryNicheIdKey_) final  String? primaryNicheId;
/// topNiches
 final  List<Map<String, dynamic>>? _topNiches;
/// topNiches
@override@JsonKey(name: ProCard.topNichesKey_) List<Map<String, dynamic>>? get topNiches {
  final value = _topNiches;
  if (value == null) return null;
  if (_topNiches is EqualUnmodifiableListView) return _topNiches;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ProCard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProCardCopyWith<_ProCard> get copyWith => __$ProCardCopyWithImpl<_ProCard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProCardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProCard&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.city, city) || other.city == city)&&const DeepCollectionEquality().equals(other._styles, _styles)&&(identical(other.minPrice, minPrice) || other.minPrice == minPrice)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.portfolioPhotoCount, portfolioPhotoCount) || other.portfolioPhotoCount == portfolioPhotoCount)&&(identical(other.portfolioVideoCount, portfolioVideoCount) || other.portfolioVideoCount == portfolioVideoCount)&&(identical(other.avgRating, avgRating) || other.avgRating == avgRating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.rankingScore, rankingScore) || other.rankingScore == rankingScore)&&(identical(other.primaryNicheId, primaryNicheId) || other.primaryNicheId == primaryNicheId)&&const DeepCollectionEquality().equals(other._topNiches, _topNiches));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,proUserId,displayName,city,const DeepCollectionEquality().hash(_styles),minPrice,currency,portfolioPhotoCount,portfolioVideoCount,avgRating,reviewCount,rankingScore,primaryNicheId,const DeepCollectionEquality().hash(_topNiches));

@override
String toString() {
  return 'ProCard(proUserId: $proUserId, displayName: $displayName, city: $city, styles: $styles, minPrice: $minPrice, currency: $currency, portfolioPhotoCount: $portfolioPhotoCount, portfolioVideoCount: $portfolioVideoCount, avgRating: $avgRating, reviewCount: $reviewCount, rankingScore: $rankingScore, primaryNicheId: $primaryNicheId, topNiches: $topNiches)';
}


}

/// @nodoc
abstract mixin class _$ProCardCopyWith<$Res> implements $ProCardCopyWith<$Res> {
  factory _$ProCardCopyWith(_ProCard value, $Res Function(_ProCard) _then) = __$ProCardCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ProCard.proUserIdKey_) String proUserId,@JsonKey(name: ProCard.displayNameKey_) String? displayName,@JsonKey(name: ProCard.cityKey_) String? city,@JsonKey(name: ProCard.stylesKey_) List<String>? styles,@JsonKey(name: ProCard.minPriceKey_) String? minPrice,@JsonKey(name: ProCard.currencyKey_) String currency,@JsonKey(name: ProCard.portfolioPhotoCountKey_) int portfolioPhotoCount,@JsonKey(name: ProCard.portfolioVideoCountKey_) int portfolioVideoCount,@JsonKey(name: ProCard.avgRatingKey_) String avgRating,@JsonKey(name: ProCard.reviewCountKey_) int reviewCount,@JsonKey(name: ProCard.rankingScoreKey_) String rankingScore,@JsonKey(name: ProCard.primaryNicheIdKey_) String? primaryNicheId,@JsonKey(name: ProCard.topNichesKey_) List<Map<String, dynamic>>? topNiches
});




}
/// @nodoc
class __$ProCardCopyWithImpl<$Res>
    implements _$ProCardCopyWith<$Res> {
  __$ProCardCopyWithImpl(this._self, this._then);

  final _ProCard _self;
  final $Res Function(_ProCard) _then;

/// Create a copy of ProCard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? proUserId = null,Object? displayName = freezed,Object? city = freezed,Object? styles = freezed,Object? minPrice = freezed,Object? currency = null,Object? portfolioPhotoCount = null,Object? portfolioVideoCount = null,Object? avgRating = null,Object? reviewCount = null,Object? rankingScore = null,Object? primaryNicheId = freezed,Object? topNiches = freezed,}) {
  return _then(_ProCard(
proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,styles: freezed == styles ? _self._styles : styles // ignore: cast_nullable_to_non_nullable
as List<String>?,minPrice: freezed == minPrice ? _self.minPrice : minPrice // ignore: cast_nullable_to_non_nullable
as String?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,portfolioPhotoCount: null == portfolioPhotoCount ? _self.portfolioPhotoCount : portfolioPhotoCount // ignore: cast_nullable_to_non_nullable
as int,portfolioVideoCount: null == portfolioVideoCount ? _self.portfolioVideoCount : portfolioVideoCount // ignore: cast_nullable_to_non_nullable
as int,avgRating: null == avgRating ? _self.avgRating : avgRating // ignore: cast_nullable_to_non_nullable
as String,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,rankingScore: null == rankingScore ? _self.rankingScore : rankingScore // ignore: cast_nullable_to_non_nullable
as String,primaryNicheId: freezed == primaryNicheId ? _self.primaryNicheId : primaryNicheId // ignore: cast_nullable_to_non_nullable
as String?,topNiches: freezed == topNiches ? _self._topNiches : topNiches // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>?,
  ));
}


}

// dart format on
