// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payout_account_upsert_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PayoutAccountUpsertRequest {

/// payoutMethod
@JsonKey(name: PayoutAccountUpsertRequest.payoutMethodKey_) PayoutMethod get payoutMethod;/// stripeConnectAccountId
@JsonKey(name: PayoutAccountUpsertRequest.stripeConnectAccountIdKey_) String? get stripeConnectAccountId;/// bankDetailsEncrypted
@JsonKey(name: PayoutAccountUpsertRequest.bankDetailsEncryptedKey_) Map<String, dynamic>? get bankDetailsEncrypted;/// status
@JsonKey(name: PayoutAccountUpsertRequest.statusKey_) PayoutAccountStatus get status;
/// Create a copy of PayoutAccountUpsertRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PayoutAccountUpsertRequestCopyWith<PayoutAccountUpsertRequest> get copyWith => _$PayoutAccountUpsertRequestCopyWithImpl<PayoutAccountUpsertRequest>(this as PayoutAccountUpsertRequest, _$identity);

  /// Serializes this PayoutAccountUpsertRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PayoutAccountUpsertRequest&&(identical(other.payoutMethod, payoutMethod) || other.payoutMethod == payoutMethod)&&(identical(other.stripeConnectAccountId, stripeConnectAccountId) || other.stripeConnectAccountId == stripeConnectAccountId)&&const DeepCollectionEquality().equals(other.bankDetailsEncrypted, bankDetailsEncrypted)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,payoutMethod,stripeConnectAccountId,const DeepCollectionEquality().hash(bankDetailsEncrypted),status);

@override
String toString() {
  return 'PayoutAccountUpsertRequest(payoutMethod: $payoutMethod, stripeConnectAccountId: $stripeConnectAccountId, bankDetailsEncrypted: $bankDetailsEncrypted, status: $status)';
}


}

/// @nodoc
abstract mixin class $PayoutAccountUpsertRequestCopyWith<$Res>  {
  factory $PayoutAccountUpsertRequestCopyWith(PayoutAccountUpsertRequest value, $Res Function(PayoutAccountUpsertRequest) _then) = _$PayoutAccountUpsertRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: PayoutAccountUpsertRequest.payoutMethodKey_) PayoutMethod payoutMethod,@JsonKey(name: PayoutAccountUpsertRequest.stripeConnectAccountIdKey_) String? stripeConnectAccountId,@JsonKey(name: PayoutAccountUpsertRequest.bankDetailsEncryptedKey_) Map<String, dynamic>? bankDetailsEncrypted,@JsonKey(name: PayoutAccountUpsertRequest.statusKey_) PayoutAccountStatus status
});




}
/// @nodoc
class _$PayoutAccountUpsertRequestCopyWithImpl<$Res>
    implements $PayoutAccountUpsertRequestCopyWith<$Res> {
  _$PayoutAccountUpsertRequestCopyWithImpl(this._self, this._then);

  final PayoutAccountUpsertRequest _self;
  final $Res Function(PayoutAccountUpsertRequest) _then;

/// Create a copy of PayoutAccountUpsertRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? payoutMethod = null,Object? stripeConnectAccountId = freezed,Object? bankDetailsEncrypted = freezed,Object? status = null,}) {
  return _then(_self.copyWith(
payoutMethod: null == payoutMethod ? _self.payoutMethod : payoutMethod // ignore: cast_nullable_to_non_nullable
as PayoutMethod,stripeConnectAccountId: freezed == stripeConnectAccountId ? _self.stripeConnectAccountId : stripeConnectAccountId // ignore: cast_nullable_to_non_nullable
as String?,bankDetailsEncrypted: freezed == bankDetailsEncrypted ? _self.bankDetailsEncrypted : bankDetailsEncrypted // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PayoutAccountStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [PayoutAccountUpsertRequest].
extension PayoutAccountUpsertRequestPatterns on PayoutAccountUpsertRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PayoutAccountUpsertRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PayoutAccountUpsertRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PayoutAccountUpsertRequest value)  $default,){
final _that = this;
switch (_that) {
case _PayoutAccountUpsertRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PayoutAccountUpsertRequest value)?  $default,){
final _that = this;
switch (_that) {
case _PayoutAccountUpsertRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: PayoutAccountUpsertRequest.payoutMethodKey_)  PayoutMethod payoutMethod, @JsonKey(name: PayoutAccountUpsertRequest.stripeConnectAccountIdKey_)  String? stripeConnectAccountId, @JsonKey(name: PayoutAccountUpsertRequest.bankDetailsEncryptedKey_)  Map<String, dynamic>? bankDetailsEncrypted, @JsonKey(name: PayoutAccountUpsertRequest.statusKey_)  PayoutAccountStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PayoutAccountUpsertRequest() when $default != null:
return $default(_that.payoutMethod,_that.stripeConnectAccountId,_that.bankDetailsEncrypted,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: PayoutAccountUpsertRequest.payoutMethodKey_)  PayoutMethod payoutMethod, @JsonKey(name: PayoutAccountUpsertRequest.stripeConnectAccountIdKey_)  String? stripeConnectAccountId, @JsonKey(name: PayoutAccountUpsertRequest.bankDetailsEncryptedKey_)  Map<String, dynamic>? bankDetailsEncrypted, @JsonKey(name: PayoutAccountUpsertRequest.statusKey_)  PayoutAccountStatus status)  $default,) {final _that = this;
switch (_that) {
case _PayoutAccountUpsertRequest():
return $default(_that.payoutMethod,_that.stripeConnectAccountId,_that.bankDetailsEncrypted,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: PayoutAccountUpsertRequest.payoutMethodKey_)  PayoutMethod payoutMethod, @JsonKey(name: PayoutAccountUpsertRequest.stripeConnectAccountIdKey_)  String? stripeConnectAccountId, @JsonKey(name: PayoutAccountUpsertRequest.bankDetailsEncryptedKey_)  Map<String, dynamic>? bankDetailsEncrypted, @JsonKey(name: PayoutAccountUpsertRequest.statusKey_)  PayoutAccountStatus status)?  $default,) {final _that = this;
switch (_that) {
case _PayoutAccountUpsertRequest() when $default != null:
return $default(_that.payoutMethod,_that.stripeConnectAccountId,_that.bankDetailsEncrypted,_that.status);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _PayoutAccountUpsertRequest extends PayoutAccountUpsertRequest {
  const _PayoutAccountUpsertRequest({@JsonKey(name: PayoutAccountUpsertRequest.payoutMethodKey_) required this.payoutMethod, @JsonKey(name: PayoutAccountUpsertRequest.stripeConnectAccountIdKey_) this.stripeConnectAccountId, @JsonKey(name: PayoutAccountUpsertRequest.bankDetailsEncryptedKey_) final  Map<String, dynamic>? bankDetailsEncrypted, @JsonKey(name: PayoutAccountUpsertRequest.statusKey_) this.status = PayoutAccountStatus.pendingVerification}): _bankDetailsEncrypted = bankDetailsEncrypted,super._();
  factory _PayoutAccountUpsertRequest.fromJson(Map<String, dynamic> json) => _$PayoutAccountUpsertRequestFromJson(json);

/// payoutMethod
@override@JsonKey(name: PayoutAccountUpsertRequest.payoutMethodKey_) final  PayoutMethod payoutMethod;
/// stripeConnectAccountId
@override@JsonKey(name: PayoutAccountUpsertRequest.stripeConnectAccountIdKey_) final  String? stripeConnectAccountId;
/// bankDetailsEncrypted
 final  Map<String, dynamic>? _bankDetailsEncrypted;
/// bankDetailsEncrypted
@override@JsonKey(name: PayoutAccountUpsertRequest.bankDetailsEncryptedKey_) Map<String, dynamic>? get bankDetailsEncrypted {
  final value = _bankDetailsEncrypted;
  if (value == null) return null;
  if (_bankDetailsEncrypted is EqualUnmodifiableMapView) return _bankDetailsEncrypted;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// status
@override@JsonKey(name: PayoutAccountUpsertRequest.statusKey_) final  PayoutAccountStatus status;

/// Create a copy of PayoutAccountUpsertRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PayoutAccountUpsertRequestCopyWith<_PayoutAccountUpsertRequest> get copyWith => __$PayoutAccountUpsertRequestCopyWithImpl<_PayoutAccountUpsertRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PayoutAccountUpsertRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PayoutAccountUpsertRequest&&(identical(other.payoutMethod, payoutMethod) || other.payoutMethod == payoutMethod)&&(identical(other.stripeConnectAccountId, stripeConnectAccountId) || other.stripeConnectAccountId == stripeConnectAccountId)&&const DeepCollectionEquality().equals(other._bankDetailsEncrypted, _bankDetailsEncrypted)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,payoutMethod,stripeConnectAccountId,const DeepCollectionEquality().hash(_bankDetailsEncrypted),status);

@override
String toString() {
  return 'PayoutAccountUpsertRequest(payoutMethod: $payoutMethod, stripeConnectAccountId: $stripeConnectAccountId, bankDetailsEncrypted: $bankDetailsEncrypted, status: $status)';
}


}

/// @nodoc
abstract mixin class _$PayoutAccountUpsertRequestCopyWith<$Res> implements $PayoutAccountUpsertRequestCopyWith<$Res> {
  factory _$PayoutAccountUpsertRequestCopyWith(_PayoutAccountUpsertRequest value, $Res Function(_PayoutAccountUpsertRequest) _then) = __$PayoutAccountUpsertRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: PayoutAccountUpsertRequest.payoutMethodKey_) PayoutMethod payoutMethod,@JsonKey(name: PayoutAccountUpsertRequest.stripeConnectAccountIdKey_) String? stripeConnectAccountId,@JsonKey(name: PayoutAccountUpsertRequest.bankDetailsEncryptedKey_) Map<String, dynamic>? bankDetailsEncrypted,@JsonKey(name: PayoutAccountUpsertRequest.statusKey_) PayoutAccountStatus status
});




}
/// @nodoc
class __$PayoutAccountUpsertRequestCopyWithImpl<$Res>
    implements _$PayoutAccountUpsertRequestCopyWith<$Res> {
  __$PayoutAccountUpsertRequestCopyWithImpl(this._self, this._then);

  final _PayoutAccountUpsertRequest _self;
  final $Res Function(_PayoutAccountUpsertRequest) _then;

/// Create a copy of PayoutAccountUpsertRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? payoutMethod = null,Object? stripeConnectAccountId = freezed,Object? bankDetailsEncrypted = freezed,Object? status = null,}) {
  return _then(_PayoutAccountUpsertRequest(
payoutMethod: null == payoutMethod ? _self.payoutMethod : payoutMethod // ignore: cast_nullable_to_non_nullable
as PayoutMethod,stripeConnectAccountId: freezed == stripeConnectAccountId ? _self.stripeConnectAccountId : stripeConnectAccountId // ignore: cast_nullable_to_non_nullable
as String?,bankDetailsEncrypted: freezed == bankDetailsEncrypted ? _self._bankDetailsEncrypted : bankDetailsEncrypted // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PayoutAccountStatus,
  ));
}


}

// dart format on
