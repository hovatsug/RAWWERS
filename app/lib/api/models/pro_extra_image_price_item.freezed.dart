// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pro_extra_image_price_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProExtraImagePriceItem {

/// nicheSlug
@JsonKey(name: ProExtraImagePriceItem.nicheSlugKey_) String get nicheSlug;/// unitPrice
@JsonKey(name: ProExtraImagePriceItem.unitPriceKey_) dynamic get unitPrice;
/// Create a copy of ProExtraImagePriceItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProExtraImagePriceItemCopyWith<ProExtraImagePriceItem> get copyWith => _$ProExtraImagePriceItemCopyWithImpl<ProExtraImagePriceItem>(this as ProExtraImagePriceItem, _$identity);

  /// Serializes this ProExtraImagePriceItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProExtraImagePriceItem&&(identical(other.nicheSlug, nicheSlug) || other.nicheSlug == nicheSlug)&&const DeepCollectionEquality().equals(other.unitPrice, unitPrice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nicheSlug,const DeepCollectionEquality().hash(unitPrice));

@override
String toString() {
  return 'ProExtraImagePriceItem(nicheSlug: $nicheSlug, unitPrice: $unitPrice)';
}


}

/// @nodoc
abstract mixin class $ProExtraImagePriceItemCopyWith<$Res>  {
  factory $ProExtraImagePriceItemCopyWith(ProExtraImagePriceItem value, $Res Function(ProExtraImagePriceItem) _then) = _$ProExtraImagePriceItemCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ProExtraImagePriceItem.nicheSlugKey_) String nicheSlug,@JsonKey(name: ProExtraImagePriceItem.unitPriceKey_) dynamic unitPrice
});




}
/// @nodoc
class _$ProExtraImagePriceItemCopyWithImpl<$Res>
    implements $ProExtraImagePriceItemCopyWith<$Res> {
  _$ProExtraImagePriceItemCopyWithImpl(this._self, this._then);

  final ProExtraImagePriceItem _self;
  final $Res Function(ProExtraImagePriceItem) _then;

/// Create a copy of ProExtraImagePriceItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nicheSlug = null,Object? unitPrice = freezed,}) {
  return _then(_self.copyWith(
nicheSlug: null == nicheSlug ? _self.nicheSlug : nicheSlug // ignore: cast_nullable_to_non_nullable
as String,unitPrice: freezed == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}

}


/// Adds pattern-matching-related methods to [ProExtraImagePriceItem].
extension ProExtraImagePriceItemPatterns on ProExtraImagePriceItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProExtraImagePriceItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProExtraImagePriceItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProExtraImagePriceItem value)  $default,){
final _that = this;
switch (_that) {
case _ProExtraImagePriceItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProExtraImagePriceItem value)?  $default,){
final _that = this;
switch (_that) {
case _ProExtraImagePriceItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ProExtraImagePriceItem.nicheSlugKey_)  String nicheSlug, @JsonKey(name: ProExtraImagePriceItem.unitPriceKey_)  dynamic unitPrice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProExtraImagePriceItem() when $default != null:
return $default(_that.nicheSlug,_that.unitPrice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ProExtraImagePriceItem.nicheSlugKey_)  String nicheSlug, @JsonKey(name: ProExtraImagePriceItem.unitPriceKey_)  dynamic unitPrice)  $default,) {final _that = this;
switch (_that) {
case _ProExtraImagePriceItem():
return $default(_that.nicheSlug,_that.unitPrice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ProExtraImagePriceItem.nicheSlugKey_)  String nicheSlug, @JsonKey(name: ProExtraImagePriceItem.unitPriceKey_)  dynamic unitPrice)?  $default,) {final _that = this;
switch (_that) {
case _ProExtraImagePriceItem() when $default != null:
return $default(_that.nicheSlug,_that.unitPrice);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ProExtraImagePriceItem extends ProExtraImagePriceItem {
  const _ProExtraImagePriceItem({@JsonKey(name: ProExtraImagePriceItem.nicheSlugKey_) required this.nicheSlug, @JsonKey(name: ProExtraImagePriceItem.unitPriceKey_) required this.unitPrice}): super._();
  factory _ProExtraImagePriceItem.fromJson(Map<String, dynamic> json) => _$ProExtraImagePriceItemFromJson(json);

/// nicheSlug
@override@JsonKey(name: ProExtraImagePriceItem.nicheSlugKey_) final  String nicheSlug;
/// unitPrice
@override@JsonKey(name: ProExtraImagePriceItem.unitPriceKey_) final  dynamic unitPrice;

/// Create a copy of ProExtraImagePriceItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProExtraImagePriceItemCopyWith<_ProExtraImagePriceItem> get copyWith => __$ProExtraImagePriceItemCopyWithImpl<_ProExtraImagePriceItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProExtraImagePriceItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProExtraImagePriceItem&&(identical(other.nicheSlug, nicheSlug) || other.nicheSlug == nicheSlug)&&const DeepCollectionEquality().equals(other.unitPrice, unitPrice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nicheSlug,const DeepCollectionEquality().hash(unitPrice));

@override
String toString() {
  return 'ProExtraImagePriceItem(nicheSlug: $nicheSlug, unitPrice: $unitPrice)';
}


}

/// @nodoc
abstract mixin class _$ProExtraImagePriceItemCopyWith<$Res> implements $ProExtraImagePriceItemCopyWith<$Res> {
  factory _$ProExtraImagePriceItemCopyWith(_ProExtraImagePriceItem value, $Res Function(_ProExtraImagePriceItem) _then) = __$ProExtraImagePriceItemCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ProExtraImagePriceItem.nicheSlugKey_) String nicheSlug,@JsonKey(name: ProExtraImagePriceItem.unitPriceKey_) dynamic unitPrice
});




}
/// @nodoc
class __$ProExtraImagePriceItemCopyWithImpl<$Res>
    implements _$ProExtraImagePriceItemCopyWith<$Res> {
  __$ProExtraImagePriceItemCopyWithImpl(this._self, this._then);

  final _ProExtraImagePriceItem _self;
  final $Res Function(_ProExtraImagePriceItem) _then;

/// Create a copy of ProExtraImagePriceItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nicheSlug = null,Object? unitPrice = freezed,}) {
  return _then(_ProExtraImagePriceItem(
nicheSlug: null == nicheSlug ? _self.nicheSlug : nicheSlug // ignore: cast_nullable_to_non_nullable
as String,unitPrice: freezed == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}

// dart format on
