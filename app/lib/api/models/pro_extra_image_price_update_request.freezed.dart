// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pro_extra_image_price_update_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProExtraImagePriceUpdateRequest {

/// items
@JsonKey(name: ProExtraImagePriceUpdateRequest.itemsKey_) List<ProExtraImagePriceItem>? get items;
/// Create a copy of ProExtraImagePriceUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProExtraImagePriceUpdateRequestCopyWith<ProExtraImagePriceUpdateRequest> get copyWith => _$ProExtraImagePriceUpdateRequestCopyWithImpl<ProExtraImagePriceUpdateRequest>(this as ProExtraImagePriceUpdateRequest, _$identity);

  /// Serializes this ProExtraImagePriceUpdateRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProExtraImagePriceUpdateRequest&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'ProExtraImagePriceUpdateRequest(items: $items)';
}


}

/// @nodoc
abstract mixin class $ProExtraImagePriceUpdateRequestCopyWith<$Res>  {
  factory $ProExtraImagePriceUpdateRequestCopyWith(ProExtraImagePriceUpdateRequest value, $Res Function(ProExtraImagePriceUpdateRequest) _then) = _$ProExtraImagePriceUpdateRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ProExtraImagePriceUpdateRequest.itemsKey_) List<ProExtraImagePriceItem>? items
});




}
/// @nodoc
class _$ProExtraImagePriceUpdateRequestCopyWithImpl<$Res>
    implements $ProExtraImagePriceUpdateRequestCopyWith<$Res> {
  _$ProExtraImagePriceUpdateRequestCopyWithImpl(this._self, this._then);

  final ProExtraImagePriceUpdateRequest _self;
  final $Res Function(ProExtraImagePriceUpdateRequest) _then;

/// Create a copy of ProExtraImagePriceUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = freezed,}) {
  return _then(_self.copyWith(
items: freezed == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ProExtraImagePriceItem>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProExtraImagePriceUpdateRequest].
extension ProExtraImagePriceUpdateRequestPatterns on ProExtraImagePriceUpdateRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProExtraImagePriceUpdateRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProExtraImagePriceUpdateRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProExtraImagePriceUpdateRequest value)  $default,){
final _that = this;
switch (_that) {
case _ProExtraImagePriceUpdateRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProExtraImagePriceUpdateRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ProExtraImagePriceUpdateRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ProExtraImagePriceUpdateRequest.itemsKey_)  List<ProExtraImagePriceItem>? items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProExtraImagePriceUpdateRequest() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ProExtraImagePriceUpdateRequest.itemsKey_)  List<ProExtraImagePriceItem>? items)  $default,) {final _that = this;
switch (_that) {
case _ProExtraImagePriceUpdateRequest():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ProExtraImagePriceUpdateRequest.itemsKey_)  List<ProExtraImagePriceItem>? items)?  $default,) {final _that = this;
switch (_that) {
case _ProExtraImagePriceUpdateRequest() when $default != null:
return $default(_that.items);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ProExtraImagePriceUpdateRequest extends ProExtraImagePriceUpdateRequest {
  const _ProExtraImagePriceUpdateRequest({@JsonKey(name: ProExtraImagePriceUpdateRequest.itemsKey_) final  List<ProExtraImagePriceItem>? items}): _items = items,super._();
  factory _ProExtraImagePriceUpdateRequest.fromJson(Map<String, dynamic> json) => _$ProExtraImagePriceUpdateRequestFromJson(json);

/// items
 final  List<ProExtraImagePriceItem>? _items;
/// items
@override@JsonKey(name: ProExtraImagePriceUpdateRequest.itemsKey_) List<ProExtraImagePriceItem>? get items {
  final value = _items;
  if (value == null) return null;
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ProExtraImagePriceUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProExtraImagePriceUpdateRequestCopyWith<_ProExtraImagePriceUpdateRequest> get copyWith => __$ProExtraImagePriceUpdateRequestCopyWithImpl<_ProExtraImagePriceUpdateRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProExtraImagePriceUpdateRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProExtraImagePriceUpdateRequest&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'ProExtraImagePriceUpdateRequest(items: $items)';
}


}

/// @nodoc
abstract mixin class _$ProExtraImagePriceUpdateRequestCopyWith<$Res> implements $ProExtraImagePriceUpdateRequestCopyWith<$Res> {
  factory _$ProExtraImagePriceUpdateRequestCopyWith(_ProExtraImagePriceUpdateRequest value, $Res Function(_ProExtraImagePriceUpdateRequest) _then) = __$ProExtraImagePriceUpdateRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ProExtraImagePriceUpdateRequest.itemsKey_) List<ProExtraImagePriceItem>? items
});




}
/// @nodoc
class __$ProExtraImagePriceUpdateRequestCopyWithImpl<$Res>
    implements _$ProExtraImagePriceUpdateRequestCopyWith<$Res> {
  __$ProExtraImagePriceUpdateRequestCopyWithImpl(this._self, this._then);

  final _ProExtraImagePriceUpdateRequest _self;
  final $Res Function(_ProExtraImagePriceUpdateRequest) _then;

/// Create a copy of ProExtraImagePriceUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = freezed,}) {
  return _then(_ProExtraImagePriceUpdateRequest(
items: freezed == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ProExtraImagePriceItem>?,
  ));
}


}

// dart format on
