// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pro_portfolio_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProPortfolioResponse {

/// items
@JsonKey(name: ProPortfolioResponse.itemsKey_) List<ProPortfolioItem>? get items;/// photoCount
@JsonKey(name: ProPortfolioResponse.photoCountKey_) int get photoCount;/// videoCount
@JsonKey(name: ProPortfolioResponse.videoCountKey_) int get videoCount;/// photoMinimum
@JsonKey(name: ProPortfolioResponse.photoMinimumKey_) int get photoMinimum;
/// Create a copy of ProPortfolioResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProPortfolioResponseCopyWith<ProPortfolioResponse> get copyWith => _$ProPortfolioResponseCopyWithImpl<ProPortfolioResponse>(this as ProPortfolioResponse, _$identity);

  /// Serializes this ProPortfolioResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProPortfolioResponse&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.photoCount, photoCount) || other.photoCount == photoCount)&&(identical(other.videoCount, videoCount) || other.videoCount == videoCount)&&(identical(other.photoMinimum, photoMinimum) || other.photoMinimum == photoMinimum));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),photoCount,videoCount,photoMinimum);

@override
String toString() {
  return 'ProPortfolioResponse(items: $items, photoCount: $photoCount, videoCount: $videoCount, photoMinimum: $photoMinimum)';
}


}

/// @nodoc
abstract mixin class $ProPortfolioResponseCopyWith<$Res>  {
  factory $ProPortfolioResponseCopyWith(ProPortfolioResponse value, $Res Function(ProPortfolioResponse) _then) = _$ProPortfolioResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ProPortfolioResponse.itemsKey_) List<ProPortfolioItem>? items,@JsonKey(name: ProPortfolioResponse.photoCountKey_) int photoCount,@JsonKey(name: ProPortfolioResponse.videoCountKey_) int videoCount,@JsonKey(name: ProPortfolioResponse.photoMinimumKey_) int photoMinimum
});




}
/// @nodoc
class _$ProPortfolioResponseCopyWithImpl<$Res>
    implements $ProPortfolioResponseCopyWith<$Res> {
  _$ProPortfolioResponseCopyWithImpl(this._self, this._then);

  final ProPortfolioResponse _self;
  final $Res Function(ProPortfolioResponse) _then;

/// Create a copy of ProPortfolioResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = freezed,Object? photoCount = null,Object? videoCount = null,Object? photoMinimum = null,}) {
  return _then(_self.copyWith(
items: freezed == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ProPortfolioItem>?,photoCount: null == photoCount ? _self.photoCount : photoCount // ignore: cast_nullable_to_non_nullable
as int,videoCount: null == videoCount ? _self.videoCount : videoCount // ignore: cast_nullable_to_non_nullable
as int,photoMinimum: null == photoMinimum ? _self.photoMinimum : photoMinimum // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ProPortfolioResponse].
extension ProPortfolioResponsePatterns on ProPortfolioResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProPortfolioResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProPortfolioResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProPortfolioResponse value)  $default,){
final _that = this;
switch (_that) {
case _ProPortfolioResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProPortfolioResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ProPortfolioResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ProPortfolioResponse.itemsKey_)  List<ProPortfolioItem>? items, @JsonKey(name: ProPortfolioResponse.photoCountKey_)  int photoCount, @JsonKey(name: ProPortfolioResponse.videoCountKey_)  int videoCount, @JsonKey(name: ProPortfolioResponse.photoMinimumKey_)  int photoMinimum)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProPortfolioResponse() when $default != null:
return $default(_that.items,_that.photoCount,_that.videoCount,_that.photoMinimum);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ProPortfolioResponse.itemsKey_)  List<ProPortfolioItem>? items, @JsonKey(name: ProPortfolioResponse.photoCountKey_)  int photoCount, @JsonKey(name: ProPortfolioResponse.videoCountKey_)  int videoCount, @JsonKey(name: ProPortfolioResponse.photoMinimumKey_)  int photoMinimum)  $default,) {final _that = this;
switch (_that) {
case _ProPortfolioResponse():
return $default(_that.items,_that.photoCount,_that.videoCount,_that.photoMinimum);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ProPortfolioResponse.itemsKey_)  List<ProPortfolioItem>? items, @JsonKey(name: ProPortfolioResponse.photoCountKey_)  int photoCount, @JsonKey(name: ProPortfolioResponse.videoCountKey_)  int videoCount, @JsonKey(name: ProPortfolioResponse.photoMinimumKey_)  int photoMinimum)?  $default,) {final _that = this;
switch (_that) {
case _ProPortfolioResponse() when $default != null:
return $default(_that.items,_that.photoCount,_that.videoCount,_that.photoMinimum);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ProPortfolioResponse extends ProPortfolioResponse {
  const _ProPortfolioResponse({@JsonKey(name: ProPortfolioResponse.itemsKey_) final  List<ProPortfolioItem>? items, @JsonKey(name: ProPortfolioResponse.photoCountKey_) required this.photoCount, @JsonKey(name: ProPortfolioResponse.videoCountKey_) required this.videoCount, @JsonKey(name: ProPortfolioResponse.photoMinimumKey_) required this.photoMinimum}): _items = items,super._();
  factory _ProPortfolioResponse.fromJson(Map<String, dynamic> json) => _$ProPortfolioResponseFromJson(json);

/// items
 final  List<ProPortfolioItem>? _items;
/// items
@override@JsonKey(name: ProPortfolioResponse.itemsKey_) List<ProPortfolioItem>? get items {
  final value = _items;
  if (value == null) return null;
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// photoCount
@override@JsonKey(name: ProPortfolioResponse.photoCountKey_) final  int photoCount;
/// videoCount
@override@JsonKey(name: ProPortfolioResponse.videoCountKey_) final  int videoCount;
/// photoMinimum
@override@JsonKey(name: ProPortfolioResponse.photoMinimumKey_) final  int photoMinimum;

/// Create a copy of ProPortfolioResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProPortfolioResponseCopyWith<_ProPortfolioResponse> get copyWith => __$ProPortfolioResponseCopyWithImpl<_ProPortfolioResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProPortfolioResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProPortfolioResponse&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.photoCount, photoCount) || other.photoCount == photoCount)&&(identical(other.videoCount, videoCount) || other.videoCount == videoCount)&&(identical(other.photoMinimum, photoMinimum) || other.photoMinimum == photoMinimum));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),photoCount,videoCount,photoMinimum);

@override
String toString() {
  return 'ProPortfolioResponse(items: $items, photoCount: $photoCount, videoCount: $videoCount, photoMinimum: $photoMinimum)';
}


}

/// @nodoc
abstract mixin class _$ProPortfolioResponseCopyWith<$Res> implements $ProPortfolioResponseCopyWith<$Res> {
  factory _$ProPortfolioResponseCopyWith(_ProPortfolioResponse value, $Res Function(_ProPortfolioResponse) _then) = __$ProPortfolioResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ProPortfolioResponse.itemsKey_) List<ProPortfolioItem>? items,@JsonKey(name: ProPortfolioResponse.photoCountKey_) int photoCount,@JsonKey(name: ProPortfolioResponse.videoCountKey_) int videoCount,@JsonKey(name: ProPortfolioResponse.photoMinimumKey_) int photoMinimum
});




}
/// @nodoc
class __$ProPortfolioResponseCopyWithImpl<$Res>
    implements _$ProPortfolioResponseCopyWith<$Res> {
  __$ProPortfolioResponseCopyWithImpl(this._self, this._then);

  final _ProPortfolioResponse _self;
  final $Res Function(_ProPortfolioResponse) _then;

/// Create a copy of ProPortfolioResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = freezed,Object? photoCount = null,Object? videoCount = null,Object? photoMinimum = null,}) {
  return _then(_ProPortfolioResponse(
items: freezed == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ProPortfolioItem>?,photoCount: null == photoCount ? _self.photoCount : photoCount // ignore: cast_nullable_to_non_nullable
as int,videoCount: null == videoCount ? _self.videoCount : videoCount // ignore: cast_nullable_to_non_nullable
as int,photoMinimum: null == photoMinimum ? _self.photoMinimum : photoMinimum // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
