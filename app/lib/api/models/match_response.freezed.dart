// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MatchResponse {

/// items
@JsonKey(name: MatchResponse.itemsKey_) List<MatchCandidate> get items;
/// Create a copy of MatchResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MatchResponseCopyWith<MatchResponse> get copyWith => _$MatchResponseCopyWithImpl<MatchResponse>(this as MatchResponse, _$identity);

  /// Serializes this MatchResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MatchResponse&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'MatchResponse(items: $items)';
}


}

/// @nodoc
abstract mixin class $MatchResponseCopyWith<$Res>  {
  factory $MatchResponseCopyWith(MatchResponse value, $Res Function(MatchResponse) _then) = _$MatchResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: MatchResponse.itemsKey_) List<MatchCandidate> items
});




}
/// @nodoc
class _$MatchResponseCopyWithImpl<$Res>
    implements $MatchResponseCopyWith<$Res> {
  _$MatchResponseCopyWithImpl(this._self, this._then);

  final MatchResponse _self;
  final $Res Function(MatchResponse) _then;

/// Create a copy of MatchResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<MatchCandidate>,
  ));
}

}


/// Adds pattern-matching-related methods to [MatchResponse].
extension MatchResponsePatterns on MatchResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MatchResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MatchResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MatchResponse value)  $default,){
final _that = this;
switch (_that) {
case _MatchResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MatchResponse value)?  $default,){
final _that = this;
switch (_that) {
case _MatchResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: MatchResponse.itemsKey_)  List<MatchCandidate> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MatchResponse() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: MatchResponse.itemsKey_)  List<MatchCandidate> items)  $default,) {final _that = this;
switch (_that) {
case _MatchResponse():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: MatchResponse.itemsKey_)  List<MatchCandidate> items)?  $default,) {final _that = this;
switch (_that) {
case _MatchResponse() when $default != null:
return $default(_that.items);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _MatchResponse extends MatchResponse {
  const _MatchResponse({@JsonKey(name: MatchResponse.itemsKey_) required final  List<MatchCandidate> items}): _items = items,super._();
  factory _MatchResponse.fromJson(Map<String, dynamic> json) => _$MatchResponseFromJson(json);

/// items
 final  List<MatchCandidate> _items;
/// items
@override@JsonKey(name: MatchResponse.itemsKey_) List<MatchCandidate> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of MatchResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MatchResponseCopyWith<_MatchResponse> get copyWith => __$MatchResponseCopyWithImpl<_MatchResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MatchResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MatchResponse&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'MatchResponse(items: $items)';
}


}

/// @nodoc
abstract mixin class _$MatchResponseCopyWith<$Res> implements $MatchResponseCopyWith<$Res> {
  factory _$MatchResponseCopyWith(_MatchResponse value, $Res Function(_MatchResponse) _then) = __$MatchResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: MatchResponse.itemsKey_) List<MatchCandidate> items
});




}
/// @nodoc
class __$MatchResponseCopyWithImpl<$Res>
    implements _$MatchResponseCopyWith<$Res> {
  __$MatchResponseCopyWithImpl(this._self, this._then);

  final _MatchResponse _self;
  final $Res Function(_MatchResponse) _then;

/// Create a copy of MatchResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,}) {
  return _then(_MatchResponse(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<MatchCandidate>,
  ));
}


}

// dart format on
