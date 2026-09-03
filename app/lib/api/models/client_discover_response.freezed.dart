// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_discover_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClientDiscoverResponse {

/// total
@JsonKey(name: ClientDiscoverResponse.totalKey_) int get total;/// items
@JsonKey(name: ClientDiscoverResponse.itemsKey_) List<ClientDiscoverCard>? get items;/// guestLimited
@JsonKey(name: ClientDiscoverResponse.guestLimitedKey_) bool get guestLimited;
/// Create a copy of ClientDiscoverResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientDiscoverResponseCopyWith<ClientDiscoverResponse> get copyWith => _$ClientDiscoverResponseCopyWithImpl<ClientDiscoverResponse>(this as ClientDiscoverResponse, _$identity);

  /// Serializes this ClientDiscoverResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientDiscoverResponse&&(identical(other.total, total) || other.total == total)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.guestLimited, guestLimited) || other.guestLimited == guestLimited));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total,const DeepCollectionEquality().hash(items),guestLimited);

@override
String toString() {
  return 'ClientDiscoverResponse(total: $total, items: $items, guestLimited: $guestLimited)';
}


}

/// @nodoc
abstract mixin class $ClientDiscoverResponseCopyWith<$Res>  {
  factory $ClientDiscoverResponseCopyWith(ClientDiscoverResponse value, $Res Function(ClientDiscoverResponse) _then) = _$ClientDiscoverResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ClientDiscoverResponse.totalKey_) int total,@JsonKey(name: ClientDiscoverResponse.itemsKey_) List<ClientDiscoverCard>? items,@JsonKey(name: ClientDiscoverResponse.guestLimitedKey_) bool guestLimited
});




}
/// @nodoc
class _$ClientDiscoverResponseCopyWithImpl<$Res>
    implements $ClientDiscoverResponseCopyWith<$Res> {
  _$ClientDiscoverResponseCopyWithImpl(this._self, this._then);

  final ClientDiscoverResponse _self;
  final $Res Function(ClientDiscoverResponse) _then;

/// Create a copy of ClientDiscoverResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? total = null,Object? items = freezed,Object? guestLimited = null,}) {
  return _then(_self.copyWith(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,items: freezed == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ClientDiscoverCard>?,guestLimited: null == guestLimited ? _self.guestLimited : guestLimited // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ClientDiscoverResponse].
extension ClientDiscoverResponsePatterns on ClientDiscoverResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientDiscoverResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientDiscoverResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientDiscoverResponse value)  $default,){
final _that = this;
switch (_that) {
case _ClientDiscoverResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientDiscoverResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ClientDiscoverResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ClientDiscoverResponse.totalKey_)  int total, @JsonKey(name: ClientDiscoverResponse.itemsKey_)  List<ClientDiscoverCard>? items, @JsonKey(name: ClientDiscoverResponse.guestLimitedKey_)  bool guestLimited)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientDiscoverResponse() when $default != null:
return $default(_that.total,_that.items,_that.guestLimited);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ClientDiscoverResponse.totalKey_)  int total, @JsonKey(name: ClientDiscoverResponse.itemsKey_)  List<ClientDiscoverCard>? items, @JsonKey(name: ClientDiscoverResponse.guestLimitedKey_)  bool guestLimited)  $default,) {final _that = this;
switch (_that) {
case _ClientDiscoverResponse():
return $default(_that.total,_that.items,_that.guestLimited);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ClientDiscoverResponse.totalKey_)  int total, @JsonKey(name: ClientDiscoverResponse.itemsKey_)  List<ClientDiscoverCard>? items, @JsonKey(name: ClientDiscoverResponse.guestLimitedKey_)  bool guestLimited)?  $default,) {final _that = this;
switch (_that) {
case _ClientDiscoverResponse() when $default != null:
return $default(_that.total,_that.items,_that.guestLimited);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ClientDiscoverResponse extends ClientDiscoverResponse {
  const _ClientDiscoverResponse({@JsonKey(name: ClientDiscoverResponse.totalKey_) required this.total, @JsonKey(name: ClientDiscoverResponse.itemsKey_) final  List<ClientDiscoverCard>? items, @JsonKey(name: ClientDiscoverResponse.guestLimitedKey_) this.guestLimited = false}): _items = items,super._();
  factory _ClientDiscoverResponse.fromJson(Map<String, dynamic> json) => _$ClientDiscoverResponseFromJson(json);

/// total
@override@JsonKey(name: ClientDiscoverResponse.totalKey_) final  int total;
/// items
 final  List<ClientDiscoverCard>? _items;
/// items
@override@JsonKey(name: ClientDiscoverResponse.itemsKey_) List<ClientDiscoverCard>? get items {
  final value = _items;
  if (value == null) return null;
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// guestLimited
@override@JsonKey(name: ClientDiscoverResponse.guestLimitedKey_) final  bool guestLimited;

/// Create a copy of ClientDiscoverResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientDiscoverResponseCopyWith<_ClientDiscoverResponse> get copyWith => __$ClientDiscoverResponseCopyWithImpl<_ClientDiscoverResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientDiscoverResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientDiscoverResponse&&(identical(other.total, total) || other.total == total)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.guestLimited, guestLimited) || other.guestLimited == guestLimited));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total,const DeepCollectionEquality().hash(_items),guestLimited);

@override
String toString() {
  return 'ClientDiscoverResponse(total: $total, items: $items, guestLimited: $guestLimited)';
}


}

/// @nodoc
abstract mixin class _$ClientDiscoverResponseCopyWith<$Res> implements $ClientDiscoverResponseCopyWith<$Res> {
  factory _$ClientDiscoverResponseCopyWith(_ClientDiscoverResponse value, $Res Function(_ClientDiscoverResponse) _then) = __$ClientDiscoverResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ClientDiscoverResponse.totalKey_) int total,@JsonKey(name: ClientDiscoverResponse.itemsKey_) List<ClientDiscoverCard>? items,@JsonKey(name: ClientDiscoverResponse.guestLimitedKey_) bool guestLimited
});




}
/// @nodoc
class __$ClientDiscoverResponseCopyWithImpl<$Res>
    implements _$ClientDiscoverResponseCopyWith<$Res> {
  __$ClientDiscoverResponseCopyWithImpl(this._self, this._then);

  final _ClientDiscoverResponse _self;
  final $Res Function(_ClientDiscoverResponse) _then;

/// Create a copy of ClientDiscoverResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? total = null,Object? items = freezed,Object? guestLimited = null,}) {
  return _then(_ClientDiscoverResponse(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,items: freezed == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ClientDiscoverCard>?,guestLimited: null == guestLimited ? _self.guestLimited : guestLimited // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
