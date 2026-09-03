// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payout_account_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PayoutAccountView {

/// proUserId
@JsonKey(name: PayoutAccountView.proUserIdKey_) String get proUserId;/// payoutMethod
@JsonKey(name: PayoutAccountView.payoutMethodKey_) PayoutMethod get payoutMethod;/// stripeConnectAccountId
@JsonKey(name: PayoutAccountView.stripeConnectAccountIdKey_) String? get stripeConnectAccountId;/// bankDetailsEncrypted
@JsonKey(name: PayoutAccountView.bankDetailsEncryptedKey_) Map<String, dynamic>? get bankDetailsEncrypted;/// status
@JsonKey(name: PayoutAccountView.statusKey_) PayoutAccountStatus get status;/// updatedAt
@JsonKey(name: PayoutAccountView.updatedAtKey_) DateTime get updatedAt;
/// Create a copy of PayoutAccountView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PayoutAccountViewCopyWith<PayoutAccountView> get copyWith => _$PayoutAccountViewCopyWithImpl<PayoutAccountView>(this as PayoutAccountView, _$identity);

  /// Serializes this PayoutAccountView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PayoutAccountView&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.payoutMethod, payoutMethod) || other.payoutMethod == payoutMethod)&&(identical(other.stripeConnectAccountId, stripeConnectAccountId) || other.stripeConnectAccountId == stripeConnectAccountId)&&const DeepCollectionEquality().equals(other.bankDetailsEncrypted, bankDetailsEncrypted)&&(identical(other.status, status) || other.status == status)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,proUserId,payoutMethod,stripeConnectAccountId,const DeepCollectionEquality().hash(bankDetailsEncrypted),status,updatedAt);

@override
String toString() {
  return 'PayoutAccountView(proUserId: $proUserId, payoutMethod: $payoutMethod, stripeConnectAccountId: $stripeConnectAccountId, bankDetailsEncrypted: $bankDetailsEncrypted, status: $status, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PayoutAccountViewCopyWith<$Res>  {
  factory $PayoutAccountViewCopyWith(PayoutAccountView value, $Res Function(PayoutAccountView) _then) = _$PayoutAccountViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: PayoutAccountView.proUserIdKey_) String proUserId,@JsonKey(name: PayoutAccountView.payoutMethodKey_) PayoutMethod payoutMethod,@JsonKey(name: PayoutAccountView.stripeConnectAccountIdKey_) String? stripeConnectAccountId,@JsonKey(name: PayoutAccountView.bankDetailsEncryptedKey_) Map<String, dynamic>? bankDetailsEncrypted,@JsonKey(name: PayoutAccountView.statusKey_) PayoutAccountStatus status,@JsonKey(name: PayoutAccountView.updatedAtKey_) DateTime updatedAt
});




}
/// @nodoc
class _$PayoutAccountViewCopyWithImpl<$Res>
    implements $PayoutAccountViewCopyWith<$Res> {
  _$PayoutAccountViewCopyWithImpl(this._self, this._then);

  final PayoutAccountView _self;
  final $Res Function(PayoutAccountView) _then;

/// Create a copy of PayoutAccountView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? proUserId = null,Object? payoutMethod = null,Object? stripeConnectAccountId = freezed,Object? bankDetailsEncrypted = freezed,Object? status = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,payoutMethod: null == payoutMethod ? _self.payoutMethod : payoutMethod // ignore: cast_nullable_to_non_nullable
as PayoutMethod,stripeConnectAccountId: freezed == stripeConnectAccountId ? _self.stripeConnectAccountId : stripeConnectAccountId // ignore: cast_nullable_to_non_nullable
as String?,bankDetailsEncrypted: freezed == bankDetailsEncrypted ? _self.bankDetailsEncrypted : bankDetailsEncrypted // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PayoutAccountStatus,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PayoutAccountView].
extension PayoutAccountViewPatterns on PayoutAccountView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PayoutAccountView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PayoutAccountView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PayoutAccountView value)  $default,){
final _that = this;
switch (_that) {
case _PayoutAccountView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PayoutAccountView value)?  $default,){
final _that = this;
switch (_that) {
case _PayoutAccountView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: PayoutAccountView.proUserIdKey_)  String proUserId, @JsonKey(name: PayoutAccountView.payoutMethodKey_)  PayoutMethod payoutMethod, @JsonKey(name: PayoutAccountView.stripeConnectAccountIdKey_)  String? stripeConnectAccountId, @JsonKey(name: PayoutAccountView.bankDetailsEncryptedKey_)  Map<String, dynamic>? bankDetailsEncrypted, @JsonKey(name: PayoutAccountView.statusKey_)  PayoutAccountStatus status, @JsonKey(name: PayoutAccountView.updatedAtKey_)  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PayoutAccountView() when $default != null:
return $default(_that.proUserId,_that.payoutMethod,_that.stripeConnectAccountId,_that.bankDetailsEncrypted,_that.status,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: PayoutAccountView.proUserIdKey_)  String proUserId, @JsonKey(name: PayoutAccountView.payoutMethodKey_)  PayoutMethod payoutMethod, @JsonKey(name: PayoutAccountView.stripeConnectAccountIdKey_)  String? stripeConnectAccountId, @JsonKey(name: PayoutAccountView.bankDetailsEncryptedKey_)  Map<String, dynamic>? bankDetailsEncrypted, @JsonKey(name: PayoutAccountView.statusKey_)  PayoutAccountStatus status, @JsonKey(name: PayoutAccountView.updatedAtKey_)  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PayoutAccountView():
return $default(_that.proUserId,_that.payoutMethod,_that.stripeConnectAccountId,_that.bankDetailsEncrypted,_that.status,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: PayoutAccountView.proUserIdKey_)  String proUserId, @JsonKey(name: PayoutAccountView.payoutMethodKey_)  PayoutMethod payoutMethod, @JsonKey(name: PayoutAccountView.stripeConnectAccountIdKey_)  String? stripeConnectAccountId, @JsonKey(name: PayoutAccountView.bankDetailsEncryptedKey_)  Map<String, dynamic>? bankDetailsEncrypted, @JsonKey(name: PayoutAccountView.statusKey_)  PayoutAccountStatus status, @JsonKey(name: PayoutAccountView.updatedAtKey_)  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PayoutAccountView() when $default != null:
return $default(_that.proUserId,_that.payoutMethod,_that.stripeConnectAccountId,_that.bankDetailsEncrypted,_that.status,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _PayoutAccountView extends PayoutAccountView {
  const _PayoutAccountView({@JsonKey(name: PayoutAccountView.proUserIdKey_) required this.proUserId, @JsonKey(name: PayoutAccountView.payoutMethodKey_) required this.payoutMethod, @JsonKey(name: PayoutAccountView.stripeConnectAccountIdKey_) this.stripeConnectAccountId, @JsonKey(name: PayoutAccountView.bankDetailsEncryptedKey_) final  Map<String, dynamic>? bankDetailsEncrypted, @JsonKey(name: PayoutAccountView.statusKey_) required this.status, @JsonKey(name: PayoutAccountView.updatedAtKey_) required this.updatedAt}): _bankDetailsEncrypted = bankDetailsEncrypted,super._();
  factory _PayoutAccountView.fromJson(Map<String, dynamic> json) => _$PayoutAccountViewFromJson(json);

/// proUserId
@override@JsonKey(name: PayoutAccountView.proUserIdKey_) final  String proUserId;
/// payoutMethod
@override@JsonKey(name: PayoutAccountView.payoutMethodKey_) final  PayoutMethod payoutMethod;
/// stripeConnectAccountId
@override@JsonKey(name: PayoutAccountView.stripeConnectAccountIdKey_) final  String? stripeConnectAccountId;
/// bankDetailsEncrypted
 final  Map<String, dynamic>? _bankDetailsEncrypted;
/// bankDetailsEncrypted
@override@JsonKey(name: PayoutAccountView.bankDetailsEncryptedKey_) Map<String, dynamic>? get bankDetailsEncrypted {
  final value = _bankDetailsEncrypted;
  if (value == null) return null;
  if (_bankDetailsEncrypted is EqualUnmodifiableMapView) return _bankDetailsEncrypted;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// status
@override@JsonKey(name: PayoutAccountView.statusKey_) final  PayoutAccountStatus status;
/// updatedAt
@override@JsonKey(name: PayoutAccountView.updatedAtKey_) final  DateTime updatedAt;

/// Create a copy of PayoutAccountView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PayoutAccountViewCopyWith<_PayoutAccountView> get copyWith => __$PayoutAccountViewCopyWithImpl<_PayoutAccountView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PayoutAccountViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PayoutAccountView&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.payoutMethod, payoutMethod) || other.payoutMethod == payoutMethod)&&(identical(other.stripeConnectAccountId, stripeConnectAccountId) || other.stripeConnectAccountId == stripeConnectAccountId)&&const DeepCollectionEquality().equals(other._bankDetailsEncrypted, _bankDetailsEncrypted)&&(identical(other.status, status) || other.status == status)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,proUserId,payoutMethod,stripeConnectAccountId,const DeepCollectionEquality().hash(_bankDetailsEncrypted),status,updatedAt);

@override
String toString() {
  return 'PayoutAccountView(proUserId: $proUserId, payoutMethod: $payoutMethod, stripeConnectAccountId: $stripeConnectAccountId, bankDetailsEncrypted: $bankDetailsEncrypted, status: $status, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PayoutAccountViewCopyWith<$Res> implements $PayoutAccountViewCopyWith<$Res> {
  factory _$PayoutAccountViewCopyWith(_PayoutAccountView value, $Res Function(_PayoutAccountView) _then) = __$PayoutAccountViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: PayoutAccountView.proUserIdKey_) String proUserId,@JsonKey(name: PayoutAccountView.payoutMethodKey_) PayoutMethod payoutMethod,@JsonKey(name: PayoutAccountView.stripeConnectAccountIdKey_) String? stripeConnectAccountId,@JsonKey(name: PayoutAccountView.bankDetailsEncryptedKey_) Map<String, dynamic>? bankDetailsEncrypted,@JsonKey(name: PayoutAccountView.statusKey_) PayoutAccountStatus status,@JsonKey(name: PayoutAccountView.updatedAtKey_) DateTime updatedAt
});




}
/// @nodoc
class __$PayoutAccountViewCopyWithImpl<$Res>
    implements _$PayoutAccountViewCopyWith<$Res> {
  __$PayoutAccountViewCopyWithImpl(this._self, this._then);

  final _PayoutAccountView _self;
  final $Res Function(_PayoutAccountView) _then;

/// Create a copy of PayoutAccountView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? proUserId = null,Object? payoutMethod = null,Object? stripeConnectAccountId = freezed,Object? bankDetailsEncrypted = freezed,Object? status = null,Object? updatedAt = null,}) {
  return _then(_PayoutAccountView(
proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,payoutMethod: null == payoutMethod ? _self.payoutMethod : payoutMethod // ignore: cast_nullable_to_non_nullable
as PayoutMethod,stripeConnectAccountId: freezed == stripeConnectAccountId ? _self.stripeConnectAccountId : stripeConnectAccountId // ignore: cast_nullable_to_non_nullable
as String?,bankDetailsEncrypted: freezed == bankDetailsEncrypted ? _self._bankDetailsEncrypted : bankDetailsEncrypted // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PayoutAccountStatus,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
