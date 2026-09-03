// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_profile_package.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClientProfilePackage {

/// id
@JsonKey(name: ClientProfilePackage.idKey_) String get id;/// title
@JsonKey(name: ClientProfilePackage.titleKey_) String get title;/// description
@JsonKey(name: ClientProfilePackage.descriptionKey_) String? get description;/// durationMinutes
@JsonKey(name: ClientProfilePackage.durationMinutesKey_) int get durationMinutes;/// price
@JsonKey(name: ClientProfilePackage.priceKey_) String get price;/// currency
@JsonKey(name: ClientProfilePackage.currencyKey_) String get currency;/// includedPhotos
@JsonKey(name: ClientProfilePackage.includedPhotosKey_) int get includedPhotos;/// extraPhotoPrice
@JsonKey(name: ClientProfilePackage.extraPhotoPriceKey_) String get extraPhotoPrice;/// proofsSlaDays
@JsonKey(name: ClientProfilePackage.proofsSlaDaysKey_) int get proofsSlaDays;/// finalsSlaDays
@JsonKey(name: ClientProfilePackage.finalsSlaDaysKey_) int get finalsSlaDays;
/// Create a copy of ClientProfilePackage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientProfilePackageCopyWith<ClientProfilePackage> get copyWith => _$ClientProfilePackageCopyWithImpl<ClientProfilePackage>(this as ClientProfilePackage, _$identity);

  /// Serializes this ClientProfilePackage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientProfilePackage&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.price, price) || other.price == price)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.includedPhotos, includedPhotos) || other.includedPhotos == includedPhotos)&&(identical(other.extraPhotoPrice, extraPhotoPrice) || other.extraPhotoPrice == extraPhotoPrice)&&(identical(other.proofsSlaDays, proofsSlaDays) || other.proofsSlaDays == proofsSlaDays)&&(identical(other.finalsSlaDays, finalsSlaDays) || other.finalsSlaDays == finalsSlaDays));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,durationMinutes,price,currency,includedPhotos,extraPhotoPrice,proofsSlaDays,finalsSlaDays);

@override
String toString() {
  return 'ClientProfilePackage(id: $id, title: $title, description: $description, durationMinutes: $durationMinutes, price: $price, currency: $currency, includedPhotos: $includedPhotos, extraPhotoPrice: $extraPhotoPrice, proofsSlaDays: $proofsSlaDays, finalsSlaDays: $finalsSlaDays)';
}


}

/// @nodoc
abstract mixin class $ClientProfilePackageCopyWith<$Res>  {
  factory $ClientProfilePackageCopyWith(ClientProfilePackage value, $Res Function(ClientProfilePackage) _then) = _$ClientProfilePackageCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ClientProfilePackage.idKey_) String id,@JsonKey(name: ClientProfilePackage.titleKey_) String title,@JsonKey(name: ClientProfilePackage.descriptionKey_) String? description,@JsonKey(name: ClientProfilePackage.durationMinutesKey_) int durationMinutes,@JsonKey(name: ClientProfilePackage.priceKey_) String price,@JsonKey(name: ClientProfilePackage.currencyKey_) String currency,@JsonKey(name: ClientProfilePackage.includedPhotosKey_) int includedPhotos,@JsonKey(name: ClientProfilePackage.extraPhotoPriceKey_) String extraPhotoPrice,@JsonKey(name: ClientProfilePackage.proofsSlaDaysKey_) int proofsSlaDays,@JsonKey(name: ClientProfilePackage.finalsSlaDaysKey_) int finalsSlaDays
});




}
/// @nodoc
class _$ClientProfilePackageCopyWithImpl<$Res>
    implements $ClientProfilePackageCopyWith<$Res> {
  _$ClientProfilePackageCopyWithImpl(this._self, this._then);

  final ClientProfilePackage _self;
  final $Res Function(ClientProfilePackage) _then;

/// Create a copy of ClientProfilePackage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? durationMinutes = null,Object? price = null,Object? currency = null,Object? includedPhotos = null,Object? extraPhotoPrice = null,Object? proofsSlaDays = null,Object? finalsSlaDays = null,}) {
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
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ClientProfilePackage].
extension ClientProfilePackagePatterns on ClientProfilePackage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientProfilePackage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientProfilePackage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientProfilePackage value)  $default,){
final _that = this;
switch (_that) {
case _ClientProfilePackage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientProfilePackage value)?  $default,){
final _that = this;
switch (_that) {
case _ClientProfilePackage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ClientProfilePackage.idKey_)  String id, @JsonKey(name: ClientProfilePackage.titleKey_)  String title, @JsonKey(name: ClientProfilePackage.descriptionKey_)  String? description, @JsonKey(name: ClientProfilePackage.durationMinutesKey_)  int durationMinutes, @JsonKey(name: ClientProfilePackage.priceKey_)  String price, @JsonKey(name: ClientProfilePackage.currencyKey_)  String currency, @JsonKey(name: ClientProfilePackage.includedPhotosKey_)  int includedPhotos, @JsonKey(name: ClientProfilePackage.extraPhotoPriceKey_)  String extraPhotoPrice, @JsonKey(name: ClientProfilePackage.proofsSlaDaysKey_)  int proofsSlaDays, @JsonKey(name: ClientProfilePackage.finalsSlaDaysKey_)  int finalsSlaDays)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientProfilePackage() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.durationMinutes,_that.price,_that.currency,_that.includedPhotos,_that.extraPhotoPrice,_that.proofsSlaDays,_that.finalsSlaDays);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ClientProfilePackage.idKey_)  String id, @JsonKey(name: ClientProfilePackage.titleKey_)  String title, @JsonKey(name: ClientProfilePackage.descriptionKey_)  String? description, @JsonKey(name: ClientProfilePackage.durationMinutesKey_)  int durationMinutes, @JsonKey(name: ClientProfilePackage.priceKey_)  String price, @JsonKey(name: ClientProfilePackage.currencyKey_)  String currency, @JsonKey(name: ClientProfilePackage.includedPhotosKey_)  int includedPhotos, @JsonKey(name: ClientProfilePackage.extraPhotoPriceKey_)  String extraPhotoPrice, @JsonKey(name: ClientProfilePackage.proofsSlaDaysKey_)  int proofsSlaDays, @JsonKey(name: ClientProfilePackage.finalsSlaDaysKey_)  int finalsSlaDays)  $default,) {final _that = this;
switch (_that) {
case _ClientProfilePackage():
return $default(_that.id,_that.title,_that.description,_that.durationMinutes,_that.price,_that.currency,_that.includedPhotos,_that.extraPhotoPrice,_that.proofsSlaDays,_that.finalsSlaDays);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ClientProfilePackage.idKey_)  String id, @JsonKey(name: ClientProfilePackage.titleKey_)  String title, @JsonKey(name: ClientProfilePackage.descriptionKey_)  String? description, @JsonKey(name: ClientProfilePackage.durationMinutesKey_)  int durationMinutes, @JsonKey(name: ClientProfilePackage.priceKey_)  String price, @JsonKey(name: ClientProfilePackage.currencyKey_)  String currency, @JsonKey(name: ClientProfilePackage.includedPhotosKey_)  int includedPhotos, @JsonKey(name: ClientProfilePackage.extraPhotoPriceKey_)  String extraPhotoPrice, @JsonKey(name: ClientProfilePackage.proofsSlaDaysKey_)  int proofsSlaDays, @JsonKey(name: ClientProfilePackage.finalsSlaDaysKey_)  int finalsSlaDays)?  $default,) {final _that = this;
switch (_that) {
case _ClientProfilePackage() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.durationMinutes,_that.price,_that.currency,_that.includedPhotos,_that.extraPhotoPrice,_that.proofsSlaDays,_that.finalsSlaDays);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ClientProfilePackage extends ClientProfilePackage {
  const _ClientProfilePackage({@JsonKey(name: ClientProfilePackage.idKey_) required this.id, @JsonKey(name: ClientProfilePackage.titleKey_) required this.title, @JsonKey(name: ClientProfilePackage.descriptionKey_) this.description, @JsonKey(name: ClientProfilePackage.durationMinutesKey_) required this.durationMinutes, @JsonKey(name: ClientProfilePackage.priceKey_) required this.price, @JsonKey(name: ClientProfilePackage.currencyKey_) required this.currency, @JsonKey(name: ClientProfilePackage.includedPhotosKey_) required this.includedPhotos, @JsonKey(name: ClientProfilePackage.extraPhotoPriceKey_) required this.extraPhotoPrice, @JsonKey(name: ClientProfilePackage.proofsSlaDaysKey_) required this.proofsSlaDays, @JsonKey(name: ClientProfilePackage.finalsSlaDaysKey_) required this.finalsSlaDays}): super._();
  factory _ClientProfilePackage.fromJson(Map<String, dynamic> json) => _$ClientProfilePackageFromJson(json);

/// id
@override@JsonKey(name: ClientProfilePackage.idKey_) final  String id;
/// title
@override@JsonKey(name: ClientProfilePackage.titleKey_) final  String title;
/// description
@override@JsonKey(name: ClientProfilePackage.descriptionKey_) final  String? description;
/// durationMinutes
@override@JsonKey(name: ClientProfilePackage.durationMinutesKey_) final  int durationMinutes;
/// price
@override@JsonKey(name: ClientProfilePackage.priceKey_) final  String price;
/// currency
@override@JsonKey(name: ClientProfilePackage.currencyKey_) final  String currency;
/// includedPhotos
@override@JsonKey(name: ClientProfilePackage.includedPhotosKey_) final  int includedPhotos;
/// extraPhotoPrice
@override@JsonKey(name: ClientProfilePackage.extraPhotoPriceKey_) final  String extraPhotoPrice;
/// proofsSlaDays
@override@JsonKey(name: ClientProfilePackage.proofsSlaDaysKey_) final  int proofsSlaDays;
/// finalsSlaDays
@override@JsonKey(name: ClientProfilePackage.finalsSlaDaysKey_) final  int finalsSlaDays;

/// Create a copy of ClientProfilePackage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientProfilePackageCopyWith<_ClientProfilePackage> get copyWith => __$ClientProfilePackageCopyWithImpl<_ClientProfilePackage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientProfilePackageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientProfilePackage&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.price, price) || other.price == price)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.includedPhotos, includedPhotos) || other.includedPhotos == includedPhotos)&&(identical(other.extraPhotoPrice, extraPhotoPrice) || other.extraPhotoPrice == extraPhotoPrice)&&(identical(other.proofsSlaDays, proofsSlaDays) || other.proofsSlaDays == proofsSlaDays)&&(identical(other.finalsSlaDays, finalsSlaDays) || other.finalsSlaDays == finalsSlaDays));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,durationMinutes,price,currency,includedPhotos,extraPhotoPrice,proofsSlaDays,finalsSlaDays);

@override
String toString() {
  return 'ClientProfilePackage(id: $id, title: $title, description: $description, durationMinutes: $durationMinutes, price: $price, currency: $currency, includedPhotos: $includedPhotos, extraPhotoPrice: $extraPhotoPrice, proofsSlaDays: $proofsSlaDays, finalsSlaDays: $finalsSlaDays)';
}


}

/// @nodoc
abstract mixin class _$ClientProfilePackageCopyWith<$Res> implements $ClientProfilePackageCopyWith<$Res> {
  factory _$ClientProfilePackageCopyWith(_ClientProfilePackage value, $Res Function(_ClientProfilePackage) _then) = __$ClientProfilePackageCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ClientProfilePackage.idKey_) String id,@JsonKey(name: ClientProfilePackage.titleKey_) String title,@JsonKey(name: ClientProfilePackage.descriptionKey_) String? description,@JsonKey(name: ClientProfilePackage.durationMinutesKey_) int durationMinutes,@JsonKey(name: ClientProfilePackage.priceKey_) String price,@JsonKey(name: ClientProfilePackage.currencyKey_) String currency,@JsonKey(name: ClientProfilePackage.includedPhotosKey_) int includedPhotos,@JsonKey(name: ClientProfilePackage.extraPhotoPriceKey_) String extraPhotoPrice,@JsonKey(name: ClientProfilePackage.proofsSlaDaysKey_) int proofsSlaDays,@JsonKey(name: ClientProfilePackage.finalsSlaDaysKey_) int finalsSlaDays
});




}
/// @nodoc
class __$ClientProfilePackageCopyWithImpl<$Res>
    implements _$ClientProfilePackageCopyWith<$Res> {
  __$ClientProfilePackageCopyWithImpl(this._self, this._then);

  final _ClientProfilePackage _self;
  final $Res Function(_ClientProfilePackage) _then;

/// Create a copy of ClientProfilePackage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? durationMinutes = null,Object? price = null,Object? currency = null,Object? includedPhotos = null,Object? extraPhotoPrice = null,Object? proofsSlaDays = null,Object? finalsSlaDays = null,}) {
  return _then(_ClientProfilePackage(
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
as int,
  ));
}


}

// dart format on
