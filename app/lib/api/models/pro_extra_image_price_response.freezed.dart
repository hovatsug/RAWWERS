// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pro_extra_image_price_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProExtraImagePriceResponse {

/// items
@JsonKey(name: ProExtraImagePriceResponse.itemsKey_) List<ProExtraImagePriceRow>? get items;
/// Create a copy of ProExtraImagePriceResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProExtraImagePriceResponseCopyWith<ProExtraImagePriceResponse> get copyWith => _$ProExtraImagePriceResponseCopyWithImpl<ProExtraImagePriceResponse>(this as ProExtraImagePriceResponse, _$identity);

  /// Serializes this ProExtraImagePriceResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProExtraImagePriceResponse&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'ProExtraImagePriceResponse(items: $items)';
}


}

/// @nodoc
abstract mixin class $ProExtraImagePriceResponseCopyWith<$Res>  {
  factory $ProExtraImagePriceResponseCopyWith(ProExtraImagePriceResponse value, $Res Function(ProExtraImagePriceResponse) _then) = _$ProExtraImagePriceResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ProExtraImagePriceResponse.itemsKey_) List<ProExtraImagePriceRow>? items
});




}
/// @nodoc
class _$ProExtraImagePriceResponseCopyWithImpl<$Res>
    implements $ProExtraImagePriceResponseCopyWith<$Res> {
  _$ProExtraImagePriceResponseCopyWithImpl(this._self, this._then);

  final ProExtraImagePriceResponse _self;
  final $Res Function(ProExtraImagePriceResponse) _then;

/// Create a copy of ProExtraImagePriceResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = freezed,}) {
  return _then(_self.copyWith(
items: freezed == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ProExtraImagePriceRow>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProExtraImagePriceResponse].
extension ProExtraImagePriceResponsePatterns on ProExtraImagePriceResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProExtraImagePriceResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProExtraImagePriceResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProExtraImagePriceResponse value)  $default,){
final _that = this;
switch (_that) {
case _ProExtraImagePriceResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProExtraImagePriceResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ProExtraImagePriceResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ProExtraImagePriceResponse.itemsKey_)  List<ProExtraImagePriceRow>? items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProExtraImagePriceResponse() when $default != null:
return $default(_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ProExtraImagePriceResponse.itemsKey_)  List<ProExtraImagePriceRow>? items)  $default,) {final _that = this;
switch (_that) {
case _ProExtraImagePriceResponse():
return $default(_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ProExtraImagePriceResponse.itemsKey_)  List<ProExtraImagePriceRow>? items)?  $default,) {final _that = this;
switch (_that) {
case _ProExtraImagePriceResponse() when $default != null:
return $default(_that.items);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ProExtraImagePriceResponse extends ProExtraImagePriceResponse {
  const _ProExtraImagePriceResponse({@JsonKey(name: ProExtraImagePriceResponse.itemsKey_) final  List<ProExtraImagePriceRow>? items}): _items = items,super._();
  factory _ProExtraImagePriceResponse.fromJson(Map<String, dynamic> json) => _$ProExtraImagePriceResponseFromJson(json);

/// items
 final  List<ProExtraImagePriceRow>? _items;
/// items
@override@JsonKey(name: ProExtraImagePriceResponse.itemsKey_) List<ProExtraImagePriceRow>? get items {
  final value = _items;
  if (value == null) return null;
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ProExtraImagePriceResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProExtraImagePriceResponseCopyWith<_ProExtraImagePriceResponse> get copyWith => __$ProExtraImagePriceResponseCopyWithImpl<_ProExtraImagePriceResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProExtraImagePriceResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProExtraImagePriceResponse&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'ProExtraImagePriceResponse(items: $items)';
}


}

/// @nodoc
abstract mixin class _$ProExtraImagePriceResponseCopyWith<$Res> implements $ProExtraImagePriceResponseCopyWith<$Res> {
  factory _$ProExtraImagePriceResponseCopyWith(_ProExtraImagePriceResponse value, $Res Function(_ProExtraImagePriceResponse) _then) = __$ProExtraImagePriceResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ProExtraImagePriceResponse.itemsKey_) List<ProExtraImagePriceRow>? items
});




}
/// @nodoc
class __$ProExtraImagePriceResponseCopyWithImpl<$Res>
    implements _$ProExtraImagePriceResponseCopyWith<$Res> {
  __$ProExtraImagePriceResponseCopyWithImpl(this._self, this._then);

  final _ProExtraImagePriceResponse _self;
  final $Res Function(_ProExtraImagePriceResponse) _then;

/// Create a copy of ProExtraImagePriceResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = freezed,}) {
  return _then(_ProExtraImagePriceResponse(
items: freezed == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ProExtraImagePriceRow>?,
  ));
}


}

// dart format on
