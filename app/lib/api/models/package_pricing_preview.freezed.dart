// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'package_pricing_preview.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PackagePricingPreview {

/// packageId
@JsonKey(name: PackagePricingPreview.packageIdKey_) String get packageId;/// title
@JsonKey(name: PackagePricingPreview.titleKey_) String get title;/// entryPrice
@JsonKey(name: PackagePricingPreview.entryPriceKey_) String get entryPrice;/// currency
@JsonKey(name: PackagePricingPreview.currencyKey_) String get currency;/// priceAtPhotoCount
@JsonKey(name: PackagePricingPreview.priceAtPhotoCountKey_) Map<String, dynamic> get priceAtPhotoCount;
/// Create a copy of PackagePricingPreview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackagePricingPreviewCopyWith<PackagePricingPreview> get copyWith => _$PackagePricingPreviewCopyWithImpl<PackagePricingPreview>(this as PackagePricingPreview, _$identity);

  /// Serializes this PackagePricingPreview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PackagePricingPreview&&(identical(other.packageId, packageId) || other.packageId == packageId)&&(identical(other.title, title) || other.title == title)&&(identical(other.entryPrice, entryPrice) || other.entryPrice == entryPrice)&&(identical(other.currency, currency) || other.currency == currency)&&const DeepCollectionEquality().equals(other.priceAtPhotoCount, priceAtPhotoCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,packageId,title,entryPrice,currency,const DeepCollectionEquality().hash(priceAtPhotoCount));

@override
String toString() {
  return 'PackagePricingPreview(packageId: $packageId, title: $title, entryPrice: $entryPrice, currency: $currency, priceAtPhotoCount: $priceAtPhotoCount)';
}


}

/// @nodoc
abstract mixin class $PackagePricingPreviewCopyWith<$Res>  {
  factory $PackagePricingPreviewCopyWith(PackagePricingPreview value, $Res Function(PackagePricingPreview) _then) = _$PackagePricingPreviewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: PackagePricingPreview.packageIdKey_) String packageId,@JsonKey(name: PackagePricingPreview.titleKey_) String title,@JsonKey(name: PackagePricingPreview.entryPriceKey_) String entryPrice,@JsonKey(name: PackagePricingPreview.currencyKey_) String currency,@JsonKey(name: PackagePricingPreview.priceAtPhotoCountKey_) Map<String, dynamic> priceAtPhotoCount
});




}
/// @nodoc
class _$PackagePricingPreviewCopyWithImpl<$Res>
    implements $PackagePricingPreviewCopyWith<$Res> {
  _$PackagePricingPreviewCopyWithImpl(this._self, this._then);

  final PackagePricingPreview _self;
  final $Res Function(PackagePricingPreview) _then;

/// Create a copy of PackagePricingPreview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? packageId = null,Object? title = null,Object? entryPrice = null,Object? currency = null,Object? priceAtPhotoCount = null,}) {
  return _then(_self.copyWith(
packageId: null == packageId ? _self.packageId : packageId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,entryPrice: null == entryPrice ? _self.entryPrice : entryPrice // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,priceAtPhotoCount: null == priceAtPhotoCount ? _self.priceAtPhotoCount : priceAtPhotoCount // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [PackagePricingPreview].
extension PackagePricingPreviewPatterns on PackagePricingPreview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PackagePricingPreview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PackagePricingPreview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PackagePricingPreview value)  $default,){
final _that = this;
switch (_that) {
case _PackagePricingPreview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PackagePricingPreview value)?  $default,){
final _that = this;
switch (_that) {
case _PackagePricingPreview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: PackagePricingPreview.packageIdKey_)  String packageId, @JsonKey(name: PackagePricingPreview.titleKey_)  String title, @JsonKey(name: PackagePricingPreview.entryPriceKey_)  String entryPrice, @JsonKey(name: PackagePricingPreview.currencyKey_)  String currency, @JsonKey(name: PackagePricingPreview.priceAtPhotoCountKey_)  Map<String, dynamic> priceAtPhotoCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PackagePricingPreview() when $default != null:
return $default(_that.packageId,_that.title,_that.entryPrice,_that.currency,_that.priceAtPhotoCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: PackagePricingPreview.packageIdKey_)  String packageId, @JsonKey(name: PackagePricingPreview.titleKey_)  String title, @JsonKey(name: PackagePricingPreview.entryPriceKey_)  String entryPrice, @JsonKey(name: PackagePricingPreview.currencyKey_)  String currency, @JsonKey(name: PackagePricingPreview.priceAtPhotoCountKey_)  Map<String, dynamic> priceAtPhotoCount)  $default,) {final _that = this;
switch (_that) {
case _PackagePricingPreview():
return $default(_that.packageId,_that.title,_that.entryPrice,_that.currency,_that.priceAtPhotoCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: PackagePricingPreview.packageIdKey_)  String packageId, @JsonKey(name: PackagePricingPreview.titleKey_)  String title, @JsonKey(name: PackagePricingPreview.entryPriceKey_)  String entryPrice, @JsonKey(name: PackagePricingPreview.currencyKey_)  String currency, @JsonKey(name: PackagePricingPreview.priceAtPhotoCountKey_)  Map<String, dynamic> priceAtPhotoCount)?  $default,) {final _that = this;
switch (_that) {
case _PackagePricingPreview() when $default != null:
return $default(_that.packageId,_that.title,_that.entryPrice,_that.currency,_that.priceAtPhotoCount);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _PackagePricingPreview extends PackagePricingPreview {
  const _PackagePricingPreview({@JsonKey(name: PackagePricingPreview.packageIdKey_) required this.packageId, @JsonKey(name: PackagePricingPreview.titleKey_) required this.title, @JsonKey(name: PackagePricingPreview.entryPriceKey_) required this.entryPrice, @JsonKey(name: PackagePricingPreview.currencyKey_) required this.currency, @JsonKey(name: PackagePricingPreview.priceAtPhotoCountKey_) required final  Map<String, dynamic> priceAtPhotoCount}): _priceAtPhotoCount = priceAtPhotoCount,super._();
  factory _PackagePricingPreview.fromJson(Map<String, dynamic> json) => _$PackagePricingPreviewFromJson(json);

/// packageId
@override@JsonKey(name: PackagePricingPreview.packageIdKey_) final  String packageId;
/// title
@override@JsonKey(name: PackagePricingPreview.titleKey_) final  String title;
/// entryPrice
@override@JsonKey(name: PackagePricingPreview.entryPriceKey_) final  String entryPrice;
/// currency
@override@JsonKey(name: PackagePricingPreview.currencyKey_) final  String currency;
/// priceAtPhotoCount
 final  Map<String, dynamic> _priceAtPhotoCount;
/// priceAtPhotoCount
@override@JsonKey(name: PackagePricingPreview.priceAtPhotoCountKey_) Map<String, dynamic> get priceAtPhotoCount {
  if (_priceAtPhotoCount is EqualUnmodifiableMapView) return _priceAtPhotoCount;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_priceAtPhotoCount);
}


/// Create a copy of PackagePricingPreview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PackagePricingPreviewCopyWith<_PackagePricingPreview> get copyWith => __$PackagePricingPreviewCopyWithImpl<_PackagePricingPreview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PackagePricingPreviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PackagePricingPreview&&(identical(other.packageId, packageId) || other.packageId == packageId)&&(identical(other.title, title) || other.title == title)&&(identical(other.entryPrice, entryPrice) || other.entryPrice == entryPrice)&&(identical(other.currency, currency) || other.currency == currency)&&const DeepCollectionEquality().equals(other._priceAtPhotoCount, _priceAtPhotoCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,packageId,title,entryPrice,currency,const DeepCollectionEquality().hash(_priceAtPhotoCount));

@override
String toString() {
  return 'PackagePricingPreview(packageId: $packageId, title: $title, entryPrice: $entryPrice, currency: $currency, priceAtPhotoCount: $priceAtPhotoCount)';
}


}

/// @nodoc
abstract mixin class _$PackagePricingPreviewCopyWith<$Res> implements $PackagePricingPreviewCopyWith<$Res> {
  factory _$PackagePricingPreviewCopyWith(_PackagePricingPreview value, $Res Function(_PackagePricingPreview) _then) = __$PackagePricingPreviewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: PackagePricingPreview.packageIdKey_) String packageId,@JsonKey(name: PackagePricingPreview.titleKey_) String title,@JsonKey(name: PackagePricingPreview.entryPriceKey_) String entryPrice,@JsonKey(name: PackagePricingPreview.currencyKey_) String currency,@JsonKey(name: PackagePricingPreview.priceAtPhotoCountKey_) Map<String, dynamic> priceAtPhotoCount
});




}
/// @nodoc
class __$PackagePricingPreviewCopyWithImpl<$Res>
    implements _$PackagePricingPreviewCopyWith<$Res> {
  __$PackagePricingPreviewCopyWithImpl(this._self, this._then);

  final _PackagePricingPreview _self;
  final $Res Function(_PackagePricingPreview) _then;

/// Create a copy of PackagePricingPreview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? packageId = null,Object? title = null,Object? entryPrice = null,Object? currency = null,Object? priceAtPhotoCount = null,}) {
  return _then(_PackagePricingPreview(
packageId: null == packageId ? _self.packageId : packageId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,entryPrice: null == entryPrice ? _self.entryPrice : entryPrice // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,priceAtPhotoCount: null == priceAtPhotoCount ? _self._priceAtPhotoCount : priceAtPhotoCount // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
