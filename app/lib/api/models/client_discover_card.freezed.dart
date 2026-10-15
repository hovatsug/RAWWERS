// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_discover_card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClientDiscoverCard {

/// proUserId
@JsonKey(name: ClientDiscoverCard.proUserIdKey_) String get proUserId;/// displayName
@JsonKey(name: ClientDiscoverCard.displayNameKey_) String? get displayName;/// headline
@JsonKey(name: ClientDiscoverCard.headlineKey_) String? get headline;/// coverMediaAssetId
@JsonKey(name: ClientDiscoverCard.coverMediaAssetIdKey_) String? get coverMediaAssetId;/// coverUrl
@JsonKey(name: ClientDiscoverCard.coverUrlKey_) String? get coverUrl;/// city
@JsonKey(name: ClientDiscoverCard.cityKey_) String? get city;/// country
@JsonKey(name: ClientDiscoverCard.countryKey_) String? get country;/// minPrice
@JsonKey(name: ClientDiscoverCard.minPriceKey_) String? get minPrice;/// maxPrice
@JsonKey(name: ClientDiscoverCard.maxPriceKey_) String? get maxPrice;/// minEntryRate
@JsonKey(name: ClientDiscoverCard.minEntryRateKey_) String? get minEntryRate;/// minEntryPhotos
@JsonKey(name: ClientDiscoverCard.minEntryPhotosKey_) int? get minEntryPhotos;/// currency
@JsonKey(name: ClientDiscoverCard.currencyKey_) String get currency;/// avgRating
@JsonKey(name: ClientDiscoverCard.avgRatingKey_) String get avgRating;/// reviewCount
@JsonKey(name: ClientDiscoverCard.reviewCountKey_) int get reviewCount;/// responseLabel
@JsonKey(name: ClientDiscoverCard.responseLabelKey_) String? get responseLabel;/// online
@JsonKey(name: ClientDiscoverCard.onlineKey_) bool get online;/// readyInMinutes
@JsonKey(name: ClientDiscoverCard.readyInMinutesKey_) int? get readyInMinutes;/// answerWithinMinutes
@JsonKey(name: ClientDiscoverCard.answerWithinMinutesKey_) int? get answerWithinMinutes;/// topNiches
@JsonKey(name: ClientDiscoverCard.topNichesKey_) List<Map<String, dynamic>>? get topNiches;/// portfolioPhotoCount
@JsonKey(name: ClientDiscoverCard.portfolioPhotoCountKey_) int get portfolioPhotoCount;/// portfolioVideoCount
@JsonKey(name: ClientDiscoverCard.portfolioVideoCountKey_) int get portfolioVideoCount;
/// Create a copy of ClientDiscoverCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientDiscoverCardCopyWith<ClientDiscoverCard> get copyWith => _$ClientDiscoverCardCopyWithImpl<ClientDiscoverCard>(this as ClientDiscoverCard, _$identity);

  /// Serializes this ClientDiscoverCard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientDiscoverCard&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.headline, headline) || other.headline == headline)&&(identical(other.coverMediaAssetId, coverMediaAssetId) || other.coverMediaAssetId == coverMediaAssetId)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&(identical(other.minPrice, minPrice) || other.minPrice == minPrice)&&(identical(other.maxPrice, maxPrice) || other.maxPrice == maxPrice)&&(identical(other.minEntryRate, minEntryRate) || other.minEntryRate == minEntryRate)&&(identical(other.minEntryPhotos, minEntryPhotos) || other.minEntryPhotos == minEntryPhotos)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.avgRating, avgRating) || other.avgRating == avgRating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.responseLabel, responseLabel) || other.responseLabel == responseLabel)&&(identical(other.online, online) || other.online == online)&&(identical(other.readyInMinutes, readyInMinutes) || other.readyInMinutes == readyInMinutes)&&(identical(other.answerWithinMinutes, answerWithinMinutes) || other.answerWithinMinutes == answerWithinMinutes)&&const DeepCollectionEquality().equals(other.topNiches, topNiches)&&(identical(other.portfolioPhotoCount, portfolioPhotoCount) || other.portfolioPhotoCount == portfolioPhotoCount)&&(identical(other.portfolioVideoCount, portfolioVideoCount) || other.portfolioVideoCount == portfolioVideoCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,proUserId,displayName,headline,coverMediaAssetId,coverUrl,city,country,minPrice,maxPrice,minEntryRate,minEntryPhotos,currency,avgRating,reviewCount,responseLabel,online,readyInMinutes,answerWithinMinutes,const DeepCollectionEquality().hash(topNiches),portfolioPhotoCount,portfolioVideoCount]);

@override
String toString() {
  return 'ClientDiscoverCard(proUserId: $proUserId, displayName: $displayName, headline: $headline, coverMediaAssetId: $coverMediaAssetId, coverUrl: $coverUrl, city: $city, country: $country, minPrice: $minPrice, maxPrice: $maxPrice, minEntryRate: $minEntryRate, minEntryPhotos: $minEntryPhotos, currency: $currency, avgRating: $avgRating, reviewCount: $reviewCount, responseLabel: $responseLabel, online: $online, readyInMinutes: $readyInMinutes, answerWithinMinutes: $answerWithinMinutes, topNiches: $topNiches, portfolioPhotoCount: $portfolioPhotoCount, portfolioVideoCount: $portfolioVideoCount)';
}


}

/// @nodoc
abstract mixin class $ClientDiscoverCardCopyWith<$Res>  {
  factory $ClientDiscoverCardCopyWith(ClientDiscoverCard value, $Res Function(ClientDiscoverCard) _then) = _$ClientDiscoverCardCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ClientDiscoverCard.proUserIdKey_) String proUserId,@JsonKey(name: ClientDiscoverCard.displayNameKey_) String? displayName,@JsonKey(name: ClientDiscoverCard.headlineKey_) String? headline,@JsonKey(name: ClientDiscoverCard.coverMediaAssetIdKey_) String? coverMediaAssetId,@JsonKey(name: ClientDiscoverCard.coverUrlKey_) String? coverUrl,@JsonKey(name: ClientDiscoverCard.cityKey_) String? city,@JsonKey(name: ClientDiscoverCard.countryKey_) String? country,@JsonKey(name: ClientDiscoverCard.minPriceKey_) String? minPrice,@JsonKey(name: ClientDiscoverCard.maxPriceKey_) String? maxPrice,@JsonKey(name: ClientDiscoverCard.minEntryRateKey_) String? minEntryRate,@JsonKey(name: ClientDiscoverCard.minEntryPhotosKey_) int? minEntryPhotos,@JsonKey(name: ClientDiscoverCard.currencyKey_) String currency,@JsonKey(name: ClientDiscoverCard.avgRatingKey_) String avgRating,@JsonKey(name: ClientDiscoverCard.reviewCountKey_) int reviewCount,@JsonKey(name: ClientDiscoverCard.responseLabelKey_) String? responseLabel,@JsonKey(name: ClientDiscoverCard.onlineKey_) bool online,@JsonKey(name: ClientDiscoverCard.readyInMinutesKey_) int? readyInMinutes,@JsonKey(name: ClientDiscoverCard.answerWithinMinutesKey_) int? answerWithinMinutes,@JsonKey(name: ClientDiscoverCard.topNichesKey_) List<Map<String, dynamic>>? topNiches,@JsonKey(name: ClientDiscoverCard.portfolioPhotoCountKey_) int portfolioPhotoCount,@JsonKey(name: ClientDiscoverCard.portfolioVideoCountKey_) int portfolioVideoCount
});




}
/// @nodoc
class _$ClientDiscoverCardCopyWithImpl<$Res>
    implements $ClientDiscoverCardCopyWith<$Res> {
  _$ClientDiscoverCardCopyWithImpl(this._self, this._then);

  final ClientDiscoverCard _self;
  final $Res Function(ClientDiscoverCard) _then;

/// Create a copy of ClientDiscoverCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? proUserId = null,Object? displayName = freezed,Object? headline = freezed,Object? coverMediaAssetId = freezed,Object? coverUrl = freezed,Object? city = freezed,Object? country = freezed,Object? minPrice = freezed,Object? maxPrice = freezed,Object? minEntryRate = freezed,Object? minEntryPhotos = freezed,Object? currency = null,Object? avgRating = null,Object? reviewCount = null,Object? responseLabel = freezed,Object? online = null,Object? readyInMinutes = freezed,Object? answerWithinMinutes = freezed,Object? topNiches = freezed,Object? portfolioPhotoCount = null,Object? portfolioVideoCount = null,}) {
  return _then(_self.copyWith(
proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,headline: freezed == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String?,coverMediaAssetId: freezed == coverMediaAssetId ? _self.coverMediaAssetId : coverMediaAssetId // ignore: cast_nullable_to_non_nullable
as String?,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,minPrice: freezed == minPrice ? _self.minPrice : minPrice // ignore: cast_nullable_to_non_nullable
as String?,maxPrice: freezed == maxPrice ? _self.maxPrice : maxPrice // ignore: cast_nullable_to_non_nullable
as String?,minEntryRate: freezed == minEntryRate ? _self.minEntryRate : minEntryRate // ignore: cast_nullable_to_non_nullable
as String?,minEntryPhotos: freezed == minEntryPhotos ? _self.minEntryPhotos : minEntryPhotos // ignore: cast_nullable_to_non_nullable
as int?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,avgRating: null == avgRating ? _self.avgRating : avgRating // ignore: cast_nullable_to_non_nullable
as String,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,responseLabel: freezed == responseLabel ? _self.responseLabel : responseLabel // ignore: cast_nullable_to_non_nullable
as String?,online: null == online ? _self.online : online // ignore: cast_nullable_to_non_nullable
as bool,readyInMinutes: freezed == readyInMinutes ? _self.readyInMinutes : readyInMinutes // ignore: cast_nullable_to_non_nullable
as int?,answerWithinMinutes: freezed == answerWithinMinutes ? _self.answerWithinMinutes : answerWithinMinutes // ignore: cast_nullable_to_non_nullable
as int?,topNiches: freezed == topNiches ? _self.topNiches : topNiches // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>?,portfolioPhotoCount: null == portfolioPhotoCount ? _self.portfolioPhotoCount : portfolioPhotoCount // ignore: cast_nullable_to_non_nullable
as int,portfolioVideoCount: null == portfolioVideoCount ? _self.portfolioVideoCount : portfolioVideoCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ClientDiscoverCard].
extension ClientDiscoverCardPatterns on ClientDiscoverCard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientDiscoverCard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientDiscoverCard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientDiscoverCard value)  $default,){
final _that = this;
switch (_that) {
case _ClientDiscoverCard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientDiscoverCard value)?  $default,){
final _that = this;
switch (_that) {
case _ClientDiscoverCard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ClientDiscoverCard.proUserIdKey_)  String proUserId, @JsonKey(name: ClientDiscoverCard.displayNameKey_)  String? displayName, @JsonKey(name: ClientDiscoverCard.headlineKey_)  String? headline, @JsonKey(name: ClientDiscoverCard.coverMediaAssetIdKey_)  String? coverMediaAssetId, @JsonKey(name: ClientDiscoverCard.coverUrlKey_)  String? coverUrl, @JsonKey(name: ClientDiscoverCard.cityKey_)  String? city, @JsonKey(name: ClientDiscoverCard.countryKey_)  String? country, @JsonKey(name: ClientDiscoverCard.minPriceKey_)  String? minPrice, @JsonKey(name: ClientDiscoverCard.maxPriceKey_)  String? maxPrice, @JsonKey(name: ClientDiscoverCard.minEntryRateKey_)  String? minEntryRate, @JsonKey(name: ClientDiscoverCard.minEntryPhotosKey_)  int? minEntryPhotos, @JsonKey(name: ClientDiscoverCard.currencyKey_)  String currency, @JsonKey(name: ClientDiscoverCard.avgRatingKey_)  String avgRating, @JsonKey(name: ClientDiscoverCard.reviewCountKey_)  int reviewCount, @JsonKey(name: ClientDiscoverCard.responseLabelKey_)  String? responseLabel, @JsonKey(name: ClientDiscoverCard.onlineKey_)  bool online, @JsonKey(name: ClientDiscoverCard.readyInMinutesKey_)  int? readyInMinutes, @JsonKey(name: ClientDiscoverCard.answerWithinMinutesKey_)  int? answerWithinMinutes, @JsonKey(name: ClientDiscoverCard.topNichesKey_)  List<Map<String, dynamic>>? topNiches, @JsonKey(name: ClientDiscoverCard.portfolioPhotoCountKey_)  int portfolioPhotoCount, @JsonKey(name: ClientDiscoverCard.portfolioVideoCountKey_)  int portfolioVideoCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientDiscoverCard() when $default != null:
return $default(_that.proUserId,_that.displayName,_that.headline,_that.coverMediaAssetId,_that.coverUrl,_that.city,_that.country,_that.minPrice,_that.maxPrice,_that.minEntryRate,_that.minEntryPhotos,_that.currency,_that.avgRating,_that.reviewCount,_that.responseLabel,_that.online,_that.readyInMinutes,_that.answerWithinMinutes,_that.topNiches,_that.portfolioPhotoCount,_that.portfolioVideoCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ClientDiscoverCard.proUserIdKey_)  String proUserId, @JsonKey(name: ClientDiscoverCard.displayNameKey_)  String? displayName, @JsonKey(name: ClientDiscoverCard.headlineKey_)  String? headline, @JsonKey(name: ClientDiscoverCard.coverMediaAssetIdKey_)  String? coverMediaAssetId, @JsonKey(name: ClientDiscoverCard.coverUrlKey_)  String? coverUrl, @JsonKey(name: ClientDiscoverCard.cityKey_)  String? city, @JsonKey(name: ClientDiscoverCard.countryKey_)  String? country, @JsonKey(name: ClientDiscoverCard.minPriceKey_)  String? minPrice, @JsonKey(name: ClientDiscoverCard.maxPriceKey_)  String? maxPrice, @JsonKey(name: ClientDiscoverCard.minEntryRateKey_)  String? minEntryRate, @JsonKey(name: ClientDiscoverCard.minEntryPhotosKey_)  int? minEntryPhotos, @JsonKey(name: ClientDiscoverCard.currencyKey_)  String currency, @JsonKey(name: ClientDiscoverCard.avgRatingKey_)  String avgRating, @JsonKey(name: ClientDiscoverCard.reviewCountKey_)  int reviewCount, @JsonKey(name: ClientDiscoverCard.responseLabelKey_)  String? responseLabel, @JsonKey(name: ClientDiscoverCard.onlineKey_)  bool online, @JsonKey(name: ClientDiscoverCard.readyInMinutesKey_)  int? readyInMinutes, @JsonKey(name: ClientDiscoverCard.answerWithinMinutesKey_)  int? answerWithinMinutes, @JsonKey(name: ClientDiscoverCard.topNichesKey_)  List<Map<String, dynamic>>? topNiches, @JsonKey(name: ClientDiscoverCard.portfolioPhotoCountKey_)  int portfolioPhotoCount, @JsonKey(name: ClientDiscoverCard.portfolioVideoCountKey_)  int portfolioVideoCount)  $default,) {final _that = this;
switch (_that) {
case _ClientDiscoverCard():
return $default(_that.proUserId,_that.displayName,_that.headline,_that.coverMediaAssetId,_that.coverUrl,_that.city,_that.country,_that.minPrice,_that.maxPrice,_that.minEntryRate,_that.minEntryPhotos,_that.currency,_that.avgRating,_that.reviewCount,_that.responseLabel,_that.online,_that.readyInMinutes,_that.answerWithinMinutes,_that.topNiches,_that.portfolioPhotoCount,_that.portfolioVideoCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ClientDiscoverCard.proUserIdKey_)  String proUserId, @JsonKey(name: ClientDiscoverCard.displayNameKey_)  String? displayName, @JsonKey(name: ClientDiscoverCard.headlineKey_)  String? headline, @JsonKey(name: ClientDiscoverCard.coverMediaAssetIdKey_)  String? coverMediaAssetId, @JsonKey(name: ClientDiscoverCard.coverUrlKey_)  String? coverUrl, @JsonKey(name: ClientDiscoverCard.cityKey_)  String? city, @JsonKey(name: ClientDiscoverCard.countryKey_)  String? country, @JsonKey(name: ClientDiscoverCard.minPriceKey_)  String? minPrice, @JsonKey(name: ClientDiscoverCard.maxPriceKey_)  String? maxPrice, @JsonKey(name: ClientDiscoverCard.minEntryRateKey_)  String? minEntryRate, @JsonKey(name: ClientDiscoverCard.minEntryPhotosKey_)  int? minEntryPhotos, @JsonKey(name: ClientDiscoverCard.currencyKey_)  String currency, @JsonKey(name: ClientDiscoverCard.avgRatingKey_)  String avgRating, @JsonKey(name: ClientDiscoverCard.reviewCountKey_)  int reviewCount, @JsonKey(name: ClientDiscoverCard.responseLabelKey_)  String? responseLabel, @JsonKey(name: ClientDiscoverCard.onlineKey_)  bool online, @JsonKey(name: ClientDiscoverCard.readyInMinutesKey_)  int? readyInMinutes, @JsonKey(name: ClientDiscoverCard.answerWithinMinutesKey_)  int? answerWithinMinutes, @JsonKey(name: ClientDiscoverCard.topNichesKey_)  List<Map<String, dynamic>>? topNiches, @JsonKey(name: ClientDiscoverCard.portfolioPhotoCountKey_)  int portfolioPhotoCount, @JsonKey(name: ClientDiscoverCard.portfolioVideoCountKey_)  int portfolioVideoCount)?  $default,) {final _that = this;
switch (_that) {
case _ClientDiscoverCard() when $default != null:
return $default(_that.proUserId,_that.displayName,_that.headline,_that.coverMediaAssetId,_that.coverUrl,_that.city,_that.country,_that.minPrice,_that.maxPrice,_that.minEntryRate,_that.minEntryPhotos,_that.currency,_that.avgRating,_that.reviewCount,_that.responseLabel,_that.online,_that.readyInMinutes,_that.answerWithinMinutes,_that.topNiches,_that.portfolioPhotoCount,_that.portfolioVideoCount);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ClientDiscoverCard extends ClientDiscoverCard {
  const _ClientDiscoverCard({@JsonKey(name: ClientDiscoverCard.proUserIdKey_) required this.proUserId, @JsonKey(name: ClientDiscoverCard.displayNameKey_) this.displayName, @JsonKey(name: ClientDiscoverCard.headlineKey_) this.headline, @JsonKey(name: ClientDiscoverCard.coverMediaAssetIdKey_) this.coverMediaAssetId, @JsonKey(name: ClientDiscoverCard.coverUrlKey_) this.coverUrl, @JsonKey(name: ClientDiscoverCard.cityKey_) this.city, @JsonKey(name: ClientDiscoverCard.countryKey_) this.country, @JsonKey(name: ClientDiscoverCard.minPriceKey_) this.minPrice, @JsonKey(name: ClientDiscoverCard.maxPriceKey_) this.maxPrice, @JsonKey(name: ClientDiscoverCard.minEntryRateKey_) this.minEntryRate, @JsonKey(name: ClientDiscoverCard.minEntryPhotosKey_) this.minEntryPhotos, @JsonKey(name: ClientDiscoverCard.currencyKey_) required this.currency, @JsonKey(name: ClientDiscoverCard.avgRatingKey_) required this.avgRating, @JsonKey(name: ClientDiscoverCard.reviewCountKey_) required this.reviewCount, @JsonKey(name: ClientDiscoverCard.responseLabelKey_) this.responseLabel, @JsonKey(name: ClientDiscoverCard.onlineKey_) this.online = false, @JsonKey(name: ClientDiscoverCard.readyInMinutesKey_) this.readyInMinutes, @JsonKey(name: ClientDiscoverCard.answerWithinMinutesKey_) this.answerWithinMinutes, @JsonKey(name: ClientDiscoverCard.topNichesKey_) final  List<Map<String, dynamic>>? topNiches, @JsonKey(name: ClientDiscoverCard.portfolioPhotoCountKey_) required this.portfolioPhotoCount, @JsonKey(name: ClientDiscoverCard.portfolioVideoCountKey_) required this.portfolioVideoCount}): _topNiches = topNiches,super._();
  factory _ClientDiscoverCard.fromJson(Map<String, dynamic> json) => _$ClientDiscoverCardFromJson(json);

/// proUserId
@override@JsonKey(name: ClientDiscoverCard.proUserIdKey_) final  String proUserId;
/// displayName
@override@JsonKey(name: ClientDiscoverCard.displayNameKey_) final  String? displayName;
/// headline
@override@JsonKey(name: ClientDiscoverCard.headlineKey_) final  String? headline;
/// coverMediaAssetId
@override@JsonKey(name: ClientDiscoverCard.coverMediaAssetIdKey_) final  String? coverMediaAssetId;
/// coverUrl
@override@JsonKey(name: ClientDiscoverCard.coverUrlKey_) final  String? coverUrl;
/// city
@override@JsonKey(name: ClientDiscoverCard.cityKey_) final  String? city;
/// country
@override@JsonKey(name: ClientDiscoverCard.countryKey_) final  String? country;
/// minPrice
@override@JsonKey(name: ClientDiscoverCard.minPriceKey_) final  String? minPrice;
/// maxPrice
@override@JsonKey(name: ClientDiscoverCard.maxPriceKey_) final  String? maxPrice;
/// minEntryRate
@override@JsonKey(name: ClientDiscoverCard.minEntryRateKey_) final  String? minEntryRate;
/// minEntryPhotos
@override@JsonKey(name: ClientDiscoverCard.minEntryPhotosKey_) final  int? minEntryPhotos;
/// currency
@override@JsonKey(name: ClientDiscoverCard.currencyKey_) final  String currency;
/// avgRating
@override@JsonKey(name: ClientDiscoverCard.avgRatingKey_) final  String avgRating;
/// reviewCount
@override@JsonKey(name: ClientDiscoverCard.reviewCountKey_) final  int reviewCount;
/// responseLabel
@override@JsonKey(name: ClientDiscoverCard.responseLabelKey_) final  String? responseLabel;
/// online
@override@JsonKey(name: ClientDiscoverCard.onlineKey_) final  bool online;
/// readyInMinutes
@override@JsonKey(name: ClientDiscoverCard.readyInMinutesKey_) final  int? readyInMinutes;
/// answerWithinMinutes
@override@JsonKey(name: ClientDiscoverCard.answerWithinMinutesKey_) final  int? answerWithinMinutes;
/// topNiches
 final  List<Map<String, dynamic>>? _topNiches;
/// topNiches
@override@JsonKey(name: ClientDiscoverCard.topNichesKey_) List<Map<String, dynamic>>? get topNiches {
  final value = _topNiches;
  if (value == null) return null;
  if (_topNiches is EqualUnmodifiableListView) return _topNiches;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// portfolioPhotoCount
@override@JsonKey(name: ClientDiscoverCard.portfolioPhotoCountKey_) final  int portfolioPhotoCount;
/// portfolioVideoCount
@override@JsonKey(name: ClientDiscoverCard.portfolioVideoCountKey_) final  int portfolioVideoCount;

/// Create a copy of ClientDiscoverCard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientDiscoverCardCopyWith<_ClientDiscoverCard> get copyWith => __$ClientDiscoverCardCopyWithImpl<_ClientDiscoverCard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientDiscoverCardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientDiscoverCard&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.headline, headline) || other.headline == headline)&&(identical(other.coverMediaAssetId, coverMediaAssetId) || other.coverMediaAssetId == coverMediaAssetId)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&(identical(other.minPrice, minPrice) || other.minPrice == minPrice)&&(identical(other.maxPrice, maxPrice) || other.maxPrice == maxPrice)&&(identical(other.minEntryRate, minEntryRate) || other.minEntryRate == minEntryRate)&&(identical(other.minEntryPhotos, minEntryPhotos) || other.minEntryPhotos == minEntryPhotos)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.avgRating, avgRating) || other.avgRating == avgRating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.responseLabel, responseLabel) || other.responseLabel == responseLabel)&&(identical(other.online, online) || other.online == online)&&(identical(other.readyInMinutes, readyInMinutes) || other.readyInMinutes == readyInMinutes)&&(identical(other.answerWithinMinutes, answerWithinMinutes) || other.answerWithinMinutes == answerWithinMinutes)&&const DeepCollectionEquality().equals(other._topNiches, _topNiches)&&(identical(other.portfolioPhotoCount, portfolioPhotoCount) || other.portfolioPhotoCount == portfolioPhotoCount)&&(identical(other.portfolioVideoCount, portfolioVideoCount) || other.portfolioVideoCount == portfolioVideoCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,proUserId,displayName,headline,coverMediaAssetId,coverUrl,city,country,minPrice,maxPrice,minEntryRate,minEntryPhotos,currency,avgRating,reviewCount,responseLabel,online,readyInMinutes,answerWithinMinutes,const DeepCollectionEquality().hash(_topNiches),portfolioPhotoCount,portfolioVideoCount]);

@override
String toString() {
  return 'ClientDiscoverCard(proUserId: $proUserId, displayName: $displayName, headline: $headline, coverMediaAssetId: $coverMediaAssetId, coverUrl: $coverUrl, city: $city, country: $country, minPrice: $minPrice, maxPrice: $maxPrice, minEntryRate: $minEntryRate, minEntryPhotos: $minEntryPhotos, currency: $currency, avgRating: $avgRating, reviewCount: $reviewCount, responseLabel: $responseLabel, online: $online, readyInMinutes: $readyInMinutes, answerWithinMinutes: $answerWithinMinutes, topNiches: $topNiches, portfolioPhotoCount: $portfolioPhotoCount, portfolioVideoCount: $portfolioVideoCount)';
}


}

/// @nodoc
abstract mixin class _$ClientDiscoverCardCopyWith<$Res> implements $ClientDiscoverCardCopyWith<$Res> {
  factory _$ClientDiscoverCardCopyWith(_ClientDiscoverCard value, $Res Function(_ClientDiscoverCard) _then) = __$ClientDiscoverCardCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ClientDiscoverCard.proUserIdKey_) String proUserId,@JsonKey(name: ClientDiscoverCard.displayNameKey_) String? displayName,@JsonKey(name: ClientDiscoverCard.headlineKey_) String? headline,@JsonKey(name: ClientDiscoverCard.coverMediaAssetIdKey_) String? coverMediaAssetId,@JsonKey(name: ClientDiscoverCard.coverUrlKey_) String? coverUrl,@JsonKey(name: ClientDiscoverCard.cityKey_) String? city,@JsonKey(name: ClientDiscoverCard.countryKey_) String? country,@JsonKey(name: ClientDiscoverCard.minPriceKey_) String? minPrice,@JsonKey(name: ClientDiscoverCard.maxPriceKey_) String? maxPrice,@JsonKey(name: ClientDiscoverCard.minEntryRateKey_) String? minEntryRate,@JsonKey(name: ClientDiscoverCard.minEntryPhotosKey_) int? minEntryPhotos,@JsonKey(name: ClientDiscoverCard.currencyKey_) String currency,@JsonKey(name: ClientDiscoverCard.avgRatingKey_) String avgRating,@JsonKey(name: ClientDiscoverCard.reviewCountKey_) int reviewCount,@JsonKey(name: ClientDiscoverCard.responseLabelKey_) String? responseLabel,@JsonKey(name: ClientDiscoverCard.onlineKey_) bool online,@JsonKey(name: ClientDiscoverCard.readyInMinutesKey_) int? readyInMinutes,@JsonKey(name: ClientDiscoverCard.answerWithinMinutesKey_) int? answerWithinMinutes,@JsonKey(name: ClientDiscoverCard.topNichesKey_) List<Map<String, dynamic>>? topNiches,@JsonKey(name: ClientDiscoverCard.portfolioPhotoCountKey_) int portfolioPhotoCount,@JsonKey(name: ClientDiscoverCard.portfolioVideoCountKey_) int portfolioVideoCount
});




}
/// @nodoc
class __$ClientDiscoverCardCopyWithImpl<$Res>
    implements _$ClientDiscoverCardCopyWith<$Res> {
  __$ClientDiscoverCardCopyWithImpl(this._self, this._then);

  final _ClientDiscoverCard _self;
  final $Res Function(_ClientDiscoverCard) _then;

/// Create a copy of ClientDiscoverCard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? proUserId = null,Object? displayName = freezed,Object? headline = freezed,Object? coverMediaAssetId = freezed,Object? coverUrl = freezed,Object? city = freezed,Object? country = freezed,Object? minPrice = freezed,Object? maxPrice = freezed,Object? minEntryRate = freezed,Object? minEntryPhotos = freezed,Object? currency = null,Object? avgRating = null,Object? reviewCount = null,Object? responseLabel = freezed,Object? online = null,Object? readyInMinutes = freezed,Object? answerWithinMinutes = freezed,Object? topNiches = freezed,Object? portfolioPhotoCount = null,Object? portfolioVideoCount = null,}) {
  return _then(_ClientDiscoverCard(
proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,headline: freezed == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String?,coverMediaAssetId: freezed == coverMediaAssetId ? _self.coverMediaAssetId : coverMediaAssetId // ignore: cast_nullable_to_non_nullable
as String?,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,minPrice: freezed == minPrice ? _self.minPrice : minPrice // ignore: cast_nullable_to_non_nullable
as String?,maxPrice: freezed == maxPrice ? _self.maxPrice : maxPrice // ignore: cast_nullable_to_non_nullable
as String?,minEntryRate: freezed == minEntryRate ? _self.minEntryRate : minEntryRate // ignore: cast_nullable_to_non_nullable
as String?,minEntryPhotos: freezed == minEntryPhotos ? _self.minEntryPhotos : minEntryPhotos // ignore: cast_nullable_to_non_nullable
as int?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,avgRating: null == avgRating ? _self.avgRating : avgRating // ignore: cast_nullable_to_non_nullable
as String,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,responseLabel: freezed == responseLabel ? _self.responseLabel : responseLabel // ignore: cast_nullable_to_non_nullable
as String?,online: null == online ? _self.online : online // ignore: cast_nullable_to_non_nullable
as bool,readyInMinutes: freezed == readyInMinutes ? _self.readyInMinutes : readyInMinutes // ignore: cast_nullable_to_non_nullable
as int?,answerWithinMinutes: freezed == answerWithinMinutes ? _self.answerWithinMinutes : answerWithinMinutes // ignore: cast_nullable_to_non_nullable
as int?,topNiches: freezed == topNiches ? _self._topNiches : topNiches // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>?,portfolioPhotoCount: null == portfolioPhotoCount ? _self.portfolioPhotoCount : portfolioPhotoCount // ignore: cast_nullable_to_non_nullable
as int,portfolioVideoCount: null == portfolioVideoCount ? _self.portfolioVideoCount : portfolioVideoCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
