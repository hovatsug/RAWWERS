// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'selection_quote_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SelectionQuoteResponse {

/// selectedCount
@JsonKey(name: SelectionQuoteResponse.selectedCountKey_) int get selectedCount;/// includedPhotos
@JsonKey(name: SelectionQuoteResponse.includedPhotosKey_) int get includedPhotos;/// minimumPhotos
@JsonKey(name: SelectionQuoteResponse.minimumPhotosKey_) int get minimumPhotos;/// currency
@JsonKey(name: SelectionQuoteResponse.currencyKey_) String get currency;/// amountTotal
@JsonKey(name: SelectionQuoteResponse.amountTotalKey_) String get amountTotal;/// amountPaid
@JsonKey(name: SelectionQuoteResponse.amountPaidKey_) String get amountPaid;/// amountDue
@JsonKey(name: SelectionQuoteResponse.amountDueKey_) String get amountDue;/// refundAmount
@JsonKey(name: SelectionQuoteResponse.refundAmountKey_) String get refundAmount;/// nextPhotoPrice
@JsonKey(name: SelectionQuoteResponse.nextPhotoPriceKey_) String? get nextPhotoPrice;/// extrasCount
@JsonKey(name: SelectionQuoteResponse.extrasCountKey_) int get extrasCount;/// canSubmit
@JsonKey(name: SelectionQuoteResponse.canSubmitKey_) bool get canSubmit;/// photosStillNeeded
@JsonKey(name: SelectionQuoteResponse.photosStillNeededKey_) int get photosStillNeeded;
/// Create a copy of SelectionQuoteResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SelectionQuoteResponseCopyWith<SelectionQuoteResponse> get copyWith => _$SelectionQuoteResponseCopyWithImpl<SelectionQuoteResponse>(this as SelectionQuoteResponse, _$identity);

  /// Serializes this SelectionQuoteResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SelectionQuoteResponse&&(identical(other.selectedCount, selectedCount) || other.selectedCount == selectedCount)&&(identical(other.includedPhotos, includedPhotos) || other.includedPhotos == includedPhotos)&&(identical(other.minimumPhotos, minimumPhotos) || other.minimumPhotos == minimumPhotos)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.amountTotal, amountTotal) || other.amountTotal == amountTotal)&&(identical(other.amountPaid, amountPaid) || other.amountPaid == amountPaid)&&(identical(other.amountDue, amountDue) || other.amountDue == amountDue)&&(identical(other.refundAmount, refundAmount) || other.refundAmount == refundAmount)&&(identical(other.nextPhotoPrice, nextPhotoPrice) || other.nextPhotoPrice == nextPhotoPrice)&&(identical(other.extrasCount, extrasCount) || other.extrasCount == extrasCount)&&(identical(other.canSubmit, canSubmit) || other.canSubmit == canSubmit)&&(identical(other.photosStillNeeded, photosStillNeeded) || other.photosStillNeeded == photosStillNeeded));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,selectedCount,includedPhotos,minimumPhotos,currency,amountTotal,amountPaid,amountDue,refundAmount,nextPhotoPrice,extrasCount,canSubmit,photosStillNeeded);

@override
String toString() {
  return 'SelectionQuoteResponse(selectedCount: $selectedCount, includedPhotos: $includedPhotos, minimumPhotos: $minimumPhotos, currency: $currency, amountTotal: $amountTotal, amountPaid: $amountPaid, amountDue: $amountDue, refundAmount: $refundAmount, nextPhotoPrice: $nextPhotoPrice, extrasCount: $extrasCount, canSubmit: $canSubmit, photosStillNeeded: $photosStillNeeded)';
}


}

/// @nodoc
abstract mixin class $SelectionQuoteResponseCopyWith<$Res>  {
  factory $SelectionQuoteResponseCopyWith(SelectionQuoteResponse value, $Res Function(SelectionQuoteResponse) _then) = _$SelectionQuoteResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: SelectionQuoteResponse.selectedCountKey_) int selectedCount,@JsonKey(name: SelectionQuoteResponse.includedPhotosKey_) int includedPhotos,@JsonKey(name: SelectionQuoteResponse.minimumPhotosKey_) int minimumPhotos,@JsonKey(name: SelectionQuoteResponse.currencyKey_) String currency,@JsonKey(name: SelectionQuoteResponse.amountTotalKey_) String amountTotal,@JsonKey(name: SelectionQuoteResponse.amountPaidKey_) String amountPaid,@JsonKey(name: SelectionQuoteResponse.amountDueKey_) String amountDue,@JsonKey(name: SelectionQuoteResponse.refundAmountKey_) String refundAmount,@JsonKey(name: SelectionQuoteResponse.nextPhotoPriceKey_) String? nextPhotoPrice,@JsonKey(name: SelectionQuoteResponse.extrasCountKey_) int extrasCount,@JsonKey(name: SelectionQuoteResponse.canSubmitKey_) bool canSubmit,@JsonKey(name: SelectionQuoteResponse.photosStillNeededKey_) int photosStillNeeded
});




}
/// @nodoc
class _$SelectionQuoteResponseCopyWithImpl<$Res>
    implements $SelectionQuoteResponseCopyWith<$Res> {
  _$SelectionQuoteResponseCopyWithImpl(this._self, this._then);

  final SelectionQuoteResponse _self;
  final $Res Function(SelectionQuoteResponse) _then;

/// Create a copy of SelectionQuoteResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedCount = null,Object? includedPhotos = null,Object? minimumPhotos = null,Object? currency = null,Object? amountTotal = null,Object? amountPaid = null,Object? amountDue = null,Object? refundAmount = null,Object? nextPhotoPrice = freezed,Object? extrasCount = null,Object? canSubmit = null,Object? photosStillNeeded = null,}) {
  return _then(_self.copyWith(
selectedCount: null == selectedCount ? _self.selectedCount : selectedCount // ignore: cast_nullable_to_non_nullable
as int,includedPhotos: null == includedPhotos ? _self.includedPhotos : includedPhotos // ignore: cast_nullable_to_non_nullable
as int,minimumPhotos: null == minimumPhotos ? _self.minimumPhotos : minimumPhotos // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,amountTotal: null == amountTotal ? _self.amountTotal : amountTotal // ignore: cast_nullable_to_non_nullable
as String,amountPaid: null == amountPaid ? _self.amountPaid : amountPaid // ignore: cast_nullable_to_non_nullable
as String,amountDue: null == amountDue ? _self.amountDue : amountDue // ignore: cast_nullable_to_non_nullable
as String,refundAmount: null == refundAmount ? _self.refundAmount : refundAmount // ignore: cast_nullable_to_non_nullable
as String,nextPhotoPrice: freezed == nextPhotoPrice ? _self.nextPhotoPrice : nextPhotoPrice // ignore: cast_nullable_to_non_nullable
as String?,extrasCount: null == extrasCount ? _self.extrasCount : extrasCount // ignore: cast_nullable_to_non_nullable
as int,canSubmit: null == canSubmit ? _self.canSubmit : canSubmit // ignore: cast_nullable_to_non_nullable
as bool,photosStillNeeded: null == photosStillNeeded ? _self.photosStillNeeded : photosStillNeeded // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SelectionQuoteResponse].
extension SelectionQuoteResponsePatterns on SelectionQuoteResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SelectionQuoteResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SelectionQuoteResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SelectionQuoteResponse value)  $default,){
final _that = this;
switch (_that) {
case _SelectionQuoteResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SelectionQuoteResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SelectionQuoteResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: SelectionQuoteResponse.selectedCountKey_)  int selectedCount, @JsonKey(name: SelectionQuoteResponse.includedPhotosKey_)  int includedPhotos, @JsonKey(name: SelectionQuoteResponse.minimumPhotosKey_)  int minimumPhotos, @JsonKey(name: SelectionQuoteResponse.currencyKey_)  String currency, @JsonKey(name: SelectionQuoteResponse.amountTotalKey_)  String amountTotal, @JsonKey(name: SelectionQuoteResponse.amountPaidKey_)  String amountPaid, @JsonKey(name: SelectionQuoteResponse.amountDueKey_)  String amountDue, @JsonKey(name: SelectionQuoteResponse.refundAmountKey_)  String refundAmount, @JsonKey(name: SelectionQuoteResponse.nextPhotoPriceKey_)  String? nextPhotoPrice, @JsonKey(name: SelectionQuoteResponse.extrasCountKey_)  int extrasCount, @JsonKey(name: SelectionQuoteResponse.canSubmitKey_)  bool canSubmit, @JsonKey(name: SelectionQuoteResponse.photosStillNeededKey_)  int photosStillNeeded)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SelectionQuoteResponse() when $default != null:
return $default(_that.selectedCount,_that.includedPhotos,_that.minimumPhotos,_that.currency,_that.amountTotal,_that.amountPaid,_that.amountDue,_that.refundAmount,_that.nextPhotoPrice,_that.extrasCount,_that.canSubmit,_that.photosStillNeeded);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: SelectionQuoteResponse.selectedCountKey_)  int selectedCount, @JsonKey(name: SelectionQuoteResponse.includedPhotosKey_)  int includedPhotos, @JsonKey(name: SelectionQuoteResponse.minimumPhotosKey_)  int minimumPhotos, @JsonKey(name: SelectionQuoteResponse.currencyKey_)  String currency, @JsonKey(name: SelectionQuoteResponse.amountTotalKey_)  String amountTotal, @JsonKey(name: SelectionQuoteResponse.amountPaidKey_)  String amountPaid, @JsonKey(name: SelectionQuoteResponse.amountDueKey_)  String amountDue, @JsonKey(name: SelectionQuoteResponse.refundAmountKey_)  String refundAmount, @JsonKey(name: SelectionQuoteResponse.nextPhotoPriceKey_)  String? nextPhotoPrice, @JsonKey(name: SelectionQuoteResponse.extrasCountKey_)  int extrasCount, @JsonKey(name: SelectionQuoteResponse.canSubmitKey_)  bool canSubmit, @JsonKey(name: SelectionQuoteResponse.photosStillNeededKey_)  int photosStillNeeded)  $default,) {final _that = this;
switch (_that) {
case _SelectionQuoteResponse():
return $default(_that.selectedCount,_that.includedPhotos,_that.minimumPhotos,_that.currency,_that.amountTotal,_that.amountPaid,_that.amountDue,_that.refundAmount,_that.nextPhotoPrice,_that.extrasCount,_that.canSubmit,_that.photosStillNeeded);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: SelectionQuoteResponse.selectedCountKey_)  int selectedCount, @JsonKey(name: SelectionQuoteResponse.includedPhotosKey_)  int includedPhotos, @JsonKey(name: SelectionQuoteResponse.minimumPhotosKey_)  int minimumPhotos, @JsonKey(name: SelectionQuoteResponse.currencyKey_)  String currency, @JsonKey(name: SelectionQuoteResponse.amountTotalKey_)  String amountTotal, @JsonKey(name: SelectionQuoteResponse.amountPaidKey_)  String amountPaid, @JsonKey(name: SelectionQuoteResponse.amountDueKey_)  String amountDue, @JsonKey(name: SelectionQuoteResponse.refundAmountKey_)  String refundAmount, @JsonKey(name: SelectionQuoteResponse.nextPhotoPriceKey_)  String? nextPhotoPrice, @JsonKey(name: SelectionQuoteResponse.extrasCountKey_)  int extrasCount, @JsonKey(name: SelectionQuoteResponse.canSubmitKey_)  bool canSubmit, @JsonKey(name: SelectionQuoteResponse.photosStillNeededKey_)  int photosStillNeeded)?  $default,) {final _that = this;
switch (_that) {
case _SelectionQuoteResponse() when $default != null:
return $default(_that.selectedCount,_that.includedPhotos,_that.minimumPhotos,_that.currency,_that.amountTotal,_that.amountPaid,_that.amountDue,_that.refundAmount,_that.nextPhotoPrice,_that.extrasCount,_that.canSubmit,_that.photosStillNeeded);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _SelectionQuoteResponse extends SelectionQuoteResponse {
  const _SelectionQuoteResponse({@JsonKey(name: SelectionQuoteResponse.selectedCountKey_) required this.selectedCount, @JsonKey(name: SelectionQuoteResponse.includedPhotosKey_) required this.includedPhotos, @JsonKey(name: SelectionQuoteResponse.minimumPhotosKey_) required this.minimumPhotos, @JsonKey(name: SelectionQuoteResponse.currencyKey_) required this.currency, @JsonKey(name: SelectionQuoteResponse.amountTotalKey_) required this.amountTotal, @JsonKey(name: SelectionQuoteResponse.amountPaidKey_) required this.amountPaid, @JsonKey(name: SelectionQuoteResponse.amountDueKey_) required this.amountDue, @JsonKey(name: SelectionQuoteResponse.refundAmountKey_) this.refundAmount = '0.00', @JsonKey(name: SelectionQuoteResponse.nextPhotoPriceKey_) this.nextPhotoPrice, @JsonKey(name: SelectionQuoteResponse.extrasCountKey_) required this.extrasCount, @JsonKey(name: SelectionQuoteResponse.canSubmitKey_) required this.canSubmit, @JsonKey(name: SelectionQuoteResponse.photosStillNeededKey_) required this.photosStillNeeded}): super._();
  factory _SelectionQuoteResponse.fromJson(Map<String, dynamic> json) => _$SelectionQuoteResponseFromJson(json);

/// selectedCount
@override@JsonKey(name: SelectionQuoteResponse.selectedCountKey_) final  int selectedCount;
/// includedPhotos
@override@JsonKey(name: SelectionQuoteResponse.includedPhotosKey_) final  int includedPhotos;
/// minimumPhotos
@override@JsonKey(name: SelectionQuoteResponse.minimumPhotosKey_) final  int minimumPhotos;
/// currency
@override@JsonKey(name: SelectionQuoteResponse.currencyKey_) final  String currency;
/// amountTotal
@override@JsonKey(name: SelectionQuoteResponse.amountTotalKey_) final  String amountTotal;
/// amountPaid
@override@JsonKey(name: SelectionQuoteResponse.amountPaidKey_) final  String amountPaid;
/// amountDue
@override@JsonKey(name: SelectionQuoteResponse.amountDueKey_) final  String amountDue;
/// refundAmount
@override@JsonKey(name: SelectionQuoteResponse.refundAmountKey_) final  String refundAmount;
/// nextPhotoPrice
@override@JsonKey(name: SelectionQuoteResponse.nextPhotoPriceKey_) final  String? nextPhotoPrice;
/// extrasCount
@override@JsonKey(name: SelectionQuoteResponse.extrasCountKey_) final  int extrasCount;
/// canSubmit
@override@JsonKey(name: SelectionQuoteResponse.canSubmitKey_) final  bool canSubmit;
/// photosStillNeeded
@override@JsonKey(name: SelectionQuoteResponse.photosStillNeededKey_) final  int photosStillNeeded;

/// Create a copy of SelectionQuoteResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SelectionQuoteResponseCopyWith<_SelectionQuoteResponse> get copyWith => __$SelectionQuoteResponseCopyWithImpl<_SelectionQuoteResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SelectionQuoteResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SelectionQuoteResponse&&(identical(other.selectedCount, selectedCount) || other.selectedCount == selectedCount)&&(identical(other.includedPhotos, includedPhotos) || other.includedPhotos == includedPhotos)&&(identical(other.minimumPhotos, minimumPhotos) || other.minimumPhotos == minimumPhotos)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.amountTotal, amountTotal) || other.amountTotal == amountTotal)&&(identical(other.amountPaid, amountPaid) || other.amountPaid == amountPaid)&&(identical(other.amountDue, amountDue) || other.amountDue == amountDue)&&(identical(other.refundAmount, refundAmount) || other.refundAmount == refundAmount)&&(identical(other.nextPhotoPrice, nextPhotoPrice) || other.nextPhotoPrice == nextPhotoPrice)&&(identical(other.extrasCount, extrasCount) || other.extrasCount == extrasCount)&&(identical(other.canSubmit, canSubmit) || other.canSubmit == canSubmit)&&(identical(other.photosStillNeeded, photosStillNeeded) || other.photosStillNeeded == photosStillNeeded));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,selectedCount,includedPhotos,minimumPhotos,currency,amountTotal,amountPaid,amountDue,refundAmount,nextPhotoPrice,extrasCount,canSubmit,photosStillNeeded);

@override
String toString() {
  return 'SelectionQuoteResponse(selectedCount: $selectedCount, includedPhotos: $includedPhotos, minimumPhotos: $minimumPhotos, currency: $currency, amountTotal: $amountTotal, amountPaid: $amountPaid, amountDue: $amountDue, refundAmount: $refundAmount, nextPhotoPrice: $nextPhotoPrice, extrasCount: $extrasCount, canSubmit: $canSubmit, photosStillNeeded: $photosStillNeeded)';
}


}

/// @nodoc
abstract mixin class _$SelectionQuoteResponseCopyWith<$Res> implements $SelectionQuoteResponseCopyWith<$Res> {
  factory _$SelectionQuoteResponseCopyWith(_SelectionQuoteResponse value, $Res Function(_SelectionQuoteResponse) _then) = __$SelectionQuoteResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: SelectionQuoteResponse.selectedCountKey_) int selectedCount,@JsonKey(name: SelectionQuoteResponse.includedPhotosKey_) int includedPhotos,@JsonKey(name: SelectionQuoteResponse.minimumPhotosKey_) int minimumPhotos,@JsonKey(name: SelectionQuoteResponse.currencyKey_) String currency,@JsonKey(name: SelectionQuoteResponse.amountTotalKey_) String amountTotal,@JsonKey(name: SelectionQuoteResponse.amountPaidKey_) String amountPaid,@JsonKey(name: SelectionQuoteResponse.amountDueKey_) String amountDue,@JsonKey(name: SelectionQuoteResponse.refundAmountKey_) String refundAmount,@JsonKey(name: SelectionQuoteResponse.nextPhotoPriceKey_) String? nextPhotoPrice,@JsonKey(name: SelectionQuoteResponse.extrasCountKey_) int extrasCount,@JsonKey(name: SelectionQuoteResponse.canSubmitKey_) bool canSubmit,@JsonKey(name: SelectionQuoteResponse.photosStillNeededKey_) int photosStillNeeded
});




}
/// @nodoc
class __$SelectionQuoteResponseCopyWithImpl<$Res>
    implements _$SelectionQuoteResponseCopyWith<$Res> {
  __$SelectionQuoteResponseCopyWithImpl(this._self, this._then);

  final _SelectionQuoteResponse _self;
  final $Res Function(_SelectionQuoteResponse) _then;

/// Create a copy of SelectionQuoteResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedCount = null,Object? includedPhotos = null,Object? minimumPhotos = null,Object? currency = null,Object? amountTotal = null,Object? amountPaid = null,Object? amountDue = null,Object? refundAmount = null,Object? nextPhotoPrice = freezed,Object? extrasCount = null,Object? canSubmit = null,Object? photosStillNeeded = null,}) {
  return _then(_SelectionQuoteResponse(
selectedCount: null == selectedCount ? _self.selectedCount : selectedCount // ignore: cast_nullable_to_non_nullable
as int,includedPhotos: null == includedPhotos ? _self.includedPhotos : includedPhotos // ignore: cast_nullable_to_non_nullable
as int,minimumPhotos: null == minimumPhotos ? _self.minimumPhotos : minimumPhotos // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,amountTotal: null == amountTotal ? _self.amountTotal : amountTotal // ignore: cast_nullable_to_non_nullable
as String,amountPaid: null == amountPaid ? _self.amountPaid : amountPaid // ignore: cast_nullable_to_non_nullable
as String,amountDue: null == amountDue ? _self.amountDue : amountDue // ignore: cast_nullable_to_non_nullable
as String,refundAmount: null == refundAmount ? _self.refundAmount : refundAmount // ignore: cast_nullable_to_non_nullable
as String,nextPhotoPrice: freezed == nextPhotoPrice ? _self.nextPhotoPrice : nextPhotoPrice // ignore: cast_nullable_to_non_nullable
as String?,extrasCount: null == extrasCount ? _self.extrasCount : extrasCount // ignore: cast_nullable_to_non_nullable
as int,canSubmit: null == canSubmit ? _self.canSubmit : canSubmit // ignore: cast_nullable_to_non_nullable
as bool,photosStillNeeded: null == photosStillNeeded ? _self.photosStillNeeded : photosStillNeeded // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
