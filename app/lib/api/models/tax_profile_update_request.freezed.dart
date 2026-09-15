// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tax_profile_update_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TaxProfileUpdateRequest {

/// vatStatus
@JsonKey(name: TaxProfileUpdateRequest.vatStatusKey_) String get vatStatus;/// vatNumber
@JsonKey(name: TaxProfileUpdateRequest.vatNumberKey_) String? get vatNumber;/// country
@JsonKey(name: TaxProfileUpdateRequest.countryKey_) String? get country;
/// Create a copy of TaxProfileUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaxProfileUpdateRequestCopyWith<TaxProfileUpdateRequest> get copyWith => _$TaxProfileUpdateRequestCopyWithImpl<TaxProfileUpdateRequest>(this as TaxProfileUpdateRequest, _$identity);

  /// Serializes this TaxProfileUpdateRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaxProfileUpdateRequest&&(identical(other.vatStatus, vatStatus) || other.vatStatus == vatStatus)&&(identical(other.vatNumber, vatNumber) || other.vatNumber == vatNumber)&&(identical(other.country, country) || other.country == country));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,vatStatus,vatNumber,country);

@override
String toString() {
  return 'TaxProfileUpdateRequest(vatStatus: $vatStatus, vatNumber: $vatNumber, country: $country)';
}


}

/// @nodoc
abstract mixin class $TaxProfileUpdateRequestCopyWith<$Res>  {
  factory $TaxProfileUpdateRequestCopyWith(TaxProfileUpdateRequest value, $Res Function(TaxProfileUpdateRequest) _then) = _$TaxProfileUpdateRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: TaxProfileUpdateRequest.vatStatusKey_) String vatStatus,@JsonKey(name: TaxProfileUpdateRequest.vatNumberKey_) String? vatNumber,@JsonKey(name: TaxProfileUpdateRequest.countryKey_) String? country
});




}
/// @nodoc
class _$TaxProfileUpdateRequestCopyWithImpl<$Res>
    implements $TaxProfileUpdateRequestCopyWith<$Res> {
  _$TaxProfileUpdateRequestCopyWithImpl(this._self, this._then);

  final TaxProfileUpdateRequest _self;
  final $Res Function(TaxProfileUpdateRequest) _then;

/// Create a copy of TaxProfileUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? vatStatus = null,Object? vatNumber = freezed,Object? country = freezed,}) {
  return _then(_self.copyWith(
vatStatus: null == vatStatus ? _self.vatStatus : vatStatus // ignore: cast_nullable_to_non_nullable
as String,vatNumber: freezed == vatNumber ? _self.vatNumber : vatNumber // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TaxProfileUpdateRequest].
extension TaxProfileUpdateRequestPatterns on TaxProfileUpdateRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaxProfileUpdateRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaxProfileUpdateRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaxProfileUpdateRequest value)  $default,){
final _that = this;
switch (_that) {
case _TaxProfileUpdateRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaxProfileUpdateRequest value)?  $default,){
final _that = this;
switch (_that) {
case _TaxProfileUpdateRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: TaxProfileUpdateRequest.vatStatusKey_)  String vatStatus, @JsonKey(name: TaxProfileUpdateRequest.vatNumberKey_)  String? vatNumber, @JsonKey(name: TaxProfileUpdateRequest.countryKey_)  String? country)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaxProfileUpdateRequest() when $default != null:
return $default(_that.vatStatus,_that.vatNumber,_that.country);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: TaxProfileUpdateRequest.vatStatusKey_)  String vatStatus, @JsonKey(name: TaxProfileUpdateRequest.vatNumberKey_)  String? vatNumber, @JsonKey(name: TaxProfileUpdateRequest.countryKey_)  String? country)  $default,) {final _that = this;
switch (_that) {
case _TaxProfileUpdateRequest():
return $default(_that.vatStatus,_that.vatNumber,_that.country);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: TaxProfileUpdateRequest.vatStatusKey_)  String vatStatus, @JsonKey(name: TaxProfileUpdateRequest.vatNumberKey_)  String? vatNumber, @JsonKey(name: TaxProfileUpdateRequest.countryKey_)  String? country)?  $default,) {final _that = this;
switch (_that) {
case _TaxProfileUpdateRequest() when $default != null:
return $default(_that.vatStatus,_that.vatNumber,_that.country);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _TaxProfileUpdateRequest extends TaxProfileUpdateRequest {
  const _TaxProfileUpdateRequest({@JsonKey(name: TaxProfileUpdateRequest.vatStatusKey_) required this.vatStatus, @JsonKey(name: TaxProfileUpdateRequest.vatNumberKey_) this.vatNumber, @JsonKey(name: TaxProfileUpdateRequest.countryKey_) this.country}): super._();
  factory _TaxProfileUpdateRequest.fromJson(Map<String, dynamic> json) => _$TaxProfileUpdateRequestFromJson(json);

/// vatStatus
@override@JsonKey(name: TaxProfileUpdateRequest.vatStatusKey_) final  String vatStatus;
/// vatNumber
@override@JsonKey(name: TaxProfileUpdateRequest.vatNumberKey_) final  String? vatNumber;
/// country
@override@JsonKey(name: TaxProfileUpdateRequest.countryKey_) final  String? country;

/// Create a copy of TaxProfileUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaxProfileUpdateRequestCopyWith<_TaxProfileUpdateRequest> get copyWith => __$TaxProfileUpdateRequestCopyWithImpl<_TaxProfileUpdateRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaxProfileUpdateRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaxProfileUpdateRequest&&(identical(other.vatStatus, vatStatus) || other.vatStatus == vatStatus)&&(identical(other.vatNumber, vatNumber) || other.vatNumber == vatNumber)&&(identical(other.country, country) || other.country == country));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,vatStatus,vatNumber,country);

@override
String toString() {
  return 'TaxProfileUpdateRequest(vatStatus: $vatStatus, vatNumber: $vatNumber, country: $country)';
}


}

/// @nodoc
abstract mixin class _$TaxProfileUpdateRequestCopyWith<$Res> implements $TaxProfileUpdateRequestCopyWith<$Res> {
  factory _$TaxProfileUpdateRequestCopyWith(_TaxProfileUpdateRequest value, $Res Function(_TaxProfileUpdateRequest) _then) = __$TaxProfileUpdateRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: TaxProfileUpdateRequest.vatStatusKey_) String vatStatus,@JsonKey(name: TaxProfileUpdateRequest.vatNumberKey_) String? vatNumber,@JsonKey(name: TaxProfileUpdateRequest.countryKey_) String? country
});




}
/// @nodoc
class __$TaxProfileUpdateRequestCopyWithImpl<$Res>
    implements _$TaxProfileUpdateRequestCopyWith<$Res> {
  __$TaxProfileUpdateRequestCopyWithImpl(this._self, this._then);

  final _TaxProfileUpdateRequest _self;
  final $Res Function(_TaxProfileUpdateRequest) _then;

/// Create a copy of TaxProfileUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? vatStatus = null,Object? vatNumber = freezed,Object? country = freezed,}) {
  return _then(_TaxProfileUpdateRequest(
vatStatus: null == vatStatus ? _self.vatStatus : vatStatus // ignore: cast_nullable_to_non_nullable
as String,vatNumber: freezed == vatNumber ? _self.vatNumber : vatNumber // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
