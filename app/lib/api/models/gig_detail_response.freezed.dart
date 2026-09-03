// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gig_detail_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GigDetailResponse {

/// gig
@JsonKey(name: GigDetailResponse.gigKey_) GigResponse get gig;/// payment
@JsonKey(name: GigDetailResponse.paymentKey_) PaymentSummary? get payment;/// ledgerSummary
@JsonKey(name: GigDetailResponse.ledgerSummaryKey_) LedgerSummary get ledgerSummary;
/// Create a copy of GigDetailResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GigDetailResponseCopyWith<GigDetailResponse> get copyWith => _$GigDetailResponseCopyWithImpl<GigDetailResponse>(this as GigDetailResponse, _$identity);

  /// Serializes this GigDetailResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GigDetailResponse&&(identical(other.gig, gig) || other.gig == gig)&&(identical(other.payment, payment) || other.payment == payment)&&(identical(other.ledgerSummary, ledgerSummary) || other.ledgerSummary == ledgerSummary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,gig,payment,ledgerSummary);

@override
String toString() {
  return 'GigDetailResponse(gig: $gig, payment: $payment, ledgerSummary: $ledgerSummary)';
}


}

/// @nodoc
abstract mixin class $GigDetailResponseCopyWith<$Res>  {
  factory $GigDetailResponseCopyWith(GigDetailResponse value, $Res Function(GigDetailResponse) _then) = _$GigDetailResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: GigDetailResponse.gigKey_) GigResponse gig,@JsonKey(name: GigDetailResponse.paymentKey_) PaymentSummary? payment,@JsonKey(name: GigDetailResponse.ledgerSummaryKey_) LedgerSummary ledgerSummary
});


$GigResponseCopyWith<$Res> get gig;$PaymentSummaryCopyWith<$Res>? get payment;$LedgerSummaryCopyWith<$Res> get ledgerSummary;

}
/// @nodoc
class _$GigDetailResponseCopyWithImpl<$Res>
    implements $GigDetailResponseCopyWith<$Res> {
  _$GigDetailResponseCopyWithImpl(this._self, this._then);

  final GigDetailResponse _self;
  final $Res Function(GigDetailResponse) _then;

/// Create a copy of GigDetailResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? gig = null,Object? payment = freezed,Object? ledgerSummary = null,}) {
  return _then(_self.copyWith(
gig: null == gig ? _self.gig : gig // ignore: cast_nullable_to_non_nullable
as GigResponse,payment: freezed == payment ? _self.payment : payment // ignore: cast_nullable_to_non_nullable
as PaymentSummary?,ledgerSummary: null == ledgerSummary ? _self.ledgerSummary : ledgerSummary // ignore: cast_nullable_to_non_nullable
as LedgerSummary,
  ));
}
/// Create a copy of GigDetailResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GigResponseCopyWith<$Res> get gig {
  
  return $GigResponseCopyWith<$Res>(_self.gig, (value) {
    return _then(_self.copyWith(gig: value));
  });
}/// Create a copy of GigDetailResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaymentSummaryCopyWith<$Res>? get payment {
    if (_self.payment == null) {
    return null;
  }

  return $PaymentSummaryCopyWith<$Res>(_self.payment!, (value) {
    return _then(_self.copyWith(payment: value));
  });
}/// Create a copy of GigDetailResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LedgerSummaryCopyWith<$Res> get ledgerSummary {
  
  return $LedgerSummaryCopyWith<$Res>(_self.ledgerSummary, (value) {
    return _then(_self.copyWith(ledgerSummary: value));
  });
}
}


/// Adds pattern-matching-related methods to [GigDetailResponse].
extension GigDetailResponsePatterns on GigDetailResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GigDetailResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GigDetailResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GigDetailResponse value)  $default,){
final _that = this;
switch (_that) {
case _GigDetailResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GigDetailResponse value)?  $default,){
final _that = this;
switch (_that) {
case _GigDetailResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: GigDetailResponse.gigKey_)  GigResponse gig, @JsonKey(name: GigDetailResponse.paymentKey_)  PaymentSummary? payment, @JsonKey(name: GigDetailResponse.ledgerSummaryKey_)  LedgerSummary ledgerSummary)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GigDetailResponse() when $default != null:
return $default(_that.gig,_that.payment,_that.ledgerSummary);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: GigDetailResponse.gigKey_)  GigResponse gig, @JsonKey(name: GigDetailResponse.paymentKey_)  PaymentSummary? payment, @JsonKey(name: GigDetailResponse.ledgerSummaryKey_)  LedgerSummary ledgerSummary)  $default,) {final _that = this;
switch (_that) {
case _GigDetailResponse():
return $default(_that.gig,_that.payment,_that.ledgerSummary);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: GigDetailResponse.gigKey_)  GigResponse gig, @JsonKey(name: GigDetailResponse.paymentKey_)  PaymentSummary? payment, @JsonKey(name: GigDetailResponse.ledgerSummaryKey_)  LedgerSummary ledgerSummary)?  $default,) {final _that = this;
switch (_that) {
case _GigDetailResponse() when $default != null:
return $default(_that.gig,_that.payment,_that.ledgerSummary);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _GigDetailResponse extends GigDetailResponse {
  const _GigDetailResponse({@JsonKey(name: GigDetailResponse.gigKey_) required this.gig, @JsonKey(name: GigDetailResponse.paymentKey_) this.payment, @JsonKey(name: GigDetailResponse.ledgerSummaryKey_) required this.ledgerSummary}): super._();
  factory _GigDetailResponse.fromJson(Map<String, dynamic> json) => _$GigDetailResponseFromJson(json);

/// gig
@override@JsonKey(name: GigDetailResponse.gigKey_) final  GigResponse gig;
/// payment
@override@JsonKey(name: GigDetailResponse.paymentKey_) final  PaymentSummary? payment;
/// ledgerSummary
@override@JsonKey(name: GigDetailResponse.ledgerSummaryKey_) final  LedgerSummary ledgerSummary;

/// Create a copy of GigDetailResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GigDetailResponseCopyWith<_GigDetailResponse> get copyWith => __$GigDetailResponseCopyWithImpl<_GigDetailResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GigDetailResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GigDetailResponse&&(identical(other.gig, gig) || other.gig == gig)&&(identical(other.payment, payment) || other.payment == payment)&&(identical(other.ledgerSummary, ledgerSummary) || other.ledgerSummary == ledgerSummary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,gig,payment,ledgerSummary);

@override
String toString() {
  return 'GigDetailResponse(gig: $gig, payment: $payment, ledgerSummary: $ledgerSummary)';
}


}

/// @nodoc
abstract mixin class _$GigDetailResponseCopyWith<$Res> implements $GigDetailResponseCopyWith<$Res> {
  factory _$GigDetailResponseCopyWith(_GigDetailResponse value, $Res Function(_GigDetailResponse) _then) = __$GigDetailResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: GigDetailResponse.gigKey_) GigResponse gig,@JsonKey(name: GigDetailResponse.paymentKey_) PaymentSummary? payment,@JsonKey(name: GigDetailResponse.ledgerSummaryKey_) LedgerSummary ledgerSummary
});


@override $GigResponseCopyWith<$Res> get gig;@override $PaymentSummaryCopyWith<$Res>? get payment;@override $LedgerSummaryCopyWith<$Res> get ledgerSummary;

}
/// @nodoc
class __$GigDetailResponseCopyWithImpl<$Res>
    implements _$GigDetailResponseCopyWith<$Res> {
  __$GigDetailResponseCopyWithImpl(this._self, this._then);

  final _GigDetailResponse _self;
  final $Res Function(_GigDetailResponse) _then;

/// Create a copy of GigDetailResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? gig = null,Object? payment = freezed,Object? ledgerSummary = null,}) {
  return _then(_GigDetailResponse(
gig: null == gig ? _self.gig : gig // ignore: cast_nullable_to_non_nullable
as GigResponse,payment: freezed == payment ? _self.payment : payment // ignore: cast_nullable_to_non_nullable
as PaymentSummary?,ledgerSummary: null == ledgerSummary ? _self.ledgerSummary : ledgerSummary // ignore: cast_nullable_to_non_nullable
as LedgerSummary,
  ));
}

/// Create a copy of GigDetailResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GigResponseCopyWith<$Res> get gig {
  
  return $GigResponseCopyWith<$Res>(_self.gig, (value) {
    return _then(_self.copyWith(gig: value));
  });
}/// Create a copy of GigDetailResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaymentSummaryCopyWith<$Res>? get payment {
    if (_self.payment == null) {
    return null;
  }

  return $PaymentSummaryCopyWith<$Res>(_self.payment!, (value) {
    return _then(_self.copyWith(payment: value));
  });
}/// Create a copy of GigDetailResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LedgerSummaryCopyWith<$Res> get ledgerSummary {
  
  return $LedgerSummaryCopyWith<$Res>(_self.ledgerSummary, (value) {
    return _then(_self.copyWith(ledgerSummary: value));
  });
}
}

// dart format on
