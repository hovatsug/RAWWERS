// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'upsell_create_intent_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpsellCreateIntentResponse {

/// purchaseId
@JsonKey(name: UpsellCreateIntentResponse.purchaseIdKey_) String get purchaseId;/// paymentIntentId
@JsonKey(name: UpsellCreateIntentResponse.paymentIntentIdKey_) String get paymentIntentId;/// paymentIntentClientSecret
@JsonKey(name: UpsellCreateIntentResponse.paymentIntentClientSecretKey_) String get paymentIntentClientSecret;/// status
@JsonKey(name: UpsellCreateIntentResponse.statusKey_) UpsellPurchaseStatus get status;/// discountAmount
@JsonKey(name: UpsellCreateIntentResponse.discountAmountKey_) String? get discountAmount;/// pointsSpent
@JsonKey(name: UpsellCreateIntentResponse.pointsSpentKey_) int? get pointsSpent;
/// Create a copy of UpsellCreateIntentResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpsellCreateIntentResponseCopyWith<UpsellCreateIntentResponse> get copyWith => _$UpsellCreateIntentResponseCopyWithImpl<UpsellCreateIntentResponse>(this as UpsellCreateIntentResponse, _$identity);

  /// Serializes this UpsellCreateIntentResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpsellCreateIntentResponse&&(identical(other.purchaseId, purchaseId) || other.purchaseId == purchaseId)&&(identical(other.paymentIntentId, paymentIntentId) || other.paymentIntentId == paymentIntentId)&&(identical(other.paymentIntentClientSecret, paymentIntentClientSecret) || other.paymentIntentClientSecret == paymentIntentClientSecret)&&(identical(other.status, status) || other.status == status)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&(identical(other.pointsSpent, pointsSpent) || other.pointsSpent == pointsSpent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,purchaseId,paymentIntentId,paymentIntentClientSecret,status,discountAmount,pointsSpent);

@override
String toString() {
  return 'UpsellCreateIntentResponse(purchaseId: $purchaseId, paymentIntentId: $paymentIntentId, paymentIntentClientSecret: $paymentIntentClientSecret, status: $status, discountAmount: $discountAmount, pointsSpent: $pointsSpent)';
}


}

/// @nodoc
abstract mixin class $UpsellCreateIntentResponseCopyWith<$Res>  {
  factory $UpsellCreateIntentResponseCopyWith(UpsellCreateIntentResponse value, $Res Function(UpsellCreateIntentResponse) _then) = _$UpsellCreateIntentResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: UpsellCreateIntentResponse.purchaseIdKey_) String purchaseId,@JsonKey(name: UpsellCreateIntentResponse.paymentIntentIdKey_) String paymentIntentId,@JsonKey(name: UpsellCreateIntentResponse.paymentIntentClientSecretKey_) String paymentIntentClientSecret,@JsonKey(name: UpsellCreateIntentResponse.statusKey_) UpsellPurchaseStatus status,@JsonKey(name: UpsellCreateIntentResponse.discountAmountKey_) String? discountAmount,@JsonKey(name: UpsellCreateIntentResponse.pointsSpentKey_) int? pointsSpent
});




}
/// @nodoc
class _$UpsellCreateIntentResponseCopyWithImpl<$Res>
    implements $UpsellCreateIntentResponseCopyWith<$Res> {
  _$UpsellCreateIntentResponseCopyWithImpl(this._self, this._then);

  final UpsellCreateIntentResponse _self;
  final $Res Function(UpsellCreateIntentResponse) _then;

/// Create a copy of UpsellCreateIntentResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? purchaseId = null,Object? paymentIntentId = null,Object? paymentIntentClientSecret = null,Object? status = null,Object? discountAmount = freezed,Object? pointsSpent = freezed,}) {
  return _then(_self.copyWith(
purchaseId: null == purchaseId ? _self.purchaseId : purchaseId // ignore: cast_nullable_to_non_nullable
as String,paymentIntentId: null == paymentIntentId ? _self.paymentIntentId : paymentIntentId // ignore: cast_nullable_to_non_nullable
as String,paymentIntentClientSecret: null == paymentIntentClientSecret ? _self.paymentIntentClientSecret : paymentIntentClientSecret // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as UpsellPurchaseStatus,discountAmount: freezed == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as String?,pointsSpent: freezed == pointsSpent ? _self.pointsSpent : pointsSpent // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpsellCreateIntentResponse].
extension UpsellCreateIntentResponsePatterns on UpsellCreateIntentResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpsellCreateIntentResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpsellCreateIntentResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpsellCreateIntentResponse value)  $default,){
final _that = this;
switch (_that) {
case _UpsellCreateIntentResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpsellCreateIntentResponse value)?  $default,){
final _that = this;
switch (_that) {
case _UpsellCreateIntentResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: UpsellCreateIntentResponse.purchaseIdKey_)  String purchaseId, @JsonKey(name: UpsellCreateIntentResponse.paymentIntentIdKey_)  String paymentIntentId, @JsonKey(name: UpsellCreateIntentResponse.paymentIntentClientSecretKey_)  String paymentIntentClientSecret, @JsonKey(name: UpsellCreateIntentResponse.statusKey_)  UpsellPurchaseStatus status, @JsonKey(name: UpsellCreateIntentResponse.discountAmountKey_)  String? discountAmount, @JsonKey(name: UpsellCreateIntentResponse.pointsSpentKey_)  int? pointsSpent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpsellCreateIntentResponse() when $default != null:
return $default(_that.purchaseId,_that.paymentIntentId,_that.paymentIntentClientSecret,_that.status,_that.discountAmount,_that.pointsSpent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: UpsellCreateIntentResponse.purchaseIdKey_)  String purchaseId, @JsonKey(name: UpsellCreateIntentResponse.paymentIntentIdKey_)  String paymentIntentId, @JsonKey(name: UpsellCreateIntentResponse.paymentIntentClientSecretKey_)  String paymentIntentClientSecret, @JsonKey(name: UpsellCreateIntentResponse.statusKey_)  UpsellPurchaseStatus status, @JsonKey(name: UpsellCreateIntentResponse.discountAmountKey_)  String? discountAmount, @JsonKey(name: UpsellCreateIntentResponse.pointsSpentKey_)  int? pointsSpent)  $default,) {final _that = this;
switch (_that) {
case _UpsellCreateIntentResponse():
return $default(_that.purchaseId,_that.paymentIntentId,_that.paymentIntentClientSecret,_that.status,_that.discountAmount,_that.pointsSpent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: UpsellCreateIntentResponse.purchaseIdKey_)  String purchaseId, @JsonKey(name: UpsellCreateIntentResponse.paymentIntentIdKey_)  String paymentIntentId, @JsonKey(name: UpsellCreateIntentResponse.paymentIntentClientSecretKey_)  String paymentIntentClientSecret, @JsonKey(name: UpsellCreateIntentResponse.statusKey_)  UpsellPurchaseStatus status, @JsonKey(name: UpsellCreateIntentResponse.discountAmountKey_)  String? discountAmount, @JsonKey(name: UpsellCreateIntentResponse.pointsSpentKey_)  int? pointsSpent)?  $default,) {final _that = this;
switch (_that) {
case _UpsellCreateIntentResponse() when $default != null:
return $default(_that.purchaseId,_that.paymentIntentId,_that.paymentIntentClientSecret,_that.status,_that.discountAmount,_that.pointsSpent);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _UpsellCreateIntentResponse extends UpsellCreateIntentResponse {
  const _UpsellCreateIntentResponse({@JsonKey(name: UpsellCreateIntentResponse.purchaseIdKey_) required this.purchaseId, @JsonKey(name: UpsellCreateIntentResponse.paymentIntentIdKey_) required this.paymentIntentId, @JsonKey(name: UpsellCreateIntentResponse.paymentIntentClientSecretKey_) required this.paymentIntentClientSecret, @JsonKey(name: UpsellCreateIntentResponse.statusKey_) required this.status, @JsonKey(name: UpsellCreateIntentResponse.discountAmountKey_) this.discountAmount, @JsonKey(name: UpsellCreateIntentResponse.pointsSpentKey_) this.pointsSpent}): super._();
  factory _UpsellCreateIntentResponse.fromJson(Map<String, dynamic> json) => _$UpsellCreateIntentResponseFromJson(json);

/// purchaseId
@override@JsonKey(name: UpsellCreateIntentResponse.purchaseIdKey_) final  String purchaseId;
/// paymentIntentId
@override@JsonKey(name: UpsellCreateIntentResponse.paymentIntentIdKey_) final  String paymentIntentId;
/// paymentIntentClientSecret
@override@JsonKey(name: UpsellCreateIntentResponse.paymentIntentClientSecretKey_) final  String paymentIntentClientSecret;
/// status
@override@JsonKey(name: UpsellCreateIntentResponse.statusKey_) final  UpsellPurchaseStatus status;
/// discountAmount
@override@JsonKey(name: UpsellCreateIntentResponse.discountAmountKey_) final  String? discountAmount;
/// pointsSpent
@override@JsonKey(name: UpsellCreateIntentResponse.pointsSpentKey_) final  int? pointsSpent;

/// Create a copy of UpsellCreateIntentResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpsellCreateIntentResponseCopyWith<_UpsellCreateIntentResponse> get copyWith => __$UpsellCreateIntentResponseCopyWithImpl<_UpsellCreateIntentResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpsellCreateIntentResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpsellCreateIntentResponse&&(identical(other.purchaseId, purchaseId) || other.purchaseId == purchaseId)&&(identical(other.paymentIntentId, paymentIntentId) || other.paymentIntentId == paymentIntentId)&&(identical(other.paymentIntentClientSecret, paymentIntentClientSecret) || other.paymentIntentClientSecret == paymentIntentClientSecret)&&(identical(other.status, status) || other.status == status)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&(identical(other.pointsSpent, pointsSpent) || other.pointsSpent == pointsSpent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,purchaseId,paymentIntentId,paymentIntentClientSecret,status,discountAmount,pointsSpent);

@override
String toString() {
  return 'UpsellCreateIntentResponse(purchaseId: $purchaseId, paymentIntentId: $paymentIntentId, paymentIntentClientSecret: $paymentIntentClientSecret, status: $status, discountAmount: $discountAmount, pointsSpent: $pointsSpent)';
}


}

/// @nodoc
abstract mixin class _$UpsellCreateIntentResponseCopyWith<$Res> implements $UpsellCreateIntentResponseCopyWith<$Res> {
  factory _$UpsellCreateIntentResponseCopyWith(_UpsellCreateIntentResponse value, $Res Function(_UpsellCreateIntentResponse) _then) = __$UpsellCreateIntentResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: UpsellCreateIntentResponse.purchaseIdKey_) String purchaseId,@JsonKey(name: UpsellCreateIntentResponse.paymentIntentIdKey_) String paymentIntentId,@JsonKey(name: UpsellCreateIntentResponse.paymentIntentClientSecretKey_) String paymentIntentClientSecret,@JsonKey(name: UpsellCreateIntentResponse.statusKey_) UpsellPurchaseStatus status,@JsonKey(name: UpsellCreateIntentResponse.discountAmountKey_) String? discountAmount,@JsonKey(name: UpsellCreateIntentResponse.pointsSpentKey_) int? pointsSpent
});




}
/// @nodoc
class __$UpsellCreateIntentResponseCopyWithImpl<$Res>
    implements _$UpsellCreateIntentResponseCopyWith<$Res> {
  __$UpsellCreateIntentResponseCopyWithImpl(this._self, this._then);

  final _UpsellCreateIntentResponse _self;
  final $Res Function(_UpsellCreateIntentResponse) _then;

/// Create a copy of UpsellCreateIntentResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? purchaseId = null,Object? paymentIntentId = null,Object? paymentIntentClientSecret = null,Object? status = null,Object? discountAmount = freezed,Object? pointsSpent = freezed,}) {
  return _then(_UpsellCreateIntentResponse(
purchaseId: null == purchaseId ? _self.purchaseId : purchaseId // ignore: cast_nullable_to_non_nullable
as String,paymentIntentId: null == paymentIntentId ? _self.paymentIntentId : paymentIntentId // ignore: cast_nullable_to_non_nullable
as String,paymentIntentClientSecret: null == paymentIntentClientSecret ? _self.paymentIntentClientSecret : paymentIntentClientSecret // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as UpsellPurchaseStatus,discountAmount: freezed == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as String?,pointsSpent: freezed == pointsSpent ? _self.pointsSpent : pointsSpent // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
