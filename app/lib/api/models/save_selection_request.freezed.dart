// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'save_selection_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SaveSelectionRequest {

/// mediaAssetIds
@JsonKey(name: SaveSelectionRequest.mediaAssetIdsKey_) List<String> get mediaAssetIds;
/// Create a copy of SaveSelectionRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SaveSelectionRequestCopyWith<SaveSelectionRequest> get copyWith => _$SaveSelectionRequestCopyWithImpl<SaveSelectionRequest>(this as SaveSelectionRequest, _$identity);

  /// Serializes this SaveSelectionRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SaveSelectionRequest&&const DeepCollectionEquality().equals(other.mediaAssetIds, mediaAssetIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(mediaAssetIds));

@override
String toString() {
  return 'SaveSelectionRequest(mediaAssetIds: $mediaAssetIds)';
}


}

/// @nodoc
abstract mixin class $SaveSelectionRequestCopyWith<$Res>  {
  factory $SaveSelectionRequestCopyWith(SaveSelectionRequest value, $Res Function(SaveSelectionRequest) _then) = _$SaveSelectionRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: SaveSelectionRequest.mediaAssetIdsKey_) List<String> mediaAssetIds
});




}
/// @nodoc
class _$SaveSelectionRequestCopyWithImpl<$Res>
    implements $SaveSelectionRequestCopyWith<$Res> {
  _$SaveSelectionRequestCopyWithImpl(this._self, this._then);

  final SaveSelectionRequest _self;
  final $Res Function(SaveSelectionRequest) _then;

/// Create a copy of SaveSelectionRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mediaAssetIds = null,}) {
  return _then(_self.copyWith(
mediaAssetIds: null == mediaAssetIds ? _self.mediaAssetIds : mediaAssetIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [SaveSelectionRequest].
extension SaveSelectionRequestPatterns on SaveSelectionRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SaveSelectionRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SaveSelectionRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SaveSelectionRequest value)  $default,){
final _that = this;
switch (_that) {
case _SaveSelectionRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SaveSelectionRequest value)?  $default,){
final _that = this;
switch (_that) {
case _SaveSelectionRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: SaveSelectionRequest.mediaAssetIdsKey_)  List<String> mediaAssetIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SaveSelectionRequest() when $default != null:
return $default(_that.mediaAssetIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: SaveSelectionRequest.mediaAssetIdsKey_)  List<String> mediaAssetIds)  $default,) {final _that = this;
switch (_that) {
case _SaveSelectionRequest():
return $default(_that.mediaAssetIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: SaveSelectionRequest.mediaAssetIdsKey_)  List<String> mediaAssetIds)?  $default,) {final _that = this;
switch (_that) {
case _SaveSelectionRequest() when $default != null:
return $default(_that.mediaAssetIds);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _SaveSelectionRequest extends SaveSelectionRequest {
  const _SaveSelectionRequest({@JsonKey(name: SaveSelectionRequest.mediaAssetIdsKey_) required final  List<String> mediaAssetIds}): _mediaAssetIds = mediaAssetIds,super._();
  factory _SaveSelectionRequest.fromJson(Map<String, dynamic> json) => _$SaveSelectionRequestFromJson(json);

/// mediaAssetIds
 final  List<String> _mediaAssetIds;
/// mediaAssetIds
@override@JsonKey(name: SaveSelectionRequest.mediaAssetIdsKey_) List<String> get mediaAssetIds {
  if (_mediaAssetIds is EqualUnmodifiableListView) return _mediaAssetIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mediaAssetIds);
}


/// Create a copy of SaveSelectionRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SaveSelectionRequestCopyWith<_SaveSelectionRequest> get copyWith => __$SaveSelectionRequestCopyWithImpl<_SaveSelectionRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SaveSelectionRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SaveSelectionRequest&&const DeepCollectionEquality().equals(other._mediaAssetIds, _mediaAssetIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_mediaAssetIds));

@override
String toString() {
  return 'SaveSelectionRequest(mediaAssetIds: $mediaAssetIds)';
}


}

/// @nodoc
abstract mixin class _$SaveSelectionRequestCopyWith<$Res> implements $SaveSelectionRequestCopyWith<$Res> {
  factory _$SaveSelectionRequestCopyWith(_SaveSelectionRequest value, $Res Function(_SaveSelectionRequest) _then) = __$SaveSelectionRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: SaveSelectionRequest.mediaAssetIdsKey_) List<String> mediaAssetIds
});




}
/// @nodoc
class __$SaveSelectionRequestCopyWithImpl<$Res>
    implements _$SaveSelectionRequestCopyWith<$Res> {
  __$SaveSelectionRequestCopyWithImpl(this._self, this._then);

  final _SaveSelectionRequest _self;
  final $Res Function(_SaveSelectionRequest) _then;

/// Create a copy of SaveSelectionRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mediaAssetIds = null,}) {
  return _then(_SaveSelectionRequest(
mediaAssetIds: null == mediaAssetIds ? _self._mediaAssetIds : mediaAssetIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
