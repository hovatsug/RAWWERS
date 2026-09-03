// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'submit_selection_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubmitSelectionResponse {

/// selectionId
@JsonKey(name: SubmitSelectionResponse.selectionIdKey_) String get selectionId;/// selectedCount
@JsonKey(name: SubmitSelectionResponse.selectedCountKey_) int get selectedCount;/// includedPhotos
@JsonKey(name: SubmitSelectionResponse.includedPhotosKey_) int get includedPhotos;/// extrasCount
@JsonKey(name: SubmitSelectionResponse.extrasCountKey_) int get extrasCount;/// galleryStatus
@JsonKey(name: SubmitSelectionResponse.galleryStatusKey_) ProofGalleryStatus get galleryStatus;/// upsellRequired
@JsonKey(name: SubmitSelectionResponse.upsellRequiredKey_) bool get upsellRequired;/// paymentIntentId
@JsonKey(name: SubmitSelectionResponse.paymentIntentIdKey_) String? get paymentIntentId;/// paymentIntentClientSecret
@JsonKey(name: SubmitSelectionResponse.paymentIntentClientSecretKey_) String? get paymentIntentClientSecret;/// differenceRequired
@JsonKey(name: SubmitSelectionResponse.differenceRequiredKey_) bool get differenceRequired;/// differenceAmount
@JsonKey(name: SubmitSelectionResponse.differenceAmountKey_) String? get differenceAmount;/// differencePaymentIntentId
@JsonKey(name: SubmitSelectionResponse.differencePaymentIntentIdKey_) String? get differencePaymentIntentId;/// differencePaymentIntentClientSecret
@JsonKey(name: SubmitSelectionResponse.differencePaymentIntentClientSecretKey_) String? get differencePaymentIntentClientSecret;
/// Create a copy of SubmitSelectionResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubmitSelectionResponseCopyWith<SubmitSelectionResponse> get copyWith => _$SubmitSelectionResponseCopyWithImpl<SubmitSelectionResponse>(this as SubmitSelectionResponse, _$identity);

  /// Serializes this SubmitSelectionResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubmitSelectionResponse&&(identical(other.selectionId, selectionId) || other.selectionId == selectionId)&&(identical(other.selectedCount, selectedCount) || other.selectedCount == selectedCount)&&(identical(other.includedPhotos, includedPhotos) || other.includedPhotos == includedPhotos)&&(identical(other.extrasCount, extrasCount) || other.extrasCount == extrasCount)&&(identical(other.galleryStatus, galleryStatus) || other.galleryStatus == galleryStatus)&&(identical(other.upsellRequired, upsellRequired) || other.upsellRequired == upsellRequired)&&(identical(other.paymentIntentId, paymentIntentId) || other.paymentIntentId == paymentIntentId)&&(identical(other.paymentIntentClientSecret, paymentIntentClientSecret) || other.paymentIntentClientSecret == paymentIntentClientSecret)&&(identical(other.differenceRequired, differenceRequired) || other.differenceRequired == differenceRequired)&&(identical(other.differenceAmount, differenceAmount) || other.differenceAmount == differenceAmount)&&(identical(other.differencePaymentIntentId, differencePaymentIntentId) || other.differencePaymentIntentId == differencePaymentIntentId)&&(identical(other.differencePaymentIntentClientSecret, differencePaymentIntentClientSecret) || other.differencePaymentIntentClientSecret == differencePaymentIntentClientSecret));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,selectionId,selectedCount,includedPhotos,extrasCount,galleryStatus,upsellRequired,paymentIntentId,paymentIntentClientSecret,differenceRequired,differenceAmount,differencePaymentIntentId,differencePaymentIntentClientSecret);

@override
String toString() {
  return 'SubmitSelectionResponse(selectionId: $selectionId, selectedCount: $selectedCount, includedPhotos: $includedPhotos, extrasCount: $extrasCount, galleryStatus: $galleryStatus, upsellRequired: $upsellRequired, paymentIntentId: $paymentIntentId, paymentIntentClientSecret: $paymentIntentClientSecret, differenceRequired: $differenceRequired, differenceAmount: $differenceAmount, differencePaymentIntentId: $differencePaymentIntentId, differencePaymentIntentClientSecret: $differencePaymentIntentClientSecret)';
}


}

/// @nodoc
abstract mixin class $SubmitSelectionResponseCopyWith<$Res>  {
  factory $SubmitSelectionResponseCopyWith(SubmitSelectionResponse value, $Res Function(SubmitSelectionResponse) _then) = _$SubmitSelectionResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: SubmitSelectionResponse.selectionIdKey_) String selectionId,@JsonKey(name: SubmitSelectionResponse.selectedCountKey_) int selectedCount,@JsonKey(name: SubmitSelectionResponse.includedPhotosKey_) int includedPhotos,@JsonKey(name: SubmitSelectionResponse.extrasCountKey_) int extrasCount,@JsonKey(name: SubmitSelectionResponse.galleryStatusKey_) ProofGalleryStatus galleryStatus,@JsonKey(name: SubmitSelectionResponse.upsellRequiredKey_) bool upsellRequired,@JsonKey(name: SubmitSelectionResponse.paymentIntentIdKey_) String? paymentIntentId,@JsonKey(name: SubmitSelectionResponse.paymentIntentClientSecretKey_) String? paymentIntentClientSecret,@JsonKey(name: SubmitSelectionResponse.differenceRequiredKey_) bool differenceRequired,@JsonKey(name: SubmitSelectionResponse.differenceAmountKey_) String? differenceAmount,@JsonKey(name: SubmitSelectionResponse.differencePaymentIntentIdKey_) String? differencePaymentIntentId,@JsonKey(name: SubmitSelectionResponse.differencePaymentIntentClientSecretKey_) String? differencePaymentIntentClientSecret
});




}
/// @nodoc
class _$SubmitSelectionResponseCopyWithImpl<$Res>
    implements $SubmitSelectionResponseCopyWith<$Res> {
  _$SubmitSelectionResponseCopyWithImpl(this._self, this._then);

  final SubmitSelectionResponse _self;
  final $Res Function(SubmitSelectionResponse) _then;

/// Create a copy of SubmitSelectionResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectionId = null,Object? selectedCount = null,Object? includedPhotos = null,Object? extrasCount = null,Object? galleryStatus = null,Object? upsellRequired = null,Object? paymentIntentId = freezed,Object? paymentIntentClientSecret = freezed,Object? differenceRequired = null,Object? differenceAmount = freezed,Object? differencePaymentIntentId = freezed,Object? differencePaymentIntentClientSecret = freezed,}) {
  return _then(_self.copyWith(
selectionId: null == selectionId ? _self.selectionId : selectionId // ignore: cast_nullable_to_non_nullable
as String,selectedCount: null == selectedCount ? _self.selectedCount : selectedCount // ignore: cast_nullable_to_non_nullable
as int,includedPhotos: null == includedPhotos ? _self.includedPhotos : includedPhotos // ignore: cast_nullable_to_non_nullable
as int,extrasCount: null == extrasCount ? _self.extrasCount : extrasCount // ignore: cast_nullable_to_non_nullable
as int,galleryStatus: null == galleryStatus ? _self.galleryStatus : galleryStatus // ignore: cast_nullable_to_non_nullable
as ProofGalleryStatus,upsellRequired: null == upsellRequired ? _self.upsellRequired : upsellRequired // ignore: cast_nullable_to_non_nullable
as bool,paymentIntentId: freezed == paymentIntentId ? _self.paymentIntentId : paymentIntentId // ignore: cast_nullable_to_non_nullable
as String?,paymentIntentClientSecret: freezed == paymentIntentClientSecret ? _self.paymentIntentClientSecret : paymentIntentClientSecret // ignore: cast_nullable_to_non_nullable
as String?,differenceRequired: null == differenceRequired ? _self.differenceRequired : differenceRequired // ignore: cast_nullable_to_non_nullable
as bool,differenceAmount: freezed == differenceAmount ? _self.differenceAmount : differenceAmount // ignore: cast_nullable_to_non_nullable
as String?,differencePaymentIntentId: freezed == differencePaymentIntentId ? _self.differencePaymentIntentId : differencePaymentIntentId // ignore: cast_nullable_to_non_nullable
as String?,differencePaymentIntentClientSecret: freezed == differencePaymentIntentClientSecret ? _self.differencePaymentIntentClientSecret : differencePaymentIntentClientSecret // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SubmitSelectionResponse].
extension SubmitSelectionResponsePatterns on SubmitSelectionResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubmitSelectionResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubmitSelectionResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubmitSelectionResponse value)  $default,){
final _that = this;
switch (_that) {
case _SubmitSelectionResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubmitSelectionResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SubmitSelectionResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: SubmitSelectionResponse.selectionIdKey_)  String selectionId, @JsonKey(name: SubmitSelectionResponse.selectedCountKey_)  int selectedCount, @JsonKey(name: SubmitSelectionResponse.includedPhotosKey_)  int includedPhotos, @JsonKey(name: SubmitSelectionResponse.extrasCountKey_)  int extrasCount, @JsonKey(name: SubmitSelectionResponse.galleryStatusKey_)  ProofGalleryStatus galleryStatus, @JsonKey(name: SubmitSelectionResponse.upsellRequiredKey_)  bool upsellRequired, @JsonKey(name: SubmitSelectionResponse.paymentIntentIdKey_)  String? paymentIntentId, @JsonKey(name: SubmitSelectionResponse.paymentIntentClientSecretKey_)  String? paymentIntentClientSecret, @JsonKey(name: SubmitSelectionResponse.differenceRequiredKey_)  bool differenceRequired, @JsonKey(name: SubmitSelectionResponse.differenceAmountKey_)  String? differenceAmount, @JsonKey(name: SubmitSelectionResponse.differencePaymentIntentIdKey_)  String? differencePaymentIntentId, @JsonKey(name: SubmitSelectionResponse.differencePaymentIntentClientSecretKey_)  String? differencePaymentIntentClientSecret)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubmitSelectionResponse() when $default != null:
return $default(_that.selectionId,_that.selectedCount,_that.includedPhotos,_that.extrasCount,_that.galleryStatus,_that.upsellRequired,_that.paymentIntentId,_that.paymentIntentClientSecret,_that.differenceRequired,_that.differenceAmount,_that.differencePaymentIntentId,_that.differencePaymentIntentClientSecret);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: SubmitSelectionResponse.selectionIdKey_)  String selectionId, @JsonKey(name: SubmitSelectionResponse.selectedCountKey_)  int selectedCount, @JsonKey(name: SubmitSelectionResponse.includedPhotosKey_)  int includedPhotos, @JsonKey(name: SubmitSelectionResponse.extrasCountKey_)  int extrasCount, @JsonKey(name: SubmitSelectionResponse.galleryStatusKey_)  ProofGalleryStatus galleryStatus, @JsonKey(name: SubmitSelectionResponse.upsellRequiredKey_)  bool upsellRequired, @JsonKey(name: SubmitSelectionResponse.paymentIntentIdKey_)  String? paymentIntentId, @JsonKey(name: SubmitSelectionResponse.paymentIntentClientSecretKey_)  String? paymentIntentClientSecret, @JsonKey(name: SubmitSelectionResponse.differenceRequiredKey_)  bool differenceRequired, @JsonKey(name: SubmitSelectionResponse.differenceAmountKey_)  String? differenceAmount, @JsonKey(name: SubmitSelectionResponse.differencePaymentIntentIdKey_)  String? differencePaymentIntentId, @JsonKey(name: SubmitSelectionResponse.differencePaymentIntentClientSecretKey_)  String? differencePaymentIntentClientSecret)  $default,) {final _that = this;
switch (_that) {
case _SubmitSelectionResponse():
return $default(_that.selectionId,_that.selectedCount,_that.includedPhotos,_that.extrasCount,_that.galleryStatus,_that.upsellRequired,_that.paymentIntentId,_that.paymentIntentClientSecret,_that.differenceRequired,_that.differenceAmount,_that.differencePaymentIntentId,_that.differencePaymentIntentClientSecret);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: SubmitSelectionResponse.selectionIdKey_)  String selectionId, @JsonKey(name: SubmitSelectionResponse.selectedCountKey_)  int selectedCount, @JsonKey(name: SubmitSelectionResponse.includedPhotosKey_)  int includedPhotos, @JsonKey(name: SubmitSelectionResponse.extrasCountKey_)  int extrasCount, @JsonKey(name: SubmitSelectionResponse.galleryStatusKey_)  ProofGalleryStatus galleryStatus, @JsonKey(name: SubmitSelectionResponse.upsellRequiredKey_)  bool upsellRequired, @JsonKey(name: SubmitSelectionResponse.paymentIntentIdKey_)  String? paymentIntentId, @JsonKey(name: SubmitSelectionResponse.paymentIntentClientSecretKey_)  String? paymentIntentClientSecret, @JsonKey(name: SubmitSelectionResponse.differenceRequiredKey_)  bool differenceRequired, @JsonKey(name: SubmitSelectionResponse.differenceAmountKey_)  String? differenceAmount, @JsonKey(name: SubmitSelectionResponse.differencePaymentIntentIdKey_)  String? differencePaymentIntentId, @JsonKey(name: SubmitSelectionResponse.differencePaymentIntentClientSecretKey_)  String? differencePaymentIntentClientSecret)?  $default,) {final _that = this;
switch (_that) {
case _SubmitSelectionResponse() when $default != null:
return $default(_that.selectionId,_that.selectedCount,_that.includedPhotos,_that.extrasCount,_that.galleryStatus,_that.upsellRequired,_that.paymentIntentId,_that.paymentIntentClientSecret,_that.differenceRequired,_that.differenceAmount,_that.differencePaymentIntentId,_that.differencePaymentIntentClientSecret);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _SubmitSelectionResponse extends SubmitSelectionResponse {
  const _SubmitSelectionResponse({@JsonKey(name: SubmitSelectionResponse.selectionIdKey_) required this.selectionId, @JsonKey(name: SubmitSelectionResponse.selectedCountKey_) required this.selectedCount, @JsonKey(name: SubmitSelectionResponse.includedPhotosKey_) required this.includedPhotos, @JsonKey(name: SubmitSelectionResponse.extrasCountKey_) required this.extrasCount, @JsonKey(name: SubmitSelectionResponse.galleryStatusKey_) required this.galleryStatus, @JsonKey(name: SubmitSelectionResponse.upsellRequiredKey_) required this.upsellRequired, @JsonKey(name: SubmitSelectionResponse.paymentIntentIdKey_) this.paymentIntentId, @JsonKey(name: SubmitSelectionResponse.paymentIntentClientSecretKey_) this.paymentIntentClientSecret, @JsonKey(name: SubmitSelectionResponse.differenceRequiredKey_) this.differenceRequired = false, @JsonKey(name: SubmitSelectionResponse.differenceAmountKey_) this.differenceAmount, @JsonKey(name: SubmitSelectionResponse.differencePaymentIntentIdKey_) this.differencePaymentIntentId, @JsonKey(name: SubmitSelectionResponse.differencePaymentIntentClientSecretKey_) this.differencePaymentIntentClientSecret}): super._();
  factory _SubmitSelectionResponse.fromJson(Map<String, dynamic> json) => _$SubmitSelectionResponseFromJson(json);

/// selectionId
@override@JsonKey(name: SubmitSelectionResponse.selectionIdKey_) final  String selectionId;
/// selectedCount
@override@JsonKey(name: SubmitSelectionResponse.selectedCountKey_) final  int selectedCount;
/// includedPhotos
@override@JsonKey(name: SubmitSelectionResponse.includedPhotosKey_) final  int includedPhotos;
/// extrasCount
@override@JsonKey(name: SubmitSelectionResponse.extrasCountKey_) final  int extrasCount;
/// galleryStatus
@override@JsonKey(name: SubmitSelectionResponse.galleryStatusKey_) final  ProofGalleryStatus galleryStatus;
/// upsellRequired
@override@JsonKey(name: SubmitSelectionResponse.upsellRequiredKey_) final  bool upsellRequired;
/// paymentIntentId
@override@JsonKey(name: SubmitSelectionResponse.paymentIntentIdKey_) final  String? paymentIntentId;
/// paymentIntentClientSecret
@override@JsonKey(name: SubmitSelectionResponse.paymentIntentClientSecretKey_) final  String? paymentIntentClientSecret;
/// differenceRequired
@override@JsonKey(name: SubmitSelectionResponse.differenceRequiredKey_) final  bool differenceRequired;
/// differenceAmount
@override@JsonKey(name: SubmitSelectionResponse.differenceAmountKey_) final  String? differenceAmount;
/// differencePaymentIntentId
@override@JsonKey(name: SubmitSelectionResponse.differencePaymentIntentIdKey_) final  String? differencePaymentIntentId;
/// differencePaymentIntentClientSecret
@override@JsonKey(name: SubmitSelectionResponse.differencePaymentIntentClientSecretKey_) final  String? differencePaymentIntentClientSecret;

/// Create a copy of SubmitSelectionResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubmitSelectionResponseCopyWith<_SubmitSelectionResponse> get copyWith => __$SubmitSelectionResponseCopyWithImpl<_SubmitSelectionResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubmitSelectionResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubmitSelectionResponse&&(identical(other.selectionId, selectionId) || other.selectionId == selectionId)&&(identical(other.selectedCount, selectedCount) || other.selectedCount == selectedCount)&&(identical(other.includedPhotos, includedPhotos) || other.includedPhotos == includedPhotos)&&(identical(other.extrasCount, extrasCount) || other.extrasCount == extrasCount)&&(identical(other.galleryStatus, galleryStatus) || other.galleryStatus == galleryStatus)&&(identical(other.upsellRequired, upsellRequired) || other.upsellRequired == upsellRequired)&&(identical(other.paymentIntentId, paymentIntentId) || other.paymentIntentId == paymentIntentId)&&(identical(other.paymentIntentClientSecret, paymentIntentClientSecret) || other.paymentIntentClientSecret == paymentIntentClientSecret)&&(identical(other.differenceRequired, differenceRequired) || other.differenceRequired == differenceRequired)&&(identical(other.differenceAmount, differenceAmount) || other.differenceAmount == differenceAmount)&&(identical(other.differencePaymentIntentId, differencePaymentIntentId) || other.differencePaymentIntentId == differencePaymentIntentId)&&(identical(other.differencePaymentIntentClientSecret, differencePaymentIntentClientSecret) || other.differencePaymentIntentClientSecret == differencePaymentIntentClientSecret));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,selectionId,selectedCount,includedPhotos,extrasCount,galleryStatus,upsellRequired,paymentIntentId,paymentIntentClientSecret,differenceRequired,differenceAmount,differencePaymentIntentId,differencePaymentIntentClientSecret);

@override
String toString() {
  return 'SubmitSelectionResponse(selectionId: $selectionId, selectedCount: $selectedCount, includedPhotos: $includedPhotos, extrasCount: $extrasCount, galleryStatus: $galleryStatus, upsellRequired: $upsellRequired, paymentIntentId: $paymentIntentId, paymentIntentClientSecret: $paymentIntentClientSecret, differenceRequired: $differenceRequired, differenceAmount: $differenceAmount, differencePaymentIntentId: $differencePaymentIntentId, differencePaymentIntentClientSecret: $differencePaymentIntentClientSecret)';
}


}

/// @nodoc
abstract mixin class _$SubmitSelectionResponseCopyWith<$Res> implements $SubmitSelectionResponseCopyWith<$Res> {
  factory _$SubmitSelectionResponseCopyWith(_SubmitSelectionResponse value, $Res Function(_SubmitSelectionResponse) _then) = __$SubmitSelectionResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: SubmitSelectionResponse.selectionIdKey_) String selectionId,@JsonKey(name: SubmitSelectionResponse.selectedCountKey_) int selectedCount,@JsonKey(name: SubmitSelectionResponse.includedPhotosKey_) int includedPhotos,@JsonKey(name: SubmitSelectionResponse.extrasCountKey_) int extrasCount,@JsonKey(name: SubmitSelectionResponse.galleryStatusKey_) ProofGalleryStatus galleryStatus,@JsonKey(name: SubmitSelectionResponse.upsellRequiredKey_) bool upsellRequired,@JsonKey(name: SubmitSelectionResponse.paymentIntentIdKey_) String? paymentIntentId,@JsonKey(name: SubmitSelectionResponse.paymentIntentClientSecretKey_) String? paymentIntentClientSecret,@JsonKey(name: SubmitSelectionResponse.differenceRequiredKey_) bool differenceRequired,@JsonKey(name: SubmitSelectionResponse.differenceAmountKey_) String? differenceAmount,@JsonKey(name: SubmitSelectionResponse.differencePaymentIntentIdKey_) String? differencePaymentIntentId,@JsonKey(name: SubmitSelectionResponse.differencePaymentIntentClientSecretKey_) String? differencePaymentIntentClientSecret
});




}
/// @nodoc
class __$SubmitSelectionResponseCopyWithImpl<$Res>
    implements _$SubmitSelectionResponseCopyWith<$Res> {
  __$SubmitSelectionResponseCopyWithImpl(this._self, this._then);

  final _SubmitSelectionResponse _self;
  final $Res Function(_SubmitSelectionResponse) _then;

/// Create a copy of SubmitSelectionResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectionId = null,Object? selectedCount = null,Object? includedPhotos = null,Object? extrasCount = null,Object? galleryStatus = null,Object? upsellRequired = null,Object? paymentIntentId = freezed,Object? paymentIntentClientSecret = freezed,Object? differenceRequired = null,Object? differenceAmount = freezed,Object? differencePaymentIntentId = freezed,Object? differencePaymentIntentClientSecret = freezed,}) {
  return _then(_SubmitSelectionResponse(
selectionId: null == selectionId ? _self.selectionId : selectionId // ignore: cast_nullable_to_non_nullable
as String,selectedCount: null == selectedCount ? _self.selectedCount : selectedCount // ignore: cast_nullable_to_non_nullable
as int,includedPhotos: null == includedPhotos ? _self.includedPhotos : includedPhotos // ignore: cast_nullable_to_non_nullable
as int,extrasCount: null == extrasCount ? _self.extrasCount : extrasCount // ignore: cast_nullable_to_non_nullable
as int,galleryStatus: null == galleryStatus ? _self.galleryStatus : galleryStatus // ignore: cast_nullable_to_non_nullable
as ProofGalleryStatus,upsellRequired: null == upsellRequired ? _self.upsellRequired : upsellRequired // ignore: cast_nullable_to_non_nullable
as bool,paymentIntentId: freezed == paymentIntentId ? _self.paymentIntentId : paymentIntentId // ignore: cast_nullable_to_non_nullable
as String?,paymentIntentClientSecret: freezed == paymentIntentClientSecret ? _self.paymentIntentClientSecret : paymentIntentClientSecret // ignore: cast_nullable_to_non_nullable
as String?,differenceRequired: null == differenceRequired ? _self.differenceRequired : differenceRequired // ignore: cast_nullable_to_non_nullable
as bool,differenceAmount: freezed == differenceAmount ? _self.differenceAmount : differenceAmount // ignore: cast_nullable_to_non_nullable
as String?,differencePaymentIntentId: freezed == differencePaymentIntentId ? _self.differencePaymentIntentId : differencePaymentIntentId // ignore: cast_nullable_to_non_nullable
as String?,differencePaymentIntentClientSecret: freezed == differencePaymentIntentClientSecret ? _self.differencePaymentIntentClientSecret : differencePaymentIntentClientSecret // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
