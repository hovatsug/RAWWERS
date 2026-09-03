// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SearchResponse {

/// total
@JsonKey(name: SearchResponse.totalKey_) int get total;/// items
@JsonKey(name: SearchResponse.itemsKey_) List<Map<String, dynamic>> get items;/// usedFallback
@JsonKey(name: SearchResponse.usedFallbackKey_) bool get usedFallback;
/// Create a copy of SearchResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchResponseCopyWith<SearchResponse> get copyWith => _$SearchResponseCopyWithImpl<SearchResponse>(this as SearchResponse, _$identity);

  /// Serializes this SearchResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchResponse&&(identical(other.total, total) || other.total == total)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.usedFallback, usedFallback) || other.usedFallback == usedFallback));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total,const DeepCollectionEquality().hash(items),usedFallback);

@override
String toString() {
  return 'SearchResponse(total: $total, items: $items, usedFallback: $usedFallback)';
}


}

/// @nodoc
abstract mixin class $SearchResponseCopyWith<$Res>  {
  factory $SearchResponseCopyWith(SearchResponse value, $Res Function(SearchResponse) _then) = _$SearchResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: SearchResponse.totalKey_) int total,@JsonKey(name: SearchResponse.itemsKey_) List<Map<String, dynamic>> items,@JsonKey(name: SearchResponse.usedFallbackKey_) bool usedFallback
});




}
/// @nodoc
class _$SearchResponseCopyWithImpl<$Res>
    implements $SearchResponseCopyWith<$Res> {
  _$SearchResponseCopyWithImpl(this._self, this._then);

  final SearchResponse _self;
  final $Res Function(SearchResponse) _then;

/// Create a copy of SearchResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? total = null,Object? items = null,Object? usedFallback = null,}) {
  return _then(_self.copyWith(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,usedFallback: null == usedFallback ? _self.usedFallback : usedFallback // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchResponse].
extension SearchResponsePatterns on SearchResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchResponse value)  $default,){
final _that = this;
switch (_that) {
case _SearchResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SearchResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: SearchResponse.totalKey_)  int total, @JsonKey(name: SearchResponse.itemsKey_)  List<Map<String, dynamic>> items, @JsonKey(name: SearchResponse.usedFallbackKey_)  bool usedFallback)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchResponse() when $default != null:
return $default(_that.total,_that.items,_that.usedFallback);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: SearchResponse.totalKey_)  int total, @JsonKey(name: SearchResponse.itemsKey_)  List<Map<String, dynamic>> items, @JsonKey(name: SearchResponse.usedFallbackKey_)  bool usedFallback)  $default,) {final _that = this;
switch (_that) {
case _SearchResponse():
return $default(_that.total,_that.items,_that.usedFallback);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: SearchResponse.totalKey_)  int total, @JsonKey(name: SearchResponse.itemsKey_)  List<Map<String, dynamic>> items, @JsonKey(name: SearchResponse.usedFallbackKey_)  bool usedFallback)?  $default,) {final _that = this;
switch (_that) {
case _SearchResponse() when $default != null:
return $default(_that.total,_that.items,_that.usedFallback);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _SearchResponse extends SearchResponse {
  const _SearchResponse({@JsonKey(name: SearchResponse.totalKey_) required this.total, @JsonKey(name: SearchResponse.itemsKey_) required final  List<Map<String, dynamic>> items, @JsonKey(name: SearchResponse.usedFallbackKey_) this.usedFallback = false}): _items = items,super._();
  factory _SearchResponse.fromJson(Map<String, dynamic> json) => _$SearchResponseFromJson(json);

/// total
@override@JsonKey(name: SearchResponse.totalKey_) final  int total;
/// items
 final  List<Map<String, dynamic>> _items;
/// items
@override@JsonKey(name: SearchResponse.itemsKey_) List<Map<String, dynamic>> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

/// usedFallback
@override@JsonKey(name: SearchResponse.usedFallbackKey_) final  bool usedFallback;

/// Create a copy of SearchResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchResponseCopyWith<_SearchResponse> get copyWith => __$SearchResponseCopyWithImpl<_SearchResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SearchResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchResponse&&(identical(other.total, total) || other.total == total)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.usedFallback, usedFallback) || other.usedFallback == usedFallback));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total,const DeepCollectionEquality().hash(_items),usedFallback);

@override
String toString() {
  return 'SearchResponse(total: $total, items: $items, usedFallback: $usedFallback)';
}


}

/// @nodoc
abstract mixin class _$SearchResponseCopyWith<$Res> implements $SearchResponseCopyWith<$Res> {
  factory _$SearchResponseCopyWith(_SearchResponse value, $Res Function(_SearchResponse) _then) = __$SearchResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: SearchResponse.totalKey_) int total,@JsonKey(name: SearchResponse.itemsKey_) List<Map<String, dynamic>> items,@JsonKey(name: SearchResponse.usedFallbackKey_) bool usedFallback
});




}
/// @nodoc
class __$SearchResponseCopyWithImpl<$Res>
    implements _$SearchResponseCopyWith<$Res> {
  __$SearchResponseCopyWithImpl(this._self, this._then);

  final _SearchResponse _self;
  final $Res Function(_SearchResponse) _then;

/// Create a copy of SearchResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? total = null,Object? items = null,Object? usedFallback = null,}) {
  return _then(_SearchResponse(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,usedFallback: null == usedFallback ? _self.usedFallback : usedFallback // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
