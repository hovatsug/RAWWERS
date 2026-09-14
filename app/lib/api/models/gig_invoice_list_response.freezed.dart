// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gig_invoice_list_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GigInvoiceListResponse {

/// items
@JsonKey(name: GigInvoiceListResponse.itemsKey_) List<GigInvoiceView>? get items;
/// Create a copy of GigInvoiceListResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GigInvoiceListResponseCopyWith<GigInvoiceListResponse> get copyWith => _$GigInvoiceListResponseCopyWithImpl<GigInvoiceListResponse>(this as GigInvoiceListResponse, _$identity);

  /// Serializes this GigInvoiceListResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GigInvoiceListResponse&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'GigInvoiceListResponse(items: $items)';
}


}

/// @nodoc
abstract mixin class $GigInvoiceListResponseCopyWith<$Res>  {
  factory $GigInvoiceListResponseCopyWith(GigInvoiceListResponse value, $Res Function(GigInvoiceListResponse) _then) = _$GigInvoiceListResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: GigInvoiceListResponse.itemsKey_) List<GigInvoiceView>? items
});




}
/// @nodoc
class _$GigInvoiceListResponseCopyWithImpl<$Res>
    implements $GigInvoiceListResponseCopyWith<$Res> {
  _$GigInvoiceListResponseCopyWithImpl(this._self, this._then);

  final GigInvoiceListResponse _self;
  final $Res Function(GigInvoiceListResponse) _then;

/// Create a copy of GigInvoiceListResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = freezed,}) {
  return _then(_self.copyWith(
items: freezed == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<GigInvoiceView>?,
  ));
}

}


/// Adds pattern-matching-related methods to [GigInvoiceListResponse].
extension GigInvoiceListResponsePatterns on GigInvoiceListResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GigInvoiceListResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GigInvoiceListResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GigInvoiceListResponse value)  $default,){
final _that = this;
switch (_that) {
case _GigInvoiceListResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GigInvoiceListResponse value)?  $default,){
final _that = this;
switch (_that) {
case _GigInvoiceListResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: GigInvoiceListResponse.itemsKey_)  List<GigInvoiceView>? items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GigInvoiceListResponse() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: GigInvoiceListResponse.itemsKey_)  List<GigInvoiceView>? items)  $default,) {final _that = this;
switch (_that) {
case _GigInvoiceListResponse():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: GigInvoiceListResponse.itemsKey_)  List<GigInvoiceView>? items)?  $default,) {final _that = this;
switch (_that) {
case _GigInvoiceListResponse() when $default != null:
return $default(_that.items);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _GigInvoiceListResponse extends GigInvoiceListResponse {
  const _GigInvoiceListResponse({@JsonKey(name: GigInvoiceListResponse.itemsKey_) final  List<GigInvoiceView>? items}): _items = items,super._();
  factory _GigInvoiceListResponse.fromJson(Map<String, dynamic> json) => _$GigInvoiceListResponseFromJson(json);

/// items
 final  List<GigInvoiceView>? _items;
/// items
@override@JsonKey(name: GigInvoiceListResponse.itemsKey_) List<GigInvoiceView>? get items {
  final value = _items;
  if (value == null) return null;
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of GigInvoiceListResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GigInvoiceListResponseCopyWith<_GigInvoiceListResponse> get copyWith => __$GigInvoiceListResponseCopyWithImpl<_GigInvoiceListResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GigInvoiceListResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GigInvoiceListResponse&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'GigInvoiceListResponse(items: $items)';
}


}

/// @nodoc
abstract mixin class _$GigInvoiceListResponseCopyWith<$Res> implements $GigInvoiceListResponseCopyWith<$Res> {
  factory _$GigInvoiceListResponseCopyWith(_GigInvoiceListResponse value, $Res Function(_GigInvoiceListResponse) _then) = __$GigInvoiceListResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: GigInvoiceListResponse.itemsKey_) List<GigInvoiceView>? items
});




}
/// @nodoc
class __$GigInvoiceListResponseCopyWithImpl<$Res>
    implements _$GigInvoiceListResponseCopyWith<$Res> {
  __$GigInvoiceListResponseCopyWithImpl(this._self, this._then);

  final _GigInvoiceListResponse _self;
  final $Res Function(_GigInvoiceListResponse) _then;

/// Create a copy of GigInvoiceListResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = freezed,}) {
  return _then(_GigInvoiceListResponse(
items: freezed == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<GigInvoiceView>?,
  ));
}


}

// dart format on
