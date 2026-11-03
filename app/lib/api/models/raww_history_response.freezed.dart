// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'raww_history_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RawwHistoryResponse {

/// total
@JsonKey(name: RawwHistoryResponse.totalKey_) int get total;/// items
@JsonKey(name: RawwHistoryResponse.itemsKey_) List<RawwEntryView> get items;
/// Create a copy of RawwHistoryResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RawwHistoryResponseCopyWith<RawwHistoryResponse> get copyWith => _$RawwHistoryResponseCopyWithImpl<RawwHistoryResponse>(this as RawwHistoryResponse, _$identity);

  /// Serializes this RawwHistoryResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RawwHistoryResponse&&(identical(other.total, total) || other.total == total)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'RawwHistoryResponse(total: $total, items: $items)';
}


}

/// @nodoc
abstract mixin class $RawwHistoryResponseCopyWith<$Res>  {
  factory $RawwHistoryResponseCopyWith(RawwHistoryResponse value, $Res Function(RawwHistoryResponse) _then) = _$RawwHistoryResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: RawwHistoryResponse.totalKey_) int total,@JsonKey(name: RawwHistoryResponse.itemsKey_) List<RawwEntryView> items
});




}
/// @nodoc
class _$RawwHistoryResponseCopyWithImpl<$Res>
    implements $RawwHistoryResponseCopyWith<$Res> {
  _$RawwHistoryResponseCopyWithImpl(this._self, this._then);

  final RawwHistoryResponse _self;
  final $Res Function(RawwHistoryResponse) _then;

/// Create a copy of RawwHistoryResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? total = null,Object? items = null,}) {
  return _then(_self.copyWith(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<RawwEntryView>,
  ));
}

}


/// Adds pattern-matching-related methods to [RawwHistoryResponse].
extension RawwHistoryResponsePatterns on RawwHistoryResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RawwHistoryResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RawwHistoryResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RawwHistoryResponse value)  $default,){
final _that = this;
switch (_that) {
case _RawwHistoryResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RawwHistoryResponse value)?  $default,){
final _that = this;
switch (_that) {
case _RawwHistoryResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: RawwHistoryResponse.totalKey_)  int total, @JsonKey(name: RawwHistoryResponse.itemsKey_)  List<RawwEntryView> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RawwHistoryResponse() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: RawwHistoryResponse.totalKey_)  int total, @JsonKey(name: RawwHistoryResponse.itemsKey_)  List<RawwEntryView> items)  $default,) {final _that = this;
switch (_that) {
case _RawwHistoryResponse():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: RawwHistoryResponse.totalKey_)  int total, @JsonKey(name: RawwHistoryResponse.itemsKey_)  List<RawwEntryView> items)?  $default,) {final _that = this;
switch (_that) {
case _RawwHistoryResponse() when $default != null:
return $default(_that.total,_that.items);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _RawwHistoryResponse extends RawwHistoryResponse {
  const _RawwHistoryResponse({@JsonKey(name: RawwHistoryResponse.totalKey_) required this.total, @JsonKey(name: RawwHistoryResponse.itemsKey_) required final  List<RawwEntryView> items}): _items = items,super._();
  factory _RawwHistoryResponse.fromJson(Map<String, dynamic> json) => _$RawwHistoryResponseFromJson(json);

/// total
@override@JsonKey(name: RawwHistoryResponse.totalKey_) final  int total;
/// items
 final  List<RawwEntryView> _items;
/// items
@override@JsonKey(name: RawwHistoryResponse.itemsKey_) List<RawwEntryView> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of RawwHistoryResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RawwHistoryResponseCopyWith<_RawwHistoryResponse> get copyWith => __$RawwHistoryResponseCopyWithImpl<_RawwHistoryResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RawwHistoryResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RawwHistoryResponse&&(identical(other.total, total) || other.total == total)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'RawwHistoryResponse(total: $total, items: $items)';
}


}

/// @nodoc
abstract mixin class _$RawwHistoryResponseCopyWith<$Res> implements $RawwHistoryResponseCopyWith<$Res> {
  factory _$RawwHistoryResponseCopyWith(_RawwHistoryResponse value, $Res Function(_RawwHistoryResponse) _then) = __$RawwHistoryResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: RawwHistoryResponse.totalKey_) int total,@JsonKey(name: RawwHistoryResponse.itemsKey_) List<RawwEntryView> items
});




}
/// @nodoc
class __$RawwHistoryResponseCopyWithImpl<$Res>
    implements _$RawwHistoryResponseCopyWith<$Res> {
  __$RawwHistoryResponseCopyWithImpl(this._self, this._then);

  final _RawwHistoryResponse _self;
  final $Res Function(_RawwHistoryResponse) _then;

/// Create a copy of RawwHistoryResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? total = null,Object? items = null,}) {
  return _then(_RawwHistoryResponse(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<RawwEntryView>,
  ));
}


}

// dart format on
