// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'my_marketing_consents_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MyMarketingConsentsResponse {

/// items
@JsonKey(name: MyMarketingConsentsResponse.itemsKey_) List<MarketingConsentView> get items;
/// Create a copy of MyMarketingConsentsResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MyMarketingConsentsResponseCopyWith<MyMarketingConsentsResponse> get copyWith => _$MyMarketingConsentsResponseCopyWithImpl<MyMarketingConsentsResponse>(this as MyMarketingConsentsResponse, _$identity);

  /// Serializes this MyMarketingConsentsResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MyMarketingConsentsResponse&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'MyMarketingConsentsResponse(items: $items)';
}


}

/// @nodoc
abstract mixin class $MyMarketingConsentsResponseCopyWith<$Res>  {
  factory $MyMarketingConsentsResponseCopyWith(MyMarketingConsentsResponse value, $Res Function(MyMarketingConsentsResponse) _then) = _$MyMarketingConsentsResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: MyMarketingConsentsResponse.itemsKey_) List<MarketingConsentView> items
});




}
/// @nodoc
class _$MyMarketingConsentsResponseCopyWithImpl<$Res>
    implements $MyMarketingConsentsResponseCopyWith<$Res> {
  _$MyMarketingConsentsResponseCopyWithImpl(this._self, this._then);

  final MyMarketingConsentsResponse _self;
  final $Res Function(MyMarketingConsentsResponse) _then;

/// Create a copy of MyMarketingConsentsResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<MarketingConsentView>,
  ));
}

}


/// Adds pattern-matching-related methods to [MyMarketingConsentsResponse].
extension MyMarketingConsentsResponsePatterns on MyMarketingConsentsResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MyMarketingConsentsResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MyMarketingConsentsResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MyMarketingConsentsResponse value)  $default,){
final _that = this;
switch (_that) {
case _MyMarketingConsentsResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MyMarketingConsentsResponse value)?  $default,){
final _that = this;
switch (_that) {
case _MyMarketingConsentsResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: MyMarketingConsentsResponse.itemsKey_)  List<MarketingConsentView> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MyMarketingConsentsResponse() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: MyMarketingConsentsResponse.itemsKey_)  List<MarketingConsentView> items)  $default,) {final _that = this;
switch (_that) {
case _MyMarketingConsentsResponse():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: MyMarketingConsentsResponse.itemsKey_)  List<MarketingConsentView> items)?  $default,) {final _that = this;
switch (_that) {
case _MyMarketingConsentsResponse() when $default != null:
return $default(_that.items);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _MyMarketingConsentsResponse extends MyMarketingConsentsResponse {
  const _MyMarketingConsentsResponse({@JsonKey(name: MyMarketingConsentsResponse.itemsKey_) required final  List<MarketingConsentView> items}): _items = items,super._();
  factory _MyMarketingConsentsResponse.fromJson(Map<String, dynamic> json) => _$MyMarketingConsentsResponseFromJson(json);

/// items
 final  List<MarketingConsentView> _items;
/// items
@override@JsonKey(name: MyMarketingConsentsResponse.itemsKey_) List<MarketingConsentView> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of MyMarketingConsentsResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MyMarketingConsentsResponseCopyWith<_MyMarketingConsentsResponse> get copyWith => __$MyMarketingConsentsResponseCopyWithImpl<_MyMarketingConsentsResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MyMarketingConsentsResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MyMarketingConsentsResponse&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'MyMarketingConsentsResponse(items: $items)';
}


}

/// @nodoc
abstract mixin class _$MyMarketingConsentsResponseCopyWith<$Res> implements $MyMarketingConsentsResponseCopyWith<$Res> {
  factory _$MyMarketingConsentsResponseCopyWith(_MyMarketingConsentsResponse value, $Res Function(_MyMarketingConsentsResponse) _then) = __$MyMarketingConsentsResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: MyMarketingConsentsResponse.itemsKey_) List<MarketingConsentView> items
});




}
/// @nodoc
class __$MyMarketingConsentsResponseCopyWithImpl<$Res>
    implements _$MyMarketingConsentsResponseCopyWith<$Res> {
  __$MyMarketingConsentsResponseCopyWithImpl(this._self, this._then);

  final _MyMarketingConsentsResponse _self;
  final $Res Function(_MyMarketingConsentsResponse) _then;

/// Create a copy of MyMarketingConsentsResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,}) {
  return _then(_MyMarketingConsentsResponse(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<MarketingConsentView>,
  ));
}


}

// dart format on
