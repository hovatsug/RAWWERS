// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pro_extra_image_price_row.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProExtraImagePriceRow {

/// nicheSlug
@JsonKey(name: ProExtraImagePriceRow.nicheSlugKey_) String get nicheSlug;/// nicheName
@JsonKey(name: ProExtraImagePriceRow.nicheNameKey_) String get nicheName;/// configuredUnitPrice
@JsonKey(name: ProExtraImagePriceRow.configuredUnitPriceKey_) String get configuredUnitPrice;/// appliedUnitPrice
@JsonKey(name: ProExtraImagePriceRow.appliedUnitPriceKey_) String get appliedUnitPrice;/// policyMin
@JsonKey(name: ProExtraImagePriceRow.policyMinKey_) String get policyMin;/// policyMax
@JsonKey(name: ProExtraImagePriceRow.policyMaxKey_) String? get policyMax;/// currency
@JsonKey(name: ProExtraImagePriceRow.currencyKey_) String get currency;
/// Create a copy of ProExtraImagePriceRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProExtraImagePriceRowCopyWith<ProExtraImagePriceRow> get copyWith => _$ProExtraImagePriceRowCopyWithImpl<ProExtraImagePriceRow>(this as ProExtraImagePriceRow, _$identity);

  /// Serializes this ProExtraImagePriceRow to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProExtraImagePriceRow&&(identical(other.nicheSlug, nicheSlug) || other.nicheSlug == nicheSlug)&&(identical(other.nicheName, nicheName) || other.nicheName == nicheName)&&(identical(other.configuredUnitPrice, configuredUnitPrice) || other.configuredUnitPrice == configuredUnitPrice)&&(identical(other.appliedUnitPrice, appliedUnitPrice) || other.appliedUnitPrice == appliedUnitPrice)&&(identical(other.policyMin, policyMin) || other.policyMin == policyMin)&&(identical(other.policyMax, policyMax) || other.policyMax == policyMax)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nicheSlug,nicheName,configuredUnitPrice,appliedUnitPrice,policyMin,policyMax,currency);

@override
String toString() {
  return 'ProExtraImagePriceRow(nicheSlug: $nicheSlug, nicheName: $nicheName, configuredUnitPrice: $configuredUnitPrice, appliedUnitPrice: $appliedUnitPrice, policyMin: $policyMin, policyMax: $policyMax, currency: $currency)';
}


}

/// @nodoc
abstract mixin class $ProExtraImagePriceRowCopyWith<$Res>  {
  factory $ProExtraImagePriceRowCopyWith(ProExtraImagePriceRow value, $Res Function(ProExtraImagePriceRow) _then) = _$ProExtraImagePriceRowCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ProExtraImagePriceRow.nicheSlugKey_) String nicheSlug,@JsonKey(name: ProExtraImagePriceRow.nicheNameKey_) String nicheName,@JsonKey(name: ProExtraImagePriceRow.configuredUnitPriceKey_) String configuredUnitPrice,@JsonKey(name: ProExtraImagePriceRow.appliedUnitPriceKey_) String appliedUnitPrice,@JsonKey(name: ProExtraImagePriceRow.policyMinKey_) String policyMin,@JsonKey(name: ProExtraImagePriceRow.policyMaxKey_) String? policyMax,@JsonKey(name: ProExtraImagePriceRow.currencyKey_) String currency
});




}
/// @nodoc
class _$ProExtraImagePriceRowCopyWithImpl<$Res>
    implements $ProExtraImagePriceRowCopyWith<$Res> {
  _$ProExtraImagePriceRowCopyWithImpl(this._self, this._then);

  final ProExtraImagePriceRow _self;
  final $Res Function(ProExtraImagePriceRow) _then;

/// Create a copy of ProExtraImagePriceRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nicheSlug = null,Object? nicheName = null,Object? configuredUnitPrice = null,Object? appliedUnitPrice = null,Object? policyMin = null,Object? policyMax = freezed,Object? currency = null,}) {
  return _then(_self.copyWith(
nicheSlug: null == nicheSlug ? _self.nicheSlug : nicheSlug // ignore: cast_nullable_to_non_nullable
as String,nicheName: null == nicheName ? _self.nicheName : nicheName // ignore: cast_nullable_to_non_nullable
as String,configuredUnitPrice: null == configuredUnitPrice ? _self.configuredUnitPrice : configuredUnitPrice // ignore: cast_nullable_to_non_nullable
as String,appliedUnitPrice: null == appliedUnitPrice ? _self.appliedUnitPrice : appliedUnitPrice // ignore: cast_nullable_to_non_nullable
as String,policyMin: null == policyMin ? _self.policyMin : policyMin // ignore: cast_nullable_to_non_nullable
as String,policyMax: freezed == policyMax ? _self.policyMax : policyMax // ignore: cast_nullable_to_non_nullable
as String?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ProExtraImagePriceRow].
extension ProExtraImagePriceRowPatterns on ProExtraImagePriceRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProExtraImagePriceRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProExtraImagePriceRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProExtraImagePriceRow value)  $default,){
final _that = this;
switch (_that) {
case _ProExtraImagePriceRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProExtraImagePriceRow value)?  $default,){
final _that = this;
switch (_that) {
case _ProExtraImagePriceRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ProExtraImagePriceRow.nicheSlugKey_)  String nicheSlug, @JsonKey(name: ProExtraImagePriceRow.nicheNameKey_)  String nicheName, @JsonKey(name: ProExtraImagePriceRow.configuredUnitPriceKey_)  String configuredUnitPrice, @JsonKey(name: ProExtraImagePriceRow.appliedUnitPriceKey_)  String appliedUnitPrice, @JsonKey(name: ProExtraImagePriceRow.policyMinKey_)  String policyMin, @JsonKey(name: ProExtraImagePriceRow.policyMaxKey_)  String? policyMax, @JsonKey(name: ProExtraImagePriceRow.currencyKey_)  String currency)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProExtraImagePriceRow() when $default != null:
return $default(_that.nicheSlug,_that.nicheName,_that.configuredUnitPrice,_that.appliedUnitPrice,_that.policyMin,_that.policyMax,_that.currency);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ProExtraImagePriceRow.nicheSlugKey_)  String nicheSlug, @JsonKey(name: ProExtraImagePriceRow.nicheNameKey_)  String nicheName, @JsonKey(name: ProExtraImagePriceRow.configuredUnitPriceKey_)  String configuredUnitPrice, @JsonKey(name: ProExtraImagePriceRow.appliedUnitPriceKey_)  String appliedUnitPrice, @JsonKey(name: ProExtraImagePriceRow.policyMinKey_)  String policyMin, @JsonKey(name: ProExtraImagePriceRow.policyMaxKey_)  String? policyMax, @JsonKey(name: ProExtraImagePriceRow.currencyKey_)  String currency)  $default,) {final _that = this;
switch (_that) {
case _ProExtraImagePriceRow():
return $default(_that.nicheSlug,_that.nicheName,_that.configuredUnitPrice,_that.appliedUnitPrice,_that.policyMin,_that.policyMax,_that.currency);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ProExtraImagePriceRow.nicheSlugKey_)  String nicheSlug, @JsonKey(name: ProExtraImagePriceRow.nicheNameKey_)  String nicheName, @JsonKey(name: ProExtraImagePriceRow.configuredUnitPriceKey_)  String configuredUnitPrice, @JsonKey(name: ProExtraImagePriceRow.appliedUnitPriceKey_)  String appliedUnitPrice, @JsonKey(name: ProExtraImagePriceRow.policyMinKey_)  String policyMin, @JsonKey(name: ProExtraImagePriceRow.policyMaxKey_)  String? policyMax, @JsonKey(name: ProExtraImagePriceRow.currencyKey_)  String currency)?  $default,) {final _that = this;
switch (_that) {
case _ProExtraImagePriceRow() when $default != null:
return $default(_that.nicheSlug,_that.nicheName,_that.configuredUnitPrice,_that.appliedUnitPrice,_that.policyMin,_that.policyMax,_that.currency);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ProExtraImagePriceRow extends ProExtraImagePriceRow {
  const _ProExtraImagePriceRow({@JsonKey(name: ProExtraImagePriceRow.nicheSlugKey_) required this.nicheSlug, @JsonKey(name: ProExtraImagePriceRow.nicheNameKey_) required this.nicheName, @JsonKey(name: ProExtraImagePriceRow.configuredUnitPriceKey_) required this.configuredUnitPrice, @JsonKey(name: ProExtraImagePriceRow.appliedUnitPriceKey_) required this.appliedUnitPrice, @JsonKey(name: ProExtraImagePriceRow.policyMinKey_) required this.policyMin, @JsonKey(name: ProExtraImagePriceRow.policyMaxKey_) this.policyMax, @JsonKey(name: ProExtraImagePriceRow.currencyKey_) required this.currency}): super._();
  factory _ProExtraImagePriceRow.fromJson(Map<String, dynamic> json) => _$ProExtraImagePriceRowFromJson(json);

/// nicheSlug
@override@JsonKey(name: ProExtraImagePriceRow.nicheSlugKey_) final  String nicheSlug;
/// nicheName
@override@JsonKey(name: ProExtraImagePriceRow.nicheNameKey_) final  String nicheName;
/// configuredUnitPrice
@override@JsonKey(name: ProExtraImagePriceRow.configuredUnitPriceKey_) final  String configuredUnitPrice;
/// appliedUnitPrice
@override@JsonKey(name: ProExtraImagePriceRow.appliedUnitPriceKey_) final  String appliedUnitPrice;
/// policyMin
@override@JsonKey(name: ProExtraImagePriceRow.policyMinKey_) final  String policyMin;
/// policyMax
@override@JsonKey(name: ProExtraImagePriceRow.policyMaxKey_) final  String? policyMax;
/// currency
@override@JsonKey(name: ProExtraImagePriceRow.currencyKey_) final  String currency;

/// Create a copy of ProExtraImagePriceRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProExtraImagePriceRowCopyWith<_ProExtraImagePriceRow> get copyWith => __$ProExtraImagePriceRowCopyWithImpl<_ProExtraImagePriceRow>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProExtraImagePriceRowToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProExtraImagePriceRow&&(identical(other.nicheSlug, nicheSlug) || other.nicheSlug == nicheSlug)&&(identical(other.nicheName, nicheName) || other.nicheName == nicheName)&&(identical(other.configuredUnitPrice, configuredUnitPrice) || other.configuredUnitPrice == configuredUnitPrice)&&(identical(other.appliedUnitPrice, appliedUnitPrice) || other.appliedUnitPrice == appliedUnitPrice)&&(identical(other.policyMin, policyMin) || other.policyMin == policyMin)&&(identical(other.policyMax, policyMax) || other.policyMax == policyMax)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nicheSlug,nicheName,configuredUnitPrice,appliedUnitPrice,policyMin,policyMax,currency);

@override
String toString() {
  return 'ProExtraImagePriceRow(nicheSlug: $nicheSlug, nicheName: $nicheName, configuredUnitPrice: $configuredUnitPrice, appliedUnitPrice: $appliedUnitPrice, policyMin: $policyMin, policyMax: $policyMax, currency: $currency)';
}


}

/// @nodoc
abstract mixin class _$ProExtraImagePriceRowCopyWith<$Res> implements $ProExtraImagePriceRowCopyWith<$Res> {
  factory _$ProExtraImagePriceRowCopyWith(_ProExtraImagePriceRow value, $Res Function(_ProExtraImagePriceRow) _then) = __$ProExtraImagePriceRowCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ProExtraImagePriceRow.nicheSlugKey_) String nicheSlug,@JsonKey(name: ProExtraImagePriceRow.nicheNameKey_) String nicheName,@JsonKey(name: ProExtraImagePriceRow.configuredUnitPriceKey_) String configuredUnitPrice,@JsonKey(name: ProExtraImagePriceRow.appliedUnitPriceKey_) String appliedUnitPrice,@JsonKey(name: ProExtraImagePriceRow.policyMinKey_) String policyMin,@JsonKey(name: ProExtraImagePriceRow.policyMaxKey_) String? policyMax,@JsonKey(name: ProExtraImagePriceRow.currencyKey_) String currency
});




}
/// @nodoc
class __$ProExtraImagePriceRowCopyWithImpl<$Res>
    implements _$ProExtraImagePriceRowCopyWith<$Res> {
  __$ProExtraImagePriceRowCopyWithImpl(this._self, this._then);

  final _ProExtraImagePriceRow _self;
  final $Res Function(_ProExtraImagePriceRow) _then;

/// Create a copy of ProExtraImagePriceRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nicheSlug = null,Object? nicheName = null,Object? configuredUnitPrice = null,Object? appliedUnitPrice = null,Object? policyMin = null,Object? policyMax = freezed,Object? currency = null,}) {
  return _then(_ProExtraImagePriceRow(
nicheSlug: null == nicheSlug ? _self.nicheSlug : nicheSlug // ignore: cast_nullable_to_non_nullable
as String,nicheName: null == nicheName ? _self.nicheName : nicheName // ignore: cast_nullable_to_non_nullable
as String,configuredUnitPrice: null == configuredUnitPrice ? _self.configuredUnitPrice : configuredUnitPrice // ignore: cast_nullable_to_non_nullable
as String,appliedUnitPrice: null == appliedUnitPrice ? _self.appliedUnitPrice : appliedUnitPrice // ignore: cast_nullable_to_non_nullable
as String,policyMin: null == policyMin ? _self.policyMin : policyMin // ignore: cast_nullable_to_non_nullable
as String,policyMax: freezed == policyMax ? _self.policyMax : policyMax // ignore: cast_nullable_to_non_nullable
as String?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
