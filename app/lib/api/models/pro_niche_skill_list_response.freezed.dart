// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pro_niche_skill_list_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProNicheSkillListResponse {

/// proUserId
@JsonKey(name: ProNicheSkillListResponse.proUserIdKey_) String get proUserId;/// items
@JsonKey(name: ProNicheSkillListResponse.itemsKey_) List<ProNicheSkillView>? get items;
/// Create a copy of ProNicheSkillListResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProNicheSkillListResponseCopyWith<ProNicheSkillListResponse> get copyWith => _$ProNicheSkillListResponseCopyWithImpl<ProNicheSkillListResponse>(this as ProNicheSkillListResponse, _$identity);

  /// Serializes this ProNicheSkillListResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProNicheSkillListResponse&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,proUserId,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'ProNicheSkillListResponse(proUserId: $proUserId, items: $items)';
}


}

/// @nodoc
abstract mixin class $ProNicheSkillListResponseCopyWith<$Res>  {
  factory $ProNicheSkillListResponseCopyWith(ProNicheSkillListResponse value, $Res Function(ProNicheSkillListResponse) _then) = _$ProNicheSkillListResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ProNicheSkillListResponse.proUserIdKey_) String proUserId,@JsonKey(name: ProNicheSkillListResponse.itemsKey_) List<ProNicheSkillView>? items
});




}
/// @nodoc
class _$ProNicheSkillListResponseCopyWithImpl<$Res>
    implements $ProNicheSkillListResponseCopyWith<$Res> {
  _$ProNicheSkillListResponseCopyWithImpl(this._self, this._then);

  final ProNicheSkillListResponse _self;
  final $Res Function(ProNicheSkillListResponse) _then;

/// Create a copy of ProNicheSkillListResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? proUserId = null,Object? items = freezed,}) {
  return _then(_self.copyWith(
proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,items: freezed == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ProNicheSkillView>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProNicheSkillListResponse].
extension ProNicheSkillListResponsePatterns on ProNicheSkillListResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProNicheSkillListResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProNicheSkillListResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProNicheSkillListResponse value)  $default,){
final _that = this;
switch (_that) {
case _ProNicheSkillListResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProNicheSkillListResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ProNicheSkillListResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ProNicheSkillListResponse.proUserIdKey_)  String proUserId, @JsonKey(name: ProNicheSkillListResponse.itemsKey_)  List<ProNicheSkillView>? items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProNicheSkillListResponse() when $default != null:
return $default(_that.proUserId,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ProNicheSkillListResponse.proUserIdKey_)  String proUserId, @JsonKey(name: ProNicheSkillListResponse.itemsKey_)  List<ProNicheSkillView>? items)  $default,) {final _that = this;
switch (_that) {
case _ProNicheSkillListResponse():
return $default(_that.proUserId,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ProNicheSkillListResponse.proUserIdKey_)  String proUserId, @JsonKey(name: ProNicheSkillListResponse.itemsKey_)  List<ProNicheSkillView>? items)?  $default,) {final _that = this;
switch (_that) {
case _ProNicheSkillListResponse() when $default != null:
return $default(_that.proUserId,_that.items);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ProNicheSkillListResponse extends ProNicheSkillListResponse {
  const _ProNicheSkillListResponse({@JsonKey(name: ProNicheSkillListResponse.proUserIdKey_) required this.proUserId, @JsonKey(name: ProNicheSkillListResponse.itemsKey_) final  List<ProNicheSkillView>? items}): _items = items,super._();
  factory _ProNicheSkillListResponse.fromJson(Map<String, dynamic> json) => _$ProNicheSkillListResponseFromJson(json);

/// proUserId
@override@JsonKey(name: ProNicheSkillListResponse.proUserIdKey_) final  String proUserId;
/// items
 final  List<ProNicheSkillView>? _items;
/// items
@override@JsonKey(name: ProNicheSkillListResponse.itemsKey_) List<ProNicheSkillView>? get items {
  final value = _items;
  if (value == null) return null;
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ProNicheSkillListResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProNicheSkillListResponseCopyWith<_ProNicheSkillListResponse> get copyWith => __$ProNicheSkillListResponseCopyWithImpl<_ProNicheSkillListResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProNicheSkillListResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProNicheSkillListResponse&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,proUserId,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'ProNicheSkillListResponse(proUserId: $proUserId, items: $items)';
}


}

/// @nodoc
abstract mixin class _$ProNicheSkillListResponseCopyWith<$Res> implements $ProNicheSkillListResponseCopyWith<$Res> {
  factory _$ProNicheSkillListResponseCopyWith(_ProNicheSkillListResponse value, $Res Function(_ProNicheSkillListResponse) _then) = __$ProNicheSkillListResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ProNicheSkillListResponse.proUserIdKey_) String proUserId,@JsonKey(name: ProNicheSkillListResponse.itemsKey_) List<ProNicheSkillView>? items
});




}
/// @nodoc
class __$ProNicheSkillListResponseCopyWithImpl<$Res>
    implements _$ProNicheSkillListResponseCopyWith<$Res> {
  __$ProNicheSkillListResponseCopyWithImpl(this._self, this._then);

  final _ProNicheSkillListResponse _self;
  final $Res Function(_ProNicheSkillListResponse) _then;

/// Create a copy of ProNicheSkillListResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? proUserId = null,Object? items = freezed,}) {
  return _then(_ProNicheSkillListResponse(
proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,items: freezed == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ProNicheSkillView>?,
  ));
}


}

// dart format on
