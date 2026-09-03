// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pro_package_create_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProPackageCreateRequest {

/// title
@JsonKey(name: ProPackageCreateRequest.titleKey_) String get title;/// nicheId
@JsonKey(name: ProPackageCreateRequest.nicheIdKey_) String? get nicheId;/// nicheSlug
@JsonKey(name: ProPackageCreateRequest.nicheSlugKey_) String? get nicheSlug;/// description
@JsonKey(name: ProPackageCreateRequest.descriptionKey_) String? get description;/// durationMinutes
@JsonKey(name: ProPackageCreateRequest.durationMinutesKey_) int get durationMinutes;/// price
@JsonKey(name: ProPackageCreateRequest.priceKey_) dynamic get price;/// currency
@JsonKey(name: ProPackageCreateRequest.currencyKey_) String get currency;/// includedPhotos
@JsonKey(name: ProPackageCreateRequest.includedPhotosKey_) int get includedPhotos;/// extraPhotoPrice
@JsonKey(name: ProPackageCreateRequest.extraPhotoPriceKey_) dynamic get extraPhotoPrice;/// proofsSlaDays
@JsonKey(name: ProPackageCreateRequest.proofsSlaDaysKey_) int get proofsSlaDays;/// finalsSlaDays
@JsonKey(name: ProPackageCreateRequest.finalsSlaDaysKey_) int get finalsSlaDays;/// addons
@JsonKey(name: ProPackageCreateRequest.addonsKey_) List<Map<String, dynamic>>? get addons;
/// Create a copy of ProPackageCreateRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProPackageCreateRequestCopyWith<ProPackageCreateRequest> get copyWith => _$ProPackageCreateRequestCopyWithImpl<ProPackageCreateRequest>(this as ProPackageCreateRequest, _$identity);

  /// Serializes this ProPackageCreateRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProPackageCreateRequest&&(identical(other.title, title) || other.title == title)&&(identical(other.nicheId, nicheId) || other.nicheId == nicheId)&&(identical(other.nicheSlug, nicheSlug) || other.nicheSlug == nicheSlug)&&(identical(other.description, description) || other.description == description)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&const DeepCollectionEquality().equals(other.price, price)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.includedPhotos, includedPhotos) || other.includedPhotos == includedPhotos)&&const DeepCollectionEquality().equals(other.extraPhotoPrice, extraPhotoPrice)&&(identical(other.proofsSlaDays, proofsSlaDays) || other.proofsSlaDays == proofsSlaDays)&&(identical(other.finalsSlaDays, finalsSlaDays) || other.finalsSlaDays == finalsSlaDays)&&const DeepCollectionEquality().equals(other.addons, addons));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,nicheId,nicheSlug,description,durationMinutes,const DeepCollectionEquality().hash(price),currency,includedPhotos,const DeepCollectionEquality().hash(extraPhotoPrice),proofsSlaDays,finalsSlaDays,const DeepCollectionEquality().hash(addons));

@override
String toString() {
  return 'ProPackageCreateRequest(title: $title, nicheId: $nicheId, nicheSlug: $nicheSlug, description: $description, durationMinutes: $durationMinutes, price: $price, currency: $currency, includedPhotos: $includedPhotos, extraPhotoPrice: $extraPhotoPrice, proofsSlaDays: $proofsSlaDays, finalsSlaDays: $finalsSlaDays, addons: $addons)';
}


}

/// @nodoc
abstract mixin class $ProPackageCreateRequestCopyWith<$Res>  {
  factory $ProPackageCreateRequestCopyWith(ProPackageCreateRequest value, $Res Function(ProPackageCreateRequest) _then) = _$ProPackageCreateRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ProPackageCreateRequest.titleKey_) String title,@JsonKey(name: ProPackageCreateRequest.nicheIdKey_) String? nicheId,@JsonKey(name: ProPackageCreateRequest.nicheSlugKey_) String? nicheSlug,@JsonKey(name: ProPackageCreateRequest.descriptionKey_) String? description,@JsonKey(name: ProPackageCreateRequest.durationMinutesKey_) int durationMinutes,@JsonKey(name: ProPackageCreateRequest.priceKey_) dynamic price,@JsonKey(name: ProPackageCreateRequest.currencyKey_) String currency,@JsonKey(name: ProPackageCreateRequest.includedPhotosKey_) int includedPhotos,@JsonKey(name: ProPackageCreateRequest.extraPhotoPriceKey_) dynamic extraPhotoPrice,@JsonKey(name: ProPackageCreateRequest.proofsSlaDaysKey_) int proofsSlaDays,@JsonKey(name: ProPackageCreateRequest.finalsSlaDaysKey_) int finalsSlaDays,@JsonKey(name: ProPackageCreateRequest.addonsKey_) List<Map<String, dynamic>>? addons
});




}
/// @nodoc
class _$ProPackageCreateRequestCopyWithImpl<$Res>
    implements $ProPackageCreateRequestCopyWith<$Res> {
  _$ProPackageCreateRequestCopyWithImpl(this._self, this._then);

  final ProPackageCreateRequest _self;
  final $Res Function(ProPackageCreateRequest) _then;

/// Create a copy of ProPackageCreateRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? nicheId = freezed,Object? nicheSlug = freezed,Object? description = freezed,Object? durationMinutes = null,Object? price = freezed,Object? currency = null,Object? includedPhotos = null,Object? extraPhotoPrice = freezed,Object? proofsSlaDays = null,Object? finalsSlaDays = null,Object? addons = freezed,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,nicheId: freezed == nicheId ? _self.nicheId : nicheId // ignore: cast_nullable_to_non_nullable
as String?,nicheSlug: freezed == nicheSlug ? _self.nicheSlug : nicheSlug // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as dynamic,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,includedPhotos: null == includedPhotos ? _self.includedPhotos : includedPhotos // ignore: cast_nullable_to_non_nullable
as int,extraPhotoPrice: freezed == extraPhotoPrice ? _self.extraPhotoPrice : extraPhotoPrice // ignore: cast_nullable_to_non_nullable
as dynamic,proofsSlaDays: null == proofsSlaDays ? _self.proofsSlaDays : proofsSlaDays // ignore: cast_nullable_to_non_nullable
as int,finalsSlaDays: null == finalsSlaDays ? _self.finalsSlaDays : finalsSlaDays // ignore: cast_nullable_to_non_nullable
as int,addons: freezed == addons ? _self.addons : addons // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProPackageCreateRequest].
extension ProPackageCreateRequestPatterns on ProPackageCreateRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProPackageCreateRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProPackageCreateRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProPackageCreateRequest value)  $default,){
final _that = this;
switch (_that) {
case _ProPackageCreateRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProPackageCreateRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ProPackageCreateRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ProPackageCreateRequest.titleKey_)  String title, @JsonKey(name: ProPackageCreateRequest.nicheIdKey_)  String? nicheId, @JsonKey(name: ProPackageCreateRequest.nicheSlugKey_)  String? nicheSlug, @JsonKey(name: ProPackageCreateRequest.descriptionKey_)  String? description, @JsonKey(name: ProPackageCreateRequest.durationMinutesKey_)  int durationMinutes, @JsonKey(name: ProPackageCreateRequest.priceKey_)  dynamic price, @JsonKey(name: ProPackageCreateRequest.currencyKey_)  String currency, @JsonKey(name: ProPackageCreateRequest.includedPhotosKey_)  int includedPhotos, @JsonKey(name: ProPackageCreateRequest.extraPhotoPriceKey_)  dynamic extraPhotoPrice, @JsonKey(name: ProPackageCreateRequest.proofsSlaDaysKey_)  int proofsSlaDays, @JsonKey(name: ProPackageCreateRequest.finalsSlaDaysKey_)  int finalsSlaDays, @JsonKey(name: ProPackageCreateRequest.addonsKey_)  List<Map<String, dynamic>>? addons)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProPackageCreateRequest() when $default != null:
return $default(_that.title,_that.nicheId,_that.nicheSlug,_that.description,_that.durationMinutes,_that.price,_that.currency,_that.includedPhotos,_that.extraPhotoPrice,_that.proofsSlaDays,_that.finalsSlaDays,_that.addons);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ProPackageCreateRequest.titleKey_)  String title, @JsonKey(name: ProPackageCreateRequest.nicheIdKey_)  String? nicheId, @JsonKey(name: ProPackageCreateRequest.nicheSlugKey_)  String? nicheSlug, @JsonKey(name: ProPackageCreateRequest.descriptionKey_)  String? description, @JsonKey(name: ProPackageCreateRequest.durationMinutesKey_)  int durationMinutes, @JsonKey(name: ProPackageCreateRequest.priceKey_)  dynamic price, @JsonKey(name: ProPackageCreateRequest.currencyKey_)  String currency, @JsonKey(name: ProPackageCreateRequest.includedPhotosKey_)  int includedPhotos, @JsonKey(name: ProPackageCreateRequest.extraPhotoPriceKey_)  dynamic extraPhotoPrice, @JsonKey(name: ProPackageCreateRequest.proofsSlaDaysKey_)  int proofsSlaDays, @JsonKey(name: ProPackageCreateRequest.finalsSlaDaysKey_)  int finalsSlaDays, @JsonKey(name: ProPackageCreateRequest.addonsKey_)  List<Map<String, dynamic>>? addons)  $default,) {final _that = this;
switch (_that) {
case _ProPackageCreateRequest():
return $default(_that.title,_that.nicheId,_that.nicheSlug,_that.description,_that.durationMinutes,_that.price,_that.currency,_that.includedPhotos,_that.extraPhotoPrice,_that.proofsSlaDays,_that.finalsSlaDays,_that.addons);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ProPackageCreateRequest.titleKey_)  String title, @JsonKey(name: ProPackageCreateRequest.nicheIdKey_)  String? nicheId, @JsonKey(name: ProPackageCreateRequest.nicheSlugKey_)  String? nicheSlug, @JsonKey(name: ProPackageCreateRequest.descriptionKey_)  String? description, @JsonKey(name: ProPackageCreateRequest.durationMinutesKey_)  int durationMinutes, @JsonKey(name: ProPackageCreateRequest.priceKey_)  dynamic price, @JsonKey(name: ProPackageCreateRequest.currencyKey_)  String currency, @JsonKey(name: ProPackageCreateRequest.includedPhotosKey_)  int includedPhotos, @JsonKey(name: ProPackageCreateRequest.extraPhotoPriceKey_)  dynamic extraPhotoPrice, @JsonKey(name: ProPackageCreateRequest.proofsSlaDaysKey_)  int proofsSlaDays, @JsonKey(name: ProPackageCreateRequest.finalsSlaDaysKey_)  int finalsSlaDays, @JsonKey(name: ProPackageCreateRequest.addonsKey_)  List<Map<String, dynamic>>? addons)?  $default,) {final _that = this;
switch (_that) {
case _ProPackageCreateRequest() when $default != null:
return $default(_that.title,_that.nicheId,_that.nicheSlug,_that.description,_that.durationMinutes,_that.price,_that.currency,_that.includedPhotos,_that.extraPhotoPrice,_that.proofsSlaDays,_that.finalsSlaDays,_that.addons);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ProPackageCreateRequest extends ProPackageCreateRequest {
  const _ProPackageCreateRequest({@JsonKey(name: ProPackageCreateRequest.titleKey_) required this.title, @JsonKey(name: ProPackageCreateRequest.nicheIdKey_) this.nicheId, @JsonKey(name: ProPackageCreateRequest.nicheSlugKey_) this.nicheSlug, @JsonKey(name: ProPackageCreateRequest.descriptionKey_) this.description, @JsonKey(name: ProPackageCreateRequest.durationMinutesKey_) required this.durationMinutes, @JsonKey(name: ProPackageCreateRequest.priceKey_) required this.price, @JsonKey(name: ProPackageCreateRequest.currencyKey_) this.currency = 'EUR', @JsonKey(name: ProPackageCreateRequest.includedPhotosKey_) required this.includedPhotos, @JsonKey(name: ProPackageCreateRequest.extraPhotoPriceKey_) required this.extraPhotoPrice, @JsonKey(name: ProPackageCreateRequest.proofsSlaDaysKey_) this.proofsSlaDays = 3, @JsonKey(name: ProPackageCreateRequest.finalsSlaDaysKey_) this.finalsSlaDays = 7, @JsonKey(name: ProPackageCreateRequest.addonsKey_) final  List<Map<String, dynamic>>? addons}): _addons = addons,super._();
  factory _ProPackageCreateRequest.fromJson(Map<String, dynamic> json) => _$ProPackageCreateRequestFromJson(json);

/// title
@override@JsonKey(name: ProPackageCreateRequest.titleKey_) final  String title;
/// nicheId
@override@JsonKey(name: ProPackageCreateRequest.nicheIdKey_) final  String? nicheId;
/// nicheSlug
@override@JsonKey(name: ProPackageCreateRequest.nicheSlugKey_) final  String? nicheSlug;
/// description
@override@JsonKey(name: ProPackageCreateRequest.descriptionKey_) final  String? description;
/// durationMinutes
@override@JsonKey(name: ProPackageCreateRequest.durationMinutesKey_) final  int durationMinutes;
/// price
@override@JsonKey(name: ProPackageCreateRequest.priceKey_) final  dynamic price;
/// currency
@override@JsonKey(name: ProPackageCreateRequest.currencyKey_) final  String currency;
/// includedPhotos
@override@JsonKey(name: ProPackageCreateRequest.includedPhotosKey_) final  int includedPhotos;
/// extraPhotoPrice
@override@JsonKey(name: ProPackageCreateRequest.extraPhotoPriceKey_) final  dynamic extraPhotoPrice;
/// proofsSlaDays
@override@JsonKey(name: ProPackageCreateRequest.proofsSlaDaysKey_) final  int proofsSlaDays;
/// finalsSlaDays
@override@JsonKey(name: ProPackageCreateRequest.finalsSlaDaysKey_) final  int finalsSlaDays;
/// addons
 final  List<Map<String, dynamic>>? _addons;
/// addons
@override@JsonKey(name: ProPackageCreateRequest.addonsKey_) List<Map<String, dynamic>>? get addons {
  final value = _addons;
  if (value == null) return null;
  if (_addons is EqualUnmodifiableListView) return _addons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ProPackageCreateRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProPackageCreateRequestCopyWith<_ProPackageCreateRequest> get copyWith => __$ProPackageCreateRequestCopyWithImpl<_ProPackageCreateRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProPackageCreateRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProPackageCreateRequest&&(identical(other.title, title) || other.title == title)&&(identical(other.nicheId, nicheId) || other.nicheId == nicheId)&&(identical(other.nicheSlug, nicheSlug) || other.nicheSlug == nicheSlug)&&(identical(other.description, description) || other.description == description)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&const DeepCollectionEquality().equals(other.price, price)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.includedPhotos, includedPhotos) || other.includedPhotos == includedPhotos)&&const DeepCollectionEquality().equals(other.extraPhotoPrice, extraPhotoPrice)&&(identical(other.proofsSlaDays, proofsSlaDays) || other.proofsSlaDays == proofsSlaDays)&&(identical(other.finalsSlaDays, finalsSlaDays) || other.finalsSlaDays == finalsSlaDays)&&const DeepCollectionEquality().equals(other._addons, _addons));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,nicheId,nicheSlug,description,durationMinutes,const DeepCollectionEquality().hash(price),currency,includedPhotos,const DeepCollectionEquality().hash(extraPhotoPrice),proofsSlaDays,finalsSlaDays,const DeepCollectionEquality().hash(_addons));

@override
String toString() {
  return 'ProPackageCreateRequest(title: $title, nicheId: $nicheId, nicheSlug: $nicheSlug, description: $description, durationMinutes: $durationMinutes, price: $price, currency: $currency, includedPhotos: $includedPhotos, extraPhotoPrice: $extraPhotoPrice, proofsSlaDays: $proofsSlaDays, finalsSlaDays: $finalsSlaDays, addons: $addons)';
}


}

/// @nodoc
abstract mixin class _$ProPackageCreateRequestCopyWith<$Res> implements $ProPackageCreateRequestCopyWith<$Res> {
  factory _$ProPackageCreateRequestCopyWith(_ProPackageCreateRequest value, $Res Function(_ProPackageCreateRequest) _then) = __$ProPackageCreateRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ProPackageCreateRequest.titleKey_) String title,@JsonKey(name: ProPackageCreateRequest.nicheIdKey_) String? nicheId,@JsonKey(name: ProPackageCreateRequest.nicheSlugKey_) String? nicheSlug,@JsonKey(name: ProPackageCreateRequest.descriptionKey_) String? description,@JsonKey(name: ProPackageCreateRequest.durationMinutesKey_) int durationMinutes,@JsonKey(name: ProPackageCreateRequest.priceKey_) dynamic price,@JsonKey(name: ProPackageCreateRequest.currencyKey_) String currency,@JsonKey(name: ProPackageCreateRequest.includedPhotosKey_) int includedPhotos,@JsonKey(name: ProPackageCreateRequest.extraPhotoPriceKey_) dynamic extraPhotoPrice,@JsonKey(name: ProPackageCreateRequest.proofsSlaDaysKey_) int proofsSlaDays,@JsonKey(name: ProPackageCreateRequest.finalsSlaDaysKey_) int finalsSlaDays,@JsonKey(name: ProPackageCreateRequest.addonsKey_) List<Map<String, dynamic>>? addons
});




}
/// @nodoc
class __$ProPackageCreateRequestCopyWithImpl<$Res>
    implements _$ProPackageCreateRequestCopyWith<$Res> {
  __$ProPackageCreateRequestCopyWithImpl(this._self, this._then);

  final _ProPackageCreateRequest _self;
  final $Res Function(_ProPackageCreateRequest) _then;

/// Create a copy of ProPackageCreateRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? nicheId = freezed,Object? nicheSlug = freezed,Object? description = freezed,Object? durationMinutes = null,Object? price = freezed,Object? currency = null,Object? includedPhotos = null,Object? extraPhotoPrice = freezed,Object? proofsSlaDays = null,Object? finalsSlaDays = null,Object? addons = freezed,}) {
  return _then(_ProPackageCreateRequest(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,nicheId: freezed == nicheId ? _self.nicheId : nicheId // ignore: cast_nullable_to_non_nullable
as String?,nicheSlug: freezed == nicheSlug ? _self.nicheSlug : nicheSlug // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as dynamic,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,includedPhotos: null == includedPhotos ? _self.includedPhotos : includedPhotos // ignore: cast_nullable_to_non_nullable
as int,extraPhotoPrice: freezed == extraPhotoPrice ? _self.extraPhotoPrice : extraPhotoPrice // ignore: cast_nullable_to_non_nullable
as dynamic,proofsSlaDays: null == proofsSlaDays ? _self.proofsSlaDays : proofsSlaDays // ignore: cast_nullable_to_non_nullable
as int,finalsSlaDays: null == finalsSlaDays ? _self.finalsSlaDays : finalsSlaDays // ignore: cast_nullable_to_non_nullable
as int,addons: freezed == addons ? _self._addons : addons // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>?,
  ));
}


}

// dart format on
