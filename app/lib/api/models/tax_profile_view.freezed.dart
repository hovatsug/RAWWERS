// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tax_profile_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TaxProfileView {

/// vatStatus
@JsonKey(name: TaxProfileView.vatStatusKey_) String get vatStatus;/// vatNumber
@JsonKey(name: TaxProfileView.vatNumberKey_) String? get vatNumber;/// country
@JsonKey(name: TaxProfileView.countryKey_) String? get country;/// taxName
@JsonKey(name: TaxProfileView.taxNameKey_) String? get taxName;/// standardRatePercent
@JsonKey(name: TaxProfileView.standardRatePercentKey_) int? get standardRatePercent;/// registrationThreshold
@JsonKey(name: TaxProfileView.registrationThresholdKey_) String? get registrationThreshold;/// thresholdCurrency
@JsonKey(name: TaxProfileView.thresholdCurrencyKey_) String? get thresholdCurrency;/// vatNumberFormat
@JsonKey(name: TaxProfileView.vatNumberFormatKey_) String? get vatNumberFormat;
/// Create a copy of TaxProfileView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaxProfileViewCopyWith<TaxProfileView> get copyWith => _$TaxProfileViewCopyWithImpl<TaxProfileView>(this as TaxProfileView, _$identity);

  /// Serializes this TaxProfileView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaxProfileView&&(identical(other.vatStatus, vatStatus) || other.vatStatus == vatStatus)&&(identical(other.vatNumber, vatNumber) || other.vatNumber == vatNumber)&&(identical(other.country, country) || other.country == country)&&(identical(other.taxName, taxName) || other.taxName == taxName)&&(identical(other.standardRatePercent, standardRatePercent) || other.standardRatePercent == standardRatePercent)&&(identical(other.registrationThreshold, registrationThreshold) || other.registrationThreshold == registrationThreshold)&&(identical(other.thresholdCurrency, thresholdCurrency) || other.thresholdCurrency == thresholdCurrency)&&(identical(other.vatNumberFormat, vatNumberFormat) || other.vatNumberFormat == vatNumberFormat));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,vatStatus,vatNumber,country,taxName,standardRatePercent,registrationThreshold,thresholdCurrency,vatNumberFormat);

@override
String toString() {
  return 'TaxProfileView(vatStatus: $vatStatus, vatNumber: $vatNumber, country: $country, taxName: $taxName, standardRatePercent: $standardRatePercent, registrationThreshold: $registrationThreshold, thresholdCurrency: $thresholdCurrency, vatNumberFormat: $vatNumberFormat)';
}


}

/// @nodoc
abstract mixin class $TaxProfileViewCopyWith<$Res>  {
  factory $TaxProfileViewCopyWith(TaxProfileView value, $Res Function(TaxProfileView) _then) = _$TaxProfileViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: TaxProfileView.vatStatusKey_) String vatStatus,@JsonKey(name: TaxProfileView.vatNumberKey_) String? vatNumber,@JsonKey(name: TaxProfileView.countryKey_) String? country,@JsonKey(name: TaxProfileView.taxNameKey_) String? taxName,@JsonKey(name: TaxProfileView.standardRatePercentKey_) int? standardRatePercent,@JsonKey(name: TaxProfileView.registrationThresholdKey_) String? registrationThreshold,@JsonKey(name: TaxProfileView.thresholdCurrencyKey_) String? thresholdCurrency,@JsonKey(name: TaxProfileView.vatNumberFormatKey_) String? vatNumberFormat
});




}
/// @nodoc
class _$TaxProfileViewCopyWithImpl<$Res>
    implements $TaxProfileViewCopyWith<$Res> {
  _$TaxProfileViewCopyWithImpl(this._self, this._then);

  final TaxProfileView _self;
  final $Res Function(TaxProfileView) _then;

/// Create a copy of TaxProfileView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? vatStatus = null,Object? vatNumber = freezed,Object? country = freezed,Object? taxName = freezed,Object? standardRatePercent = freezed,Object? registrationThreshold = freezed,Object? thresholdCurrency = freezed,Object? vatNumberFormat = freezed,}) {
  return _then(_self.copyWith(
vatStatus: null == vatStatus ? _self.vatStatus : vatStatus // ignore: cast_nullable_to_non_nullable
as String,vatNumber: freezed == vatNumber ? _self.vatNumber : vatNumber // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,taxName: freezed == taxName ? _self.taxName : taxName // ignore: cast_nullable_to_non_nullable
as String?,standardRatePercent: freezed == standardRatePercent ? _self.standardRatePercent : standardRatePercent // ignore: cast_nullable_to_non_nullable
as int?,registrationThreshold: freezed == registrationThreshold ? _self.registrationThreshold : registrationThreshold // ignore: cast_nullable_to_non_nullable
as String?,thresholdCurrency: freezed == thresholdCurrency ? _self.thresholdCurrency : thresholdCurrency // ignore: cast_nullable_to_non_nullable
as String?,vatNumberFormat: freezed == vatNumberFormat ? _self.vatNumberFormat : vatNumberFormat // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TaxProfileView].
extension TaxProfileViewPatterns on TaxProfileView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaxProfileView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaxProfileView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaxProfileView value)  $default,){
final _that = this;
switch (_that) {
case _TaxProfileView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaxProfileView value)?  $default,){
final _that = this;
switch (_that) {
case _TaxProfileView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: TaxProfileView.vatStatusKey_)  String vatStatus, @JsonKey(name: TaxProfileView.vatNumberKey_)  String? vatNumber, @JsonKey(name: TaxProfileView.countryKey_)  String? country, @JsonKey(name: TaxProfileView.taxNameKey_)  String? taxName, @JsonKey(name: TaxProfileView.standardRatePercentKey_)  int? standardRatePercent, @JsonKey(name: TaxProfileView.registrationThresholdKey_)  String? registrationThreshold, @JsonKey(name: TaxProfileView.thresholdCurrencyKey_)  String? thresholdCurrency, @JsonKey(name: TaxProfileView.vatNumberFormatKey_)  String? vatNumberFormat)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaxProfileView() when $default != null:
return $default(_that.vatStatus,_that.vatNumber,_that.country,_that.taxName,_that.standardRatePercent,_that.registrationThreshold,_that.thresholdCurrency,_that.vatNumberFormat);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: TaxProfileView.vatStatusKey_)  String vatStatus, @JsonKey(name: TaxProfileView.vatNumberKey_)  String? vatNumber, @JsonKey(name: TaxProfileView.countryKey_)  String? country, @JsonKey(name: TaxProfileView.taxNameKey_)  String? taxName, @JsonKey(name: TaxProfileView.standardRatePercentKey_)  int? standardRatePercent, @JsonKey(name: TaxProfileView.registrationThresholdKey_)  String? registrationThreshold, @JsonKey(name: TaxProfileView.thresholdCurrencyKey_)  String? thresholdCurrency, @JsonKey(name: TaxProfileView.vatNumberFormatKey_)  String? vatNumberFormat)  $default,) {final _that = this;
switch (_that) {
case _TaxProfileView():
return $default(_that.vatStatus,_that.vatNumber,_that.country,_that.taxName,_that.standardRatePercent,_that.registrationThreshold,_that.thresholdCurrency,_that.vatNumberFormat);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: TaxProfileView.vatStatusKey_)  String vatStatus, @JsonKey(name: TaxProfileView.vatNumberKey_)  String? vatNumber, @JsonKey(name: TaxProfileView.countryKey_)  String? country, @JsonKey(name: TaxProfileView.taxNameKey_)  String? taxName, @JsonKey(name: TaxProfileView.standardRatePercentKey_)  int? standardRatePercent, @JsonKey(name: TaxProfileView.registrationThresholdKey_)  String? registrationThreshold, @JsonKey(name: TaxProfileView.thresholdCurrencyKey_)  String? thresholdCurrency, @JsonKey(name: TaxProfileView.vatNumberFormatKey_)  String? vatNumberFormat)?  $default,) {final _that = this;
switch (_that) {
case _TaxProfileView() when $default != null:
return $default(_that.vatStatus,_that.vatNumber,_that.country,_that.taxName,_that.standardRatePercent,_that.registrationThreshold,_that.thresholdCurrency,_that.vatNumberFormat);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _TaxProfileView extends TaxProfileView {
  const _TaxProfileView({@JsonKey(name: TaxProfileView.vatStatusKey_) required this.vatStatus, @JsonKey(name: TaxProfileView.vatNumberKey_) this.vatNumber, @JsonKey(name: TaxProfileView.countryKey_) this.country, @JsonKey(name: TaxProfileView.taxNameKey_) this.taxName, @JsonKey(name: TaxProfileView.standardRatePercentKey_) this.standardRatePercent, @JsonKey(name: TaxProfileView.registrationThresholdKey_) this.registrationThreshold, @JsonKey(name: TaxProfileView.thresholdCurrencyKey_) this.thresholdCurrency, @JsonKey(name: TaxProfileView.vatNumberFormatKey_) this.vatNumberFormat}): super._();
  factory _TaxProfileView.fromJson(Map<String, dynamic> json) => _$TaxProfileViewFromJson(json);

/// vatStatus
@override@JsonKey(name: TaxProfileView.vatStatusKey_) final  String vatStatus;
/// vatNumber
@override@JsonKey(name: TaxProfileView.vatNumberKey_) final  String? vatNumber;
/// country
@override@JsonKey(name: TaxProfileView.countryKey_) final  String? country;
/// taxName
@override@JsonKey(name: TaxProfileView.taxNameKey_) final  String? taxName;
/// standardRatePercent
@override@JsonKey(name: TaxProfileView.standardRatePercentKey_) final  int? standardRatePercent;
/// registrationThreshold
@override@JsonKey(name: TaxProfileView.registrationThresholdKey_) final  String? registrationThreshold;
/// thresholdCurrency
@override@JsonKey(name: TaxProfileView.thresholdCurrencyKey_) final  String? thresholdCurrency;
/// vatNumberFormat
@override@JsonKey(name: TaxProfileView.vatNumberFormatKey_) final  String? vatNumberFormat;

/// Create a copy of TaxProfileView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaxProfileViewCopyWith<_TaxProfileView> get copyWith => __$TaxProfileViewCopyWithImpl<_TaxProfileView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaxProfileViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaxProfileView&&(identical(other.vatStatus, vatStatus) || other.vatStatus == vatStatus)&&(identical(other.vatNumber, vatNumber) || other.vatNumber == vatNumber)&&(identical(other.country, country) || other.country == country)&&(identical(other.taxName, taxName) || other.taxName == taxName)&&(identical(other.standardRatePercent, standardRatePercent) || other.standardRatePercent == standardRatePercent)&&(identical(other.registrationThreshold, registrationThreshold) || other.registrationThreshold == registrationThreshold)&&(identical(other.thresholdCurrency, thresholdCurrency) || other.thresholdCurrency == thresholdCurrency)&&(identical(other.vatNumberFormat, vatNumberFormat) || other.vatNumberFormat == vatNumberFormat));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,vatStatus,vatNumber,country,taxName,standardRatePercent,registrationThreshold,thresholdCurrency,vatNumberFormat);

@override
String toString() {
  return 'TaxProfileView(vatStatus: $vatStatus, vatNumber: $vatNumber, country: $country, taxName: $taxName, standardRatePercent: $standardRatePercent, registrationThreshold: $registrationThreshold, thresholdCurrency: $thresholdCurrency, vatNumberFormat: $vatNumberFormat)';
}


}

/// @nodoc
abstract mixin class _$TaxProfileViewCopyWith<$Res> implements $TaxProfileViewCopyWith<$Res> {
  factory _$TaxProfileViewCopyWith(_TaxProfileView value, $Res Function(_TaxProfileView) _then) = __$TaxProfileViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: TaxProfileView.vatStatusKey_) String vatStatus,@JsonKey(name: TaxProfileView.vatNumberKey_) String? vatNumber,@JsonKey(name: TaxProfileView.countryKey_) String? country,@JsonKey(name: TaxProfileView.taxNameKey_) String? taxName,@JsonKey(name: TaxProfileView.standardRatePercentKey_) int? standardRatePercent,@JsonKey(name: TaxProfileView.registrationThresholdKey_) String? registrationThreshold,@JsonKey(name: TaxProfileView.thresholdCurrencyKey_) String? thresholdCurrency,@JsonKey(name: TaxProfileView.vatNumberFormatKey_) String? vatNumberFormat
});




}
/// @nodoc
class __$TaxProfileViewCopyWithImpl<$Res>
    implements _$TaxProfileViewCopyWith<$Res> {
  __$TaxProfileViewCopyWithImpl(this._self, this._then);

  final _TaxProfileView _self;
  final $Res Function(_TaxProfileView) _then;

/// Create a copy of TaxProfileView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? vatStatus = null,Object? vatNumber = freezed,Object? country = freezed,Object? taxName = freezed,Object? standardRatePercent = freezed,Object? registrationThreshold = freezed,Object? thresholdCurrency = freezed,Object? vatNumberFormat = freezed,}) {
  return _then(_TaxProfileView(
vatStatus: null == vatStatus ? _self.vatStatus : vatStatus // ignore: cast_nullable_to_non_nullable
as String,vatNumber: freezed == vatNumber ? _self.vatNumber : vatNumber // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,taxName: freezed == taxName ? _self.taxName : taxName // ignore: cast_nullable_to_non_nullable
as String?,standardRatePercent: freezed == standardRatePercent ? _self.standardRatePercent : standardRatePercent // ignore: cast_nullable_to_non_nullable
as int?,registrationThreshold: freezed == registrationThreshold ? _self.registrationThreshold : registrationThreshold // ignore: cast_nullable_to_non_nullable
as String?,thresholdCurrency: freezed == thresholdCurrency ? _self.thresholdCurrency : thresholdCurrency // ignore: cast_nullable_to_non_nullable
as String?,vatNumberFormat: freezed == vatNumberFormat ? _self.vatNumberFormat : vatNumberFormat // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
