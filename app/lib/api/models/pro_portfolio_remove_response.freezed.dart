// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pro_portfolio_remove_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProPortfolioRemoveResponse {

/// mediaAssetId
@JsonKey(name: ProPortfolioRemoveResponse.mediaAssetIdKey_) String get mediaAssetId;/// removed
@JsonKey(name: ProPortfolioRemoveResponse.removedKey_) bool get removed;/// coverCleared
@JsonKey(name: ProPortfolioRemoveResponse.coverClearedKey_) bool get coverCleared;
/// Create a copy of ProPortfolioRemoveResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProPortfolioRemoveResponseCopyWith<ProPortfolioRemoveResponse> get copyWith => _$ProPortfolioRemoveResponseCopyWithImpl<ProPortfolioRemoveResponse>(this as ProPortfolioRemoveResponse, _$identity);

  /// Serializes this ProPortfolioRemoveResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProPortfolioRemoveResponse&&(identical(other.mediaAssetId, mediaAssetId) || other.mediaAssetId == mediaAssetId)&&(identical(other.removed, removed) || other.removed == removed)&&(identical(other.coverCleared, coverCleared) || other.coverCleared == coverCleared));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaAssetId,removed,coverCleared);

@override
String toString() {
  return 'ProPortfolioRemoveResponse(mediaAssetId: $mediaAssetId, removed: $removed, coverCleared: $coverCleared)';
}


}

/// @nodoc
abstract mixin class $ProPortfolioRemoveResponseCopyWith<$Res>  {
  factory $ProPortfolioRemoveResponseCopyWith(ProPortfolioRemoveResponse value, $Res Function(ProPortfolioRemoveResponse) _then) = _$ProPortfolioRemoveResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ProPortfolioRemoveResponse.mediaAssetIdKey_) String mediaAssetId,@JsonKey(name: ProPortfolioRemoveResponse.removedKey_) bool removed,@JsonKey(name: ProPortfolioRemoveResponse.coverClearedKey_) bool coverCleared
});




}
/// @nodoc
class _$ProPortfolioRemoveResponseCopyWithImpl<$Res>
    implements $ProPortfolioRemoveResponseCopyWith<$Res> {
  _$ProPortfolioRemoveResponseCopyWithImpl(this._self, this._then);

  final ProPortfolioRemoveResponse _self;
  final $Res Function(ProPortfolioRemoveResponse) _then;

/// Create a copy of ProPortfolioRemoveResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mediaAssetId = null,Object? removed = null,Object? coverCleared = null,}) {
  return _then(_self.copyWith(
mediaAssetId: null == mediaAssetId ? _self.mediaAssetId : mediaAssetId // ignore: cast_nullable_to_non_nullable
as String,removed: null == removed ? _self.removed : removed // ignore: cast_nullable_to_non_nullable
as bool,coverCleared: null == coverCleared ? _self.coverCleared : coverCleared // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ProPortfolioRemoveResponse].
extension ProPortfolioRemoveResponsePatterns on ProPortfolioRemoveResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProPortfolioRemoveResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProPortfolioRemoveResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProPortfolioRemoveResponse value)  $default,){
final _that = this;
switch (_that) {
case _ProPortfolioRemoveResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProPortfolioRemoveResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ProPortfolioRemoveResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ProPortfolioRemoveResponse.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: ProPortfolioRemoveResponse.removedKey_)  bool removed, @JsonKey(name: ProPortfolioRemoveResponse.coverClearedKey_)  bool coverCleared)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProPortfolioRemoveResponse() when $default != null:
return $default(_that.mediaAssetId,_that.removed,_that.coverCleared);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ProPortfolioRemoveResponse.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: ProPortfolioRemoveResponse.removedKey_)  bool removed, @JsonKey(name: ProPortfolioRemoveResponse.coverClearedKey_)  bool coverCleared)  $default,) {final _that = this;
switch (_that) {
case _ProPortfolioRemoveResponse():
return $default(_that.mediaAssetId,_that.removed,_that.coverCleared);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ProPortfolioRemoveResponse.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: ProPortfolioRemoveResponse.removedKey_)  bool removed, @JsonKey(name: ProPortfolioRemoveResponse.coverClearedKey_)  bool coverCleared)?  $default,) {final _that = this;
switch (_that) {
case _ProPortfolioRemoveResponse() when $default != null:
return $default(_that.mediaAssetId,_that.removed,_that.coverCleared);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ProPortfolioRemoveResponse extends ProPortfolioRemoveResponse {
  const _ProPortfolioRemoveResponse({@JsonKey(name: ProPortfolioRemoveResponse.mediaAssetIdKey_) required this.mediaAssetId, @JsonKey(name: ProPortfolioRemoveResponse.removedKey_) required this.removed, @JsonKey(name: ProPortfolioRemoveResponse.coverClearedKey_) this.coverCleared = false}): super._();
  factory _ProPortfolioRemoveResponse.fromJson(Map<String, dynamic> json) => _$ProPortfolioRemoveResponseFromJson(json);

/// mediaAssetId
@override@JsonKey(name: ProPortfolioRemoveResponse.mediaAssetIdKey_) final  String mediaAssetId;
/// removed
@override@JsonKey(name: ProPortfolioRemoveResponse.removedKey_) final  bool removed;
/// coverCleared
@override@JsonKey(name: ProPortfolioRemoveResponse.coverClearedKey_) final  bool coverCleared;

/// Create a copy of ProPortfolioRemoveResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProPortfolioRemoveResponseCopyWith<_ProPortfolioRemoveResponse> get copyWith => __$ProPortfolioRemoveResponseCopyWithImpl<_ProPortfolioRemoveResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProPortfolioRemoveResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProPortfolioRemoveResponse&&(identical(other.mediaAssetId, mediaAssetId) || other.mediaAssetId == mediaAssetId)&&(identical(other.removed, removed) || other.removed == removed)&&(identical(other.coverCleared, coverCleared) || other.coverCleared == coverCleared));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaAssetId,removed,coverCleared);

@override
String toString() {
  return 'ProPortfolioRemoveResponse(mediaAssetId: $mediaAssetId, removed: $removed, coverCleared: $coverCleared)';
}


}

/// @nodoc
abstract mixin class _$ProPortfolioRemoveResponseCopyWith<$Res> implements $ProPortfolioRemoveResponseCopyWith<$Res> {
  factory _$ProPortfolioRemoveResponseCopyWith(_ProPortfolioRemoveResponse value, $Res Function(_ProPortfolioRemoveResponse) _then) = __$ProPortfolioRemoveResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ProPortfolioRemoveResponse.mediaAssetIdKey_) String mediaAssetId,@JsonKey(name: ProPortfolioRemoveResponse.removedKey_) bool removed,@JsonKey(name: ProPortfolioRemoveResponse.coverClearedKey_) bool coverCleared
});




}
/// @nodoc
class __$ProPortfolioRemoveResponseCopyWithImpl<$Res>
    implements _$ProPortfolioRemoveResponseCopyWith<$Res> {
  __$ProPortfolioRemoveResponseCopyWithImpl(this._self, this._then);

  final _ProPortfolioRemoveResponse _self;
  final $Res Function(_ProPortfolioRemoveResponse) _then;

/// Create a copy of ProPortfolioRemoveResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mediaAssetId = null,Object? removed = null,Object? coverCleared = null,}) {
  return _then(_ProPortfolioRemoveResponse(
mediaAssetId: null == mediaAssetId ? _self.mediaAssetId : mediaAssetId // ignore: cast_nullable_to_non_nullable
as String,removed: null == removed ? _self.removed : removed // ignore: cast_nullable_to_non_nullable
as bool,coverCleared: null == coverCleared ? _self.coverCleared : coverCleared // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
