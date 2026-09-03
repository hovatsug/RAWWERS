// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'proof_gallery_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProofGalleryResponse {

/// id
@JsonKey(name: ProofGalleryResponse.idKey_) String get id;/// gigId
@JsonKey(name: ProofGalleryResponse.gigIdKey_) String get gigId;/// proUserId
@JsonKey(name: ProofGalleryResponse.proUserIdKey_) String get proUserId;/// clientUserId
@JsonKey(name: ProofGalleryResponse.clientUserIdKey_) String get clientUserId;/// includedPhotos
@JsonKey(name: ProofGalleryResponse.includedPhotosKey_) int get includedPhotos;/// extraPhotoPrice
@JsonKey(name: ProofGalleryResponse.extraPhotoPriceKey_) String get extraPhotoPrice;/// currency
@JsonKey(name: ProofGalleryResponse.currencyKey_) String get currency;/// status
@JsonKey(name: ProofGalleryResponse.statusKey_) ProofGalleryStatus get status;/// publishedAt
@JsonKey(name: ProofGalleryResponse.publishedAtKey_) DateTime? get publishedAt;/// createdAt
@JsonKey(name: ProofGalleryResponse.createdAtKey_) DateTime get createdAt;/// updatedAt
@JsonKey(name: ProofGalleryResponse.updatedAtKey_) DateTime get updatedAt;
/// Create a copy of ProofGalleryResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProofGalleryResponseCopyWith<ProofGalleryResponse> get copyWith => _$ProofGalleryResponseCopyWithImpl<ProofGalleryResponse>(this as ProofGalleryResponse, _$identity);

  /// Serializes this ProofGalleryResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProofGalleryResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.gigId, gigId) || other.gigId == gigId)&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.clientUserId, clientUserId) || other.clientUserId == clientUserId)&&(identical(other.includedPhotos, includedPhotos) || other.includedPhotos == includedPhotos)&&(identical(other.extraPhotoPrice, extraPhotoPrice) || other.extraPhotoPrice == extraPhotoPrice)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,gigId,proUserId,clientUserId,includedPhotos,extraPhotoPrice,currency,status,publishedAt,createdAt,updatedAt);

@override
String toString() {
  return 'ProofGalleryResponse(id: $id, gigId: $gigId, proUserId: $proUserId, clientUserId: $clientUserId, includedPhotos: $includedPhotos, extraPhotoPrice: $extraPhotoPrice, currency: $currency, status: $status, publishedAt: $publishedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ProofGalleryResponseCopyWith<$Res>  {
  factory $ProofGalleryResponseCopyWith(ProofGalleryResponse value, $Res Function(ProofGalleryResponse) _then) = _$ProofGalleryResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ProofGalleryResponse.idKey_) String id,@JsonKey(name: ProofGalleryResponse.gigIdKey_) String gigId,@JsonKey(name: ProofGalleryResponse.proUserIdKey_) String proUserId,@JsonKey(name: ProofGalleryResponse.clientUserIdKey_) String clientUserId,@JsonKey(name: ProofGalleryResponse.includedPhotosKey_) int includedPhotos,@JsonKey(name: ProofGalleryResponse.extraPhotoPriceKey_) String extraPhotoPrice,@JsonKey(name: ProofGalleryResponse.currencyKey_) String currency,@JsonKey(name: ProofGalleryResponse.statusKey_) ProofGalleryStatus status,@JsonKey(name: ProofGalleryResponse.publishedAtKey_) DateTime? publishedAt,@JsonKey(name: ProofGalleryResponse.createdAtKey_) DateTime createdAt,@JsonKey(name: ProofGalleryResponse.updatedAtKey_) DateTime updatedAt
});




}
/// @nodoc
class _$ProofGalleryResponseCopyWithImpl<$Res>
    implements $ProofGalleryResponseCopyWith<$Res> {
  _$ProofGalleryResponseCopyWithImpl(this._self, this._then);

  final ProofGalleryResponse _self;
  final $Res Function(ProofGalleryResponse) _then;

/// Create a copy of ProofGalleryResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? gigId = null,Object? proUserId = null,Object? clientUserId = null,Object? includedPhotos = null,Object? extraPhotoPrice = null,Object? currency = null,Object? status = null,Object? publishedAt = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gigId: null == gigId ? _self.gigId : gigId // ignore: cast_nullable_to_non_nullable
as String,proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,clientUserId: null == clientUserId ? _self.clientUserId : clientUserId // ignore: cast_nullable_to_non_nullable
as String,includedPhotos: null == includedPhotos ? _self.includedPhotos : includedPhotos // ignore: cast_nullable_to_non_nullable
as int,extraPhotoPrice: null == extraPhotoPrice ? _self.extraPhotoPrice : extraPhotoPrice // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProofGalleryStatus,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ProofGalleryResponse].
extension ProofGalleryResponsePatterns on ProofGalleryResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProofGalleryResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProofGalleryResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProofGalleryResponse value)  $default,){
final _that = this;
switch (_that) {
case _ProofGalleryResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProofGalleryResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ProofGalleryResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ProofGalleryResponse.idKey_)  String id, @JsonKey(name: ProofGalleryResponse.gigIdKey_)  String gigId, @JsonKey(name: ProofGalleryResponse.proUserIdKey_)  String proUserId, @JsonKey(name: ProofGalleryResponse.clientUserIdKey_)  String clientUserId, @JsonKey(name: ProofGalleryResponse.includedPhotosKey_)  int includedPhotos, @JsonKey(name: ProofGalleryResponse.extraPhotoPriceKey_)  String extraPhotoPrice, @JsonKey(name: ProofGalleryResponse.currencyKey_)  String currency, @JsonKey(name: ProofGalleryResponse.statusKey_)  ProofGalleryStatus status, @JsonKey(name: ProofGalleryResponse.publishedAtKey_)  DateTime? publishedAt, @JsonKey(name: ProofGalleryResponse.createdAtKey_)  DateTime createdAt, @JsonKey(name: ProofGalleryResponse.updatedAtKey_)  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProofGalleryResponse() when $default != null:
return $default(_that.id,_that.gigId,_that.proUserId,_that.clientUserId,_that.includedPhotos,_that.extraPhotoPrice,_that.currency,_that.status,_that.publishedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ProofGalleryResponse.idKey_)  String id, @JsonKey(name: ProofGalleryResponse.gigIdKey_)  String gigId, @JsonKey(name: ProofGalleryResponse.proUserIdKey_)  String proUserId, @JsonKey(name: ProofGalleryResponse.clientUserIdKey_)  String clientUserId, @JsonKey(name: ProofGalleryResponse.includedPhotosKey_)  int includedPhotos, @JsonKey(name: ProofGalleryResponse.extraPhotoPriceKey_)  String extraPhotoPrice, @JsonKey(name: ProofGalleryResponse.currencyKey_)  String currency, @JsonKey(name: ProofGalleryResponse.statusKey_)  ProofGalleryStatus status, @JsonKey(name: ProofGalleryResponse.publishedAtKey_)  DateTime? publishedAt, @JsonKey(name: ProofGalleryResponse.createdAtKey_)  DateTime createdAt, @JsonKey(name: ProofGalleryResponse.updatedAtKey_)  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ProofGalleryResponse():
return $default(_that.id,_that.gigId,_that.proUserId,_that.clientUserId,_that.includedPhotos,_that.extraPhotoPrice,_that.currency,_that.status,_that.publishedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ProofGalleryResponse.idKey_)  String id, @JsonKey(name: ProofGalleryResponse.gigIdKey_)  String gigId, @JsonKey(name: ProofGalleryResponse.proUserIdKey_)  String proUserId, @JsonKey(name: ProofGalleryResponse.clientUserIdKey_)  String clientUserId, @JsonKey(name: ProofGalleryResponse.includedPhotosKey_)  int includedPhotos, @JsonKey(name: ProofGalleryResponse.extraPhotoPriceKey_)  String extraPhotoPrice, @JsonKey(name: ProofGalleryResponse.currencyKey_)  String currency, @JsonKey(name: ProofGalleryResponse.statusKey_)  ProofGalleryStatus status, @JsonKey(name: ProofGalleryResponse.publishedAtKey_)  DateTime? publishedAt, @JsonKey(name: ProofGalleryResponse.createdAtKey_)  DateTime createdAt, @JsonKey(name: ProofGalleryResponse.updatedAtKey_)  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ProofGalleryResponse() when $default != null:
return $default(_that.id,_that.gigId,_that.proUserId,_that.clientUserId,_that.includedPhotos,_that.extraPhotoPrice,_that.currency,_that.status,_that.publishedAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ProofGalleryResponse extends ProofGalleryResponse {
  const _ProofGalleryResponse({@JsonKey(name: ProofGalleryResponse.idKey_) required this.id, @JsonKey(name: ProofGalleryResponse.gigIdKey_) required this.gigId, @JsonKey(name: ProofGalleryResponse.proUserIdKey_) required this.proUserId, @JsonKey(name: ProofGalleryResponse.clientUserIdKey_) required this.clientUserId, @JsonKey(name: ProofGalleryResponse.includedPhotosKey_) required this.includedPhotos, @JsonKey(name: ProofGalleryResponse.extraPhotoPriceKey_) required this.extraPhotoPrice, @JsonKey(name: ProofGalleryResponse.currencyKey_) required this.currency, @JsonKey(name: ProofGalleryResponse.statusKey_) required this.status, @JsonKey(name: ProofGalleryResponse.publishedAtKey_) this.publishedAt, @JsonKey(name: ProofGalleryResponse.createdAtKey_) required this.createdAt, @JsonKey(name: ProofGalleryResponse.updatedAtKey_) required this.updatedAt}): super._();
  factory _ProofGalleryResponse.fromJson(Map<String, dynamic> json) => _$ProofGalleryResponseFromJson(json);

/// id
@override@JsonKey(name: ProofGalleryResponse.idKey_) final  String id;
/// gigId
@override@JsonKey(name: ProofGalleryResponse.gigIdKey_) final  String gigId;
/// proUserId
@override@JsonKey(name: ProofGalleryResponse.proUserIdKey_) final  String proUserId;
/// clientUserId
@override@JsonKey(name: ProofGalleryResponse.clientUserIdKey_) final  String clientUserId;
/// includedPhotos
@override@JsonKey(name: ProofGalleryResponse.includedPhotosKey_) final  int includedPhotos;
/// extraPhotoPrice
@override@JsonKey(name: ProofGalleryResponse.extraPhotoPriceKey_) final  String extraPhotoPrice;
/// currency
@override@JsonKey(name: ProofGalleryResponse.currencyKey_) final  String currency;
/// status
@override@JsonKey(name: ProofGalleryResponse.statusKey_) final  ProofGalleryStatus status;
/// publishedAt
@override@JsonKey(name: ProofGalleryResponse.publishedAtKey_) final  DateTime? publishedAt;
/// createdAt
@override@JsonKey(name: ProofGalleryResponse.createdAtKey_) final  DateTime createdAt;
/// updatedAt
@override@JsonKey(name: ProofGalleryResponse.updatedAtKey_) final  DateTime updatedAt;

/// Create a copy of ProofGalleryResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProofGalleryResponseCopyWith<_ProofGalleryResponse> get copyWith => __$ProofGalleryResponseCopyWithImpl<_ProofGalleryResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProofGalleryResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProofGalleryResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.gigId, gigId) || other.gigId == gigId)&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.clientUserId, clientUserId) || other.clientUserId == clientUserId)&&(identical(other.includedPhotos, includedPhotos) || other.includedPhotos == includedPhotos)&&(identical(other.extraPhotoPrice, extraPhotoPrice) || other.extraPhotoPrice == extraPhotoPrice)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,gigId,proUserId,clientUserId,includedPhotos,extraPhotoPrice,currency,status,publishedAt,createdAt,updatedAt);

@override
String toString() {
  return 'ProofGalleryResponse(id: $id, gigId: $gigId, proUserId: $proUserId, clientUserId: $clientUserId, includedPhotos: $includedPhotos, extraPhotoPrice: $extraPhotoPrice, currency: $currency, status: $status, publishedAt: $publishedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ProofGalleryResponseCopyWith<$Res> implements $ProofGalleryResponseCopyWith<$Res> {
  factory _$ProofGalleryResponseCopyWith(_ProofGalleryResponse value, $Res Function(_ProofGalleryResponse) _then) = __$ProofGalleryResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ProofGalleryResponse.idKey_) String id,@JsonKey(name: ProofGalleryResponse.gigIdKey_) String gigId,@JsonKey(name: ProofGalleryResponse.proUserIdKey_) String proUserId,@JsonKey(name: ProofGalleryResponse.clientUserIdKey_) String clientUserId,@JsonKey(name: ProofGalleryResponse.includedPhotosKey_) int includedPhotos,@JsonKey(name: ProofGalleryResponse.extraPhotoPriceKey_) String extraPhotoPrice,@JsonKey(name: ProofGalleryResponse.currencyKey_) String currency,@JsonKey(name: ProofGalleryResponse.statusKey_) ProofGalleryStatus status,@JsonKey(name: ProofGalleryResponse.publishedAtKey_) DateTime? publishedAt,@JsonKey(name: ProofGalleryResponse.createdAtKey_) DateTime createdAt,@JsonKey(name: ProofGalleryResponse.updatedAtKey_) DateTime updatedAt
});




}
/// @nodoc
class __$ProofGalleryResponseCopyWithImpl<$Res>
    implements _$ProofGalleryResponseCopyWith<$Res> {
  __$ProofGalleryResponseCopyWithImpl(this._self, this._then);

  final _ProofGalleryResponse _self;
  final $Res Function(_ProofGalleryResponse) _then;

/// Create a copy of ProofGalleryResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? gigId = null,Object? proUserId = null,Object? clientUserId = null,Object? includedPhotos = null,Object? extraPhotoPrice = null,Object? currency = null,Object? status = null,Object? publishedAt = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_ProofGalleryResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gigId: null == gigId ? _self.gigId : gigId // ignore: cast_nullable_to_non_nullable
as String,proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,clientUserId: null == clientUserId ? _self.clientUserId : clientUserId // ignore: cast_nullable_to_non_nullable
as String,includedPhotos: null == includedPhotos ? _self.includedPhotos : includedPhotos // ignore: cast_nullable_to_non_nullable
as int,extraPhotoPrice: null == extraPhotoPrice ? _self.extraPhotoPrice : extraPhotoPrice // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProofGalleryStatus,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
