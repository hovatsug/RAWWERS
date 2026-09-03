// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_match_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClientMatchResponse {

/// matchRequestId
@JsonKey(name: ClientMatchResponse.matchRequestIdKey_) String get matchRequestId;/// items
@JsonKey(name: ClientMatchResponse.itemsKey_) List<ClientMatchCard>? get items;
/// Create a copy of ClientMatchResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientMatchResponseCopyWith<ClientMatchResponse> get copyWith => _$ClientMatchResponseCopyWithImpl<ClientMatchResponse>(this as ClientMatchResponse, _$identity);

  /// Serializes this ClientMatchResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientMatchResponse&&(identical(other.matchRequestId, matchRequestId) || other.matchRequestId == matchRequestId)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,matchRequestId,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'ClientMatchResponse(matchRequestId: $matchRequestId, items: $items)';
}


}

/// @nodoc
abstract mixin class $ClientMatchResponseCopyWith<$Res>  {
  factory $ClientMatchResponseCopyWith(ClientMatchResponse value, $Res Function(ClientMatchResponse) _then) = _$ClientMatchResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ClientMatchResponse.matchRequestIdKey_) String matchRequestId,@JsonKey(name: ClientMatchResponse.itemsKey_) List<ClientMatchCard>? items
});




}
/// @nodoc
class _$ClientMatchResponseCopyWithImpl<$Res>
    implements $ClientMatchResponseCopyWith<$Res> {
  _$ClientMatchResponseCopyWithImpl(this._self, this._then);

  final ClientMatchResponse _self;
  final $Res Function(ClientMatchResponse) _then;

/// Create a copy of ClientMatchResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? matchRequestId = null,Object? items = freezed,}) {
  return _then(_self.copyWith(
matchRequestId: null == matchRequestId ? _self.matchRequestId : matchRequestId // ignore: cast_nullable_to_non_nullable
as String,items: freezed == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ClientMatchCard>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ClientMatchResponse].
extension ClientMatchResponsePatterns on ClientMatchResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientMatchResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientMatchResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientMatchResponse value)  $default,){
final _that = this;
switch (_that) {
case _ClientMatchResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientMatchResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ClientMatchResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ClientMatchResponse.matchRequestIdKey_)  String matchRequestId, @JsonKey(name: ClientMatchResponse.itemsKey_)  List<ClientMatchCard>? items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientMatchResponse() when $default != null:
return $default(_that.matchRequestId,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ClientMatchResponse.matchRequestIdKey_)  String matchRequestId, @JsonKey(name: ClientMatchResponse.itemsKey_)  List<ClientMatchCard>? items)  $default,) {final _that = this;
switch (_that) {
case _ClientMatchResponse():
return $default(_that.matchRequestId,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ClientMatchResponse.matchRequestIdKey_)  String matchRequestId, @JsonKey(name: ClientMatchResponse.itemsKey_)  List<ClientMatchCard>? items)?  $default,) {final _that = this;
switch (_that) {
case _ClientMatchResponse() when $default != null:
return $default(_that.matchRequestId,_that.items);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ClientMatchResponse extends ClientMatchResponse {
  const _ClientMatchResponse({@JsonKey(name: ClientMatchResponse.matchRequestIdKey_) required this.matchRequestId, @JsonKey(name: ClientMatchResponse.itemsKey_) final  List<ClientMatchCard>? items}): _items = items,super._();
  factory _ClientMatchResponse.fromJson(Map<String, dynamic> json) => _$ClientMatchResponseFromJson(json);

/// matchRequestId
@override@JsonKey(name: ClientMatchResponse.matchRequestIdKey_) final  String matchRequestId;
/// items
 final  List<ClientMatchCard>? _items;
/// items
@override@JsonKey(name: ClientMatchResponse.itemsKey_) List<ClientMatchCard>? get items {
  final value = _items;
  if (value == null) return null;
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ClientMatchResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientMatchResponseCopyWith<_ClientMatchResponse> get copyWith => __$ClientMatchResponseCopyWithImpl<_ClientMatchResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientMatchResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientMatchResponse&&(identical(other.matchRequestId, matchRequestId) || other.matchRequestId == matchRequestId)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,matchRequestId,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'ClientMatchResponse(matchRequestId: $matchRequestId, items: $items)';
}


}

/// @nodoc
abstract mixin class _$ClientMatchResponseCopyWith<$Res> implements $ClientMatchResponseCopyWith<$Res> {
  factory _$ClientMatchResponseCopyWith(_ClientMatchResponse value, $Res Function(_ClientMatchResponse) _then) = __$ClientMatchResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ClientMatchResponse.matchRequestIdKey_) String matchRequestId,@JsonKey(name: ClientMatchResponse.itemsKey_) List<ClientMatchCard>? items
});




}
/// @nodoc
class __$ClientMatchResponseCopyWithImpl<$Res>
    implements _$ClientMatchResponseCopyWith<$Res> {
  __$ClientMatchResponseCopyWithImpl(this._self, this._then);

  final _ClientMatchResponse _self;
  final $Res Function(_ClientMatchResponse) _then;

/// Create a copy of ClientMatchResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? matchRequestId = null,Object? items = freezed,}) {
  return _then(_ClientMatchResponse(
matchRequestId: null == matchRequestId ? _self.matchRequestId : matchRequestId // ignore: cast_nullable_to_non_nullable
as String,items: freezed == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ClientMatchCard>?,
  ));
}


}

// dart format on
