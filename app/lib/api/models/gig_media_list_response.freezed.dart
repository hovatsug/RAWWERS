// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gig_media_list_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GigMediaListResponse {

/// gigId
@JsonKey(name: GigMediaListResponse.gigIdKey_) String get gigId;/// assets
@JsonKey(name: GigMediaListResponse.assetsKey_) List<GigMediaAssetView>? get assets;
/// Create a copy of GigMediaListResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GigMediaListResponseCopyWith<GigMediaListResponse> get copyWith => _$GigMediaListResponseCopyWithImpl<GigMediaListResponse>(this as GigMediaListResponse, _$identity);

  /// Serializes this GigMediaListResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GigMediaListResponse&&(identical(other.gigId, gigId) || other.gigId == gigId)&&const DeepCollectionEquality().equals(other.assets, assets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,gigId,const DeepCollectionEquality().hash(assets));

@override
String toString() {
  return 'GigMediaListResponse(gigId: $gigId, assets: $assets)';
}


}

/// @nodoc
abstract mixin class $GigMediaListResponseCopyWith<$Res>  {
  factory $GigMediaListResponseCopyWith(GigMediaListResponse value, $Res Function(GigMediaListResponse) _then) = _$GigMediaListResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: GigMediaListResponse.gigIdKey_) String gigId,@JsonKey(name: GigMediaListResponse.assetsKey_) List<GigMediaAssetView>? assets
});




}
/// @nodoc
class _$GigMediaListResponseCopyWithImpl<$Res>
    implements $GigMediaListResponseCopyWith<$Res> {
  _$GigMediaListResponseCopyWithImpl(this._self, this._then);

  final GigMediaListResponse _self;
  final $Res Function(GigMediaListResponse) _then;

/// Create a copy of GigMediaListResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? gigId = null,Object? assets = freezed,}) {
  return _then(_self.copyWith(
gigId: null == gigId ? _self.gigId : gigId // ignore: cast_nullable_to_non_nullable
as String,assets: freezed == assets ? _self.assets : assets // ignore: cast_nullable_to_non_nullable
as List<GigMediaAssetView>?,
  ));
}

}


/// Adds pattern-matching-related methods to [GigMediaListResponse].
extension GigMediaListResponsePatterns on GigMediaListResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GigMediaListResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GigMediaListResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GigMediaListResponse value)  $default,){
final _that = this;
switch (_that) {
case _GigMediaListResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GigMediaListResponse value)?  $default,){
final _that = this;
switch (_that) {
case _GigMediaListResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: GigMediaListResponse.gigIdKey_)  String gigId, @JsonKey(name: GigMediaListResponse.assetsKey_)  List<GigMediaAssetView>? assets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GigMediaListResponse() when $default != null:
return $default(_that.gigId,_that.assets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: GigMediaListResponse.gigIdKey_)  String gigId, @JsonKey(name: GigMediaListResponse.assetsKey_)  List<GigMediaAssetView>? assets)  $default,) {final _that = this;
switch (_that) {
case _GigMediaListResponse():
return $default(_that.gigId,_that.assets);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: GigMediaListResponse.gigIdKey_)  String gigId, @JsonKey(name: GigMediaListResponse.assetsKey_)  List<GigMediaAssetView>? assets)?  $default,) {final _that = this;
switch (_that) {
case _GigMediaListResponse() when $default != null:
return $default(_that.gigId,_that.assets);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _GigMediaListResponse extends GigMediaListResponse {
  const _GigMediaListResponse({@JsonKey(name: GigMediaListResponse.gigIdKey_) required this.gigId, @JsonKey(name: GigMediaListResponse.assetsKey_) final  List<GigMediaAssetView>? assets}): _assets = assets,super._();
  factory _GigMediaListResponse.fromJson(Map<String, dynamic> json) => _$GigMediaListResponseFromJson(json);

/// gigId
@override@JsonKey(name: GigMediaListResponse.gigIdKey_) final  String gigId;
/// assets
 final  List<GigMediaAssetView>? _assets;
/// assets
@override@JsonKey(name: GigMediaListResponse.assetsKey_) List<GigMediaAssetView>? get assets {
  final value = _assets;
  if (value == null) return null;
  if (_assets is EqualUnmodifiableListView) return _assets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of GigMediaListResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GigMediaListResponseCopyWith<_GigMediaListResponse> get copyWith => __$GigMediaListResponseCopyWithImpl<_GigMediaListResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GigMediaListResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GigMediaListResponse&&(identical(other.gigId, gigId) || other.gigId == gigId)&&const DeepCollectionEquality().equals(other._assets, _assets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,gigId,const DeepCollectionEquality().hash(_assets));

@override
String toString() {
  return 'GigMediaListResponse(gigId: $gigId, assets: $assets)';
}


}

/// @nodoc
abstract mixin class _$GigMediaListResponseCopyWith<$Res> implements $GigMediaListResponseCopyWith<$Res> {
  factory _$GigMediaListResponseCopyWith(_GigMediaListResponse value, $Res Function(_GigMediaListResponse) _then) = __$GigMediaListResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: GigMediaListResponse.gigIdKey_) String gigId,@JsonKey(name: GigMediaListResponse.assetsKey_) List<GigMediaAssetView>? assets
});




}
/// @nodoc
class __$GigMediaListResponseCopyWithImpl<$Res>
    implements _$GigMediaListResponseCopyWith<$Res> {
  __$GigMediaListResponseCopyWithImpl(this._self, this._then);

  final _GigMediaListResponse _self;
  final $Res Function(_GigMediaListResponse) _then;

/// Create a copy of GigMediaListResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? gigId = null,Object? assets = freezed,}) {
  return _then(_GigMediaListResponse(
gigId: null == gigId ? _self.gigId : gigId // ignore: cast_nullable_to_non_nullable
as String,assets: freezed == assets ? _self._assets : assets // ignore: cast_nullable_to_non_nullable
as List<GigMediaAssetView>?,
  ));
}


}

// dart format on
