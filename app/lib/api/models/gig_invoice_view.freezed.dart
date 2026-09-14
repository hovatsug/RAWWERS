// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gig_invoice_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GigInvoiceView {

/// gigId
@JsonKey(name: GigInvoiceView.gigIdKey_) String get gigId;/// issuedAt
@JsonKey(name: GigInvoiceView.issuedAtKey_) DateTime get issuedAt;/// currency
@JsonKey(name: GigInvoiceView.currencyKey_) String get currency;/// clientTotal
@JsonKey(name: GigInvoiceView.clientTotalKey_) String get clientTotal;/// platformRetained
@JsonKey(name: GigInvoiceView.platformRetainedKey_) String get platformRetained;/// proRaww
@JsonKey(name: GigInvoiceView.proRawwKey_) String get proRaww;/// clientRaww
@JsonKey(name: GigInvoiceView.clientRawwKey_) String get clientRaww;/// proCash
@JsonKey(name: GigInvoiceView.proCashKey_) String get proCash;/// retainedPercent
@JsonKey(name: GigInvoiceView.retainedPercentKey_) int get retainedPercent;/// proRawwPercent
@JsonKey(name: GigInvoiceView.proRawwPercentKey_) int get proRawwPercent;/// clientCreditPercent
@JsonKey(name: GigInvoiceView.clientCreditPercentKey_) int get clientCreditPercent;/// photosDelivered
@JsonKey(name: GigInvoiceView.photosDeliveredKey_) int? get photosDelivered;/// ratesWereStamped
@JsonKey(name: GigInvoiceView.ratesWereStampedKey_) bool get ratesWereStamped;
/// Create a copy of GigInvoiceView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GigInvoiceViewCopyWith<GigInvoiceView> get copyWith => _$GigInvoiceViewCopyWithImpl<GigInvoiceView>(this as GigInvoiceView, _$identity);

  /// Serializes this GigInvoiceView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GigInvoiceView&&(identical(other.gigId, gigId) || other.gigId == gigId)&&(identical(other.issuedAt, issuedAt) || other.issuedAt == issuedAt)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.clientTotal, clientTotal) || other.clientTotal == clientTotal)&&(identical(other.platformRetained, platformRetained) || other.platformRetained == platformRetained)&&(identical(other.proRaww, proRaww) || other.proRaww == proRaww)&&(identical(other.clientRaww, clientRaww) || other.clientRaww == clientRaww)&&(identical(other.proCash, proCash) || other.proCash == proCash)&&(identical(other.retainedPercent, retainedPercent) || other.retainedPercent == retainedPercent)&&(identical(other.proRawwPercent, proRawwPercent) || other.proRawwPercent == proRawwPercent)&&(identical(other.clientCreditPercent, clientCreditPercent) || other.clientCreditPercent == clientCreditPercent)&&(identical(other.photosDelivered, photosDelivered) || other.photosDelivered == photosDelivered)&&(identical(other.ratesWereStamped, ratesWereStamped) || other.ratesWereStamped == ratesWereStamped));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,gigId,issuedAt,currency,clientTotal,platformRetained,proRaww,clientRaww,proCash,retainedPercent,proRawwPercent,clientCreditPercent,photosDelivered,ratesWereStamped);

@override
String toString() {
  return 'GigInvoiceView(gigId: $gigId, issuedAt: $issuedAt, currency: $currency, clientTotal: $clientTotal, platformRetained: $platformRetained, proRaww: $proRaww, clientRaww: $clientRaww, proCash: $proCash, retainedPercent: $retainedPercent, proRawwPercent: $proRawwPercent, clientCreditPercent: $clientCreditPercent, photosDelivered: $photosDelivered, ratesWereStamped: $ratesWereStamped)';
}


}

/// @nodoc
abstract mixin class $GigInvoiceViewCopyWith<$Res>  {
  factory $GigInvoiceViewCopyWith(GigInvoiceView value, $Res Function(GigInvoiceView) _then) = _$GigInvoiceViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: GigInvoiceView.gigIdKey_) String gigId,@JsonKey(name: GigInvoiceView.issuedAtKey_) DateTime issuedAt,@JsonKey(name: GigInvoiceView.currencyKey_) String currency,@JsonKey(name: GigInvoiceView.clientTotalKey_) String clientTotal,@JsonKey(name: GigInvoiceView.platformRetainedKey_) String platformRetained,@JsonKey(name: GigInvoiceView.proRawwKey_) String proRaww,@JsonKey(name: GigInvoiceView.clientRawwKey_) String clientRaww,@JsonKey(name: GigInvoiceView.proCashKey_) String proCash,@JsonKey(name: GigInvoiceView.retainedPercentKey_) int retainedPercent,@JsonKey(name: GigInvoiceView.proRawwPercentKey_) int proRawwPercent,@JsonKey(name: GigInvoiceView.clientCreditPercentKey_) int clientCreditPercent,@JsonKey(name: GigInvoiceView.photosDeliveredKey_) int? photosDelivered,@JsonKey(name: GigInvoiceView.ratesWereStampedKey_) bool ratesWereStamped
});




}
/// @nodoc
class _$GigInvoiceViewCopyWithImpl<$Res>
    implements $GigInvoiceViewCopyWith<$Res> {
  _$GigInvoiceViewCopyWithImpl(this._self, this._then);

  final GigInvoiceView _self;
  final $Res Function(GigInvoiceView) _then;

/// Create a copy of GigInvoiceView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? gigId = null,Object? issuedAt = null,Object? currency = null,Object? clientTotal = null,Object? platformRetained = null,Object? proRaww = null,Object? clientRaww = null,Object? proCash = null,Object? retainedPercent = null,Object? proRawwPercent = null,Object? clientCreditPercent = null,Object? photosDelivered = freezed,Object? ratesWereStamped = null,}) {
  return _then(_self.copyWith(
gigId: null == gigId ? _self.gigId : gigId // ignore: cast_nullable_to_non_nullable
as String,issuedAt: null == issuedAt ? _self.issuedAt : issuedAt // ignore: cast_nullable_to_non_nullable
as DateTime,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,clientTotal: null == clientTotal ? _self.clientTotal : clientTotal // ignore: cast_nullable_to_non_nullable
as String,platformRetained: null == platformRetained ? _self.platformRetained : platformRetained // ignore: cast_nullable_to_non_nullable
as String,proRaww: null == proRaww ? _self.proRaww : proRaww // ignore: cast_nullable_to_non_nullable
as String,clientRaww: null == clientRaww ? _self.clientRaww : clientRaww // ignore: cast_nullable_to_non_nullable
as String,proCash: null == proCash ? _self.proCash : proCash // ignore: cast_nullable_to_non_nullable
as String,retainedPercent: null == retainedPercent ? _self.retainedPercent : retainedPercent // ignore: cast_nullable_to_non_nullable
as int,proRawwPercent: null == proRawwPercent ? _self.proRawwPercent : proRawwPercent // ignore: cast_nullable_to_non_nullable
as int,clientCreditPercent: null == clientCreditPercent ? _self.clientCreditPercent : clientCreditPercent // ignore: cast_nullable_to_non_nullable
as int,photosDelivered: freezed == photosDelivered ? _self.photosDelivered : photosDelivered // ignore: cast_nullable_to_non_nullable
as int?,ratesWereStamped: null == ratesWereStamped ? _self.ratesWereStamped : ratesWereStamped // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [GigInvoiceView].
extension GigInvoiceViewPatterns on GigInvoiceView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GigInvoiceView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GigInvoiceView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GigInvoiceView value)  $default,){
final _that = this;
switch (_that) {
case _GigInvoiceView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GigInvoiceView value)?  $default,){
final _that = this;
switch (_that) {
case _GigInvoiceView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: GigInvoiceView.gigIdKey_)  String gigId, @JsonKey(name: GigInvoiceView.issuedAtKey_)  DateTime issuedAt, @JsonKey(name: GigInvoiceView.currencyKey_)  String currency, @JsonKey(name: GigInvoiceView.clientTotalKey_)  String clientTotal, @JsonKey(name: GigInvoiceView.platformRetainedKey_)  String platformRetained, @JsonKey(name: GigInvoiceView.proRawwKey_)  String proRaww, @JsonKey(name: GigInvoiceView.clientRawwKey_)  String clientRaww, @JsonKey(name: GigInvoiceView.proCashKey_)  String proCash, @JsonKey(name: GigInvoiceView.retainedPercentKey_)  int retainedPercent, @JsonKey(name: GigInvoiceView.proRawwPercentKey_)  int proRawwPercent, @JsonKey(name: GigInvoiceView.clientCreditPercentKey_)  int clientCreditPercent, @JsonKey(name: GigInvoiceView.photosDeliveredKey_)  int? photosDelivered, @JsonKey(name: GigInvoiceView.ratesWereStampedKey_)  bool ratesWereStamped)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GigInvoiceView() when $default != null:
return $default(_that.gigId,_that.issuedAt,_that.currency,_that.clientTotal,_that.platformRetained,_that.proRaww,_that.clientRaww,_that.proCash,_that.retainedPercent,_that.proRawwPercent,_that.clientCreditPercent,_that.photosDelivered,_that.ratesWereStamped);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: GigInvoiceView.gigIdKey_)  String gigId, @JsonKey(name: GigInvoiceView.issuedAtKey_)  DateTime issuedAt, @JsonKey(name: GigInvoiceView.currencyKey_)  String currency, @JsonKey(name: GigInvoiceView.clientTotalKey_)  String clientTotal, @JsonKey(name: GigInvoiceView.platformRetainedKey_)  String platformRetained, @JsonKey(name: GigInvoiceView.proRawwKey_)  String proRaww, @JsonKey(name: GigInvoiceView.clientRawwKey_)  String clientRaww, @JsonKey(name: GigInvoiceView.proCashKey_)  String proCash, @JsonKey(name: GigInvoiceView.retainedPercentKey_)  int retainedPercent, @JsonKey(name: GigInvoiceView.proRawwPercentKey_)  int proRawwPercent, @JsonKey(name: GigInvoiceView.clientCreditPercentKey_)  int clientCreditPercent, @JsonKey(name: GigInvoiceView.photosDeliveredKey_)  int? photosDelivered, @JsonKey(name: GigInvoiceView.ratesWereStampedKey_)  bool ratesWereStamped)  $default,) {final _that = this;
switch (_that) {
case _GigInvoiceView():
return $default(_that.gigId,_that.issuedAt,_that.currency,_that.clientTotal,_that.platformRetained,_that.proRaww,_that.clientRaww,_that.proCash,_that.retainedPercent,_that.proRawwPercent,_that.clientCreditPercent,_that.photosDelivered,_that.ratesWereStamped);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: GigInvoiceView.gigIdKey_)  String gigId, @JsonKey(name: GigInvoiceView.issuedAtKey_)  DateTime issuedAt, @JsonKey(name: GigInvoiceView.currencyKey_)  String currency, @JsonKey(name: GigInvoiceView.clientTotalKey_)  String clientTotal, @JsonKey(name: GigInvoiceView.platformRetainedKey_)  String platformRetained, @JsonKey(name: GigInvoiceView.proRawwKey_)  String proRaww, @JsonKey(name: GigInvoiceView.clientRawwKey_)  String clientRaww, @JsonKey(name: GigInvoiceView.proCashKey_)  String proCash, @JsonKey(name: GigInvoiceView.retainedPercentKey_)  int retainedPercent, @JsonKey(name: GigInvoiceView.proRawwPercentKey_)  int proRawwPercent, @JsonKey(name: GigInvoiceView.clientCreditPercentKey_)  int clientCreditPercent, @JsonKey(name: GigInvoiceView.photosDeliveredKey_)  int? photosDelivered, @JsonKey(name: GigInvoiceView.ratesWereStampedKey_)  bool ratesWereStamped)?  $default,) {final _that = this;
switch (_that) {
case _GigInvoiceView() when $default != null:
return $default(_that.gigId,_that.issuedAt,_that.currency,_that.clientTotal,_that.platformRetained,_that.proRaww,_that.clientRaww,_that.proCash,_that.retainedPercent,_that.proRawwPercent,_that.clientCreditPercent,_that.photosDelivered,_that.ratesWereStamped);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _GigInvoiceView extends GigInvoiceView {
  const _GigInvoiceView({@JsonKey(name: GigInvoiceView.gigIdKey_) required this.gigId, @JsonKey(name: GigInvoiceView.issuedAtKey_) required this.issuedAt, @JsonKey(name: GigInvoiceView.currencyKey_) required this.currency, @JsonKey(name: GigInvoiceView.clientTotalKey_) required this.clientTotal, @JsonKey(name: GigInvoiceView.platformRetainedKey_) required this.platformRetained, @JsonKey(name: GigInvoiceView.proRawwKey_) required this.proRaww, @JsonKey(name: GigInvoiceView.clientRawwKey_) required this.clientRaww, @JsonKey(name: GigInvoiceView.proCashKey_) required this.proCash, @JsonKey(name: GigInvoiceView.retainedPercentKey_) required this.retainedPercent, @JsonKey(name: GigInvoiceView.proRawwPercentKey_) required this.proRawwPercent, @JsonKey(name: GigInvoiceView.clientCreditPercentKey_) required this.clientCreditPercent, @JsonKey(name: GigInvoiceView.photosDeliveredKey_) this.photosDelivered, @JsonKey(name: GigInvoiceView.ratesWereStampedKey_) this.ratesWereStamped = true}): super._();
  factory _GigInvoiceView.fromJson(Map<String, dynamic> json) => _$GigInvoiceViewFromJson(json);

/// gigId
@override@JsonKey(name: GigInvoiceView.gigIdKey_) final  String gigId;
/// issuedAt
@override@JsonKey(name: GigInvoiceView.issuedAtKey_) final  DateTime issuedAt;
/// currency
@override@JsonKey(name: GigInvoiceView.currencyKey_) final  String currency;
/// clientTotal
@override@JsonKey(name: GigInvoiceView.clientTotalKey_) final  String clientTotal;
/// platformRetained
@override@JsonKey(name: GigInvoiceView.platformRetainedKey_) final  String platformRetained;
/// proRaww
@override@JsonKey(name: GigInvoiceView.proRawwKey_) final  String proRaww;
/// clientRaww
@override@JsonKey(name: GigInvoiceView.clientRawwKey_) final  String clientRaww;
/// proCash
@override@JsonKey(name: GigInvoiceView.proCashKey_) final  String proCash;
/// retainedPercent
@override@JsonKey(name: GigInvoiceView.retainedPercentKey_) final  int retainedPercent;
/// proRawwPercent
@override@JsonKey(name: GigInvoiceView.proRawwPercentKey_) final  int proRawwPercent;
/// clientCreditPercent
@override@JsonKey(name: GigInvoiceView.clientCreditPercentKey_) final  int clientCreditPercent;
/// photosDelivered
@override@JsonKey(name: GigInvoiceView.photosDeliveredKey_) final  int? photosDelivered;
/// ratesWereStamped
@override@JsonKey(name: GigInvoiceView.ratesWereStampedKey_) final  bool ratesWereStamped;

/// Create a copy of GigInvoiceView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GigInvoiceViewCopyWith<_GigInvoiceView> get copyWith => __$GigInvoiceViewCopyWithImpl<_GigInvoiceView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GigInvoiceViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GigInvoiceView&&(identical(other.gigId, gigId) || other.gigId == gigId)&&(identical(other.issuedAt, issuedAt) || other.issuedAt == issuedAt)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.clientTotal, clientTotal) || other.clientTotal == clientTotal)&&(identical(other.platformRetained, platformRetained) || other.platformRetained == platformRetained)&&(identical(other.proRaww, proRaww) || other.proRaww == proRaww)&&(identical(other.clientRaww, clientRaww) || other.clientRaww == clientRaww)&&(identical(other.proCash, proCash) || other.proCash == proCash)&&(identical(other.retainedPercent, retainedPercent) || other.retainedPercent == retainedPercent)&&(identical(other.proRawwPercent, proRawwPercent) || other.proRawwPercent == proRawwPercent)&&(identical(other.clientCreditPercent, clientCreditPercent) || other.clientCreditPercent == clientCreditPercent)&&(identical(other.photosDelivered, photosDelivered) || other.photosDelivered == photosDelivered)&&(identical(other.ratesWereStamped, ratesWereStamped) || other.ratesWereStamped == ratesWereStamped));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,gigId,issuedAt,currency,clientTotal,platformRetained,proRaww,clientRaww,proCash,retainedPercent,proRawwPercent,clientCreditPercent,photosDelivered,ratesWereStamped);

@override
String toString() {
  return 'GigInvoiceView(gigId: $gigId, issuedAt: $issuedAt, currency: $currency, clientTotal: $clientTotal, platformRetained: $platformRetained, proRaww: $proRaww, clientRaww: $clientRaww, proCash: $proCash, retainedPercent: $retainedPercent, proRawwPercent: $proRawwPercent, clientCreditPercent: $clientCreditPercent, photosDelivered: $photosDelivered, ratesWereStamped: $ratesWereStamped)';
}


}

/// @nodoc
abstract mixin class _$GigInvoiceViewCopyWith<$Res> implements $GigInvoiceViewCopyWith<$Res> {
  factory _$GigInvoiceViewCopyWith(_GigInvoiceView value, $Res Function(_GigInvoiceView) _then) = __$GigInvoiceViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: GigInvoiceView.gigIdKey_) String gigId,@JsonKey(name: GigInvoiceView.issuedAtKey_) DateTime issuedAt,@JsonKey(name: GigInvoiceView.currencyKey_) String currency,@JsonKey(name: GigInvoiceView.clientTotalKey_) String clientTotal,@JsonKey(name: GigInvoiceView.platformRetainedKey_) String platformRetained,@JsonKey(name: GigInvoiceView.proRawwKey_) String proRaww,@JsonKey(name: GigInvoiceView.clientRawwKey_) String clientRaww,@JsonKey(name: GigInvoiceView.proCashKey_) String proCash,@JsonKey(name: GigInvoiceView.retainedPercentKey_) int retainedPercent,@JsonKey(name: GigInvoiceView.proRawwPercentKey_) int proRawwPercent,@JsonKey(name: GigInvoiceView.clientCreditPercentKey_) int clientCreditPercent,@JsonKey(name: GigInvoiceView.photosDeliveredKey_) int? photosDelivered,@JsonKey(name: GigInvoiceView.ratesWereStampedKey_) bool ratesWereStamped
});




}
/// @nodoc
class __$GigInvoiceViewCopyWithImpl<$Res>
    implements _$GigInvoiceViewCopyWith<$Res> {
  __$GigInvoiceViewCopyWithImpl(this._self, this._then);

  final _GigInvoiceView _self;
  final $Res Function(_GigInvoiceView) _then;

/// Create a copy of GigInvoiceView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? gigId = null,Object? issuedAt = null,Object? currency = null,Object? clientTotal = null,Object? platformRetained = null,Object? proRaww = null,Object? clientRaww = null,Object? proCash = null,Object? retainedPercent = null,Object? proRawwPercent = null,Object? clientCreditPercent = null,Object? photosDelivered = freezed,Object? ratesWereStamped = null,}) {
  return _then(_GigInvoiceView(
gigId: null == gigId ? _self.gigId : gigId // ignore: cast_nullable_to_non_nullable
as String,issuedAt: null == issuedAt ? _self.issuedAt : issuedAt // ignore: cast_nullable_to_non_nullable
as DateTime,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,clientTotal: null == clientTotal ? _self.clientTotal : clientTotal // ignore: cast_nullable_to_non_nullable
as String,platformRetained: null == platformRetained ? _self.platformRetained : platformRetained // ignore: cast_nullable_to_non_nullable
as String,proRaww: null == proRaww ? _self.proRaww : proRaww // ignore: cast_nullable_to_non_nullable
as String,clientRaww: null == clientRaww ? _self.clientRaww : clientRaww // ignore: cast_nullable_to_non_nullable
as String,proCash: null == proCash ? _self.proCash : proCash // ignore: cast_nullable_to_non_nullable
as String,retainedPercent: null == retainedPercent ? _self.retainedPercent : retainedPercent // ignore: cast_nullable_to_non_nullable
as int,proRawwPercent: null == proRawwPercent ? _self.proRawwPercent : proRawwPercent // ignore: cast_nullable_to_non_nullable
as int,clientCreditPercent: null == clientCreditPercent ? _self.clientCreditPercent : clientCreditPercent // ignore: cast_nullable_to_non_nullable
as int,photosDelivered: freezed == photosDelivered ? _self.photosDelivered : photosDelivered // ignore: cast_nullable_to_non_nullable
as int?,ratesWereStamped: null == ratesWereStamped ? _self.ratesWereStamped : ratesWereStamped // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
