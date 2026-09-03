// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pro_package_update_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProPackageUpdateRequest {

/// title
@JsonKey(name: ProPackageUpdateRequest.titleKey_) String? get title;/// nicheId
@JsonKey(name: ProPackageUpdateRequest.nicheIdKey_) String? get nicheId;/// nicheSlug
@JsonKey(name: ProPackageUpdateRequest.nicheSlugKey_) String? get nicheSlug;/// description
@JsonKey(name: ProPackageUpdateRequest.descriptionKey_) String? get description;/// durationMinutes
@JsonKey(name: ProPackageUpdateRequest.durationMinutesKey_) int? get durationMinutes;/// price
@JsonKey(name: ProPackageUpdateRequest.priceKey_) dynamic? get price;/// currency
@JsonKey(name: ProPackageUpdateRequest.currencyKey_) String? get currency;/// includedPhotos
@JsonKey(name: ProPackageUpdateRequest.includedPhotosKey_) int? get includedPhotos;/// extraPhotoPrice
@JsonKey(name: ProPackageUpdateRequest.extraPhotoPriceKey_) dynamic? get extraPhotoPrice;/// proofsSlaDays
@JsonKey(name: ProPackageUpdateRequest.proofsSlaDaysKey_) int? get proofsSlaDays;/// finalsSlaDays
@JsonKey(name: ProPackageUpdateRequest.finalsSlaDaysKey_) int? get finalsSlaDays;/// addons
@JsonKey(name: ProPackageUpdateRequest.addonsKey_) List<Map<String, dynamic>>? get addons;/// isActive
@JsonKey(name: ProPackageUpdateRequest.isActiveKey_) bool? get isActive;
/// Create a copy of ProPackageUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProPackageUpdateRequestCopyWith<ProPackageUpdateRequest> get copyWith => _$ProPackageUpdateRequestCopyWithImpl<ProPackageUpdateRequest>(this as ProPackageUpdateRequest, _$identity);

  /// Serializes this ProPackageUpdateRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProPackageUpdateRequest&&(identical(other.title, title) || other.title == title)&&(identical(other.nicheId, nicheId) || other.nicheId == nicheId)&&(identical(other.nicheSlug, nicheSlug) || other.nicheSlug == nicheSlug)&&(identical(other.description, description) || other.description == description)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&const DeepCollectionEquality().equals(other.price, price)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.includedPhotos, includedPhotos) || other.includedPhotos == includedPhotos)&&const DeepCollectionEquality().equals(other.extraPhotoPrice, extraPhotoPrice)&&(identical(other.proofsSlaDays, proofsSlaDays) || other.proofsSlaDays == proofsSlaDays)&&(identical(other.finalsSlaDays, finalsSlaDays) || other.finalsSlaDays == finalsSlaDays)&&const DeepCollectionEquality().equals(other.addons, addons)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,nicheId,nicheSlug,description,durationMinutes,const DeepCollectionEquality().hash(price),currency,includedPhotos,const DeepCollectionEquality().hash(extraPhotoPrice),proofsSlaDays,finalsSlaDays,const DeepCollectionEquality().hash(addons),isActive);

@override
String toString() {
  return 'ProPackageUpdateRequest(title: $title, nicheId: $nicheId, nicheSlug: $nicheSlug, description: $description, durationMinutes: $durationMinutes, price: $price, currency: $currency, includedPhotos: $includedPhotos, extraPhotoPrice: $extraPhotoPrice, proofsSlaDays: $proofsSlaDays, finalsSlaDays: $finalsSlaDays, addons: $addons, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class $ProPackageUpdateRequestCopyWith<$Res>  {
  factory $ProPackageUpdateRequestCopyWith(ProPackageUpdateRequest value, $Res Function(ProPackageUpdateRequest) _then) = _$ProPackageUpdateRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ProPackageUpdateRequest.titleKey_) String? title,@JsonKey(name: ProPackageUpdateRequest.nicheIdKey_) String? nicheId,@JsonKey(name: ProPackageUpdateRequest.nicheSlugKey_) String? nicheSlug,@JsonKey(name: ProPackageUpdateRequest.descriptionKey_) String? description,@JsonKey(name: ProPackageUpdateRequest.durationMinutesKey_) int? durationMinutes,@JsonKey(name: ProPackageUpdateRequest.priceKey_) dynamic? price,@JsonKey(name: ProPackageUpdateRequest.currencyKey_) String? currency,@JsonKey(name: ProPackageUpdateRequest.includedPhotosKey_) int? includedPhotos,@JsonKey(name: ProPackageUpdateRequest.extraPhotoPriceKey_) dynamic? extraPhotoPrice,@JsonKey(name: ProPackageUpdateRequest.proofsSlaDaysKey_) int? proofsSlaDays,@JsonKey(name: ProPackageUpdateRequest.finalsSlaDaysKey_) int? finalsSlaDays,@JsonKey(name: ProPackageUpdateRequest.addonsKey_) List<Map<String, dynamic>>? addons,@JsonKey(name: ProPackageUpdateRequest.isActiveKey_) bool? isActive
});




}
/// @nodoc
class _$ProPackageUpdateRequestCopyWithImpl<$Res>
    implements $ProPackageUpdateRequestCopyWith<$Res> {
  _$ProPackageUpdateRequestCopyWithImpl(this._self, this._then);

  final ProPackageUpdateRequest _self;
  final $Res Function(ProPackageUpdateRequest) _then;

/// Create a copy of ProPackageUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = freezed,Object? nicheId = freezed,Object? nicheSlug = freezed,Object? description = freezed,Object? durationMinutes = freezed,Object? price = freezed,Object? currency = freezed,Object? includedPhotos = freezed,Object? extraPhotoPrice = freezed,Object? proofsSlaDays = freezed,Object? finalsSlaDays = freezed,Object? addons = freezed,Object? isActive = freezed,}) {
  return _then(_self.copyWith(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,nicheId: freezed == nicheId ? _self.nicheId : nicheId // ignore: cast_nullable_to_non_nullable
as String?,nicheSlug: freezed == nicheSlug ? _self.nicheSlug : nicheSlug // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,durationMinutes: freezed == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as dynamic?,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,includedPhotos: freezed == includedPhotos ? _self.includedPhotos : includedPhotos // ignore: cast_nullable_to_non_nullable
as int?,extraPhotoPrice: freezed == extraPhotoPrice ? _self.extraPhotoPrice : extraPhotoPrice // ignore: cast_nullable_to_non_nullable
as dynamic?,proofsSlaDays: freezed == proofsSlaDays ? _self.proofsSlaDays : proofsSlaDays // ignore: cast_nullable_to_non_nullable
as int?,finalsSlaDays: freezed == finalsSlaDays ? _self.finalsSlaDays : finalsSlaDays // ignore: cast_nullable_to_non_nullable
as int?,addons: freezed == addons ? _self.addons : addons // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>?,isActive: freezed == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProPackageUpdateRequest].
extension ProPackageUpdateRequestPatterns on ProPackageUpdateRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProPackageUpdateRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProPackageUpdateRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProPackageUpdateRequest value)  $default,){
final _that = this;
switch (_that) {
case _ProPackageUpdateRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProPackageUpdateRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ProPackageUpdateRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ProPackageUpdateRequest.titleKey_)  String? title, @JsonKey(name: ProPackageUpdateRequest.nicheIdKey_)  String? nicheId, @JsonKey(name: ProPackageUpdateRequest.nicheSlugKey_)  String? nicheSlug, @JsonKey(name: ProPackageUpdateRequest.descriptionKey_)  String? description, @JsonKey(name: ProPackageUpdateRequest.durationMinutesKey_)  int? durationMinutes, @JsonKey(name: ProPackageUpdateRequest.priceKey_)  dynamic? price, @JsonKey(name: ProPackageUpdateRequest.currencyKey_)  String? currency, @JsonKey(name: ProPackageUpdateRequest.includedPhotosKey_)  int? includedPhotos, @JsonKey(name: ProPackageUpdateRequest.extraPhotoPriceKey_)  dynamic? extraPhotoPrice, @JsonKey(name: ProPackageUpdateRequest.proofsSlaDaysKey_)  int? proofsSlaDays, @JsonKey(name: ProPackageUpdateRequest.finalsSlaDaysKey_)  int? finalsSlaDays, @JsonKey(name: ProPackageUpdateRequest.addonsKey_)  List<Map<String, dynamic>>? addons, @JsonKey(name: ProPackageUpdateRequest.isActiveKey_)  bool? isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProPackageUpdateRequest() when $default != null:
return $default(_that.title,_that.nicheId,_that.nicheSlug,_that.description,_that.durationMinutes,_that.price,_that.currency,_that.includedPhotos,_that.extraPhotoPrice,_that.proofsSlaDays,_that.finalsSlaDays,_that.addons,_that.isActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ProPackageUpdateRequest.titleKey_)  String? title, @JsonKey(name: ProPackageUpdateRequest.nicheIdKey_)  String? nicheId, @JsonKey(name: ProPackageUpdateRequest.nicheSlugKey_)  String? nicheSlug, @JsonKey(name: ProPackageUpdateRequest.descriptionKey_)  String? description, @JsonKey(name: ProPackageUpdateRequest.durationMinutesKey_)  int? durationMinutes, @JsonKey(name: ProPackageUpdateRequest.priceKey_)  dynamic? price, @JsonKey(name: ProPackageUpdateRequest.currencyKey_)  String? currency, @JsonKey(name: ProPackageUpdateRequest.includedPhotosKey_)  int? includedPhotos, @JsonKey(name: ProPackageUpdateRequest.extraPhotoPriceKey_)  dynamic? extraPhotoPrice, @JsonKey(name: ProPackageUpdateRequest.proofsSlaDaysKey_)  int? proofsSlaDays, @JsonKey(name: ProPackageUpdateRequest.finalsSlaDaysKey_)  int? finalsSlaDays, @JsonKey(name: ProPackageUpdateRequest.addonsKey_)  List<Map<String, dynamic>>? addons, @JsonKey(name: ProPackageUpdateRequest.isActiveKey_)  bool? isActive)  $default,) {final _that = this;
switch (_that) {
case _ProPackageUpdateRequest():
return $default(_that.title,_that.nicheId,_that.nicheSlug,_that.description,_that.durationMinutes,_that.price,_that.currency,_that.includedPhotos,_that.extraPhotoPrice,_that.proofsSlaDays,_that.finalsSlaDays,_that.addons,_that.isActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ProPackageUpdateRequest.titleKey_)  String? title, @JsonKey(name: ProPackageUpdateRequest.nicheIdKey_)  String? nicheId, @JsonKey(name: ProPackageUpdateRequest.nicheSlugKey_)  String? nicheSlug, @JsonKey(name: ProPackageUpdateRequest.descriptionKey_)  String? description, @JsonKey(name: ProPackageUpdateRequest.durationMinutesKey_)  int? durationMinutes, @JsonKey(name: ProPackageUpdateRequest.priceKey_)  dynamic? price, @JsonKey(name: ProPackageUpdateRequest.currencyKey_)  String? currency, @JsonKey(name: ProPackageUpdateRequest.includedPhotosKey_)  int? includedPhotos, @JsonKey(name: ProPackageUpdateRequest.extraPhotoPriceKey_)  dynamic? extraPhotoPrice, @JsonKey(name: ProPackageUpdateRequest.proofsSlaDaysKey_)  int? proofsSlaDays, @JsonKey(name: ProPackageUpdateRequest.finalsSlaDaysKey_)  int? finalsSlaDays, @JsonKey(name: ProPackageUpdateRequest.addonsKey_)  List<Map<String, dynamic>>? addons, @JsonKey(name: ProPackageUpdateRequest.isActiveKey_)  bool? isActive)?  $default,) {final _that = this;
switch (_that) {
case _ProPackageUpdateRequest() when $default != null:
return $default(_that.title,_that.nicheId,_that.nicheSlug,_that.description,_that.durationMinutes,_that.price,_that.currency,_that.includedPhotos,_that.extraPhotoPrice,_that.proofsSlaDays,_that.finalsSlaDays,_that.addons,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ProPackageUpdateRequest extends ProPackageUpdateRequest {
  const _ProPackageUpdateRequest({@JsonKey(name: ProPackageUpdateRequest.titleKey_) this.title, @JsonKey(name: ProPackageUpdateRequest.nicheIdKey_) this.nicheId, @JsonKey(name: ProPackageUpdateRequest.nicheSlugKey_) this.nicheSlug, @JsonKey(name: ProPackageUpdateRequest.descriptionKey_) this.description, @JsonKey(name: ProPackageUpdateRequest.durationMinutesKey_) this.durationMinutes, @JsonKey(name: ProPackageUpdateRequest.priceKey_) this.price, @JsonKey(name: ProPackageUpdateRequest.currencyKey_) this.currency, @JsonKey(name: ProPackageUpdateRequest.includedPhotosKey_) this.includedPhotos, @JsonKey(name: ProPackageUpdateRequest.extraPhotoPriceKey_) this.extraPhotoPrice, @JsonKey(name: ProPackageUpdateRequest.proofsSlaDaysKey_) this.proofsSlaDays, @JsonKey(name: ProPackageUpdateRequest.finalsSlaDaysKey_) this.finalsSlaDays, @JsonKey(name: ProPackageUpdateRequest.addonsKey_) final  List<Map<String, dynamic>>? addons, @JsonKey(name: ProPackageUpdateRequest.isActiveKey_) this.isActive}): _addons = addons,super._();
  factory _ProPackageUpdateRequest.fromJson(Map<String, dynamic> json) => _$ProPackageUpdateRequestFromJson(json);

/// title
@override@JsonKey(name: ProPackageUpdateRequest.titleKey_) final  String? title;
/// nicheId
@override@JsonKey(name: ProPackageUpdateRequest.nicheIdKey_) final  String? nicheId;
/// nicheSlug
@override@JsonKey(name: ProPackageUpdateRequest.nicheSlugKey_) final  String? nicheSlug;
/// description
@override@JsonKey(name: ProPackageUpdateRequest.descriptionKey_) final  String? description;
/// durationMinutes
@override@JsonKey(name: ProPackageUpdateRequest.durationMinutesKey_) final  int? durationMinutes;
/// price
@override@JsonKey(name: ProPackageUpdateRequest.priceKey_) final  dynamic? price;
/// currency
@override@JsonKey(name: ProPackageUpdateRequest.currencyKey_) final  String? currency;
/// includedPhotos
@override@JsonKey(name: ProPackageUpdateRequest.includedPhotosKey_) final  int? includedPhotos;
/// extraPhotoPrice
@override@JsonKey(name: ProPackageUpdateRequest.extraPhotoPriceKey_) final  dynamic? extraPhotoPrice;
/// proofsSlaDays
@override@JsonKey(name: ProPackageUpdateRequest.proofsSlaDaysKey_) final  int? proofsSlaDays;
/// finalsSlaDays
@override@JsonKey(name: ProPackageUpdateRequest.finalsSlaDaysKey_) final  int? finalsSlaDays;
/// addons
 final  List<Map<String, dynamic>>? _addons;
/// addons
@override@JsonKey(name: ProPackageUpdateRequest.addonsKey_) List<Map<String, dynamic>>? get addons {
  final value = _addons;
  if (value == null) return null;
  if (_addons is EqualUnmodifiableListView) return _addons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// isActive
@override@JsonKey(name: ProPackageUpdateRequest.isActiveKey_) final  bool? isActive;

/// Create a copy of ProPackageUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProPackageUpdateRequestCopyWith<_ProPackageUpdateRequest> get copyWith => __$ProPackageUpdateRequestCopyWithImpl<_ProPackageUpdateRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProPackageUpdateRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProPackageUpdateRequest&&(identical(other.title, title) || other.title == title)&&(identical(other.nicheId, nicheId) || other.nicheId == nicheId)&&(identical(other.nicheSlug, nicheSlug) || other.nicheSlug == nicheSlug)&&(identical(other.description, description) || other.description == description)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&const DeepCollectionEquality().equals(other.price, price)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.includedPhotos, includedPhotos) || other.includedPhotos == includedPhotos)&&const DeepCollectionEquality().equals(other.extraPhotoPrice, extraPhotoPrice)&&(identical(other.proofsSlaDays, proofsSlaDays) || other.proofsSlaDays == proofsSlaDays)&&(identical(other.finalsSlaDays, finalsSlaDays) || other.finalsSlaDays == finalsSlaDays)&&const DeepCollectionEquality().equals(other._addons, _addons)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,nicheId,nicheSlug,description,durationMinutes,const DeepCollectionEquality().hash(price),currency,includedPhotos,const DeepCollectionEquality().hash(extraPhotoPrice),proofsSlaDays,finalsSlaDays,const DeepCollectionEquality().hash(_addons),isActive);

@override
String toString() {
  return 'ProPackageUpdateRequest(title: $title, nicheId: $nicheId, nicheSlug: $nicheSlug, description: $description, durationMinutes: $durationMinutes, price: $price, currency: $currency, includedPhotos: $includedPhotos, extraPhotoPrice: $extraPhotoPrice, proofsSlaDays: $proofsSlaDays, finalsSlaDays: $finalsSlaDays, addons: $addons, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$ProPackageUpdateRequestCopyWith<$Res> implements $ProPackageUpdateRequestCopyWith<$Res> {
  factory _$ProPackageUpdateRequestCopyWith(_ProPackageUpdateRequest value, $Res Function(_ProPackageUpdateRequest) _then) = __$ProPackageUpdateRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ProPackageUpdateRequest.titleKey_) String? title,@JsonKey(name: ProPackageUpdateRequest.nicheIdKey_) String? nicheId,@JsonKey(name: ProPackageUpdateRequest.nicheSlugKey_) String? nicheSlug,@JsonKey(name: ProPackageUpdateRequest.descriptionKey_) String? description,@JsonKey(name: ProPackageUpdateRequest.durationMinutesKey_) int? durationMinutes,@JsonKey(name: ProPackageUpdateRequest.priceKey_) dynamic? price,@JsonKey(name: ProPackageUpdateRequest.currencyKey_) String? currency,@JsonKey(name: ProPackageUpdateRequest.includedPhotosKey_) int? includedPhotos,@JsonKey(name: ProPackageUpdateRequest.extraPhotoPriceKey_) dynamic? extraPhotoPrice,@JsonKey(name: ProPackageUpdateRequest.proofsSlaDaysKey_) int? proofsSlaDays,@JsonKey(name: ProPackageUpdateRequest.finalsSlaDaysKey_) int? finalsSlaDays,@JsonKey(name: ProPackageUpdateRequest.addonsKey_) List<Map<String, dynamic>>? addons,@JsonKey(name: ProPackageUpdateRequest.isActiveKey_) bool? isActive
});




}
/// @nodoc
class __$ProPackageUpdateRequestCopyWithImpl<$Res>
    implements _$ProPackageUpdateRequestCopyWith<$Res> {
  __$ProPackageUpdateRequestCopyWithImpl(this._self, this._then);

  final _ProPackageUpdateRequest _self;
  final $Res Function(_ProPackageUpdateRequest) _then;

/// Create a copy of ProPackageUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = freezed,Object? nicheId = freezed,Object? nicheSlug = freezed,Object? description = freezed,Object? durationMinutes = freezed,Object? price = freezed,Object? currency = freezed,Object? includedPhotos = freezed,Object? extraPhotoPrice = freezed,Object? proofsSlaDays = freezed,Object? finalsSlaDays = freezed,Object? addons = freezed,Object? isActive = freezed,}) {
  return _then(_ProPackageUpdateRequest(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,nicheId: freezed == nicheId ? _self.nicheId : nicheId // ignore: cast_nullable_to_non_nullable
as String?,nicheSlug: freezed == nicheSlug ? _self.nicheSlug : nicheSlug // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,durationMinutes: freezed == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as dynamic?,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,includedPhotos: freezed == includedPhotos ? _self.includedPhotos : includedPhotos // ignore: cast_nullable_to_non_nullable
as int?,extraPhotoPrice: freezed == extraPhotoPrice ? _self.extraPhotoPrice : extraPhotoPrice // ignore: cast_nullable_to_non_nullable
as dynamic?,proofsSlaDays: freezed == proofsSlaDays ? _self.proofsSlaDays : proofsSlaDays // ignore: cast_nullable_to_non_nullable
as int?,finalsSlaDays: freezed == finalsSlaDays ? _self.finalsSlaDays : finalsSlaDays // ignore: cast_nullable_to_non_nullable
as int?,addons: freezed == addons ? _self._addons : addons // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>?,isActive: freezed == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
