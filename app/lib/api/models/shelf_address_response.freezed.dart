// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shelf_address_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ShelfAddressResponse {

/// address
@JsonKey(name: ShelfAddressResponse.addressKey_) ShelfAddress? get address;/// allowedCountries
@JsonKey(name: ShelfAddressResponse.allowedCountriesKey_) List<String> get allowedCountries;
/// Create a copy of ShelfAddressResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShelfAddressResponseCopyWith<ShelfAddressResponse> get copyWith => _$ShelfAddressResponseCopyWithImpl<ShelfAddressResponse>(this as ShelfAddressResponse, _$identity);

  /// Serializes this ShelfAddressResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShelfAddressResponse&&(identical(other.address, address) || other.address == address)&&const DeepCollectionEquality().equals(other.allowedCountries, allowedCountries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,address,const DeepCollectionEquality().hash(allowedCountries));

@override
String toString() {
  return 'ShelfAddressResponse(address: $address, allowedCountries: $allowedCountries)';
}


}

/// @nodoc
abstract mixin class $ShelfAddressResponseCopyWith<$Res>  {
  factory $ShelfAddressResponseCopyWith(ShelfAddressResponse value, $Res Function(ShelfAddressResponse) _then) = _$ShelfAddressResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ShelfAddressResponse.addressKey_) ShelfAddress? address,@JsonKey(name: ShelfAddressResponse.allowedCountriesKey_) List<String> allowedCountries
});


$ShelfAddressCopyWith<$Res>? get address;

}
/// @nodoc
class _$ShelfAddressResponseCopyWithImpl<$Res>
    implements $ShelfAddressResponseCopyWith<$Res> {
  _$ShelfAddressResponseCopyWithImpl(this._self, this._then);

  final ShelfAddressResponse _self;
  final $Res Function(ShelfAddressResponse) _then;

/// Create a copy of ShelfAddressResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? address = freezed,Object? allowedCountries = null,}) {
  return _then(_self.copyWith(
address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as ShelfAddress?,allowedCountries: null == allowedCountries ? _self.allowedCountries : allowedCountries // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}
/// Create a copy of ShelfAddressResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShelfAddressCopyWith<$Res>? get address {
    if (_self.address == null) {
    return null;
  }

  return $ShelfAddressCopyWith<$Res>(_self.address!, (value) {
    return _then(_self.copyWith(address: value));
  });
}
}


/// Adds pattern-matching-related methods to [ShelfAddressResponse].
extension ShelfAddressResponsePatterns on ShelfAddressResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShelfAddressResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShelfAddressResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShelfAddressResponse value)  $default,){
final _that = this;
switch (_that) {
case _ShelfAddressResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShelfAddressResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ShelfAddressResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ShelfAddressResponse.addressKey_)  ShelfAddress? address, @JsonKey(name: ShelfAddressResponse.allowedCountriesKey_)  List<String> allowedCountries)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShelfAddressResponse() when $default != null:
return $default(_that.address,_that.allowedCountries);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ShelfAddressResponse.addressKey_)  ShelfAddress? address, @JsonKey(name: ShelfAddressResponse.allowedCountriesKey_)  List<String> allowedCountries)  $default,) {final _that = this;
switch (_that) {
case _ShelfAddressResponse():
return $default(_that.address,_that.allowedCountries);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ShelfAddressResponse.addressKey_)  ShelfAddress? address, @JsonKey(name: ShelfAddressResponse.allowedCountriesKey_)  List<String> allowedCountries)?  $default,) {final _that = this;
switch (_that) {
case _ShelfAddressResponse() when $default != null:
return $default(_that.address,_that.allowedCountries);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ShelfAddressResponse extends ShelfAddressResponse {
  const _ShelfAddressResponse({@JsonKey(name: ShelfAddressResponse.addressKey_) this.address, @JsonKey(name: ShelfAddressResponse.allowedCountriesKey_) required final  List<String> allowedCountries}): _allowedCountries = allowedCountries,super._();
  factory _ShelfAddressResponse.fromJson(Map<String, dynamic> json) => _$ShelfAddressResponseFromJson(json);

/// address
@override@JsonKey(name: ShelfAddressResponse.addressKey_) final  ShelfAddress? address;
/// allowedCountries
 final  List<String> _allowedCountries;
/// allowedCountries
@override@JsonKey(name: ShelfAddressResponse.allowedCountriesKey_) List<String> get allowedCountries {
  if (_allowedCountries is EqualUnmodifiableListView) return _allowedCountries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allowedCountries);
}


/// Create a copy of ShelfAddressResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShelfAddressResponseCopyWith<_ShelfAddressResponse> get copyWith => __$ShelfAddressResponseCopyWithImpl<_ShelfAddressResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShelfAddressResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShelfAddressResponse&&(identical(other.address, address) || other.address == address)&&const DeepCollectionEquality().equals(other._allowedCountries, _allowedCountries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,address,const DeepCollectionEquality().hash(_allowedCountries));

@override
String toString() {
  return 'ShelfAddressResponse(address: $address, allowedCountries: $allowedCountries)';
}


}

/// @nodoc
abstract mixin class _$ShelfAddressResponseCopyWith<$Res> implements $ShelfAddressResponseCopyWith<$Res> {
  factory _$ShelfAddressResponseCopyWith(_ShelfAddressResponse value, $Res Function(_ShelfAddressResponse) _then) = __$ShelfAddressResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ShelfAddressResponse.addressKey_) ShelfAddress? address,@JsonKey(name: ShelfAddressResponse.allowedCountriesKey_) List<String> allowedCountries
});


@override $ShelfAddressCopyWith<$Res>? get address;

}
/// @nodoc
class __$ShelfAddressResponseCopyWithImpl<$Res>
    implements _$ShelfAddressResponseCopyWith<$Res> {
  __$ShelfAddressResponseCopyWithImpl(this._self, this._then);

  final _ShelfAddressResponse _self;
  final $Res Function(_ShelfAddressResponse) _then;

/// Create a copy of ShelfAddressResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? address = freezed,Object? allowedCountries = null,}) {
  return _then(_ShelfAddressResponse(
address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as ShelfAddress?,allowedCountries: null == allowedCountries ? _self._allowedCountries : allowedCountries // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

/// Create a copy of ShelfAddressResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShelfAddressCopyWith<$Res>? get address {
    if (_self.address == null) {
    return null;
  }

  return $ShelfAddressCopyWith<$Res>(_self.address!, (value) {
    return _then(_self.copyWith(address: value));
  });
}
}

// dart format on
