// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shelf_wishlist_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ShelfWishlistResponse {

/// itemIds
@JsonKey(name: ShelfWishlistResponse.itemIdsKey_) List<String> get itemIds;/// limit
@JsonKey(name: ShelfWishlistResponse.limitKey_) int get limit;
/// Create a copy of ShelfWishlistResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShelfWishlistResponseCopyWith<ShelfWishlistResponse> get copyWith => _$ShelfWishlistResponseCopyWithImpl<ShelfWishlistResponse>(this as ShelfWishlistResponse, _$identity);

  /// Serializes this ShelfWishlistResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShelfWishlistResponse&&const DeepCollectionEquality().equals(other.itemIds, itemIds)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(itemIds),limit);

@override
String toString() {
  return 'ShelfWishlistResponse(itemIds: $itemIds, limit: $limit)';
}


}

/// @nodoc
abstract mixin class $ShelfWishlistResponseCopyWith<$Res>  {
  factory $ShelfWishlistResponseCopyWith(ShelfWishlistResponse value, $Res Function(ShelfWishlistResponse) _then) = _$ShelfWishlistResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ShelfWishlistResponse.itemIdsKey_) List<String> itemIds,@JsonKey(name: ShelfWishlistResponse.limitKey_) int limit
});




}
/// @nodoc
class _$ShelfWishlistResponseCopyWithImpl<$Res>
    implements $ShelfWishlistResponseCopyWith<$Res> {
  _$ShelfWishlistResponseCopyWithImpl(this._self, this._then);

  final ShelfWishlistResponse _self;
  final $Res Function(ShelfWishlistResponse) _then;

/// Create a copy of ShelfWishlistResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? itemIds = null,Object? limit = null,}) {
  return _then(_self.copyWith(
itemIds: null == itemIds ? _self.itemIds : itemIds // ignore: cast_nullable_to_non_nullable
as List<String>,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ShelfWishlistResponse].
extension ShelfWishlistResponsePatterns on ShelfWishlistResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShelfWishlistResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShelfWishlistResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShelfWishlistResponse value)  $default,){
final _that = this;
switch (_that) {
case _ShelfWishlistResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShelfWishlistResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ShelfWishlistResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ShelfWishlistResponse.itemIdsKey_)  List<String> itemIds, @JsonKey(name: ShelfWishlistResponse.limitKey_)  int limit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShelfWishlistResponse() when $default != null:
return $default(_that.itemIds,_that.limit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ShelfWishlistResponse.itemIdsKey_)  List<String> itemIds, @JsonKey(name: ShelfWishlistResponse.limitKey_)  int limit)  $default,) {final _that = this;
switch (_that) {
case _ShelfWishlistResponse():
return $default(_that.itemIds,_that.limit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ShelfWishlistResponse.itemIdsKey_)  List<String> itemIds, @JsonKey(name: ShelfWishlistResponse.limitKey_)  int limit)?  $default,) {final _that = this;
switch (_that) {
case _ShelfWishlistResponse() when $default != null:
return $default(_that.itemIds,_that.limit);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ShelfWishlistResponse extends ShelfWishlistResponse {
  const _ShelfWishlistResponse({@JsonKey(name: ShelfWishlistResponse.itemIdsKey_) required final  List<String> itemIds, @JsonKey(name: ShelfWishlistResponse.limitKey_) required this.limit}): _itemIds = itemIds,super._();
  factory _ShelfWishlistResponse.fromJson(Map<String, dynamic> json) => _$ShelfWishlistResponseFromJson(json);

/// itemIds
 final  List<String> _itemIds;
/// itemIds
@override@JsonKey(name: ShelfWishlistResponse.itemIdsKey_) List<String> get itemIds {
  if (_itemIds is EqualUnmodifiableListView) return _itemIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_itemIds);
}

/// limit
@override@JsonKey(name: ShelfWishlistResponse.limitKey_) final  int limit;

/// Create a copy of ShelfWishlistResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShelfWishlistResponseCopyWith<_ShelfWishlistResponse> get copyWith => __$ShelfWishlistResponseCopyWithImpl<_ShelfWishlistResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShelfWishlistResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShelfWishlistResponse&&const DeepCollectionEquality().equals(other._itemIds, _itemIds)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_itemIds),limit);

@override
String toString() {
  return 'ShelfWishlistResponse(itemIds: $itemIds, limit: $limit)';
}


}

/// @nodoc
abstract mixin class _$ShelfWishlistResponseCopyWith<$Res> implements $ShelfWishlistResponseCopyWith<$Res> {
  factory _$ShelfWishlistResponseCopyWith(_ShelfWishlistResponse value, $Res Function(_ShelfWishlistResponse) _then) = __$ShelfWishlistResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ShelfWishlistResponse.itemIdsKey_) List<String> itemIds,@JsonKey(name: ShelfWishlistResponse.limitKey_) int limit
});




}
/// @nodoc
class __$ShelfWishlistResponseCopyWithImpl<$Res>
    implements _$ShelfWishlistResponseCopyWith<$Res> {
  __$ShelfWishlistResponseCopyWithImpl(this._self, this._then);

  final _ShelfWishlistResponse _self;
  final $Res Function(_ShelfWishlistResponse) _then;

/// Create a copy of ShelfWishlistResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? itemIds = null,Object? limit = null,}) {
  return _then(_ShelfWishlistResponse(
itemIds: null == itemIds ? _self._itemIds : itemIds // ignore: cast_nullable_to_non_nullable
as List<String>,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
