// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_proof_gallery_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateProofGalleryRequest {

/// includedPhotos
@JsonKey(name: CreateProofGalleryRequest.includedPhotosKey_) int get includedPhotos;/// extraPhotoPrice
@JsonKey(name: CreateProofGalleryRequest.extraPhotoPriceKey_) dynamic get extraPhotoPrice;
/// Create a copy of CreateProofGalleryRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateProofGalleryRequestCopyWith<CreateProofGalleryRequest> get copyWith => _$CreateProofGalleryRequestCopyWithImpl<CreateProofGalleryRequest>(this as CreateProofGalleryRequest, _$identity);

  /// Serializes this CreateProofGalleryRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateProofGalleryRequest&&(identical(other.includedPhotos, includedPhotos) || other.includedPhotos == includedPhotos)&&const DeepCollectionEquality().equals(other.extraPhotoPrice, extraPhotoPrice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,includedPhotos,const DeepCollectionEquality().hash(extraPhotoPrice));

@override
String toString() {
  return 'CreateProofGalleryRequest(includedPhotos: $includedPhotos, extraPhotoPrice: $extraPhotoPrice)';
}


}

/// @nodoc
abstract mixin class $CreateProofGalleryRequestCopyWith<$Res>  {
  factory $CreateProofGalleryRequestCopyWith(CreateProofGalleryRequest value, $Res Function(CreateProofGalleryRequest) _then) = _$CreateProofGalleryRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: CreateProofGalleryRequest.includedPhotosKey_) int includedPhotos,@JsonKey(name: CreateProofGalleryRequest.extraPhotoPriceKey_) dynamic extraPhotoPrice
});




}
/// @nodoc
class _$CreateProofGalleryRequestCopyWithImpl<$Res>
    implements $CreateProofGalleryRequestCopyWith<$Res> {
  _$CreateProofGalleryRequestCopyWithImpl(this._self, this._then);

  final CreateProofGalleryRequest _self;
  final $Res Function(CreateProofGalleryRequest) _then;

/// Create a copy of CreateProofGalleryRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? includedPhotos = null,Object? extraPhotoPrice = freezed,}) {
  return _then(_self.copyWith(
includedPhotos: null == includedPhotos ? _self.includedPhotos : includedPhotos // ignore: cast_nullable_to_non_nullable
as int,extraPhotoPrice: freezed == extraPhotoPrice ? _self.extraPhotoPrice : extraPhotoPrice // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateProofGalleryRequest].
extension CreateProofGalleryRequestPatterns on CreateProofGalleryRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateProofGalleryRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateProofGalleryRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateProofGalleryRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateProofGalleryRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateProofGalleryRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateProofGalleryRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: CreateProofGalleryRequest.includedPhotosKey_)  int includedPhotos, @JsonKey(name: CreateProofGalleryRequest.extraPhotoPriceKey_)  dynamic extraPhotoPrice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateProofGalleryRequest() when $default != null:
return $default(_that.includedPhotos,_that.extraPhotoPrice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: CreateProofGalleryRequest.includedPhotosKey_)  int includedPhotos, @JsonKey(name: CreateProofGalleryRequest.extraPhotoPriceKey_)  dynamic extraPhotoPrice)  $default,) {final _that = this;
switch (_that) {
case _CreateProofGalleryRequest():
return $default(_that.includedPhotos,_that.extraPhotoPrice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: CreateProofGalleryRequest.includedPhotosKey_)  int includedPhotos, @JsonKey(name: CreateProofGalleryRequest.extraPhotoPriceKey_)  dynamic extraPhotoPrice)?  $default,) {final _that = this;
switch (_that) {
case _CreateProofGalleryRequest() when $default != null:
return $default(_that.includedPhotos,_that.extraPhotoPrice);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _CreateProofGalleryRequest extends CreateProofGalleryRequest {
  const _CreateProofGalleryRequest({@JsonKey(name: CreateProofGalleryRequest.includedPhotosKey_) required this.includedPhotos, @JsonKey(name: CreateProofGalleryRequest.extraPhotoPriceKey_) required this.extraPhotoPrice}): super._();
  factory _CreateProofGalleryRequest.fromJson(Map<String, dynamic> json) => _$CreateProofGalleryRequestFromJson(json);

/// includedPhotos
@override@JsonKey(name: CreateProofGalleryRequest.includedPhotosKey_) final  int includedPhotos;
/// extraPhotoPrice
@override@JsonKey(name: CreateProofGalleryRequest.extraPhotoPriceKey_) final  dynamic extraPhotoPrice;

/// Create a copy of CreateProofGalleryRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateProofGalleryRequestCopyWith<_CreateProofGalleryRequest> get copyWith => __$CreateProofGalleryRequestCopyWithImpl<_CreateProofGalleryRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateProofGalleryRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateProofGalleryRequest&&(identical(other.includedPhotos, includedPhotos) || other.includedPhotos == includedPhotos)&&const DeepCollectionEquality().equals(other.extraPhotoPrice, extraPhotoPrice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,includedPhotos,const DeepCollectionEquality().hash(extraPhotoPrice));

@override
String toString() {
  return 'CreateProofGalleryRequest(includedPhotos: $includedPhotos, extraPhotoPrice: $extraPhotoPrice)';
}


}

/// @nodoc
abstract mixin class _$CreateProofGalleryRequestCopyWith<$Res> implements $CreateProofGalleryRequestCopyWith<$Res> {
  factory _$CreateProofGalleryRequestCopyWith(_CreateProofGalleryRequest value, $Res Function(_CreateProofGalleryRequest) _then) = __$CreateProofGalleryRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: CreateProofGalleryRequest.includedPhotosKey_) int includedPhotos,@JsonKey(name: CreateProofGalleryRequest.extraPhotoPriceKey_) dynamic extraPhotoPrice
});




}
/// @nodoc
class __$CreateProofGalleryRequestCopyWithImpl<$Res>
    implements _$CreateProofGalleryRequestCopyWith<$Res> {
  __$CreateProofGalleryRequestCopyWithImpl(this._self, this._then);

  final _CreateProofGalleryRequest _self;
  final $Res Function(_CreateProofGalleryRequest) _then;

/// Create a copy of CreateProofGalleryRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? includedPhotos = null,Object? extraPhotoPrice = freezed,}) {
  return _then(_CreateProofGalleryRequest(
includedPhotos: null == includedPhotos ? _self.includedPhotos : includedPhotos // ignore: cast_nullable_to_non_nullable
as int,extraPhotoPrice: freezed == extraPhotoPrice ? _self.extraPhotoPrice : extraPhotoPrice // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}

// dart format on
