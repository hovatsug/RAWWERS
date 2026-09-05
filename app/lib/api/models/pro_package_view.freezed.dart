// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pro_package_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProPackageView {

/// id
@JsonKey(name: ProPackageView.idKey_) String get id;/// proUserId
@JsonKey(name: ProPackageView.proUserIdKey_) String get proUserId;/// nicheId
@JsonKey(name: ProPackageView.nicheIdKey_) String get nicheId;/// title
@JsonKey(name: ProPackageView.titleKey_) String get title;/// description
@JsonKey(name: ProPackageView.descriptionKey_) String? get description;/// durationMinutes
@JsonKey(name: ProPackageView.durationMinutesKey_) int get durationMinutes;/// price
@JsonKey(name: ProPackageView.priceKey_) String get price;/// currency
@JsonKey(name: ProPackageView.currencyKey_) String get currency;/// includedPhotos
@JsonKey(name: ProPackageView.includedPhotosKey_) int get includedPhotos;/// extraPhotoPrice
@JsonKey(name: ProPackageView.extraPhotoPriceKey_) String get extraPhotoPrice;/// proofsSlaDays
@JsonKey(name: ProPackageView.proofsSlaDaysKey_) int get proofsSlaDays;/// finalsSlaDays
@JsonKey(name: ProPackageView.finalsSlaDaysKey_) int get finalsSlaDays;/// addons
@JsonKey(name: ProPackageView.addonsKey_) List<Map<String, dynamic>> get addons;/// isActive
@JsonKey(name: ProPackageView.isActiveKey_) bool get isActive;
/// Create a copy of ProPackageView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProPackageViewCopyWith<ProPackageView> get copyWith => _$ProPackageViewCopyWithImpl<ProPackageView>(this as ProPackageView, _$identity);

  /// Serializes this ProPackageView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProPackageView&&(identical(other.id, id) || other.id == id)&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.nicheId, nicheId) || other.nicheId == nicheId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.price, price) || other.price == price)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.includedPhotos, includedPhotos) || other.includedPhotos == includedPhotos)&&(identical(other.extraPhotoPrice, extraPhotoPrice) || other.extraPhotoPrice == extraPhotoPrice)&&(identical(other.proofsSlaDays, proofsSlaDays) || other.proofsSlaDays == proofsSlaDays)&&(identical(other.finalsSlaDays, finalsSlaDays) || other.finalsSlaDays == finalsSlaDays)&&const DeepCollectionEquality().equals(other.addons, addons)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,proUserId,nicheId,title,description,durationMinutes,price,currency,includedPhotos,extraPhotoPrice,proofsSlaDays,finalsSlaDays,const DeepCollectionEquality().hash(addons),isActive);

@override
String toString() {
  return 'ProPackageView(id: $id, proUserId: $proUserId, nicheId: $nicheId, title: $title, description: $description, durationMinutes: $durationMinutes, price: $price, currency: $currency, includedPhotos: $includedPhotos, extraPhotoPrice: $extraPhotoPrice, proofsSlaDays: $proofsSlaDays, finalsSlaDays: $finalsSlaDays, addons: $addons, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class $ProPackageViewCopyWith<$Res>  {
  factory $ProPackageViewCopyWith(ProPackageView value, $Res Function(ProPackageView) _then) = _$ProPackageViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ProPackageView.idKey_) String id,@JsonKey(name: ProPackageView.proUserIdKey_) String proUserId,@JsonKey(name: ProPackageView.nicheIdKey_) String nicheId,@JsonKey(name: ProPackageView.titleKey_) String title,@JsonKey(name: ProPackageView.descriptionKey_) String? description,@JsonKey(name: ProPackageView.durationMinutesKey_) int durationMinutes,@JsonKey(name: ProPackageView.priceKey_) String price,@JsonKey(name: ProPackageView.currencyKey_) String currency,@JsonKey(name: ProPackageView.includedPhotosKey_) int includedPhotos,@JsonKey(name: ProPackageView.extraPhotoPriceKey_) String extraPhotoPrice,@JsonKey(name: ProPackageView.proofsSlaDaysKey_) int proofsSlaDays,@JsonKey(name: ProPackageView.finalsSlaDaysKey_) int finalsSlaDays,@JsonKey(name: ProPackageView.addonsKey_) List<Map<String, dynamic>> addons,@JsonKey(name: ProPackageView.isActiveKey_) bool isActive
});




}
/// @nodoc
class _$ProPackageViewCopyWithImpl<$Res>
    implements $ProPackageViewCopyWith<$Res> {
  _$ProPackageViewCopyWithImpl(this._self, this._then);

  final ProPackageView _self;
  final $Res Function(ProPackageView) _then;

/// Create a copy of ProPackageView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? proUserId = null,Object? nicheId = null,Object? title = null,Object? description = freezed,Object? durationMinutes = null,Object? price = null,Object? currency = null,Object? includedPhotos = null,Object? extraPhotoPrice = null,Object? proofsSlaDays = null,Object? finalsSlaDays = null,Object? addons = null,Object? isActive = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,nicheId: null == nicheId ? _self.nicheId : nicheId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,includedPhotos: null == includedPhotos ? _self.includedPhotos : includedPhotos // ignore: cast_nullable_to_non_nullable
as int,extraPhotoPrice: null == extraPhotoPrice ? _self.extraPhotoPrice : extraPhotoPrice // ignore: cast_nullable_to_non_nullable
as String,proofsSlaDays: null == proofsSlaDays ? _self.proofsSlaDays : proofsSlaDays // ignore: cast_nullable_to_non_nullable
as int,finalsSlaDays: null == finalsSlaDays ? _self.finalsSlaDays : finalsSlaDays // ignore: cast_nullable_to_non_nullable
as int,addons: null == addons ? _self.addons : addons // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ProPackageView].
extension ProPackageViewPatterns on ProPackageView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProPackageView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProPackageView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProPackageView value)  $default,){
final _that = this;
switch (_that) {
case _ProPackageView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProPackageView value)?  $default,){
final _that = this;
switch (_that) {
case _ProPackageView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ProPackageView.idKey_)  String id, @JsonKey(name: ProPackageView.proUserIdKey_)  String proUserId, @JsonKey(name: ProPackageView.nicheIdKey_)  String nicheId, @JsonKey(name: ProPackageView.titleKey_)  String title, @JsonKey(name: ProPackageView.descriptionKey_)  String? description, @JsonKey(name: ProPackageView.durationMinutesKey_)  int durationMinutes, @JsonKey(name: ProPackageView.priceKey_)  String price, @JsonKey(name: ProPackageView.currencyKey_)  String currency, @JsonKey(name: ProPackageView.includedPhotosKey_)  int includedPhotos, @JsonKey(name: ProPackageView.extraPhotoPriceKey_)  String extraPhotoPrice, @JsonKey(name: ProPackageView.proofsSlaDaysKey_)  int proofsSlaDays, @JsonKey(name: ProPackageView.finalsSlaDaysKey_)  int finalsSlaDays, @JsonKey(name: ProPackageView.addonsKey_)  List<Map<String, dynamic>> addons, @JsonKey(name: ProPackageView.isActiveKey_)  bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProPackageView() when $default != null:
return $default(_that.id,_that.proUserId,_that.nicheId,_that.title,_that.description,_that.durationMinutes,_that.price,_that.currency,_that.includedPhotos,_that.extraPhotoPrice,_that.proofsSlaDays,_that.finalsSlaDays,_that.addons,_that.isActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ProPackageView.idKey_)  String id, @JsonKey(name: ProPackageView.proUserIdKey_)  String proUserId, @JsonKey(name: ProPackageView.nicheIdKey_)  String nicheId, @JsonKey(name: ProPackageView.titleKey_)  String title, @JsonKey(name: ProPackageView.descriptionKey_)  String? description, @JsonKey(name: ProPackageView.durationMinutesKey_)  int durationMinutes, @JsonKey(name: ProPackageView.priceKey_)  String price, @JsonKey(name: ProPackageView.currencyKey_)  String currency, @JsonKey(name: ProPackageView.includedPhotosKey_)  int includedPhotos, @JsonKey(name: ProPackageView.extraPhotoPriceKey_)  String extraPhotoPrice, @JsonKey(name: ProPackageView.proofsSlaDaysKey_)  int proofsSlaDays, @JsonKey(name: ProPackageView.finalsSlaDaysKey_)  int finalsSlaDays, @JsonKey(name: ProPackageView.addonsKey_)  List<Map<String, dynamic>> addons, @JsonKey(name: ProPackageView.isActiveKey_)  bool isActive)  $default,) {final _that = this;
switch (_that) {
case _ProPackageView():
return $default(_that.id,_that.proUserId,_that.nicheId,_that.title,_that.description,_that.durationMinutes,_that.price,_that.currency,_that.includedPhotos,_that.extraPhotoPrice,_that.proofsSlaDays,_that.finalsSlaDays,_that.addons,_that.isActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ProPackageView.idKey_)  String id, @JsonKey(name: ProPackageView.proUserIdKey_)  String proUserId, @JsonKey(name: ProPackageView.nicheIdKey_)  String nicheId, @JsonKey(name: ProPackageView.titleKey_)  String title, @JsonKey(name: ProPackageView.descriptionKey_)  String? description, @JsonKey(name: ProPackageView.durationMinutesKey_)  int durationMinutes, @JsonKey(name: ProPackageView.priceKey_)  String price, @JsonKey(name: ProPackageView.currencyKey_)  String currency, @JsonKey(name: ProPackageView.includedPhotosKey_)  int includedPhotos, @JsonKey(name: ProPackageView.extraPhotoPriceKey_)  String extraPhotoPrice, @JsonKey(name: ProPackageView.proofsSlaDaysKey_)  int proofsSlaDays, @JsonKey(name: ProPackageView.finalsSlaDaysKey_)  int finalsSlaDays, @JsonKey(name: ProPackageView.addonsKey_)  List<Map<String, dynamic>> addons, @JsonKey(name: ProPackageView.isActiveKey_)  bool isActive)?  $default,) {final _that = this;
switch (_that) {
case _ProPackageView() when $default != null:
return $default(_that.id,_that.proUserId,_that.nicheId,_that.title,_that.description,_that.durationMinutes,_that.price,_that.currency,_that.includedPhotos,_that.extraPhotoPrice,_that.proofsSlaDays,_that.finalsSlaDays,_that.addons,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ProPackageView extends ProPackageView {
  const _ProPackageView({@JsonKey(name: ProPackageView.idKey_) required this.id, @JsonKey(name: ProPackageView.proUserIdKey_) required this.proUserId, @JsonKey(name: ProPackageView.nicheIdKey_) required this.nicheId, @JsonKey(name: ProPackageView.titleKey_) required this.title, @JsonKey(name: ProPackageView.descriptionKey_) this.description, @JsonKey(name: ProPackageView.durationMinutesKey_) required this.durationMinutes, @JsonKey(name: ProPackageView.priceKey_) required this.price, @JsonKey(name: ProPackageView.currencyKey_) required this.currency, @JsonKey(name: ProPackageView.includedPhotosKey_) required this.includedPhotos, @JsonKey(name: ProPackageView.extraPhotoPriceKey_) required this.extraPhotoPrice, @JsonKey(name: ProPackageView.proofsSlaDaysKey_) required this.proofsSlaDays, @JsonKey(name: ProPackageView.finalsSlaDaysKey_) required this.finalsSlaDays, @JsonKey(name: ProPackageView.addonsKey_) required final  List<Map<String, dynamic>> addons, @JsonKey(name: ProPackageView.isActiveKey_) required this.isActive}): _addons = addons,super._();
  factory _ProPackageView.fromJson(Map<String, dynamic> json) => _$ProPackageViewFromJson(json);

/// id
@override@JsonKey(name: ProPackageView.idKey_) final  String id;
/// proUserId
@override@JsonKey(name: ProPackageView.proUserIdKey_) final  String proUserId;
/// nicheId
@override@JsonKey(name: ProPackageView.nicheIdKey_) final  String nicheId;
/// title
@override@JsonKey(name: ProPackageView.titleKey_) final  String title;
/// description
@override@JsonKey(name: ProPackageView.descriptionKey_) final  String? description;
/// durationMinutes
@override@JsonKey(name: ProPackageView.durationMinutesKey_) final  int durationMinutes;
/// price
@override@JsonKey(name: ProPackageView.priceKey_) final  String price;
/// currency
@override@JsonKey(name: ProPackageView.currencyKey_) final  String currency;
/// includedPhotos
@override@JsonKey(name: ProPackageView.includedPhotosKey_) final  int includedPhotos;
/// extraPhotoPrice
@override@JsonKey(name: ProPackageView.extraPhotoPriceKey_) final  String extraPhotoPrice;
/// proofsSlaDays
@override@JsonKey(name: ProPackageView.proofsSlaDaysKey_) final  int proofsSlaDays;
/// finalsSlaDays
@override@JsonKey(name: ProPackageView.finalsSlaDaysKey_) final  int finalsSlaDays;
/// addons
 final  List<Map<String, dynamic>> _addons;
/// addons
@override@JsonKey(name: ProPackageView.addonsKey_) List<Map<String, dynamic>> get addons {
  if (_addons is EqualUnmodifiableListView) return _addons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_addons);
}

/// isActive
@override@JsonKey(name: ProPackageView.isActiveKey_) final  bool isActive;

/// Create a copy of ProPackageView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProPackageViewCopyWith<_ProPackageView> get copyWith => __$ProPackageViewCopyWithImpl<_ProPackageView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProPackageViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProPackageView&&(identical(other.id, id) || other.id == id)&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.nicheId, nicheId) || other.nicheId == nicheId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.price, price) || other.price == price)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.includedPhotos, includedPhotos) || other.includedPhotos == includedPhotos)&&(identical(other.extraPhotoPrice, extraPhotoPrice) || other.extraPhotoPrice == extraPhotoPrice)&&(identical(other.proofsSlaDays, proofsSlaDays) || other.proofsSlaDays == proofsSlaDays)&&(identical(other.finalsSlaDays, finalsSlaDays) || other.finalsSlaDays == finalsSlaDays)&&const DeepCollectionEquality().equals(other._addons, _addons)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,proUserId,nicheId,title,description,durationMinutes,price,currency,includedPhotos,extraPhotoPrice,proofsSlaDays,finalsSlaDays,const DeepCollectionEquality().hash(_addons),isActive);

@override
String toString() {
  return 'ProPackageView(id: $id, proUserId: $proUserId, nicheId: $nicheId, title: $title, description: $description, durationMinutes: $durationMinutes, price: $price, currency: $currency, includedPhotos: $includedPhotos, extraPhotoPrice: $extraPhotoPrice, proofsSlaDays: $proofsSlaDays, finalsSlaDays: $finalsSlaDays, addons: $addons, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$ProPackageViewCopyWith<$Res> implements $ProPackageViewCopyWith<$Res> {
  factory _$ProPackageViewCopyWith(_ProPackageView value, $Res Function(_ProPackageView) _then) = __$ProPackageViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ProPackageView.idKey_) String id,@JsonKey(name: ProPackageView.proUserIdKey_) String proUserId,@JsonKey(name: ProPackageView.nicheIdKey_) String nicheId,@JsonKey(name: ProPackageView.titleKey_) String title,@JsonKey(name: ProPackageView.descriptionKey_) String? description,@JsonKey(name: ProPackageView.durationMinutesKey_) int durationMinutes,@JsonKey(name: ProPackageView.priceKey_) String price,@JsonKey(name: ProPackageView.currencyKey_) String currency,@JsonKey(name: ProPackageView.includedPhotosKey_) int includedPhotos,@JsonKey(name: ProPackageView.extraPhotoPriceKey_) String extraPhotoPrice,@JsonKey(name: ProPackageView.proofsSlaDaysKey_) int proofsSlaDays,@JsonKey(name: ProPackageView.finalsSlaDaysKey_) int finalsSlaDays,@JsonKey(name: ProPackageView.addonsKey_) List<Map<String, dynamic>> addons,@JsonKey(name: ProPackageView.isActiveKey_) bool isActive
});




}
/// @nodoc
class __$ProPackageViewCopyWithImpl<$Res>
    implements _$ProPackageViewCopyWith<$Res> {
  __$ProPackageViewCopyWithImpl(this._self, this._then);

  final _ProPackageView _self;
  final $Res Function(_ProPackageView) _then;

/// Create a copy of ProPackageView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? proUserId = null,Object? nicheId = null,Object? title = null,Object? description = freezed,Object? durationMinutes = null,Object? price = null,Object? currency = null,Object? includedPhotos = null,Object? extraPhotoPrice = null,Object? proofsSlaDays = null,Object? finalsSlaDays = null,Object? addons = null,Object? isActive = null,}) {
  return _then(_ProPackageView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,nicheId: null == nicheId ? _self.nicheId : nicheId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,includedPhotos: null == includedPhotos ? _self.includedPhotos : includedPhotos // ignore: cast_nullable_to_non_nullable
as int,extraPhotoPrice: null == extraPhotoPrice ? _self.extraPhotoPrice : extraPhotoPrice // ignore: cast_nullable_to_non_nullable
as String,proofsSlaDays: null == proofsSlaDays ? _self.proofsSlaDays : proofsSlaDays // ignore: cast_nullable_to_non_nullable
as int,finalsSlaDays: null == finalsSlaDays ? _self.finalsSlaDays : finalsSlaDays // ignore: cast_nullable_to_non_nullable
as int,addons: null == addons ? _self._addons : addons // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
