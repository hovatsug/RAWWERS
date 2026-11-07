// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_credit_preview.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BookingCreditPreview {

/// balanceEur
@JsonKey(name: BookingCreditPreview.balanceEurKey_) String get balanceEur;/// discountEur
@JsonKey(name: BookingCreditPreview.discountEurKey_) String get discountEur;/// priceEur
@JsonKey(name: BookingCreditPreview.priceEurKey_) String get priceEur;/// totalEur
@JsonKey(name: BookingCreditPreview.totalEurKey_) String get totalEur;/// maxDiscountPercent
@JsonKey(name: BookingCreditPreview.maxDiscountPercentKey_) int get maxDiscountPercent;/// applied
@JsonKey(name: BookingCreditPreview.appliedKey_) bool get applied;/// currency
@JsonKey(name: BookingCreditPreview.currencyKey_) String get currency;
/// Create a copy of BookingCreditPreview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingCreditPreviewCopyWith<BookingCreditPreview> get copyWith => _$BookingCreditPreviewCopyWithImpl<BookingCreditPreview>(this as BookingCreditPreview, _$identity);

  /// Serializes this BookingCreditPreview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookingCreditPreview&&(identical(other.balanceEur, balanceEur) || other.balanceEur == balanceEur)&&(identical(other.discountEur, discountEur) || other.discountEur == discountEur)&&(identical(other.priceEur, priceEur) || other.priceEur == priceEur)&&(identical(other.totalEur, totalEur) || other.totalEur == totalEur)&&(identical(other.maxDiscountPercent, maxDiscountPercent) || other.maxDiscountPercent == maxDiscountPercent)&&(identical(other.applied, applied) || other.applied == applied)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,balanceEur,discountEur,priceEur,totalEur,maxDiscountPercent,applied,currency);

@override
String toString() {
  return 'BookingCreditPreview(balanceEur: $balanceEur, discountEur: $discountEur, priceEur: $priceEur, totalEur: $totalEur, maxDiscountPercent: $maxDiscountPercent, applied: $applied, currency: $currency)';
}


}

/// @nodoc
abstract mixin class $BookingCreditPreviewCopyWith<$Res>  {
  factory $BookingCreditPreviewCopyWith(BookingCreditPreview value, $Res Function(BookingCreditPreview) _then) = _$BookingCreditPreviewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: BookingCreditPreview.balanceEurKey_) String balanceEur,@JsonKey(name: BookingCreditPreview.discountEurKey_) String discountEur,@JsonKey(name: BookingCreditPreview.priceEurKey_) String priceEur,@JsonKey(name: BookingCreditPreview.totalEurKey_) String totalEur,@JsonKey(name: BookingCreditPreview.maxDiscountPercentKey_) int maxDiscountPercent,@JsonKey(name: BookingCreditPreview.appliedKey_) bool applied,@JsonKey(name: BookingCreditPreview.currencyKey_) String currency
});




}
/// @nodoc
class _$BookingCreditPreviewCopyWithImpl<$Res>
    implements $BookingCreditPreviewCopyWith<$Res> {
  _$BookingCreditPreviewCopyWithImpl(this._self, this._then);

  final BookingCreditPreview _self;
  final $Res Function(BookingCreditPreview) _then;

/// Create a copy of BookingCreditPreview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? balanceEur = null,Object? discountEur = null,Object? priceEur = null,Object? totalEur = null,Object? maxDiscountPercent = null,Object? applied = null,Object? currency = null,}) {
  return _then(_self.copyWith(
balanceEur: null == balanceEur ? _self.balanceEur : balanceEur // ignore: cast_nullable_to_non_nullable
as String,discountEur: null == discountEur ? _self.discountEur : discountEur // ignore: cast_nullable_to_non_nullable
as String,priceEur: null == priceEur ? _self.priceEur : priceEur // ignore: cast_nullable_to_non_nullable
as String,totalEur: null == totalEur ? _self.totalEur : totalEur // ignore: cast_nullable_to_non_nullable
as String,maxDiscountPercent: null == maxDiscountPercent ? _self.maxDiscountPercent : maxDiscountPercent // ignore: cast_nullable_to_non_nullable
as int,applied: null == applied ? _self.applied : applied // ignore: cast_nullable_to_non_nullable
as bool,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BookingCreditPreview].
extension BookingCreditPreviewPatterns on BookingCreditPreview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookingCreditPreview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookingCreditPreview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookingCreditPreview value)  $default,){
final _that = this;
switch (_that) {
case _BookingCreditPreview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookingCreditPreview value)?  $default,){
final _that = this;
switch (_that) {
case _BookingCreditPreview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: BookingCreditPreview.balanceEurKey_)  String balanceEur, @JsonKey(name: BookingCreditPreview.discountEurKey_)  String discountEur, @JsonKey(name: BookingCreditPreview.priceEurKey_)  String priceEur, @JsonKey(name: BookingCreditPreview.totalEurKey_)  String totalEur, @JsonKey(name: BookingCreditPreview.maxDiscountPercentKey_)  int maxDiscountPercent, @JsonKey(name: BookingCreditPreview.appliedKey_)  bool applied, @JsonKey(name: BookingCreditPreview.currencyKey_)  String currency)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookingCreditPreview() when $default != null:
return $default(_that.balanceEur,_that.discountEur,_that.priceEur,_that.totalEur,_that.maxDiscountPercent,_that.applied,_that.currency);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: BookingCreditPreview.balanceEurKey_)  String balanceEur, @JsonKey(name: BookingCreditPreview.discountEurKey_)  String discountEur, @JsonKey(name: BookingCreditPreview.priceEurKey_)  String priceEur, @JsonKey(name: BookingCreditPreview.totalEurKey_)  String totalEur, @JsonKey(name: BookingCreditPreview.maxDiscountPercentKey_)  int maxDiscountPercent, @JsonKey(name: BookingCreditPreview.appliedKey_)  bool applied, @JsonKey(name: BookingCreditPreview.currencyKey_)  String currency)  $default,) {final _that = this;
switch (_that) {
case _BookingCreditPreview():
return $default(_that.balanceEur,_that.discountEur,_that.priceEur,_that.totalEur,_that.maxDiscountPercent,_that.applied,_that.currency);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: BookingCreditPreview.balanceEurKey_)  String balanceEur, @JsonKey(name: BookingCreditPreview.discountEurKey_)  String discountEur, @JsonKey(name: BookingCreditPreview.priceEurKey_)  String priceEur, @JsonKey(name: BookingCreditPreview.totalEurKey_)  String totalEur, @JsonKey(name: BookingCreditPreview.maxDiscountPercentKey_)  int maxDiscountPercent, @JsonKey(name: BookingCreditPreview.appliedKey_)  bool applied, @JsonKey(name: BookingCreditPreview.currencyKey_)  String currency)?  $default,) {final _that = this;
switch (_that) {
case _BookingCreditPreview() when $default != null:
return $default(_that.balanceEur,_that.discountEur,_that.priceEur,_that.totalEur,_that.maxDiscountPercent,_that.applied,_that.currency);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _BookingCreditPreview extends BookingCreditPreview {
  const _BookingCreditPreview({@JsonKey(name: BookingCreditPreview.balanceEurKey_) required this.balanceEur, @JsonKey(name: BookingCreditPreview.discountEurKey_) required this.discountEur, @JsonKey(name: BookingCreditPreview.priceEurKey_) required this.priceEur, @JsonKey(name: BookingCreditPreview.totalEurKey_) required this.totalEur, @JsonKey(name: BookingCreditPreview.maxDiscountPercentKey_) required this.maxDiscountPercent, @JsonKey(name: BookingCreditPreview.appliedKey_) required this.applied, @JsonKey(name: BookingCreditPreview.currencyKey_) required this.currency}): super._();
  factory _BookingCreditPreview.fromJson(Map<String, dynamic> json) => _$BookingCreditPreviewFromJson(json);

/// balanceEur
@override@JsonKey(name: BookingCreditPreview.balanceEurKey_) final  String balanceEur;
/// discountEur
@override@JsonKey(name: BookingCreditPreview.discountEurKey_) final  String discountEur;
/// priceEur
@override@JsonKey(name: BookingCreditPreview.priceEurKey_) final  String priceEur;
/// totalEur
@override@JsonKey(name: BookingCreditPreview.totalEurKey_) final  String totalEur;
/// maxDiscountPercent
@override@JsonKey(name: BookingCreditPreview.maxDiscountPercentKey_) final  int maxDiscountPercent;
/// applied
@override@JsonKey(name: BookingCreditPreview.appliedKey_) final  bool applied;
/// currency
@override@JsonKey(name: BookingCreditPreview.currencyKey_) final  String currency;

/// Create a copy of BookingCreditPreview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingCreditPreviewCopyWith<_BookingCreditPreview> get copyWith => __$BookingCreditPreviewCopyWithImpl<_BookingCreditPreview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingCreditPreviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookingCreditPreview&&(identical(other.balanceEur, balanceEur) || other.balanceEur == balanceEur)&&(identical(other.discountEur, discountEur) || other.discountEur == discountEur)&&(identical(other.priceEur, priceEur) || other.priceEur == priceEur)&&(identical(other.totalEur, totalEur) || other.totalEur == totalEur)&&(identical(other.maxDiscountPercent, maxDiscountPercent) || other.maxDiscountPercent == maxDiscountPercent)&&(identical(other.applied, applied) || other.applied == applied)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,balanceEur,discountEur,priceEur,totalEur,maxDiscountPercent,applied,currency);

@override
String toString() {
  return 'BookingCreditPreview(balanceEur: $balanceEur, discountEur: $discountEur, priceEur: $priceEur, totalEur: $totalEur, maxDiscountPercent: $maxDiscountPercent, applied: $applied, currency: $currency)';
}


}

/// @nodoc
abstract mixin class _$BookingCreditPreviewCopyWith<$Res> implements $BookingCreditPreviewCopyWith<$Res> {
  factory _$BookingCreditPreviewCopyWith(_BookingCreditPreview value, $Res Function(_BookingCreditPreview) _then) = __$BookingCreditPreviewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: BookingCreditPreview.balanceEurKey_) String balanceEur,@JsonKey(name: BookingCreditPreview.discountEurKey_) String discountEur,@JsonKey(name: BookingCreditPreview.priceEurKey_) String priceEur,@JsonKey(name: BookingCreditPreview.totalEurKey_) String totalEur,@JsonKey(name: BookingCreditPreview.maxDiscountPercentKey_) int maxDiscountPercent,@JsonKey(name: BookingCreditPreview.appliedKey_) bool applied,@JsonKey(name: BookingCreditPreview.currencyKey_) String currency
});




}
/// @nodoc
class __$BookingCreditPreviewCopyWithImpl<$Res>
    implements _$BookingCreditPreviewCopyWith<$Res> {
  __$BookingCreditPreviewCopyWithImpl(this._self, this._then);

  final _BookingCreditPreview _self;
  final $Res Function(_BookingCreditPreview) _then;

/// Create a copy of BookingCreditPreview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? balanceEur = null,Object? discountEur = null,Object? priceEur = null,Object? totalEur = null,Object? maxDiscountPercent = null,Object? applied = null,Object? currency = null,}) {
  return _then(_BookingCreditPreview(
balanceEur: null == balanceEur ? _self.balanceEur : balanceEur // ignore: cast_nullable_to_non_nullable
as String,discountEur: null == discountEur ? _self.discountEur : discountEur // ignore: cast_nullable_to_non_nullable
as String,priceEur: null == priceEur ? _self.priceEur : priceEur // ignore: cast_nullable_to_non_nullable
as String,totalEur: null == totalEur ? _self.totalEur : totalEur // ignore: cast_nullable_to_non_nullable
as String,maxDiscountPercent: null == maxDiscountPercent ? _self.maxDiscountPercent : maxDiscountPercent // ignore: cast_nullable_to_non_nullable
as int,applied: null == applied ? _self.applied : applied // ignore: cast_nullable_to_non_nullable
as bool,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
