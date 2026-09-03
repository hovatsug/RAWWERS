// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'public_pro_package_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PublicProPackageView {

/// id
@JsonKey(name: PublicProPackageView.idKey_) String get id;/// title
@JsonKey(name: PublicProPackageView.titleKey_) String get title;/// description
@JsonKey(name: PublicProPackageView.descriptionKey_) String? get description;/// durationMinutes
@JsonKey(name: PublicProPackageView.durationMinutesKey_) int get durationMinutes;/// price
@JsonKey(name: PublicProPackageView.priceKey_) String get price;/// currency
@JsonKey(name: PublicProPackageView.currencyKey_) String get currency;/// includedPhotos
@JsonKey(name: PublicProPackageView.includedPhotosKey_) int get includedPhotos;/// extraPhotoPrice
@JsonKey(name: PublicProPackageView.extraPhotoPriceKey_) String get extraPhotoPrice;/// proofsSlaDays
@JsonKey(name: PublicProPackageView.proofsSlaDaysKey_) int get proofsSlaDays;/// finalsSlaDays
@JsonKey(name: PublicProPackageView.finalsSlaDaysKey_) int get finalsSlaDays;/// addons
@JsonKey(name: PublicProPackageView.addonsKey_) List<Map<String, dynamic>> get addons;
/// Create a copy of PublicProPackageView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PublicProPackageViewCopyWith<PublicProPackageView> get copyWith => _$PublicProPackageViewCopyWithImpl<PublicProPackageView>(this as PublicProPackageView, _$identity);

  /// Serializes this PublicProPackageView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PublicProPackageView&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.price, price) || other.price == price)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.includedPhotos, includedPhotos) || other.includedPhotos == includedPhotos)&&(identical(other.extraPhotoPrice, extraPhotoPrice) || other.extraPhotoPrice == extraPhotoPrice)&&(identical(other.proofsSlaDays, proofsSlaDays) || other.proofsSlaDays == proofsSlaDays)&&(identical(other.finalsSlaDays, finalsSlaDays) || other.finalsSlaDays == finalsSlaDays)&&const DeepCollectionEquality().equals(other.addons, addons));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,durationMinutes,price,currency,includedPhotos,extraPhotoPrice,proofsSlaDays,finalsSlaDays,const DeepCollectionEquality().hash(addons));

@override
String toString() {
  return 'PublicProPackageView(id: $id, title: $title, description: $description, durationMinutes: $durationMinutes, price: $price, currency: $currency, includedPhotos: $includedPhotos, extraPhotoPrice: $extraPhotoPrice, proofsSlaDays: $proofsSlaDays, finalsSlaDays: $finalsSlaDays, addons: $addons)';
}


}

/// @nodoc
abstract mixin class $PublicProPackageViewCopyWith<$Res>  {
  factory $PublicProPackageViewCopyWith(PublicProPackageView value, $Res Function(PublicProPackageView) _then) = _$PublicProPackageViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: PublicProPackageView.idKey_) String id,@JsonKey(name: PublicProPackageView.titleKey_) String title,@JsonKey(name: PublicProPackageView.descriptionKey_) String? description,@JsonKey(name: PublicProPackageView.durationMinutesKey_) int durationMinutes,@JsonKey(name: PublicProPackageView.priceKey_) String price,@JsonKey(name: PublicProPackageView.currencyKey_) String currency,@JsonKey(name: PublicProPackageView.includedPhotosKey_) int includedPhotos,@JsonKey(name: PublicProPackageView.extraPhotoPriceKey_) String extraPhotoPrice,@JsonKey(name: PublicProPackageView.proofsSlaDaysKey_) int proofsSlaDays,@JsonKey(name: PublicProPackageView.finalsSlaDaysKey_) int finalsSlaDays,@JsonKey(name: PublicProPackageView.addonsKey_) List<Map<String, dynamic>> addons
});




}
/// @nodoc
class _$PublicProPackageViewCopyWithImpl<$Res>
    implements $PublicProPackageViewCopyWith<$Res> {
  _$PublicProPackageViewCopyWithImpl(this._self, this._then);

  final PublicProPackageView _self;
  final $Res Function(PublicProPackageView) _then;

/// Create a copy of PublicProPackageView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? durationMinutes = null,Object? price = null,Object? currency = null,Object? includedPhotos = null,Object? extraPhotoPrice = null,Object? proofsSlaDays = null,Object? finalsSlaDays = null,Object? addons = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
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
as List<Map<String, dynamic>>,
  ));
}

}


/// Adds pattern-matching-related methods to [PublicProPackageView].
extension PublicProPackageViewPatterns on PublicProPackageView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PublicProPackageView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PublicProPackageView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PublicProPackageView value)  $default,){
final _that = this;
switch (_that) {
case _PublicProPackageView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PublicProPackageView value)?  $default,){
final _that = this;
switch (_that) {
case _PublicProPackageView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: PublicProPackageView.idKey_)  String id, @JsonKey(name: PublicProPackageView.titleKey_)  String title, @JsonKey(name: PublicProPackageView.descriptionKey_)  String? description, @JsonKey(name: PublicProPackageView.durationMinutesKey_)  int durationMinutes, @JsonKey(name: PublicProPackageView.priceKey_)  String price, @JsonKey(name: PublicProPackageView.currencyKey_)  String currency, @JsonKey(name: PublicProPackageView.includedPhotosKey_)  int includedPhotos, @JsonKey(name: PublicProPackageView.extraPhotoPriceKey_)  String extraPhotoPrice, @JsonKey(name: PublicProPackageView.proofsSlaDaysKey_)  int proofsSlaDays, @JsonKey(name: PublicProPackageView.finalsSlaDaysKey_)  int finalsSlaDays, @JsonKey(name: PublicProPackageView.addonsKey_)  List<Map<String, dynamic>> addons)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PublicProPackageView() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.durationMinutes,_that.price,_that.currency,_that.includedPhotos,_that.extraPhotoPrice,_that.proofsSlaDays,_that.finalsSlaDays,_that.addons);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: PublicProPackageView.idKey_)  String id, @JsonKey(name: PublicProPackageView.titleKey_)  String title, @JsonKey(name: PublicProPackageView.descriptionKey_)  String? description, @JsonKey(name: PublicProPackageView.durationMinutesKey_)  int durationMinutes, @JsonKey(name: PublicProPackageView.priceKey_)  String price, @JsonKey(name: PublicProPackageView.currencyKey_)  String currency, @JsonKey(name: PublicProPackageView.includedPhotosKey_)  int includedPhotos, @JsonKey(name: PublicProPackageView.extraPhotoPriceKey_)  String extraPhotoPrice, @JsonKey(name: PublicProPackageView.proofsSlaDaysKey_)  int proofsSlaDays, @JsonKey(name: PublicProPackageView.finalsSlaDaysKey_)  int finalsSlaDays, @JsonKey(name: PublicProPackageView.addonsKey_)  List<Map<String, dynamic>> addons)  $default,) {final _that = this;
switch (_that) {
case _PublicProPackageView():
return $default(_that.id,_that.title,_that.description,_that.durationMinutes,_that.price,_that.currency,_that.includedPhotos,_that.extraPhotoPrice,_that.proofsSlaDays,_that.finalsSlaDays,_that.addons);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: PublicProPackageView.idKey_)  String id, @JsonKey(name: PublicProPackageView.titleKey_)  String title, @JsonKey(name: PublicProPackageView.descriptionKey_)  String? description, @JsonKey(name: PublicProPackageView.durationMinutesKey_)  int durationMinutes, @JsonKey(name: PublicProPackageView.priceKey_)  String price, @JsonKey(name: PublicProPackageView.currencyKey_)  String currency, @JsonKey(name: PublicProPackageView.includedPhotosKey_)  int includedPhotos, @JsonKey(name: PublicProPackageView.extraPhotoPriceKey_)  String extraPhotoPrice, @JsonKey(name: PublicProPackageView.proofsSlaDaysKey_)  int proofsSlaDays, @JsonKey(name: PublicProPackageView.finalsSlaDaysKey_)  int finalsSlaDays, @JsonKey(name: PublicProPackageView.addonsKey_)  List<Map<String, dynamic>> addons)?  $default,) {final _that = this;
switch (_that) {
case _PublicProPackageView() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.durationMinutes,_that.price,_that.currency,_that.includedPhotos,_that.extraPhotoPrice,_that.proofsSlaDays,_that.finalsSlaDays,_that.addons);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _PublicProPackageView extends PublicProPackageView {
  const _PublicProPackageView({@JsonKey(name: PublicProPackageView.idKey_) required this.id, @JsonKey(name: PublicProPackageView.titleKey_) required this.title, @JsonKey(name: PublicProPackageView.descriptionKey_) this.description, @JsonKey(name: PublicProPackageView.durationMinutesKey_) required this.durationMinutes, @JsonKey(name: PublicProPackageView.priceKey_) required this.price, @JsonKey(name: PublicProPackageView.currencyKey_) required this.currency, @JsonKey(name: PublicProPackageView.includedPhotosKey_) required this.includedPhotos, @JsonKey(name: PublicProPackageView.extraPhotoPriceKey_) required this.extraPhotoPrice, @JsonKey(name: PublicProPackageView.proofsSlaDaysKey_) required this.proofsSlaDays, @JsonKey(name: PublicProPackageView.finalsSlaDaysKey_) required this.finalsSlaDays, @JsonKey(name: PublicProPackageView.addonsKey_) required final  List<Map<String, dynamic>> addons}): _addons = addons,super._();
  factory _PublicProPackageView.fromJson(Map<String, dynamic> json) => _$PublicProPackageViewFromJson(json);

/// id
@override@JsonKey(name: PublicProPackageView.idKey_) final  String id;
/// title
@override@JsonKey(name: PublicProPackageView.titleKey_) final  String title;
/// description
@override@JsonKey(name: PublicProPackageView.descriptionKey_) final  String? description;
/// durationMinutes
@override@JsonKey(name: PublicProPackageView.durationMinutesKey_) final  int durationMinutes;
/// price
@override@JsonKey(name: PublicProPackageView.priceKey_) final  String price;
/// currency
@override@JsonKey(name: PublicProPackageView.currencyKey_) final  String currency;
/// includedPhotos
@override@JsonKey(name: PublicProPackageView.includedPhotosKey_) final  int includedPhotos;
/// extraPhotoPrice
@override@JsonKey(name: PublicProPackageView.extraPhotoPriceKey_) final  String extraPhotoPrice;
/// proofsSlaDays
@override@JsonKey(name: PublicProPackageView.proofsSlaDaysKey_) final  int proofsSlaDays;
/// finalsSlaDays
@override@JsonKey(name: PublicProPackageView.finalsSlaDaysKey_) final  int finalsSlaDays;
/// addons
 final  List<Map<String, dynamic>> _addons;
/// addons
@override@JsonKey(name: PublicProPackageView.addonsKey_) List<Map<String, dynamic>> get addons {
  if (_addons is EqualUnmodifiableListView) return _addons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_addons);
}


/// Create a copy of PublicProPackageView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PublicProPackageViewCopyWith<_PublicProPackageView> get copyWith => __$PublicProPackageViewCopyWithImpl<_PublicProPackageView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PublicProPackageViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PublicProPackageView&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.price, price) || other.price == price)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.includedPhotos, includedPhotos) || other.includedPhotos == includedPhotos)&&(identical(other.extraPhotoPrice, extraPhotoPrice) || other.extraPhotoPrice == extraPhotoPrice)&&(identical(other.proofsSlaDays, proofsSlaDays) || other.proofsSlaDays == proofsSlaDays)&&(identical(other.finalsSlaDays, finalsSlaDays) || other.finalsSlaDays == finalsSlaDays)&&const DeepCollectionEquality().equals(other._addons, _addons));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,durationMinutes,price,currency,includedPhotos,extraPhotoPrice,proofsSlaDays,finalsSlaDays,const DeepCollectionEquality().hash(_addons));

@override
String toString() {
  return 'PublicProPackageView(id: $id, title: $title, description: $description, durationMinutes: $durationMinutes, price: $price, currency: $currency, includedPhotos: $includedPhotos, extraPhotoPrice: $extraPhotoPrice, proofsSlaDays: $proofsSlaDays, finalsSlaDays: $finalsSlaDays, addons: $addons)';
}


}

/// @nodoc
abstract mixin class _$PublicProPackageViewCopyWith<$Res> implements $PublicProPackageViewCopyWith<$Res> {
  factory _$PublicProPackageViewCopyWith(_PublicProPackageView value, $Res Function(_PublicProPackageView) _then) = __$PublicProPackageViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: PublicProPackageView.idKey_) String id,@JsonKey(name: PublicProPackageView.titleKey_) String title,@JsonKey(name: PublicProPackageView.descriptionKey_) String? description,@JsonKey(name: PublicProPackageView.durationMinutesKey_) int durationMinutes,@JsonKey(name: PublicProPackageView.priceKey_) String price,@JsonKey(name: PublicProPackageView.currencyKey_) String currency,@JsonKey(name: PublicProPackageView.includedPhotosKey_) int includedPhotos,@JsonKey(name: PublicProPackageView.extraPhotoPriceKey_) String extraPhotoPrice,@JsonKey(name: PublicProPackageView.proofsSlaDaysKey_) int proofsSlaDays,@JsonKey(name: PublicProPackageView.finalsSlaDaysKey_) int finalsSlaDays,@JsonKey(name: PublicProPackageView.addonsKey_) List<Map<String, dynamic>> addons
});




}
/// @nodoc
class __$PublicProPackageViewCopyWithImpl<$Res>
    implements _$PublicProPackageViewCopyWith<$Res> {
  __$PublicProPackageViewCopyWithImpl(this._self, this._then);

  final _PublicProPackageView _self;
  final $Res Function(_PublicProPackageView) _then;

/// Create a copy of PublicProPackageView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? durationMinutes = null,Object? price = null,Object? currency = null,Object? includedPhotos = null,Object? extraPhotoPrice = null,Object? proofsSlaDays = null,Object? finalsSlaDays = null,Object? addons = null,}) {
  return _then(_PublicProPackageView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
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
as List<Map<String, dynamic>>,
  ));
}


}

// dart format on
