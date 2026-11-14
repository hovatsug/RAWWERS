// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'marketing_term_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MarketingTermView {

/// months
@JsonKey(name: MarketingTermView.monthsKey_) int get months;/// credit
@JsonKey(name: MarketingTermView.creditKey_) int get credit;/// creditAmount
@JsonKey(name: MarketingTermView.creditAmountKey_) String get creditAmount;/// currency
@JsonKey(name: MarketingTermView.currencyKey_) String get currency;
/// Create a copy of MarketingTermView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarketingTermViewCopyWith<MarketingTermView> get copyWith => _$MarketingTermViewCopyWithImpl<MarketingTermView>(this as MarketingTermView, _$identity);

  /// Serializes this MarketingTermView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarketingTermView&&(identical(other.months, months) || other.months == months)&&(identical(other.credit, credit) || other.credit == credit)&&(identical(other.creditAmount, creditAmount) || other.creditAmount == creditAmount)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,months,credit,creditAmount,currency);

@override
String toString() {
  return 'MarketingTermView(months: $months, credit: $credit, creditAmount: $creditAmount, currency: $currency)';
}


}

/// @nodoc
abstract mixin class $MarketingTermViewCopyWith<$Res>  {
  factory $MarketingTermViewCopyWith(MarketingTermView value, $Res Function(MarketingTermView) _then) = _$MarketingTermViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: MarketingTermView.monthsKey_) int months,@JsonKey(name: MarketingTermView.creditKey_) int credit,@JsonKey(name: MarketingTermView.creditAmountKey_) String creditAmount,@JsonKey(name: MarketingTermView.currencyKey_) String currency
});




}
/// @nodoc
class _$MarketingTermViewCopyWithImpl<$Res>
    implements $MarketingTermViewCopyWith<$Res> {
  _$MarketingTermViewCopyWithImpl(this._self, this._then);

  final MarketingTermView _self;
  final $Res Function(MarketingTermView) _then;

/// Create a copy of MarketingTermView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? months = null,Object? credit = null,Object? creditAmount = null,Object? currency = null,}) {
  return _then(_self.copyWith(
months: null == months ? _self.months : months // ignore: cast_nullable_to_non_nullable
as int,credit: null == credit ? _self.credit : credit // ignore: cast_nullable_to_non_nullable
as int,creditAmount: null == creditAmount ? _self.creditAmount : creditAmount // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MarketingTermView].
extension MarketingTermViewPatterns on MarketingTermView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MarketingTermView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MarketingTermView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MarketingTermView value)  $default,){
final _that = this;
switch (_that) {
case _MarketingTermView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MarketingTermView value)?  $default,){
final _that = this;
switch (_that) {
case _MarketingTermView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: MarketingTermView.monthsKey_)  int months, @JsonKey(name: MarketingTermView.creditKey_)  int credit, @JsonKey(name: MarketingTermView.creditAmountKey_)  String creditAmount, @JsonKey(name: MarketingTermView.currencyKey_)  String currency)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MarketingTermView() when $default != null:
return $default(_that.months,_that.credit,_that.creditAmount,_that.currency);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: MarketingTermView.monthsKey_)  int months, @JsonKey(name: MarketingTermView.creditKey_)  int credit, @JsonKey(name: MarketingTermView.creditAmountKey_)  String creditAmount, @JsonKey(name: MarketingTermView.currencyKey_)  String currency)  $default,) {final _that = this;
switch (_that) {
case _MarketingTermView():
return $default(_that.months,_that.credit,_that.creditAmount,_that.currency);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: MarketingTermView.monthsKey_)  int months, @JsonKey(name: MarketingTermView.creditKey_)  int credit, @JsonKey(name: MarketingTermView.creditAmountKey_)  String creditAmount, @JsonKey(name: MarketingTermView.currencyKey_)  String currency)?  $default,) {final _that = this;
switch (_that) {
case _MarketingTermView() when $default != null:
return $default(_that.months,_that.credit,_that.creditAmount,_that.currency);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _MarketingTermView extends MarketingTermView {
  const _MarketingTermView({@JsonKey(name: MarketingTermView.monthsKey_) required this.months, @JsonKey(name: MarketingTermView.creditKey_) required this.credit, @JsonKey(name: MarketingTermView.creditAmountKey_) this.creditAmount = '0.00', @JsonKey(name: MarketingTermView.currencyKey_) this.currency = 'EUR'}): super._();
  factory _MarketingTermView.fromJson(Map<String, dynamic> json) => _$MarketingTermViewFromJson(json);

/// months
@override@JsonKey(name: MarketingTermView.monthsKey_) final  int months;
/// credit
@override@JsonKey(name: MarketingTermView.creditKey_) final  int credit;
/// creditAmount
@override@JsonKey(name: MarketingTermView.creditAmountKey_) final  String creditAmount;
/// currency
@override@JsonKey(name: MarketingTermView.currencyKey_) final  String currency;

/// Create a copy of MarketingTermView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarketingTermViewCopyWith<_MarketingTermView> get copyWith => __$MarketingTermViewCopyWithImpl<_MarketingTermView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MarketingTermViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarketingTermView&&(identical(other.months, months) || other.months == months)&&(identical(other.credit, credit) || other.credit == credit)&&(identical(other.creditAmount, creditAmount) || other.creditAmount == creditAmount)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,months,credit,creditAmount,currency);

@override
String toString() {
  return 'MarketingTermView(months: $months, credit: $credit, creditAmount: $creditAmount, currency: $currency)';
}


}

/// @nodoc
abstract mixin class _$MarketingTermViewCopyWith<$Res> implements $MarketingTermViewCopyWith<$Res> {
  factory _$MarketingTermViewCopyWith(_MarketingTermView value, $Res Function(_MarketingTermView) _then) = __$MarketingTermViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: MarketingTermView.monthsKey_) int months,@JsonKey(name: MarketingTermView.creditKey_) int credit,@JsonKey(name: MarketingTermView.creditAmountKey_) String creditAmount,@JsonKey(name: MarketingTermView.currencyKey_) String currency
});




}
/// @nodoc
class __$MarketingTermViewCopyWithImpl<$Res>
    implements _$MarketingTermViewCopyWith<$Res> {
  __$MarketingTermViewCopyWithImpl(this._self, this._then);

  final _MarketingTermView _self;
  final $Res Function(_MarketingTermView) _then;

/// Create a copy of MarketingTermView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? months = null,Object? credit = null,Object? creditAmount = null,Object? currency = null,}) {
  return _then(_MarketingTermView(
months: null == months ? _self.months : months // ignore: cast_nullable_to_non_nullable
as int,credit: null == credit ? _self.credit : credit // ignore: cast_nullable_to_non_nullable
as int,creditAmount: null == creditAmount ? _self.creditAmount : creditAmount // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
