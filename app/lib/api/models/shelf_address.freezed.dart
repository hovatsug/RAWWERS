// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shelf_address.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ShelfAddress {

/// name
@JsonKey(name: ShelfAddress.nameKey_) String? get name;/// line1
@JsonKey(name: ShelfAddress.line1Key_) String? get line1;/// line2
@JsonKey(name: ShelfAddress.line2Key_) String? get line2;/// city
@JsonKey(name: ShelfAddress.cityKey_) String? get city;/// region
@JsonKey(name: ShelfAddress.regionKey_) String? get region;/// postalCode
@JsonKey(name: ShelfAddress.postalCodeKey_) String? get postalCode;/// country
@JsonKey(name: ShelfAddress.countryKey_) String? get country;/// phone
@JsonKey(name: ShelfAddress.phoneKey_) String? get phone;
/// Create a copy of ShelfAddress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShelfAddressCopyWith<ShelfAddress> get copyWith => _$ShelfAddressCopyWithImpl<ShelfAddress>(this as ShelfAddress, _$identity);

  /// Serializes this ShelfAddress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShelfAddress&&(identical(other.name, name) || other.name == name)&&(identical(other.line1, line1) || other.line1 == line1)&&(identical(other.line2, line2) || other.line2 == line2)&&(identical(other.city, city) || other.city == city)&&(identical(other.region, region) || other.region == region)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.country, country) || other.country == country)&&(identical(other.phone, phone) || other.phone == phone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,line1,line2,city,region,postalCode,country,phone);

@override
String toString() {
  return 'ShelfAddress(name: $name, line1: $line1, line2: $line2, city: $city, region: $region, postalCode: $postalCode, country: $country, phone: $phone)';
}


}

/// @nodoc
abstract mixin class $ShelfAddressCopyWith<$Res>  {
  factory $ShelfAddressCopyWith(ShelfAddress value, $Res Function(ShelfAddress) _then) = _$ShelfAddressCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ShelfAddress.nameKey_) String? name,@JsonKey(name: ShelfAddress.line1Key_) String? line1,@JsonKey(name: ShelfAddress.line2Key_) String? line2,@JsonKey(name: ShelfAddress.cityKey_) String? city,@JsonKey(name: ShelfAddress.regionKey_) String? region,@JsonKey(name: ShelfAddress.postalCodeKey_) String? postalCode,@JsonKey(name: ShelfAddress.countryKey_) String? country,@JsonKey(name: ShelfAddress.phoneKey_) String? phone
});




}
/// @nodoc
class _$ShelfAddressCopyWithImpl<$Res>
    implements $ShelfAddressCopyWith<$Res> {
  _$ShelfAddressCopyWithImpl(this._self, this._then);

  final ShelfAddress _self;
  final $Res Function(ShelfAddress) _then;

/// Create a copy of ShelfAddress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? line1 = freezed,Object? line2 = freezed,Object? city = freezed,Object? region = freezed,Object? postalCode = freezed,Object? country = freezed,Object? phone = freezed,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,line1: freezed == line1 ? _self.line1 : line1 // ignore: cast_nullable_to_non_nullable
as String?,line2: freezed == line2 ? _self.line2 : line2 // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String?,postalCode: freezed == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ShelfAddress].
extension ShelfAddressPatterns on ShelfAddress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShelfAddress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShelfAddress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShelfAddress value)  $default,){
final _that = this;
switch (_that) {
case _ShelfAddress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShelfAddress value)?  $default,){
final _that = this;
switch (_that) {
case _ShelfAddress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ShelfAddress.nameKey_)  String? name, @JsonKey(name: ShelfAddress.line1Key_)  String? line1, @JsonKey(name: ShelfAddress.line2Key_)  String? line2, @JsonKey(name: ShelfAddress.cityKey_)  String? city, @JsonKey(name: ShelfAddress.regionKey_)  String? region, @JsonKey(name: ShelfAddress.postalCodeKey_)  String? postalCode, @JsonKey(name: ShelfAddress.countryKey_)  String? country, @JsonKey(name: ShelfAddress.phoneKey_)  String? phone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShelfAddress() when $default != null:
return $default(_that.name,_that.line1,_that.line2,_that.city,_that.region,_that.postalCode,_that.country,_that.phone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ShelfAddress.nameKey_)  String? name, @JsonKey(name: ShelfAddress.line1Key_)  String? line1, @JsonKey(name: ShelfAddress.line2Key_)  String? line2, @JsonKey(name: ShelfAddress.cityKey_)  String? city, @JsonKey(name: ShelfAddress.regionKey_)  String? region, @JsonKey(name: ShelfAddress.postalCodeKey_)  String? postalCode, @JsonKey(name: ShelfAddress.countryKey_)  String? country, @JsonKey(name: ShelfAddress.phoneKey_)  String? phone)  $default,) {final _that = this;
switch (_that) {
case _ShelfAddress():
return $default(_that.name,_that.line1,_that.line2,_that.city,_that.region,_that.postalCode,_that.country,_that.phone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ShelfAddress.nameKey_)  String? name, @JsonKey(name: ShelfAddress.line1Key_)  String? line1, @JsonKey(name: ShelfAddress.line2Key_)  String? line2, @JsonKey(name: ShelfAddress.cityKey_)  String? city, @JsonKey(name: ShelfAddress.regionKey_)  String? region, @JsonKey(name: ShelfAddress.postalCodeKey_)  String? postalCode, @JsonKey(name: ShelfAddress.countryKey_)  String? country, @JsonKey(name: ShelfAddress.phoneKey_)  String? phone)?  $default,) {final _that = this;
switch (_that) {
case _ShelfAddress() when $default != null:
return $default(_that.name,_that.line1,_that.line2,_that.city,_that.region,_that.postalCode,_that.country,_that.phone);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ShelfAddress extends ShelfAddress {
  const _ShelfAddress({@JsonKey(name: ShelfAddress.nameKey_) this.name, @JsonKey(name: ShelfAddress.line1Key_) this.line1, @JsonKey(name: ShelfAddress.line2Key_) this.line2, @JsonKey(name: ShelfAddress.cityKey_) this.city, @JsonKey(name: ShelfAddress.regionKey_) this.region, @JsonKey(name: ShelfAddress.postalCodeKey_) this.postalCode, @JsonKey(name: ShelfAddress.countryKey_) this.country, @JsonKey(name: ShelfAddress.phoneKey_) this.phone}): super._();
  factory _ShelfAddress.fromJson(Map<String, dynamic> json) => _$ShelfAddressFromJson(json);

/// name
@override@JsonKey(name: ShelfAddress.nameKey_) final  String? name;
/// line1
@override@JsonKey(name: ShelfAddress.line1Key_) final  String? line1;
/// line2
@override@JsonKey(name: ShelfAddress.line2Key_) final  String? line2;
/// city
@override@JsonKey(name: ShelfAddress.cityKey_) final  String? city;
/// region
@override@JsonKey(name: ShelfAddress.regionKey_) final  String? region;
/// postalCode
@override@JsonKey(name: ShelfAddress.postalCodeKey_) final  String? postalCode;
/// country
@override@JsonKey(name: ShelfAddress.countryKey_) final  String? country;
/// phone
@override@JsonKey(name: ShelfAddress.phoneKey_) final  String? phone;

/// Create a copy of ShelfAddress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShelfAddressCopyWith<_ShelfAddress> get copyWith => __$ShelfAddressCopyWithImpl<_ShelfAddress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShelfAddressToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShelfAddress&&(identical(other.name, name) || other.name == name)&&(identical(other.line1, line1) || other.line1 == line1)&&(identical(other.line2, line2) || other.line2 == line2)&&(identical(other.city, city) || other.city == city)&&(identical(other.region, region) || other.region == region)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.country, country) || other.country == country)&&(identical(other.phone, phone) || other.phone == phone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,line1,line2,city,region,postalCode,country,phone);

@override
String toString() {
  return 'ShelfAddress(name: $name, line1: $line1, line2: $line2, city: $city, region: $region, postalCode: $postalCode, country: $country, phone: $phone)';
}


}

/// @nodoc
abstract mixin class _$ShelfAddressCopyWith<$Res> implements $ShelfAddressCopyWith<$Res> {
  factory _$ShelfAddressCopyWith(_ShelfAddress value, $Res Function(_ShelfAddress) _then) = __$ShelfAddressCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ShelfAddress.nameKey_) String? name,@JsonKey(name: ShelfAddress.line1Key_) String? line1,@JsonKey(name: ShelfAddress.line2Key_) String? line2,@JsonKey(name: ShelfAddress.cityKey_) String? city,@JsonKey(name: ShelfAddress.regionKey_) String? region,@JsonKey(name: ShelfAddress.postalCodeKey_) String? postalCode,@JsonKey(name: ShelfAddress.countryKey_) String? country,@JsonKey(name: ShelfAddress.phoneKey_) String? phone
});




}
/// @nodoc
class __$ShelfAddressCopyWithImpl<$Res>
    implements _$ShelfAddressCopyWith<$Res> {
  __$ShelfAddressCopyWithImpl(this._self, this._then);

  final _ShelfAddress _self;
  final $Res Function(_ShelfAddress) _then;

/// Create a copy of ShelfAddress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? line1 = freezed,Object? line2 = freezed,Object? city = freezed,Object? region = freezed,Object? postalCode = freezed,Object? country = freezed,Object? phone = freezed,}) {
  return _then(_ShelfAddress(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,line1: freezed == line1 ? _self.line1 : line1 // ignore: cast_nullable_to_non_nullable
as String?,line2: freezed == line2 ? _self.line2 : line2 // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String?,postalCode: freezed == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
