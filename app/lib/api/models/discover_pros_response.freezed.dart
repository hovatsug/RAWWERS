// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'discover_pros_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DiscoverProsResponse {

/// total
@JsonKey(name: DiscoverProsResponse.totalKey_) int get total;/// items
@JsonKey(name: DiscoverProsResponse.itemsKey_) List<ProCard> get items;
/// Create a copy of DiscoverProsResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiscoverProsResponseCopyWith<DiscoverProsResponse> get copyWith => _$DiscoverProsResponseCopyWithImpl<DiscoverProsResponse>(this as DiscoverProsResponse, _$identity);

  /// Serializes this DiscoverProsResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiscoverProsResponse&&(identical(other.total, total) || other.total == total)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'DiscoverProsResponse(total: $total, items: $items)';
}


}

/// @nodoc
abstract mixin class $DiscoverProsResponseCopyWith<$Res>  {
  factory $DiscoverProsResponseCopyWith(DiscoverProsResponse value, $Res Function(DiscoverProsResponse) _then) = _$DiscoverProsResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: DiscoverProsResponse.totalKey_) int total,@JsonKey(name: DiscoverProsResponse.itemsKey_) List<ProCard> items
});




}
/// @nodoc
class _$DiscoverProsResponseCopyWithImpl<$Res>
    implements $DiscoverProsResponseCopyWith<$Res> {
  _$DiscoverProsResponseCopyWithImpl(this._self, this._then);

  final DiscoverProsResponse _self;
  final $Res Function(DiscoverProsResponse) _then;

/// Create a copy of DiscoverProsResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? total = null,Object? items = null,}) {
  return _then(_self.copyWith(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ProCard>,
  ));
}

}


/// Adds pattern-matching-related methods to [DiscoverProsResponse].
extension DiscoverProsResponsePatterns on DiscoverProsResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DiscoverProsResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DiscoverProsResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DiscoverProsResponse value)  $default,){
final _that = this;
switch (_that) {
case _DiscoverProsResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DiscoverProsResponse value)?  $default,){
final _that = this;
switch (_that) {
case _DiscoverProsResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: DiscoverProsResponse.totalKey_)  int total, @JsonKey(name: DiscoverProsResponse.itemsKey_)  List<ProCard> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DiscoverProsResponse() when $default != null:
return $default(_that.total,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: DiscoverProsResponse.totalKey_)  int total, @JsonKey(name: DiscoverProsResponse.itemsKey_)  List<ProCard> items)  $default,) {final _that = this;
switch (_that) {
case _DiscoverProsResponse():
return $default(_that.total,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: DiscoverProsResponse.totalKey_)  int total, @JsonKey(name: DiscoverProsResponse.itemsKey_)  List<ProCard> items)?  $default,) {final _that = this;
switch (_that) {
case _DiscoverProsResponse() when $default != null:
return $default(_that.total,_that.items);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _DiscoverProsResponse extends DiscoverProsResponse {
  const _DiscoverProsResponse({@JsonKey(name: DiscoverProsResponse.totalKey_) required this.total, @JsonKey(name: DiscoverProsResponse.itemsKey_) required final  List<ProCard> items}): _items = items,super._();
  factory _DiscoverProsResponse.fromJson(Map<String, dynamic> json) => _$DiscoverProsResponseFromJson(json);

/// total
@override@JsonKey(name: DiscoverProsResponse.totalKey_) final  int total;
/// items
 final  List<ProCard> _items;
/// items
@override@JsonKey(name: DiscoverProsResponse.itemsKey_) List<ProCard> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of DiscoverProsResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DiscoverProsResponseCopyWith<_DiscoverProsResponse> get copyWith => __$DiscoverProsResponseCopyWithImpl<_DiscoverProsResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DiscoverProsResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DiscoverProsResponse&&(identical(other.total, total) || other.total == total)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'DiscoverProsResponse(total: $total, items: $items)';
}


}

/// @nodoc
abstract mixin class _$DiscoverProsResponseCopyWith<$Res> implements $DiscoverProsResponseCopyWith<$Res> {
  factory _$DiscoverProsResponseCopyWith(_DiscoverProsResponse value, $Res Function(_DiscoverProsResponse) _then) = __$DiscoverProsResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: DiscoverProsResponse.totalKey_) int total,@JsonKey(name: DiscoverProsResponse.itemsKey_) List<ProCard> items
});




}
/// @nodoc
class __$DiscoverProsResponseCopyWithImpl<$Res>
    implements _$DiscoverProsResponseCopyWith<$Res> {
  __$DiscoverProsResponseCopyWithImpl(this._self, this._then);

  final _DiscoverProsResponse _self;
  final $Res Function(_DiscoverProsResponse) _then;

/// Create a copy of DiscoverProsResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? total = null,Object? items = null,}) {
  return _then(_DiscoverProsResponse(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ProCard>,
  ));
}


}

// dart format on
