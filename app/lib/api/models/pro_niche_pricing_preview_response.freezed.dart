// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pro_niche_pricing_preview_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProNichePricingPreviewResponse {

/// nicheId
@JsonKey(name: ProNichePricingPreviewResponse.nicheIdKey_) String get nicheId;/// nicheSlug
@JsonKey(name: ProNichePricingPreviewResponse.nicheSlugKey_) String get nicheSlug;/// nicheName
@JsonKey(name: ProNichePricingPreviewResponse.nicheNameKey_) String get nicheName;/// tier
@JsonKey(name: ProNichePricingPreviewResponse.tierKey_) String get tier;/// entryPrice
@JsonKey(name: ProNichePricingPreviewResponse.entryPriceKey_) String get entryPrice;/// currency
@JsonKey(name: ProNichePricingPreviewResponse.currencyKey_) String get currency;/// entryPriceMin
@JsonKey(name: ProNichePricingPreviewResponse.entryPriceMinKey_) String get entryPriceMin;/// entryPriceMax
@JsonKey(name: ProNichePricingPreviewResponse.entryPriceMaxKey_) String? get entryPriceMax;/// withinCap
@JsonKey(name: ProNichePricingPreviewResponse.withinCapKey_) bool get withinCap;/// curve
@JsonKey(name: ProNichePricingPreviewResponse.curveKey_) List<ProPricingCurvePoint>? get curve;
/// Create a copy of ProNichePricingPreviewResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProNichePricingPreviewResponseCopyWith<ProNichePricingPreviewResponse> get copyWith => _$ProNichePricingPreviewResponseCopyWithImpl<ProNichePricingPreviewResponse>(this as ProNichePricingPreviewResponse, _$identity);

  /// Serializes this ProNichePricingPreviewResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProNichePricingPreviewResponse&&(identical(other.nicheId, nicheId) || other.nicheId == nicheId)&&(identical(other.nicheSlug, nicheSlug) || other.nicheSlug == nicheSlug)&&(identical(other.nicheName, nicheName) || other.nicheName == nicheName)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.entryPrice, entryPrice) || other.entryPrice == entryPrice)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.entryPriceMin, entryPriceMin) || other.entryPriceMin == entryPriceMin)&&(identical(other.entryPriceMax, entryPriceMax) || other.entryPriceMax == entryPriceMax)&&(identical(other.withinCap, withinCap) || other.withinCap == withinCap)&&const DeepCollectionEquality().equals(other.curve, curve));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nicheId,nicheSlug,nicheName,tier,entryPrice,currency,entryPriceMin,entryPriceMax,withinCap,const DeepCollectionEquality().hash(curve));

@override
String toString() {
  return 'ProNichePricingPreviewResponse(nicheId: $nicheId, nicheSlug: $nicheSlug, nicheName: $nicheName, tier: $tier, entryPrice: $entryPrice, currency: $currency, entryPriceMin: $entryPriceMin, entryPriceMax: $entryPriceMax, withinCap: $withinCap, curve: $curve)';
}


}

/// @nodoc
abstract mixin class $ProNichePricingPreviewResponseCopyWith<$Res>  {
  factory $ProNichePricingPreviewResponseCopyWith(ProNichePricingPreviewResponse value, $Res Function(ProNichePricingPreviewResponse) _then) = _$ProNichePricingPreviewResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ProNichePricingPreviewResponse.nicheIdKey_) String nicheId,@JsonKey(name: ProNichePricingPreviewResponse.nicheSlugKey_) String nicheSlug,@JsonKey(name: ProNichePricingPreviewResponse.nicheNameKey_) String nicheName,@JsonKey(name: ProNichePricingPreviewResponse.tierKey_) String tier,@JsonKey(name: ProNichePricingPreviewResponse.entryPriceKey_) String entryPrice,@JsonKey(name: ProNichePricingPreviewResponse.currencyKey_) String currency,@JsonKey(name: ProNichePricingPreviewResponse.entryPriceMinKey_) String entryPriceMin,@JsonKey(name: ProNichePricingPreviewResponse.entryPriceMaxKey_) String? entryPriceMax,@JsonKey(name: ProNichePricingPreviewResponse.withinCapKey_) bool withinCap,@JsonKey(name: ProNichePricingPreviewResponse.curveKey_) List<ProPricingCurvePoint>? curve
});




}
/// @nodoc
class _$ProNichePricingPreviewResponseCopyWithImpl<$Res>
    implements $ProNichePricingPreviewResponseCopyWith<$Res> {
  _$ProNichePricingPreviewResponseCopyWithImpl(this._self, this._then);

  final ProNichePricingPreviewResponse _self;
  final $Res Function(ProNichePricingPreviewResponse) _then;

/// Create a copy of ProNichePricingPreviewResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nicheId = null,Object? nicheSlug = null,Object? nicheName = null,Object? tier = null,Object? entryPrice = null,Object? currency = null,Object? entryPriceMin = null,Object? entryPriceMax = freezed,Object? withinCap = null,Object? curve = freezed,}) {
  return _then(_self.copyWith(
nicheId: null == nicheId ? _self.nicheId : nicheId // ignore: cast_nullable_to_non_nullable
as String,nicheSlug: null == nicheSlug ? _self.nicheSlug : nicheSlug // ignore: cast_nullable_to_non_nullable
as String,nicheName: null == nicheName ? _self.nicheName : nicheName // ignore: cast_nullable_to_non_nullable
as String,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as String,entryPrice: null == entryPrice ? _self.entryPrice : entryPrice // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,entryPriceMin: null == entryPriceMin ? _self.entryPriceMin : entryPriceMin // ignore: cast_nullable_to_non_nullable
as String,entryPriceMax: freezed == entryPriceMax ? _self.entryPriceMax : entryPriceMax // ignore: cast_nullable_to_non_nullable
as String?,withinCap: null == withinCap ? _self.withinCap : withinCap // ignore: cast_nullable_to_non_nullable
as bool,curve: freezed == curve ? _self.curve : curve // ignore: cast_nullable_to_non_nullable
as List<ProPricingCurvePoint>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProNichePricingPreviewResponse].
extension ProNichePricingPreviewResponsePatterns on ProNichePricingPreviewResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProNichePricingPreviewResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProNichePricingPreviewResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProNichePricingPreviewResponse value)  $default,){
final _that = this;
switch (_that) {
case _ProNichePricingPreviewResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProNichePricingPreviewResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ProNichePricingPreviewResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ProNichePricingPreviewResponse.nicheIdKey_)  String nicheId, @JsonKey(name: ProNichePricingPreviewResponse.nicheSlugKey_)  String nicheSlug, @JsonKey(name: ProNichePricingPreviewResponse.nicheNameKey_)  String nicheName, @JsonKey(name: ProNichePricingPreviewResponse.tierKey_)  String tier, @JsonKey(name: ProNichePricingPreviewResponse.entryPriceKey_)  String entryPrice, @JsonKey(name: ProNichePricingPreviewResponse.currencyKey_)  String currency, @JsonKey(name: ProNichePricingPreviewResponse.entryPriceMinKey_)  String entryPriceMin, @JsonKey(name: ProNichePricingPreviewResponse.entryPriceMaxKey_)  String? entryPriceMax, @JsonKey(name: ProNichePricingPreviewResponse.withinCapKey_)  bool withinCap, @JsonKey(name: ProNichePricingPreviewResponse.curveKey_)  List<ProPricingCurvePoint>? curve)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProNichePricingPreviewResponse() when $default != null:
return $default(_that.nicheId,_that.nicheSlug,_that.nicheName,_that.tier,_that.entryPrice,_that.currency,_that.entryPriceMin,_that.entryPriceMax,_that.withinCap,_that.curve);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ProNichePricingPreviewResponse.nicheIdKey_)  String nicheId, @JsonKey(name: ProNichePricingPreviewResponse.nicheSlugKey_)  String nicheSlug, @JsonKey(name: ProNichePricingPreviewResponse.nicheNameKey_)  String nicheName, @JsonKey(name: ProNichePricingPreviewResponse.tierKey_)  String tier, @JsonKey(name: ProNichePricingPreviewResponse.entryPriceKey_)  String entryPrice, @JsonKey(name: ProNichePricingPreviewResponse.currencyKey_)  String currency, @JsonKey(name: ProNichePricingPreviewResponse.entryPriceMinKey_)  String entryPriceMin, @JsonKey(name: ProNichePricingPreviewResponse.entryPriceMaxKey_)  String? entryPriceMax, @JsonKey(name: ProNichePricingPreviewResponse.withinCapKey_)  bool withinCap, @JsonKey(name: ProNichePricingPreviewResponse.curveKey_)  List<ProPricingCurvePoint>? curve)  $default,) {final _that = this;
switch (_that) {
case _ProNichePricingPreviewResponse():
return $default(_that.nicheId,_that.nicheSlug,_that.nicheName,_that.tier,_that.entryPrice,_that.currency,_that.entryPriceMin,_that.entryPriceMax,_that.withinCap,_that.curve);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ProNichePricingPreviewResponse.nicheIdKey_)  String nicheId, @JsonKey(name: ProNichePricingPreviewResponse.nicheSlugKey_)  String nicheSlug, @JsonKey(name: ProNichePricingPreviewResponse.nicheNameKey_)  String nicheName, @JsonKey(name: ProNichePricingPreviewResponse.tierKey_)  String tier, @JsonKey(name: ProNichePricingPreviewResponse.entryPriceKey_)  String entryPrice, @JsonKey(name: ProNichePricingPreviewResponse.currencyKey_)  String currency, @JsonKey(name: ProNichePricingPreviewResponse.entryPriceMinKey_)  String entryPriceMin, @JsonKey(name: ProNichePricingPreviewResponse.entryPriceMaxKey_)  String? entryPriceMax, @JsonKey(name: ProNichePricingPreviewResponse.withinCapKey_)  bool withinCap, @JsonKey(name: ProNichePricingPreviewResponse.curveKey_)  List<ProPricingCurvePoint>? curve)?  $default,) {final _that = this;
switch (_that) {
case _ProNichePricingPreviewResponse() when $default != null:
return $default(_that.nicheId,_that.nicheSlug,_that.nicheName,_that.tier,_that.entryPrice,_that.currency,_that.entryPriceMin,_that.entryPriceMax,_that.withinCap,_that.curve);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ProNichePricingPreviewResponse extends ProNichePricingPreviewResponse {
  const _ProNichePricingPreviewResponse({@JsonKey(name: ProNichePricingPreviewResponse.nicheIdKey_) required this.nicheId, @JsonKey(name: ProNichePricingPreviewResponse.nicheSlugKey_) required this.nicheSlug, @JsonKey(name: ProNichePricingPreviewResponse.nicheNameKey_) required this.nicheName, @JsonKey(name: ProNichePricingPreviewResponse.tierKey_) required this.tier, @JsonKey(name: ProNichePricingPreviewResponse.entryPriceKey_) required this.entryPrice, @JsonKey(name: ProNichePricingPreviewResponse.currencyKey_) required this.currency, @JsonKey(name: ProNichePricingPreviewResponse.entryPriceMinKey_) required this.entryPriceMin, @JsonKey(name: ProNichePricingPreviewResponse.entryPriceMaxKey_) this.entryPriceMax, @JsonKey(name: ProNichePricingPreviewResponse.withinCapKey_) required this.withinCap, @JsonKey(name: ProNichePricingPreviewResponse.curveKey_) final  List<ProPricingCurvePoint>? curve}): _curve = curve,super._();
  factory _ProNichePricingPreviewResponse.fromJson(Map<String, dynamic> json) => _$ProNichePricingPreviewResponseFromJson(json);

/// nicheId
@override@JsonKey(name: ProNichePricingPreviewResponse.nicheIdKey_) final  String nicheId;
/// nicheSlug
@override@JsonKey(name: ProNichePricingPreviewResponse.nicheSlugKey_) final  String nicheSlug;
/// nicheName
@override@JsonKey(name: ProNichePricingPreviewResponse.nicheNameKey_) final  String nicheName;
/// tier
@override@JsonKey(name: ProNichePricingPreviewResponse.tierKey_) final  String tier;
/// entryPrice
@override@JsonKey(name: ProNichePricingPreviewResponse.entryPriceKey_) final  String entryPrice;
/// currency
@override@JsonKey(name: ProNichePricingPreviewResponse.currencyKey_) final  String currency;
/// entryPriceMin
@override@JsonKey(name: ProNichePricingPreviewResponse.entryPriceMinKey_) final  String entryPriceMin;
/// entryPriceMax
@override@JsonKey(name: ProNichePricingPreviewResponse.entryPriceMaxKey_) final  String? entryPriceMax;
/// withinCap
@override@JsonKey(name: ProNichePricingPreviewResponse.withinCapKey_) final  bool withinCap;
/// curve
 final  List<ProPricingCurvePoint>? _curve;
/// curve
@override@JsonKey(name: ProNichePricingPreviewResponse.curveKey_) List<ProPricingCurvePoint>? get curve {
  final value = _curve;
  if (value == null) return null;
  if (_curve is EqualUnmodifiableListView) return _curve;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ProNichePricingPreviewResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProNichePricingPreviewResponseCopyWith<_ProNichePricingPreviewResponse> get copyWith => __$ProNichePricingPreviewResponseCopyWithImpl<_ProNichePricingPreviewResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProNichePricingPreviewResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProNichePricingPreviewResponse&&(identical(other.nicheId, nicheId) || other.nicheId == nicheId)&&(identical(other.nicheSlug, nicheSlug) || other.nicheSlug == nicheSlug)&&(identical(other.nicheName, nicheName) || other.nicheName == nicheName)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.entryPrice, entryPrice) || other.entryPrice == entryPrice)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.entryPriceMin, entryPriceMin) || other.entryPriceMin == entryPriceMin)&&(identical(other.entryPriceMax, entryPriceMax) || other.entryPriceMax == entryPriceMax)&&(identical(other.withinCap, withinCap) || other.withinCap == withinCap)&&const DeepCollectionEquality().equals(other._curve, _curve));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nicheId,nicheSlug,nicheName,tier,entryPrice,currency,entryPriceMin,entryPriceMax,withinCap,const DeepCollectionEquality().hash(_curve));

@override
String toString() {
  return 'ProNichePricingPreviewResponse(nicheId: $nicheId, nicheSlug: $nicheSlug, nicheName: $nicheName, tier: $tier, entryPrice: $entryPrice, currency: $currency, entryPriceMin: $entryPriceMin, entryPriceMax: $entryPriceMax, withinCap: $withinCap, curve: $curve)';
}


}

/// @nodoc
abstract mixin class _$ProNichePricingPreviewResponseCopyWith<$Res> implements $ProNichePricingPreviewResponseCopyWith<$Res> {
  factory _$ProNichePricingPreviewResponseCopyWith(_ProNichePricingPreviewResponse value, $Res Function(_ProNichePricingPreviewResponse) _then) = __$ProNichePricingPreviewResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ProNichePricingPreviewResponse.nicheIdKey_) String nicheId,@JsonKey(name: ProNichePricingPreviewResponse.nicheSlugKey_) String nicheSlug,@JsonKey(name: ProNichePricingPreviewResponse.nicheNameKey_) String nicheName,@JsonKey(name: ProNichePricingPreviewResponse.tierKey_) String tier,@JsonKey(name: ProNichePricingPreviewResponse.entryPriceKey_) String entryPrice,@JsonKey(name: ProNichePricingPreviewResponse.currencyKey_) String currency,@JsonKey(name: ProNichePricingPreviewResponse.entryPriceMinKey_) String entryPriceMin,@JsonKey(name: ProNichePricingPreviewResponse.entryPriceMaxKey_) String? entryPriceMax,@JsonKey(name: ProNichePricingPreviewResponse.withinCapKey_) bool withinCap,@JsonKey(name: ProNichePricingPreviewResponse.curveKey_) List<ProPricingCurvePoint>? curve
});




}
/// @nodoc
class __$ProNichePricingPreviewResponseCopyWithImpl<$Res>
    implements _$ProNichePricingPreviewResponseCopyWith<$Res> {
  __$ProNichePricingPreviewResponseCopyWithImpl(this._self, this._then);

  final _ProNichePricingPreviewResponse _self;
  final $Res Function(_ProNichePricingPreviewResponse) _then;

/// Create a copy of ProNichePricingPreviewResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nicheId = null,Object? nicheSlug = null,Object? nicheName = null,Object? tier = null,Object? entryPrice = null,Object? currency = null,Object? entryPriceMin = null,Object? entryPriceMax = freezed,Object? withinCap = null,Object? curve = freezed,}) {
  return _then(_ProNichePricingPreviewResponse(
nicheId: null == nicheId ? _self.nicheId : nicheId // ignore: cast_nullable_to_non_nullable
as String,nicheSlug: null == nicheSlug ? _self.nicheSlug : nicheSlug // ignore: cast_nullable_to_non_nullable
as String,nicheName: null == nicheName ? _self.nicheName : nicheName // ignore: cast_nullable_to_non_nullable
as String,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as String,entryPrice: null == entryPrice ? _self.entryPrice : entryPrice // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,entryPriceMin: null == entryPriceMin ? _self.entryPriceMin : entryPriceMin // ignore: cast_nullable_to_non_nullable
as String,entryPriceMax: freezed == entryPriceMax ? _self.entryPriceMax : entryPriceMax // ignore: cast_nullable_to_non_nullable
as String?,withinCap: null == withinCap ? _self.withinCap : withinCap // ignore: cast_nullable_to_non_nullable
as bool,curve: freezed == curve ? _self._curve : curve // ignore: cast_nullable_to_non_nullable
as List<ProPricingCurvePoint>?,
  ));
}


}

// dart format on
