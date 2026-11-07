// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'start_addon_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StartAddonRequest {

/// mediaAssetIds
@JsonKey(name: StartAddonRequest.mediaAssetIdsKey_) List<String> get mediaAssetIds;/// clientRequestId
@JsonKey(name: StartAddonRequest.clientRequestIdKey_) String get clientRequestId;
/// Create a copy of StartAddonRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StartAddonRequestCopyWith<StartAddonRequest> get copyWith => _$StartAddonRequestCopyWithImpl<StartAddonRequest>(this as StartAddonRequest, _$identity);

  /// Serializes this StartAddonRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StartAddonRequest&&const DeepCollectionEquality().equals(other.mediaAssetIds, mediaAssetIds)&&(identical(other.clientRequestId, clientRequestId) || other.clientRequestId == clientRequestId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(mediaAssetIds),clientRequestId);

@override
String toString() {
  return 'StartAddonRequest(mediaAssetIds: $mediaAssetIds, clientRequestId: $clientRequestId)';
}


}

/// @nodoc
abstract mixin class $StartAddonRequestCopyWith<$Res>  {
  factory $StartAddonRequestCopyWith(StartAddonRequest value, $Res Function(StartAddonRequest) _then) = _$StartAddonRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: StartAddonRequest.mediaAssetIdsKey_) List<String> mediaAssetIds,@JsonKey(name: StartAddonRequest.clientRequestIdKey_) String clientRequestId
});




}
/// @nodoc
class _$StartAddonRequestCopyWithImpl<$Res>
    implements $StartAddonRequestCopyWith<$Res> {
  _$StartAddonRequestCopyWithImpl(this._self, this._then);

  final StartAddonRequest _self;
  final $Res Function(StartAddonRequest) _then;

/// Create a copy of StartAddonRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mediaAssetIds = null,Object? clientRequestId = null,}) {
  return _then(_self.copyWith(
mediaAssetIds: null == mediaAssetIds ? _self.mediaAssetIds : mediaAssetIds // ignore: cast_nullable_to_non_nullable
as List<String>,clientRequestId: null == clientRequestId ? _self.clientRequestId : clientRequestId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [StartAddonRequest].
extension StartAddonRequestPatterns on StartAddonRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StartAddonRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StartAddonRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StartAddonRequest value)  $default,){
final _that = this;
switch (_that) {
case _StartAddonRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StartAddonRequest value)?  $default,){
final _that = this;
switch (_that) {
case _StartAddonRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: StartAddonRequest.mediaAssetIdsKey_)  List<String> mediaAssetIds, @JsonKey(name: StartAddonRequest.clientRequestIdKey_)  String clientRequestId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StartAddonRequest() when $default != null:
return $default(_that.mediaAssetIds,_that.clientRequestId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: StartAddonRequest.mediaAssetIdsKey_)  List<String> mediaAssetIds, @JsonKey(name: StartAddonRequest.clientRequestIdKey_)  String clientRequestId)  $default,) {final _that = this;
switch (_that) {
case _StartAddonRequest():
return $default(_that.mediaAssetIds,_that.clientRequestId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: StartAddonRequest.mediaAssetIdsKey_)  List<String> mediaAssetIds, @JsonKey(name: StartAddonRequest.clientRequestIdKey_)  String clientRequestId)?  $default,) {final _that = this;
switch (_that) {
case _StartAddonRequest() when $default != null:
return $default(_that.mediaAssetIds,_that.clientRequestId);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _StartAddonRequest extends StartAddonRequest {
  const _StartAddonRequest({@JsonKey(name: StartAddonRequest.mediaAssetIdsKey_) required final  List<String> mediaAssetIds, @JsonKey(name: StartAddonRequest.clientRequestIdKey_) required this.clientRequestId}): _mediaAssetIds = mediaAssetIds,super._();
  factory _StartAddonRequest.fromJson(Map<String, dynamic> json) => _$StartAddonRequestFromJson(json);

/// mediaAssetIds
 final  List<String> _mediaAssetIds;
/// mediaAssetIds
@override@JsonKey(name: StartAddonRequest.mediaAssetIdsKey_) List<String> get mediaAssetIds {
  if (_mediaAssetIds is EqualUnmodifiableListView) return _mediaAssetIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mediaAssetIds);
}

/// clientRequestId
@override@JsonKey(name: StartAddonRequest.clientRequestIdKey_) final  String clientRequestId;

/// Create a copy of StartAddonRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StartAddonRequestCopyWith<_StartAddonRequest> get copyWith => __$StartAddonRequestCopyWithImpl<_StartAddonRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StartAddonRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StartAddonRequest&&const DeepCollectionEquality().equals(other._mediaAssetIds, _mediaAssetIds)&&(identical(other.clientRequestId, clientRequestId) || other.clientRequestId == clientRequestId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_mediaAssetIds),clientRequestId);

@override
String toString() {
  return 'StartAddonRequest(mediaAssetIds: $mediaAssetIds, clientRequestId: $clientRequestId)';
}


}

/// @nodoc
abstract mixin class _$StartAddonRequestCopyWith<$Res> implements $StartAddonRequestCopyWith<$Res> {
  factory _$StartAddonRequestCopyWith(_StartAddonRequest value, $Res Function(_StartAddonRequest) _then) = __$StartAddonRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: StartAddonRequest.mediaAssetIdsKey_) List<String> mediaAssetIds,@JsonKey(name: StartAddonRequest.clientRequestIdKey_) String clientRequestId
});




}
/// @nodoc
class __$StartAddonRequestCopyWithImpl<$Res>
    implements _$StartAddonRequestCopyWith<$Res> {
  __$StartAddonRequestCopyWithImpl(this._self, this._then);

  final _StartAddonRequest _self;
  final $Res Function(_StartAddonRequest) _then;

/// Create a copy of StartAddonRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mediaAssetIds = null,Object? clientRequestId = null,}) {
  return _then(_StartAddonRequest(
mediaAssetIds: null == mediaAssetIds ? _self._mediaAssetIds : mediaAssetIds // ignore: cast_nullable_to_non_nullable
as List<String>,clientRequestId: null == clientRequestId ? _self.clientRequestId : clientRequestId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
