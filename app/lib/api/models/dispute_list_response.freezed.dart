// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dispute_list_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DisputeListResponse {

/// items
@JsonKey(name: DisputeListResponse.itemsKey_) List<DisputeDetailView>? get items;
/// Create a copy of DisputeListResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DisputeListResponseCopyWith<DisputeListResponse> get copyWith => _$DisputeListResponseCopyWithImpl<DisputeListResponse>(this as DisputeListResponse, _$identity);

  /// Serializes this DisputeListResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DisputeListResponse&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'DisputeListResponse(items: $items)';
}


}

/// @nodoc
abstract mixin class $DisputeListResponseCopyWith<$Res>  {
  factory $DisputeListResponseCopyWith(DisputeListResponse value, $Res Function(DisputeListResponse) _then) = _$DisputeListResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: DisputeListResponse.itemsKey_) List<DisputeDetailView>? items
});




}
/// @nodoc
class _$DisputeListResponseCopyWithImpl<$Res>
    implements $DisputeListResponseCopyWith<$Res> {
  _$DisputeListResponseCopyWithImpl(this._self, this._then);

  final DisputeListResponse _self;
  final $Res Function(DisputeListResponse) _then;

/// Create a copy of DisputeListResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = freezed,}) {
  return _then(_self.copyWith(
items: freezed == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<DisputeDetailView>?,
  ));
}

}


/// Adds pattern-matching-related methods to [DisputeListResponse].
extension DisputeListResponsePatterns on DisputeListResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DisputeListResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DisputeListResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DisputeListResponse value)  $default,){
final _that = this;
switch (_that) {
case _DisputeListResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DisputeListResponse value)?  $default,){
final _that = this;
switch (_that) {
case _DisputeListResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: DisputeListResponse.itemsKey_)  List<DisputeDetailView>? items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DisputeListResponse() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: DisputeListResponse.itemsKey_)  List<DisputeDetailView>? items)  $default,) {final _that = this;
switch (_that) {
case _DisputeListResponse():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: DisputeListResponse.itemsKey_)  List<DisputeDetailView>? items)?  $default,) {final _that = this;
switch (_that) {
case _DisputeListResponse() when $default != null:
return $default(_that.items);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _DisputeListResponse extends DisputeListResponse {
  const _DisputeListResponse({@JsonKey(name: DisputeListResponse.itemsKey_) final  List<DisputeDetailView>? items}): _items = items,super._();
  factory _DisputeListResponse.fromJson(Map<String, dynamic> json) => _$DisputeListResponseFromJson(json);

/// items
 final  List<DisputeDetailView>? _items;
/// items
@override@JsonKey(name: DisputeListResponse.itemsKey_) List<DisputeDetailView>? get items {
  final value = _items;
  if (value == null) return null;
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of DisputeListResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DisputeListResponseCopyWith<_DisputeListResponse> get copyWith => __$DisputeListResponseCopyWithImpl<_DisputeListResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DisputeListResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DisputeListResponse&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'DisputeListResponse(items: $items)';
}


}

/// @nodoc
abstract mixin class _$DisputeListResponseCopyWith<$Res> implements $DisputeListResponseCopyWith<$Res> {
  factory _$DisputeListResponseCopyWith(_DisputeListResponse value, $Res Function(_DisputeListResponse) _then) = __$DisputeListResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: DisputeListResponse.itemsKey_) List<DisputeDetailView>? items
});




}
/// @nodoc
class __$DisputeListResponseCopyWithImpl<$Res>
    implements _$DisputeListResponseCopyWith<$Res> {
  __$DisputeListResponseCopyWithImpl(this._self, this._then);

  final _DisputeListResponse _self;
  final $Res Function(_DisputeListResponse) _then;

/// Create a copy of DisputeListResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = freezed,}) {
  return _then(_DisputeListResponse(
items: freezed == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<DisputeDetailView>?,
  ));
}


}

// dart format on
