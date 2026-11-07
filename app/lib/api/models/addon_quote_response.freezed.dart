// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'addon_quote_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AddonQuoteResponse {

/// alreadyChosen
@JsonKey(name: AddonQuoteResponse.alreadyChosenKey_) int get alreadyChosen;/// adding
@JsonKey(name: AddonQuoteResponse.addingKey_) int get adding;/// amount
@JsonKey(name: AddonQuoteResponse.amountKey_) String get amount;/// currency
@JsonKey(name: AddonQuoteResponse.currencyKey_) String get currency;/// windowEndsAt
@JsonKey(name: AddonQuoteResponse.windowEndsAtKey_) DateTime? get windowEndsAt;
/// Create a copy of AddonQuoteResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddonQuoteResponseCopyWith<AddonQuoteResponse> get copyWith => _$AddonQuoteResponseCopyWithImpl<AddonQuoteResponse>(this as AddonQuoteResponse, _$identity);

  /// Serializes this AddonQuoteResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddonQuoteResponse&&(identical(other.alreadyChosen, alreadyChosen) || other.alreadyChosen == alreadyChosen)&&(identical(other.adding, adding) || other.adding == adding)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.windowEndsAt, windowEndsAt) || other.windowEndsAt == windowEndsAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,alreadyChosen,adding,amount,currency,windowEndsAt);

@override
String toString() {
  return 'AddonQuoteResponse(alreadyChosen: $alreadyChosen, adding: $adding, amount: $amount, currency: $currency, windowEndsAt: $windowEndsAt)';
}


}

/// @nodoc
abstract mixin class $AddonQuoteResponseCopyWith<$Res>  {
  factory $AddonQuoteResponseCopyWith(AddonQuoteResponse value, $Res Function(AddonQuoteResponse) _then) = _$AddonQuoteResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: AddonQuoteResponse.alreadyChosenKey_) int alreadyChosen,@JsonKey(name: AddonQuoteResponse.addingKey_) int adding,@JsonKey(name: AddonQuoteResponse.amountKey_) String amount,@JsonKey(name: AddonQuoteResponse.currencyKey_) String currency,@JsonKey(name: AddonQuoteResponse.windowEndsAtKey_) DateTime? windowEndsAt
});




}
/// @nodoc
class _$AddonQuoteResponseCopyWithImpl<$Res>
    implements $AddonQuoteResponseCopyWith<$Res> {
  _$AddonQuoteResponseCopyWithImpl(this._self, this._then);

  final AddonQuoteResponse _self;
  final $Res Function(AddonQuoteResponse) _then;

/// Create a copy of AddonQuoteResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? alreadyChosen = null,Object? adding = null,Object? amount = null,Object? currency = null,Object? windowEndsAt = freezed,}) {
  return _then(_self.copyWith(
alreadyChosen: null == alreadyChosen ? _self.alreadyChosen : alreadyChosen // ignore: cast_nullable_to_non_nullable
as int,adding: null == adding ? _self.adding : adding // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,windowEndsAt: freezed == windowEndsAt ? _self.windowEndsAt : windowEndsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AddonQuoteResponse].
extension AddonQuoteResponsePatterns on AddonQuoteResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AddonQuoteResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AddonQuoteResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AddonQuoteResponse value)  $default,){
final _that = this;
switch (_that) {
case _AddonQuoteResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AddonQuoteResponse value)?  $default,){
final _that = this;
switch (_that) {
case _AddonQuoteResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: AddonQuoteResponse.alreadyChosenKey_)  int alreadyChosen, @JsonKey(name: AddonQuoteResponse.addingKey_)  int adding, @JsonKey(name: AddonQuoteResponse.amountKey_)  String amount, @JsonKey(name: AddonQuoteResponse.currencyKey_)  String currency, @JsonKey(name: AddonQuoteResponse.windowEndsAtKey_)  DateTime? windowEndsAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AddonQuoteResponse() when $default != null:
return $default(_that.alreadyChosen,_that.adding,_that.amount,_that.currency,_that.windowEndsAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: AddonQuoteResponse.alreadyChosenKey_)  int alreadyChosen, @JsonKey(name: AddonQuoteResponse.addingKey_)  int adding, @JsonKey(name: AddonQuoteResponse.amountKey_)  String amount, @JsonKey(name: AddonQuoteResponse.currencyKey_)  String currency, @JsonKey(name: AddonQuoteResponse.windowEndsAtKey_)  DateTime? windowEndsAt)  $default,) {final _that = this;
switch (_that) {
case _AddonQuoteResponse():
return $default(_that.alreadyChosen,_that.adding,_that.amount,_that.currency,_that.windowEndsAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: AddonQuoteResponse.alreadyChosenKey_)  int alreadyChosen, @JsonKey(name: AddonQuoteResponse.addingKey_)  int adding, @JsonKey(name: AddonQuoteResponse.amountKey_)  String amount, @JsonKey(name: AddonQuoteResponse.currencyKey_)  String currency, @JsonKey(name: AddonQuoteResponse.windowEndsAtKey_)  DateTime? windowEndsAt)?  $default,) {final _that = this;
switch (_that) {
case _AddonQuoteResponse() when $default != null:
return $default(_that.alreadyChosen,_that.adding,_that.amount,_that.currency,_that.windowEndsAt);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _AddonQuoteResponse extends AddonQuoteResponse {
  const _AddonQuoteResponse({@JsonKey(name: AddonQuoteResponse.alreadyChosenKey_) required this.alreadyChosen, @JsonKey(name: AddonQuoteResponse.addingKey_) required this.adding, @JsonKey(name: AddonQuoteResponse.amountKey_) required this.amount, @JsonKey(name: AddonQuoteResponse.currencyKey_) required this.currency, @JsonKey(name: AddonQuoteResponse.windowEndsAtKey_) this.windowEndsAt}): super._();
  factory _AddonQuoteResponse.fromJson(Map<String, dynamic> json) => _$AddonQuoteResponseFromJson(json);

/// alreadyChosen
@override@JsonKey(name: AddonQuoteResponse.alreadyChosenKey_) final  int alreadyChosen;
/// adding
@override@JsonKey(name: AddonQuoteResponse.addingKey_) final  int adding;
/// amount
@override@JsonKey(name: AddonQuoteResponse.amountKey_) final  String amount;
/// currency
@override@JsonKey(name: AddonQuoteResponse.currencyKey_) final  String currency;
/// windowEndsAt
@override@JsonKey(name: AddonQuoteResponse.windowEndsAtKey_) final  DateTime? windowEndsAt;

/// Create a copy of AddonQuoteResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddonQuoteResponseCopyWith<_AddonQuoteResponse> get copyWith => __$AddonQuoteResponseCopyWithImpl<_AddonQuoteResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AddonQuoteResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddonQuoteResponse&&(identical(other.alreadyChosen, alreadyChosen) || other.alreadyChosen == alreadyChosen)&&(identical(other.adding, adding) || other.adding == adding)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.windowEndsAt, windowEndsAt) || other.windowEndsAt == windowEndsAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,alreadyChosen,adding,amount,currency,windowEndsAt);

@override
String toString() {
  return 'AddonQuoteResponse(alreadyChosen: $alreadyChosen, adding: $adding, amount: $amount, currency: $currency, windowEndsAt: $windowEndsAt)';
}


}

/// @nodoc
abstract mixin class _$AddonQuoteResponseCopyWith<$Res> implements $AddonQuoteResponseCopyWith<$Res> {
  factory _$AddonQuoteResponseCopyWith(_AddonQuoteResponse value, $Res Function(_AddonQuoteResponse) _then) = __$AddonQuoteResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: AddonQuoteResponse.alreadyChosenKey_) int alreadyChosen,@JsonKey(name: AddonQuoteResponse.addingKey_) int adding,@JsonKey(name: AddonQuoteResponse.amountKey_) String amount,@JsonKey(name: AddonQuoteResponse.currencyKey_) String currency,@JsonKey(name: AddonQuoteResponse.windowEndsAtKey_) DateTime? windowEndsAt
});




}
/// @nodoc
class __$AddonQuoteResponseCopyWithImpl<$Res>
    implements _$AddonQuoteResponseCopyWith<$Res> {
  __$AddonQuoteResponseCopyWithImpl(this._self, this._then);

  final _AddonQuoteResponse _self;
  final $Res Function(_AddonQuoteResponse) _then;

/// Create a copy of AddonQuoteResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? alreadyChosen = null,Object? adding = null,Object? amount = null,Object? currency = null,Object? windowEndsAt = freezed,}) {
  return _then(_AddonQuoteResponse(
alreadyChosen: null == alreadyChosen ? _self.alreadyChosen : alreadyChosen // ignore: cast_nullable_to_non_nullable
as int,adding: null == adding ? _self.adding : adding // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,windowEndsAt: freezed == windowEndsAt ? _self.windowEndsAt : windowEndsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
