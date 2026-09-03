// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'portfolio_niche_tags_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PortfolioNicheTagsResponse {

/// mediaAssetId
@JsonKey(name: PortfolioNicheTagsResponse.mediaAssetIdKey_) String get mediaAssetId;/// nicheSlugs
@JsonKey(name: PortfolioNicheTagsResponse.nicheSlugsKey_) List<String>? get nicheSlugs;
/// Create a copy of PortfolioNicheTagsResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PortfolioNicheTagsResponseCopyWith<PortfolioNicheTagsResponse> get copyWith => _$PortfolioNicheTagsResponseCopyWithImpl<PortfolioNicheTagsResponse>(this as PortfolioNicheTagsResponse, _$identity);

  /// Serializes this PortfolioNicheTagsResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PortfolioNicheTagsResponse&&(identical(other.mediaAssetId, mediaAssetId) || other.mediaAssetId == mediaAssetId)&&const DeepCollectionEquality().equals(other.nicheSlugs, nicheSlugs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaAssetId,const DeepCollectionEquality().hash(nicheSlugs));

@override
String toString() {
  return 'PortfolioNicheTagsResponse(mediaAssetId: $mediaAssetId, nicheSlugs: $nicheSlugs)';
}


}

/// @nodoc
abstract mixin class $PortfolioNicheTagsResponseCopyWith<$Res>  {
  factory $PortfolioNicheTagsResponseCopyWith(PortfolioNicheTagsResponse value, $Res Function(PortfolioNicheTagsResponse) _then) = _$PortfolioNicheTagsResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: PortfolioNicheTagsResponse.mediaAssetIdKey_) String mediaAssetId,@JsonKey(name: PortfolioNicheTagsResponse.nicheSlugsKey_) List<String>? nicheSlugs
});




}
/// @nodoc
class _$PortfolioNicheTagsResponseCopyWithImpl<$Res>
    implements $PortfolioNicheTagsResponseCopyWith<$Res> {
  _$PortfolioNicheTagsResponseCopyWithImpl(this._self, this._then);

  final PortfolioNicheTagsResponse _self;
  final $Res Function(PortfolioNicheTagsResponse) _then;

/// Create a copy of PortfolioNicheTagsResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mediaAssetId = null,Object? nicheSlugs = freezed,}) {
  return _then(_self.copyWith(
mediaAssetId: null == mediaAssetId ? _self.mediaAssetId : mediaAssetId // ignore: cast_nullable_to_non_nullable
as String,nicheSlugs: freezed == nicheSlugs ? _self.nicheSlugs : nicheSlugs // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [PortfolioNicheTagsResponse].
extension PortfolioNicheTagsResponsePatterns on PortfolioNicheTagsResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PortfolioNicheTagsResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PortfolioNicheTagsResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PortfolioNicheTagsResponse value)  $default,){
final _that = this;
switch (_that) {
case _PortfolioNicheTagsResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PortfolioNicheTagsResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PortfolioNicheTagsResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: PortfolioNicheTagsResponse.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: PortfolioNicheTagsResponse.nicheSlugsKey_)  List<String>? nicheSlugs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PortfolioNicheTagsResponse() when $default != null:
return $default(_that.mediaAssetId,_that.nicheSlugs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: PortfolioNicheTagsResponse.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: PortfolioNicheTagsResponse.nicheSlugsKey_)  List<String>? nicheSlugs)  $default,) {final _that = this;
switch (_that) {
case _PortfolioNicheTagsResponse():
return $default(_that.mediaAssetId,_that.nicheSlugs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: PortfolioNicheTagsResponse.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: PortfolioNicheTagsResponse.nicheSlugsKey_)  List<String>? nicheSlugs)?  $default,) {final _that = this;
switch (_that) {
case _PortfolioNicheTagsResponse() when $default != null:
return $default(_that.mediaAssetId,_that.nicheSlugs);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _PortfolioNicheTagsResponse extends PortfolioNicheTagsResponse {
  const _PortfolioNicheTagsResponse({@JsonKey(name: PortfolioNicheTagsResponse.mediaAssetIdKey_) required this.mediaAssetId, @JsonKey(name: PortfolioNicheTagsResponse.nicheSlugsKey_) final  List<String>? nicheSlugs}): _nicheSlugs = nicheSlugs,super._();
  factory _PortfolioNicheTagsResponse.fromJson(Map<String, dynamic> json) => _$PortfolioNicheTagsResponseFromJson(json);

/// mediaAssetId
@override@JsonKey(name: PortfolioNicheTagsResponse.mediaAssetIdKey_) final  String mediaAssetId;
/// nicheSlugs
 final  List<String>? _nicheSlugs;
/// nicheSlugs
@override@JsonKey(name: PortfolioNicheTagsResponse.nicheSlugsKey_) List<String>? get nicheSlugs {
  final value = _nicheSlugs;
  if (value == null) return null;
  if (_nicheSlugs is EqualUnmodifiableListView) return _nicheSlugs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of PortfolioNicheTagsResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PortfolioNicheTagsResponseCopyWith<_PortfolioNicheTagsResponse> get copyWith => __$PortfolioNicheTagsResponseCopyWithImpl<_PortfolioNicheTagsResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PortfolioNicheTagsResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PortfolioNicheTagsResponse&&(identical(other.mediaAssetId, mediaAssetId) || other.mediaAssetId == mediaAssetId)&&const DeepCollectionEquality().equals(other._nicheSlugs, _nicheSlugs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaAssetId,const DeepCollectionEquality().hash(_nicheSlugs));

@override
String toString() {
  return 'PortfolioNicheTagsResponse(mediaAssetId: $mediaAssetId, nicheSlugs: $nicheSlugs)';
}


}

/// @nodoc
abstract mixin class _$PortfolioNicheTagsResponseCopyWith<$Res> implements $PortfolioNicheTagsResponseCopyWith<$Res> {
  factory _$PortfolioNicheTagsResponseCopyWith(_PortfolioNicheTagsResponse value, $Res Function(_PortfolioNicheTagsResponse) _then) = __$PortfolioNicheTagsResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: PortfolioNicheTagsResponse.mediaAssetIdKey_) String mediaAssetId,@JsonKey(name: PortfolioNicheTagsResponse.nicheSlugsKey_) List<String>? nicheSlugs
});




}
/// @nodoc
class __$PortfolioNicheTagsResponseCopyWithImpl<$Res>
    implements _$PortfolioNicheTagsResponseCopyWith<$Res> {
  __$PortfolioNicheTagsResponseCopyWithImpl(this._self, this._then);

  final _PortfolioNicheTagsResponse _self;
  final $Res Function(_PortfolioNicheTagsResponse) _then;

/// Create a copy of PortfolioNicheTagsResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mediaAssetId = null,Object? nicheSlugs = freezed,}) {
  return _then(_PortfolioNicheTagsResponse(
mediaAssetId: null == mediaAssetId ? _self.mediaAssetId : mediaAssetId // ignore: cast_nullable_to_non_nullable
as String,nicheSlugs: freezed == nicheSlugs ? _self._nicheSlugs : nicheSlugs // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
