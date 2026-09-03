// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'complete_photo_upload_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CompletePhotoUploadResponse {

/// ok
@JsonKey(name: CompletePhotoUploadResponse.okKey_) bool get ok;/// currentStatus
@JsonKey(name: CompletePhotoUploadResponse.currentStatusKey_) String get currentStatus;
/// Create a copy of CompletePhotoUploadResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompletePhotoUploadResponseCopyWith<CompletePhotoUploadResponse> get copyWith => _$CompletePhotoUploadResponseCopyWithImpl<CompletePhotoUploadResponse>(this as CompletePhotoUploadResponse, _$identity);

  /// Serializes this CompletePhotoUploadResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompletePhotoUploadResponse&&(identical(other.ok, ok) || other.ok == ok)&&(identical(other.currentStatus, currentStatus) || other.currentStatus == currentStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ok,currentStatus);

@override
String toString() {
  return 'CompletePhotoUploadResponse(ok: $ok, currentStatus: $currentStatus)';
}


}

/// @nodoc
abstract mixin class $CompletePhotoUploadResponseCopyWith<$Res>  {
  factory $CompletePhotoUploadResponseCopyWith(CompletePhotoUploadResponse value, $Res Function(CompletePhotoUploadResponse) _then) = _$CompletePhotoUploadResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: CompletePhotoUploadResponse.okKey_) bool ok,@JsonKey(name: CompletePhotoUploadResponse.currentStatusKey_) String currentStatus
});




}
/// @nodoc
class _$CompletePhotoUploadResponseCopyWithImpl<$Res>
    implements $CompletePhotoUploadResponseCopyWith<$Res> {
  _$CompletePhotoUploadResponseCopyWithImpl(this._self, this._then);

  final CompletePhotoUploadResponse _self;
  final $Res Function(CompletePhotoUploadResponse) _then;

/// Create a copy of CompletePhotoUploadResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ok = null,Object? currentStatus = null,}) {
  return _then(_self.copyWith(
ok: null == ok ? _self.ok : ok // ignore: cast_nullable_to_non_nullable
as bool,currentStatus: null == currentStatus ? _self.currentStatus : currentStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CompletePhotoUploadResponse].
extension CompletePhotoUploadResponsePatterns on CompletePhotoUploadResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompletePhotoUploadResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompletePhotoUploadResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompletePhotoUploadResponse value)  $default,){
final _that = this;
switch (_that) {
case _CompletePhotoUploadResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompletePhotoUploadResponse value)?  $default,){
final _that = this;
switch (_that) {
case _CompletePhotoUploadResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: CompletePhotoUploadResponse.okKey_)  bool ok, @JsonKey(name: CompletePhotoUploadResponse.currentStatusKey_)  String currentStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompletePhotoUploadResponse() when $default != null:
return $default(_that.ok,_that.currentStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: CompletePhotoUploadResponse.okKey_)  bool ok, @JsonKey(name: CompletePhotoUploadResponse.currentStatusKey_)  String currentStatus)  $default,) {final _that = this;
switch (_that) {
case _CompletePhotoUploadResponse():
return $default(_that.ok,_that.currentStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: CompletePhotoUploadResponse.okKey_)  bool ok, @JsonKey(name: CompletePhotoUploadResponse.currentStatusKey_)  String currentStatus)?  $default,) {final _that = this;
switch (_that) {
case _CompletePhotoUploadResponse() when $default != null:
return $default(_that.ok,_that.currentStatus);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _CompletePhotoUploadResponse extends CompletePhotoUploadResponse {
  const _CompletePhotoUploadResponse({@JsonKey(name: CompletePhotoUploadResponse.okKey_) required this.ok, @JsonKey(name: CompletePhotoUploadResponse.currentStatusKey_) required this.currentStatus}): super._();
  factory _CompletePhotoUploadResponse.fromJson(Map<String, dynamic> json) => _$CompletePhotoUploadResponseFromJson(json);

/// ok
@override@JsonKey(name: CompletePhotoUploadResponse.okKey_) final  bool ok;
/// currentStatus
@override@JsonKey(name: CompletePhotoUploadResponse.currentStatusKey_) final  String currentStatus;

/// Create a copy of CompletePhotoUploadResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompletePhotoUploadResponseCopyWith<_CompletePhotoUploadResponse> get copyWith => __$CompletePhotoUploadResponseCopyWithImpl<_CompletePhotoUploadResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CompletePhotoUploadResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompletePhotoUploadResponse&&(identical(other.ok, ok) || other.ok == ok)&&(identical(other.currentStatus, currentStatus) || other.currentStatus == currentStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ok,currentStatus);

@override
String toString() {
  return 'CompletePhotoUploadResponse(ok: $ok, currentStatus: $currentStatus)';
}


}

/// @nodoc
abstract mixin class _$CompletePhotoUploadResponseCopyWith<$Res> implements $CompletePhotoUploadResponseCopyWith<$Res> {
  factory _$CompletePhotoUploadResponseCopyWith(_CompletePhotoUploadResponse value, $Res Function(_CompletePhotoUploadResponse) _then) = __$CompletePhotoUploadResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: CompletePhotoUploadResponse.okKey_) bool ok,@JsonKey(name: CompletePhotoUploadResponse.currentStatusKey_) String currentStatus
});




}
/// @nodoc
class __$CompletePhotoUploadResponseCopyWithImpl<$Res>
    implements _$CompletePhotoUploadResponseCopyWith<$Res> {
  __$CompletePhotoUploadResponseCopyWithImpl(this._self, this._then);

  final _CompletePhotoUploadResponse _self;
  final $Res Function(_CompletePhotoUploadResponse) _then;

/// Create a copy of CompletePhotoUploadResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ok = null,Object? currentStatus = null,}) {
  return _then(_CompletePhotoUploadResponse(
ok: null == ok ? _self.ok : ok // ignore: cast_nullable_to_non_nullable
as bool,currentStatus: null == currentStatus ? _self.currentStatus : currentStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
