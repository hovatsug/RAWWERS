// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'add_gallery_items_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AddGalleryItemsRequest {

/// mediaAssetIds
@JsonKey(name: AddGalleryItemsRequest.mediaAssetIdsKey_) List<String> get mediaAssetIds;/// sortOrderOptional
@JsonKey(name: AddGalleryItemsRequest.sortOrderOptionalKey_) int? get sortOrderOptional;
/// Create a copy of AddGalleryItemsRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddGalleryItemsRequestCopyWith<AddGalleryItemsRequest> get copyWith => _$AddGalleryItemsRequestCopyWithImpl<AddGalleryItemsRequest>(this as AddGalleryItemsRequest, _$identity);

  /// Serializes this AddGalleryItemsRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddGalleryItemsRequest&&const DeepCollectionEquality().equals(other.mediaAssetIds, mediaAssetIds)&&(identical(other.sortOrderOptional, sortOrderOptional) || other.sortOrderOptional == sortOrderOptional));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(mediaAssetIds),sortOrderOptional);

@override
String toString() {
  return 'AddGalleryItemsRequest(mediaAssetIds: $mediaAssetIds, sortOrderOptional: $sortOrderOptional)';
}


}

/// @nodoc
abstract mixin class $AddGalleryItemsRequestCopyWith<$Res>  {
  factory $AddGalleryItemsRequestCopyWith(AddGalleryItemsRequest value, $Res Function(AddGalleryItemsRequest) _then) = _$AddGalleryItemsRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: AddGalleryItemsRequest.mediaAssetIdsKey_) List<String> mediaAssetIds,@JsonKey(name: AddGalleryItemsRequest.sortOrderOptionalKey_) int? sortOrderOptional
});




}
/// @nodoc
class _$AddGalleryItemsRequestCopyWithImpl<$Res>
    implements $AddGalleryItemsRequestCopyWith<$Res> {
  _$AddGalleryItemsRequestCopyWithImpl(this._self, this._then);

  final AddGalleryItemsRequest _self;
  final $Res Function(AddGalleryItemsRequest) _then;

/// Create a copy of AddGalleryItemsRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mediaAssetIds = null,Object? sortOrderOptional = freezed,}) {
  return _then(_self.copyWith(
mediaAssetIds: null == mediaAssetIds ? _self.mediaAssetIds : mediaAssetIds // ignore: cast_nullable_to_non_nullable
as List<String>,sortOrderOptional: freezed == sortOrderOptional ? _self.sortOrderOptional : sortOrderOptional // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [AddGalleryItemsRequest].
extension AddGalleryItemsRequestPatterns on AddGalleryItemsRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AddGalleryItemsRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AddGalleryItemsRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AddGalleryItemsRequest value)  $default,){
final _that = this;
switch (_that) {
case _AddGalleryItemsRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AddGalleryItemsRequest value)?  $default,){
final _that = this;
switch (_that) {
case _AddGalleryItemsRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: AddGalleryItemsRequest.mediaAssetIdsKey_)  List<String> mediaAssetIds, @JsonKey(name: AddGalleryItemsRequest.sortOrderOptionalKey_)  int? sortOrderOptional)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AddGalleryItemsRequest() when $default != null:
return $default(_that.mediaAssetIds,_that.sortOrderOptional);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: AddGalleryItemsRequest.mediaAssetIdsKey_)  List<String> mediaAssetIds, @JsonKey(name: AddGalleryItemsRequest.sortOrderOptionalKey_)  int? sortOrderOptional)  $default,) {final _that = this;
switch (_that) {
case _AddGalleryItemsRequest():
return $default(_that.mediaAssetIds,_that.sortOrderOptional);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: AddGalleryItemsRequest.mediaAssetIdsKey_)  List<String> mediaAssetIds, @JsonKey(name: AddGalleryItemsRequest.sortOrderOptionalKey_)  int? sortOrderOptional)?  $default,) {final _that = this;
switch (_that) {
case _AddGalleryItemsRequest() when $default != null:
return $default(_that.mediaAssetIds,_that.sortOrderOptional);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _AddGalleryItemsRequest extends AddGalleryItemsRequest {
  const _AddGalleryItemsRequest({@JsonKey(name: AddGalleryItemsRequest.mediaAssetIdsKey_) required final  List<String> mediaAssetIds, @JsonKey(name: AddGalleryItemsRequest.sortOrderOptionalKey_) this.sortOrderOptional}): _mediaAssetIds = mediaAssetIds,super._();
  factory _AddGalleryItemsRequest.fromJson(Map<String, dynamic> json) => _$AddGalleryItemsRequestFromJson(json);

/// mediaAssetIds
 final  List<String> _mediaAssetIds;
/// mediaAssetIds
@override@JsonKey(name: AddGalleryItemsRequest.mediaAssetIdsKey_) List<String> get mediaAssetIds {
  if (_mediaAssetIds is EqualUnmodifiableListView) return _mediaAssetIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mediaAssetIds);
}

/// sortOrderOptional
@override@JsonKey(name: AddGalleryItemsRequest.sortOrderOptionalKey_) final  int? sortOrderOptional;

/// Create a copy of AddGalleryItemsRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddGalleryItemsRequestCopyWith<_AddGalleryItemsRequest> get copyWith => __$AddGalleryItemsRequestCopyWithImpl<_AddGalleryItemsRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AddGalleryItemsRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddGalleryItemsRequest&&const DeepCollectionEquality().equals(other._mediaAssetIds, _mediaAssetIds)&&(identical(other.sortOrderOptional, sortOrderOptional) || other.sortOrderOptional == sortOrderOptional));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_mediaAssetIds),sortOrderOptional);

@override
String toString() {
  return 'AddGalleryItemsRequest(mediaAssetIds: $mediaAssetIds, sortOrderOptional: $sortOrderOptional)';
}


}

/// @nodoc
abstract mixin class _$AddGalleryItemsRequestCopyWith<$Res> implements $AddGalleryItemsRequestCopyWith<$Res> {
  factory _$AddGalleryItemsRequestCopyWith(_AddGalleryItemsRequest value, $Res Function(_AddGalleryItemsRequest) _then) = __$AddGalleryItemsRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: AddGalleryItemsRequest.mediaAssetIdsKey_) List<String> mediaAssetIds,@JsonKey(name: AddGalleryItemsRequest.sortOrderOptionalKey_) int? sortOrderOptional
});




}
/// @nodoc
class __$AddGalleryItemsRequestCopyWithImpl<$Res>
    implements _$AddGalleryItemsRequestCopyWith<$Res> {
  __$AddGalleryItemsRequestCopyWithImpl(this._self, this._then);

  final _AddGalleryItemsRequest _self;
  final $Res Function(_AddGalleryItemsRequest) _then;

/// Create a copy of AddGalleryItemsRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mediaAssetIds = null,Object? sortOrderOptional = freezed,}) {
  return _then(_AddGalleryItemsRequest(
mediaAssetIds: null == mediaAssetIds ? _self._mediaAssetIds : mediaAssetIds // ignore: cast_nullable_to_non_nullable
as List<String>,sortOrderOptional: freezed == sortOrderOptional ? _self.sortOrderOptional : sortOrderOptional // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
