// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_draft_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AIDraftResponse {

/// content
@JsonKey(name: AIDraftResponse.contentKey_) String get content;/// metadata
@JsonKey(name: AIDraftResponse.metadataKey_) Map<String, dynamic>? get metadata;
/// Create a copy of AIDraftResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AIDraftResponseCopyWith<AIDraftResponse> get copyWith => _$AIDraftResponseCopyWithImpl<AIDraftResponse>(this as AIDraftResponse, _$identity);

  /// Serializes this AIDraftResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AIDraftResponse&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,content,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'AIDraftResponse(content: $content, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $AIDraftResponseCopyWith<$Res>  {
  factory $AIDraftResponseCopyWith(AIDraftResponse value, $Res Function(AIDraftResponse) _then) = _$AIDraftResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: AIDraftResponse.contentKey_) String content,@JsonKey(name: AIDraftResponse.metadataKey_) Map<String, dynamic>? metadata
});




}
/// @nodoc
class _$AIDraftResponseCopyWithImpl<$Res>
    implements $AIDraftResponseCopyWith<$Res> {
  _$AIDraftResponseCopyWithImpl(this._self, this._then);

  final AIDraftResponse _self;
  final $Res Function(AIDraftResponse) _then;

/// Create a copy of AIDraftResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? content = null,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [AIDraftResponse].
extension AIDraftResponsePatterns on AIDraftResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AIDraftResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AIDraftResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AIDraftResponse value)  $default,){
final _that = this;
switch (_that) {
case _AIDraftResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AIDraftResponse value)?  $default,){
final _that = this;
switch (_that) {
case _AIDraftResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: AIDraftResponse.contentKey_)  String content, @JsonKey(name: AIDraftResponse.metadataKey_)  Map<String, dynamic>? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AIDraftResponse() when $default != null:
return $default(_that.content,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: AIDraftResponse.contentKey_)  String content, @JsonKey(name: AIDraftResponse.metadataKey_)  Map<String, dynamic>? metadata)  $default,) {final _that = this;
switch (_that) {
case _AIDraftResponse():
return $default(_that.content,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: AIDraftResponse.contentKey_)  String content, @JsonKey(name: AIDraftResponse.metadataKey_)  Map<String, dynamic>? metadata)?  $default,) {final _that = this;
switch (_that) {
case _AIDraftResponse() when $default != null:
return $default(_that.content,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _AIDraftResponse extends AIDraftResponse {
  const _AIDraftResponse({@JsonKey(name: AIDraftResponse.contentKey_) required this.content, @JsonKey(name: AIDraftResponse.metadataKey_) final  Map<String, dynamic>? metadata}): _metadata = metadata,super._();
  factory _AIDraftResponse.fromJson(Map<String, dynamic> json) => _$AIDraftResponseFromJson(json);

/// content
@override@JsonKey(name: AIDraftResponse.contentKey_) final  String content;
/// metadata
 final  Map<String, dynamic>? _metadata;
/// metadata
@override@JsonKey(name: AIDraftResponse.metadataKey_) Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of AIDraftResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AIDraftResponseCopyWith<_AIDraftResponse> get copyWith => __$AIDraftResponseCopyWithImpl<_AIDraftResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AIDraftResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AIDraftResponse&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,content,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'AIDraftResponse(content: $content, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$AIDraftResponseCopyWith<$Res> implements $AIDraftResponseCopyWith<$Res> {
  factory _$AIDraftResponseCopyWith(_AIDraftResponse value, $Res Function(_AIDraftResponse) _then) = __$AIDraftResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: AIDraftResponse.contentKey_) String content,@JsonKey(name: AIDraftResponse.metadataKey_) Map<String, dynamic>? metadata
});




}
/// @nodoc
class __$AIDraftResponseCopyWithImpl<$Res>
    implements _$AIDraftResponseCopyWith<$Res> {
  __$AIDraftResponseCopyWithImpl(this._self, this._then);

  final _AIDraftResponse _self;
  final $Res Function(_AIDraftResponse) _then;

/// Create a copy of AIDraftResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? content = null,Object? metadata = freezed,}) {
  return _then(_AIDraftResponse(
content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
