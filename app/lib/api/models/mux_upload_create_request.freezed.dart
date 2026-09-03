// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mux_upload_create_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MuxUploadCreateRequest {

/// purpose
@JsonKey(name: MuxUploadCreateRequest.purposeKey_) MediaPurpose get purpose;/// visibility
@JsonKey(name: MuxUploadCreateRequest.visibilityKey_) MediaVisibility? get visibility;
/// Create a copy of MuxUploadCreateRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MuxUploadCreateRequestCopyWith<MuxUploadCreateRequest> get copyWith => _$MuxUploadCreateRequestCopyWithImpl<MuxUploadCreateRequest>(this as MuxUploadCreateRequest, _$identity);

  /// Serializes this MuxUploadCreateRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MuxUploadCreateRequest&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.visibility, visibility) || other.visibility == visibility));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,purpose,visibility);

@override
String toString() {
  return 'MuxUploadCreateRequest(purpose: $purpose, visibility: $visibility)';
}


}

/// @nodoc
abstract mixin class $MuxUploadCreateRequestCopyWith<$Res>  {
  factory $MuxUploadCreateRequestCopyWith(MuxUploadCreateRequest value, $Res Function(MuxUploadCreateRequest) _then) = _$MuxUploadCreateRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: MuxUploadCreateRequest.purposeKey_) MediaPurpose purpose,@JsonKey(name: MuxUploadCreateRequest.visibilityKey_) MediaVisibility? visibility
});




}
/// @nodoc
class _$MuxUploadCreateRequestCopyWithImpl<$Res>
    implements $MuxUploadCreateRequestCopyWith<$Res> {
  _$MuxUploadCreateRequestCopyWithImpl(this._self, this._then);

  final MuxUploadCreateRequest _self;
  final $Res Function(MuxUploadCreateRequest) _then;

/// Create a copy of MuxUploadCreateRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? purpose = null,Object? visibility = freezed,}) {
  return _then(_self.copyWith(
purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as MediaPurpose,visibility: freezed == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as MediaVisibility?,
  ));
}

}


/// Adds pattern-matching-related methods to [MuxUploadCreateRequest].
extension MuxUploadCreateRequestPatterns on MuxUploadCreateRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MuxUploadCreateRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MuxUploadCreateRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MuxUploadCreateRequest value)  $default,){
final _that = this;
switch (_that) {
case _MuxUploadCreateRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MuxUploadCreateRequest value)?  $default,){
final _that = this;
switch (_that) {
case _MuxUploadCreateRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: MuxUploadCreateRequest.purposeKey_)  MediaPurpose purpose, @JsonKey(name: MuxUploadCreateRequest.visibilityKey_)  MediaVisibility? visibility)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MuxUploadCreateRequest() when $default != null:
return $default(_that.purpose,_that.visibility);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: MuxUploadCreateRequest.purposeKey_)  MediaPurpose purpose, @JsonKey(name: MuxUploadCreateRequest.visibilityKey_)  MediaVisibility? visibility)  $default,) {final _that = this;
switch (_that) {
case _MuxUploadCreateRequest():
return $default(_that.purpose,_that.visibility);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: MuxUploadCreateRequest.purposeKey_)  MediaPurpose purpose, @JsonKey(name: MuxUploadCreateRequest.visibilityKey_)  MediaVisibility? visibility)?  $default,) {final _that = this;
switch (_that) {
case _MuxUploadCreateRequest() when $default != null:
return $default(_that.purpose,_that.visibility);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _MuxUploadCreateRequest extends MuxUploadCreateRequest {
  const _MuxUploadCreateRequest({@JsonKey(name: MuxUploadCreateRequest.purposeKey_) required this.purpose, @JsonKey(name: MuxUploadCreateRequest.visibilityKey_) this.visibility}): super._();
  factory _MuxUploadCreateRequest.fromJson(Map<String, dynamic> json) => _$MuxUploadCreateRequestFromJson(json);

/// purpose
@override@JsonKey(name: MuxUploadCreateRequest.purposeKey_) final  MediaPurpose purpose;
/// visibility
@override@JsonKey(name: MuxUploadCreateRequest.visibilityKey_) final  MediaVisibility? visibility;

/// Create a copy of MuxUploadCreateRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MuxUploadCreateRequestCopyWith<_MuxUploadCreateRequest> get copyWith => __$MuxUploadCreateRequestCopyWithImpl<_MuxUploadCreateRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MuxUploadCreateRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MuxUploadCreateRequest&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.visibility, visibility) || other.visibility == visibility));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,purpose,visibility);

@override
String toString() {
  return 'MuxUploadCreateRequest(purpose: $purpose, visibility: $visibility)';
}


}

/// @nodoc
abstract mixin class _$MuxUploadCreateRequestCopyWith<$Res> implements $MuxUploadCreateRequestCopyWith<$Res> {
  factory _$MuxUploadCreateRequestCopyWith(_MuxUploadCreateRequest value, $Res Function(_MuxUploadCreateRequest) _then) = __$MuxUploadCreateRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: MuxUploadCreateRequest.purposeKey_) MediaPurpose purpose,@JsonKey(name: MuxUploadCreateRequest.visibilityKey_) MediaVisibility? visibility
});




}
/// @nodoc
class __$MuxUploadCreateRequestCopyWithImpl<$Res>
    implements _$MuxUploadCreateRequestCopyWith<$Res> {
  __$MuxUploadCreateRequestCopyWithImpl(this._self, this._then);

  final _MuxUploadCreateRequest _self;
  final $Res Function(_MuxUploadCreateRequest) _then;

/// Create a copy of MuxUploadCreateRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? purpose = null,Object? visibility = freezed,}) {
  return _then(_MuxUploadCreateRequest(
purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as MediaPurpose,visibility: freezed == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as MediaVisibility?,
  ));
}


}

// dart format on
