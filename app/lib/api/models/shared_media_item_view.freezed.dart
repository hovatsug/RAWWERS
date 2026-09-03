// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shared_media_item_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SharedMediaItemView {

/// mediaAssetId
@JsonKey(name: SharedMediaItemView.mediaAssetIdKey_) String get mediaAssetId;/// previewUrl
@JsonKey(name: SharedMediaItemView.previewUrlKey_) String get previewUrl;
/// Create a copy of SharedMediaItemView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SharedMediaItemViewCopyWith<SharedMediaItemView> get copyWith => _$SharedMediaItemViewCopyWithImpl<SharedMediaItemView>(this as SharedMediaItemView, _$identity);

  /// Serializes this SharedMediaItemView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SharedMediaItemView&&(identical(other.mediaAssetId, mediaAssetId) || other.mediaAssetId == mediaAssetId)&&(identical(other.previewUrl, previewUrl) || other.previewUrl == previewUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaAssetId,previewUrl);

@override
String toString() {
  return 'SharedMediaItemView(mediaAssetId: $mediaAssetId, previewUrl: $previewUrl)';
}


}

/// @nodoc
abstract mixin class $SharedMediaItemViewCopyWith<$Res>  {
  factory $SharedMediaItemViewCopyWith(SharedMediaItemView value, $Res Function(SharedMediaItemView) _then) = _$SharedMediaItemViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: SharedMediaItemView.mediaAssetIdKey_) String mediaAssetId,@JsonKey(name: SharedMediaItemView.previewUrlKey_) String previewUrl
});




}
/// @nodoc
class _$SharedMediaItemViewCopyWithImpl<$Res>
    implements $SharedMediaItemViewCopyWith<$Res> {
  _$SharedMediaItemViewCopyWithImpl(this._self, this._then);

  final SharedMediaItemView _self;
  final $Res Function(SharedMediaItemView) _then;

/// Create a copy of SharedMediaItemView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mediaAssetId = null,Object? previewUrl = null,}) {
  return _then(_self.copyWith(
mediaAssetId: null == mediaAssetId ? _self.mediaAssetId : mediaAssetId // ignore: cast_nullable_to_non_nullable
as String,previewUrl: null == previewUrl ? _self.previewUrl : previewUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SharedMediaItemView].
extension SharedMediaItemViewPatterns on SharedMediaItemView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SharedMediaItemView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SharedMediaItemView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SharedMediaItemView value)  $default,){
final _that = this;
switch (_that) {
case _SharedMediaItemView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SharedMediaItemView value)?  $default,){
final _that = this;
switch (_that) {
case _SharedMediaItemView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: SharedMediaItemView.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: SharedMediaItemView.previewUrlKey_)  String previewUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SharedMediaItemView() when $default != null:
return $default(_that.mediaAssetId,_that.previewUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: SharedMediaItemView.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: SharedMediaItemView.previewUrlKey_)  String previewUrl)  $default,) {final _that = this;
switch (_that) {
case _SharedMediaItemView():
return $default(_that.mediaAssetId,_that.previewUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: SharedMediaItemView.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: SharedMediaItemView.previewUrlKey_)  String previewUrl)?  $default,) {final _that = this;
switch (_that) {
case _SharedMediaItemView() when $default != null:
return $default(_that.mediaAssetId,_that.previewUrl);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _SharedMediaItemView extends SharedMediaItemView {
  const _SharedMediaItemView({@JsonKey(name: SharedMediaItemView.mediaAssetIdKey_) required this.mediaAssetId, @JsonKey(name: SharedMediaItemView.previewUrlKey_) required this.previewUrl}): super._();
  factory _SharedMediaItemView.fromJson(Map<String, dynamic> json) => _$SharedMediaItemViewFromJson(json);

/// mediaAssetId
@override@JsonKey(name: SharedMediaItemView.mediaAssetIdKey_) final  String mediaAssetId;
/// previewUrl
@override@JsonKey(name: SharedMediaItemView.previewUrlKey_) final  String previewUrl;

/// Create a copy of SharedMediaItemView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SharedMediaItemViewCopyWith<_SharedMediaItemView> get copyWith => __$SharedMediaItemViewCopyWithImpl<_SharedMediaItemView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SharedMediaItemViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SharedMediaItemView&&(identical(other.mediaAssetId, mediaAssetId) || other.mediaAssetId == mediaAssetId)&&(identical(other.previewUrl, previewUrl) || other.previewUrl == previewUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaAssetId,previewUrl);

@override
String toString() {
  return 'SharedMediaItemView(mediaAssetId: $mediaAssetId, previewUrl: $previewUrl)';
}


}

/// @nodoc
abstract mixin class _$SharedMediaItemViewCopyWith<$Res> implements $SharedMediaItemViewCopyWith<$Res> {
  factory _$SharedMediaItemViewCopyWith(_SharedMediaItemView value, $Res Function(_SharedMediaItemView) _then) = __$SharedMediaItemViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: SharedMediaItemView.mediaAssetIdKey_) String mediaAssetId,@JsonKey(name: SharedMediaItemView.previewUrlKey_) String previewUrl
});




}
/// @nodoc
class __$SharedMediaItemViewCopyWithImpl<$Res>
    implements _$SharedMediaItemViewCopyWith<$Res> {
  __$SharedMediaItemViewCopyWithImpl(this._self, this._then);

  final _SharedMediaItemView _self;
  final $Res Function(_SharedMediaItemView) _then;

/// Create a copy of SharedMediaItemView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mediaAssetId = null,Object? previewUrl = null,}) {
  return _then(_SharedMediaItemView(
mediaAssetId: null == mediaAssetId ? _self.mediaAssetId : mediaAssetId // ignore: cast_nullable_to_non_nullable
as String,previewUrl: null == previewUrl ? _self.previewUrl : previewUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
