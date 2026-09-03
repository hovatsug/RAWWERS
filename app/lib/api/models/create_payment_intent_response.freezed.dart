// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_payment_intent_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreatePaymentIntentResponse {

/// paymentIntentClientSecret
@JsonKey(name: CreatePaymentIntentResponse.paymentIntentClientSecretKey_) String get paymentIntentClientSecret;/// paymentIntentId
@JsonKey(name: CreatePaymentIntentResponse.paymentIntentIdKey_) String get paymentIntentId;/// status
@JsonKey(name: CreatePaymentIntentResponse.statusKey_) String get status;/// discountAmount
@JsonKey(name: CreatePaymentIntentResponse.discountAmountKey_) String? get discountAmount;/// pointsSpent
@JsonKey(name: CreatePaymentIntentResponse.pointsSpentKey_) int? get pointsSpent;
/// Create a copy of CreatePaymentIntentResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreatePaymentIntentResponseCopyWith<CreatePaymentIntentResponse> get copyWith => _$CreatePaymentIntentResponseCopyWithImpl<CreatePaymentIntentResponse>(this as CreatePaymentIntentResponse, _$identity);

  /// Serializes this CreatePaymentIntentResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreatePaymentIntentResponse&&(identical(other.paymentIntentClientSecret, paymentIntentClientSecret) || other.paymentIntentClientSecret == paymentIntentClientSecret)&&(identical(other.paymentIntentId, paymentIntentId) || other.paymentIntentId == paymentIntentId)&&(identical(other.status, status) || other.status == status)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&(identical(other.pointsSpent, pointsSpent) || other.pointsSpent == pointsSpent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,paymentIntentClientSecret,paymentIntentId,status,discountAmount,pointsSpent);

@override
String toString() {
  return 'CreatePaymentIntentResponse(paymentIntentClientSecret: $paymentIntentClientSecret, paymentIntentId: $paymentIntentId, status: $status, discountAmount: $discountAmount, pointsSpent: $pointsSpent)';
}


}

/// @nodoc
abstract mixin class $CreatePaymentIntentResponseCopyWith<$Res>  {
  factory $CreatePaymentIntentResponseCopyWith(CreatePaymentIntentResponse value, $Res Function(CreatePaymentIntentResponse) _then) = _$CreatePaymentIntentResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: CreatePaymentIntentResponse.paymentIntentClientSecretKey_) String paymentIntentClientSecret,@JsonKey(name: CreatePaymentIntentResponse.paymentIntentIdKey_) String paymentIntentId,@JsonKey(name: CreatePaymentIntentResponse.statusKey_) String status,@JsonKey(name: CreatePaymentIntentResponse.discountAmountKey_) String? discountAmount,@JsonKey(name: CreatePaymentIntentResponse.pointsSpentKey_) int? pointsSpent
});




}
/// @nodoc
class _$CreatePaymentIntentResponseCopyWithImpl<$Res>
    implements $CreatePaymentIntentResponseCopyWith<$Res> {
  _$CreatePaymentIntentResponseCopyWithImpl(this._self, this._then);

  final CreatePaymentIntentResponse _self;
  final $Res Function(CreatePaymentIntentResponse) _then;

/// Create a copy of CreatePaymentIntentResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? paymentIntentClientSecret = null,Object? paymentIntentId = null,Object? status = null,Object? discountAmount = freezed,Object? pointsSpent = freezed,}) {
  return _then(_self.copyWith(
paymentIntentClientSecret: null == paymentIntentClientSecret ? _self.paymentIntentClientSecret : paymentIntentClientSecret // ignore: cast_nullable_to_non_nullable
as String,paymentIntentId: null == paymentIntentId ? _self.paymentIntentId : paymentIntentId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,discountAmount: freezed == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as String?,pointsSpent: freezed == pointsSpent ? _self.pointsSpent : pointsSpent // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreatePaymentIntentResponse].
extension CreatePaymentIntentResponsePatterns on CreatePaymentIntentResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreatePaymentIntentResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreatePaymentIntentResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreatePaymentIntentResponse value)  $default,){
final _that = this;
switch (_that) {
case _CreatePaymentIntentResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreatePaymentIntentResponse value)?  $default,){
final _that = this;
switch (_that) {
case _CreatePaymentIntentResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: CreatePaymentIntentResponse.paymentIntentClientSecretKey_)  String paymentIntentClientSecret, @JsonKey(name: CreatePaymentIntentResponse.paymentIntentIdKey_)  String paymentIntentId, @JsonKey(name: CreatePaymentIntentResponse.statusKey_)  String status, @JsonKey(name: CreatePaymentIntentResponse.discountAmountKey_)  String? discountAmount, @JsonKey(name: CreatePaymentIntentResponse.pointsSpentKey_)  int? pointsSpent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreatePaymentIntentResponse() when $default != null:
return $default(_that.paymentIntentClientSecret,_that.paymentIntentId,_that.status,_that.discountAmount,_that.pointsSpent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: CreatePaymentIntentResponse.paymentIntentClientSecretKey_)  String paymentIntentClientSecret, @JsonKey(name: CreatePaymentIntentResponse.paymentIntentIdKey_)  String paymentIntentId, @JsonKey(name: CreatePaymentIntentResponse.statusKey_)  String status, @JsonKey(name: CreatePaymentIntentResponse.discountAmountKey_)  String? discountAmount, @JsonKey(name: CreatePaymentIntentResponse.pointsSpentKey_)  int? pointsSpent)  $default,) {final _that = this;
switch (_that) {
case _CreatePaymentIntentResponse():
return $default(_that.paymentIntentClientSecret,_that.paymentIntentId,_that.status,_that.discountAmount,_that.pointsSpent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: CreatePaymentIntentResponse.paymentIntentClientSecretKey_)  String paymentIntentClientSecret, @JsonKey(name: CreatePaymentIntentResponse.paymentIntentIdKey_)  String paymentIntentId, @JsonKey(name: CreatePaymentIntentResponse.statusKey_)  String status, @JsonKey(name: CreatePaymentIntentResponse.discountAmountKey_)  String? discountAmount, @JsonKey(name: CreatePaymentIntentResponse.pointsSpentKey_)  int? pointsSpent)?  $default,) {final _that = this;
switch (_that) {
case _CreatePaymentIntentResponse() when $default != null:
return $default(_that.paymentIntentClientSecret,_that.paymentIntentId,_that.status,_that.discountAmount,_that.pointsSpent);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _CreatePaymentIntentResponse extends CreatePaymentIntentResponse {
  const _CreatePaymentIntentResponse({@JsonKey(name: CreatePaymentIntentResponse.paymentIntentClientSecretKey_) required this.paymentIntentClientSecret, @JsonKey(name: CreatePaymentIntentResponse.paymentIntentIdKey_) required this.paymentIntentId, @JsonKey(name: CreatePaymentIntentResponse.statusKey_) required this.status, @JsonKey(name: CreatePaymentIntentResponse.discountAmountKey_) this.discountAmount, @JsonKey(name: CreatePaymentIntentResponse.pointsSpentKey_) this.pointsSpent}): super._();
  factory _CreatePaymentIntentResponse.fromJson(Map<String, dynamic> json) => _$CreatePaymentIntentResponseFromJson(json);

/// paymentIntentClientSecret
@override@JsonKey(name: CreatePaymentIntentResponse.paymentIntentClientSecretKey_) final  String paymentIntentClientSecret;
/// paymentIntentId
@override@JsonKey(name: CreatePaymentIntentResponse.paymentIntentIdKey_) final  String paymentIntentId;
/// status
@override@JsonKey(name: CreatePaymentIntentResponse.statusKey_) final  String status;
/// discountAmount
@override@JsonKey(name: CreatePaymentIntentResponse.discountAmountKey_) final  String? discountAmount;
/// pointsSpent
@override@JsonKey(name: CreatePaymentIntentResponse.pointsSpentKey_) final  int? pointsSpent;

/// Create a copy of CreatePaymentIntentResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreatePaymentIntentResponseCopyWith<_CreatePaymentIntentResponse> get copyWith => __$CreatePaymentIntentResponseCopyWithImpl<_CreatePaymentIntentResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreatePaymentIntentResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreatePaymentIntentResponse&&(identical(other.paymentIntentClientSecret, paymentIntentClientSecret) || other.paymentIntentClientSecret == paymentIntentClientSecret)&&(identical(other.paymentIntentId, paymentIntentId) || other.paymentIntentId == paymentIntentId)&&(identical(other.status, status) || other.status == status)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&(identical(other.pointsSpent, pointsSpent) || other.pointsSpent == pointsSpent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,paymentIntentClientSecret,paymentIntentId,status,discountAmount,pointsSpent);

@override
String toString() {
  return 'CreatePaymentIntentResponse(paymentIntentClientSecret: $paymentIntentClientSecret, paymentIntentId: $paymentIntentId, status: $status, discountAmount: $discountAmount, pointsSpent: $pointsSpent)';
}


}

/// @nodoc
abstract mixin class _$CreatePaymentIntentResponseCopyWith<$Res> implements $CreatePaymentIntentResponseCopyWith<$Res> {
  factory _$CreatePaymentIntentResponseCopyWith(_CreatePaymentIntentResponse value, $Res Function(_CreatePaymentIntentResponse) _then) = __$CreatePaymentIntentResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: CreatePaymentIntentResponse.paymentIntentClientSecretKey_) String paymentIntentClientSecret,@JsonKey(name: CreatePaymentIntentResponse.paymentIntentIdKey_) String paymentIntentId,@JsonKey(name: CreatePaymentIntentResponse.statusKey_) String status,@JsonKey(name: CreatePaymentIntentResponse.discountAmountKey_) String? discountAmount,@JsonKey(name: CreatePaymentIntentResponse.pointsSpentKey_) int? pointsSpent
});




}
/// @nodoc
class __$CreatePaymentIntentResponseCopyWithImpl<$Res>
    implements _$CreatePaymentIntentResponseCopyWith<$Res> {
  __$CreatePaymentIntentResponseCopyWithImpl(this._self, this._then);

  final _CreatePaymentIntentResponse _self;
  final $Res Function(_CreatePaymentIntentResponse) _then;

/// Create a copy of CreatePaymentIntentResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? paymentIntentClientSecret = null,Object? paymentIntentId = null,Object? status = null,Object? discountAmount = freezed,Object? pointsSpent = freezed,}) {
  return _then(_CreatePaymentIntentResponse(
paymentIntentClientSecret: null == paymentIntentClientSecret ? _self.paymentIntentClientSecret : paymentIntentClientSecret // ignore: cast_nullable_to_non_nullable
as String,paymentIntentId: null == paymentIntentId ? _self.paymentIntentId : paymentIntentId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,discountAmount: freezed == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as String?,pointsSpent: freezed == pointsSpent ? _self.pointsSpent : pointsSpent // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
