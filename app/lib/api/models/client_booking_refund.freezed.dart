// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_booking_refund.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClientBookingRefund {

/// amount
@JsonKey(name: ClientBookingRefund.amountKey_) String get amount;/// currency
@JsonKey(name: ClientBookingRefund.currencyKey_) String get currency;/// reasons
@JsonKey(name: ClientBookingRefund.reasonsKey_) List<String> get reasons;/// at
@JsonKey(name: ClientBookingRefund.atKey_) DateTime get at;
/// Create a copy of ClientBookingRefund
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientBookingRefundCopyWith<ClientBookingRefund> get copyWith => _$ClientBookingRefundCopyWithImpl<ClientBookingRefund>(this as ClientBookingRefund, _$identity);

  /// Serializes this ClientBookingRefund to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientBookingRefund&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&const DeepCollectionEquality().equals(other.reasons, reasons)&&(identical(other.at, at) || other.at == at));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,amount,currency,const DeepCollectionEquality().hash(reasons),at);

@override
String toString() {
  return 'ClientBookingRefund(amount: $amount, currency: $currency, reasons: $reasons, at: $at)';
}


}

/// @nodoc
abstract mixin class $ClientBookingRefundCopyWith<$Res>  {
  factory $ClientBookingRefundCopyWith(ClientBookingRefund value, $Res Function(ClientBookingRefund) _then) = _$ClientBookingRefundCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ClientBookingRefund.amountKey_) String amount,@JsonKey(name: ClientBookingRefund.currencyKey_) String currency,@JsonKey(name: ClientBookingRefund.reasonsKey_) List<String> reasons,@JsonKey(name: ClientBookingRefund.atKey_) DateTime at
});




}
/// @nodoc
class _$ClientBookingRefundCopyWithImpl<$Res>
    implements $ClientBookingRefundCopyWith<$Res> {
  _$ClientBookingRefundCopyWithImpl(this._self, this._then);

  final ClientBookingRefund _self;
  final $Res Function(ClientBookingRefund) _then;

/// Create a copy of ClientBookingRefund
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? amount = null,Object? currency = null,Object? reasons = null,Object? at = null,}) {
  return _then(_self.copyWith(
amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,reasons: null == reasons ? _self.reasons : reasons // ignore: cast_nullable_to_non_nullable
as List<String>,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ClientBookingRefund].
extension ClientBookingRefundPatterns on ClientBookingRefund {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientBookingRefund value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientBookingRefund() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientBookingRefund value)  $default,){
final _that = this;
switch (_that) {
case _ClientBookingRefund():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientBookingRefund value)?  $default,){
final _that = this;
switch (_that) {
case _ClientBookingRefund() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ClientBookingRefund.amountKey_)  String amount, @JsonKey(name: ClientBookingRefund.currencyKey_)  String currency, @JsonKey(name: ClientBookingRefund.reasonsKey_)  List<String> reasons, @JsonKey(name: ClientBookingRefund.atKey_)  DateTime at)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientBookingRefund() when $default != null:
return $default(_that.amount,_that.currency,_that.reasons,_that.at);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ClientBookingRefund.amountKey_)  String amount, @JsonKey(name: ClientBookingRefund.currencyKey_)  String currency, @JsonKey(name: ClientBookingRefund.reasonsKey_)  List<String> reasons, @JsonKey(name: ClientBookingRefund.atKey_)  DateTime at)  $default,) {final _that = this;
switch (_that) {
case _ClientBookingRefund():
return $default(_that.amount,_that.currency,_that.reasons,_that.at);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ClientBookingRefund.amountKey_)  String amount, @JsonKey(name: ClientBookingRefund.currencyKey_)  String currency, @JsonKey(name: ClientBookingRefund.reasonsKey_)  List<String> reasons, @JsonKey(name: ClientBookingRefund.atKey_)  DateTime at)?  $default,) {final _that = this;
switch (_that) {
case _ClientBookingRefund() when $default != null:
return $default(_that.amount,_that.currency,_that.reasons,_that.at);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ClientBookingRefund extends ClientBookingRefund {
  const _ClientBookingRefund({@JsonKey(name: ClientBookingRefund.amountKey_) required this.amount, @JsonKey(name: ClientBookingRefund.currencyKey_) required this.currency, @JsonKey(name: ClientBookingRefund.reasonsKey_) required final  List<String> reasons, @JsonKey(name: ClientBookingRefund.atKey_) required this.at}): _reasons = reasons,super._();
  factory _ClientBookingRefund.fromJson(Map<String, dynamic> json) => _$ClientBookingRefundFromJson(json);

/// amount
@override@JsonKey(name: ClientBookingRefund.amountKey_) final  String amount;
/// currency
@override@JsonKey(name: ClientBookingRefund.currencyKey_) final  String currency;
/// reasons
 final  List<String> _reasons;
/// reasons
@override@JsonKey(name: ClientBookingRefund.reasonsKey_) List<String> get reasons {
  if (_reasons is EqualUnmodifiableListView) return _reasons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reasons);
}

/// at
@override@JsonKey(name: ClientBookingRefund.atKey_) final  DateTime at;

/// Create a copy of ClientBookingRefund
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientBookingRefundCopyWith<_ClientBookingRefund> get copyWith => __$ClientBookingRefundCopyWithImpl<_ClientBookingRefund>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientBookingRefundToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientBookingRefund&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&const DeepCollectionEquality().equals(other._reasons, _reasons)&&(identical(other.at, at) || other.at == at));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,amount,currency,const DeepCollectionEquality().hash(_reasons),at);

@override
String toString() {
  return 'ClientBookingRefund(amount: $amount, currency: $currency, reasons: $reasons, at: $at)';
}


}

/// @nodoc
abstract mixin class _$ClientBookingRefundCopyWith<$Res> implements $ClientBookingRefundCopyWith<$Res> {
  factory _$ClientBookingRefundCopyWith(_ClientBookingRefund value, $Res Function(_ClientBookingRefund) _then) = __$ClientBookingRefundCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ClientBookingRefund.amountKey_) String amount,@JsonKey(name: ClientBookingRefund.currencyKey_) String currency,@JsonKey(name: ClientBookingRefund.reasonsKey_) List<String> reasons,@JsonKey(name: ClientBookingRefund.atKey_) DateTime at
});




}
/// @nodoc
class __$ClientBookingRefundCopyWithImpl<$Res>
    implements _$ClientBookingRefundCopyWith<$Res> {
  __$ClientBookingRefundCopyWithImpl(this._self, this._then);

  final _ClientBookingRefund _self;
  final $Res Function(_ClientBookingRefund) _then;

/// Create a copy of ClientBookingRefund
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? amount = null,Object? currency = null,Object? reasons = null,Object? at = null,}) {
  return _then(_ClientBookingRefund(
amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,reasons: null == reasons ? _self._reasons : reasons // ignore: cast_nullable_to_non_nullable
as List<String>,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
