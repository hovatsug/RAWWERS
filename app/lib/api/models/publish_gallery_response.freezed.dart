// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'publish_gallery_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PublishGalleryResponse {

/// ok
@JsonKey(name: PublishGalleryResponse.okKey_) bool get ok;/// status
@JsonKey(name: PublishGalleryResponse.statusKey_) ProofGalleryStatus get status;
/// Create a copy of PublishGalleryResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PublishGalleryResponseCopyWith<PublishGalleryResponse> get copyWith => _$PublishGalleryResponseCopyWithImpl<PublishGalleryResponse>(this as PublishGalleryResponse, _$identity);

  /// Serializes this PublishGalleryResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PublishGalleryResponse&&(identical(other.ok, ok) || other.ok == ok)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ok,status);

@override
String toString() {
  return 'PublishGalleryResponse(ok: $ok, status: $status)';
}


}

/// @nodoc
abstract mixin class $PublishGalleryResponseCopyWith<$Res>  {
  factory $PublishGalleryResponseCopyWith(PublishGalleryResponse value, $Res Function(PublishGalleryResponse) _then) = _$PublishGalleryResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: PublishGalleryResponse.okKey_) bool ok,@JsonKey(name: PublishGalleryResponse.statusKey_) ProofGalleryStatus status
});




}
/// @nodoc
class _$PublishGalleryResponseCopyWithImpl<$Res>
    implements $PublishGalleryResponseCopyWith<$Res> {
  _$PublishGalleryResponseCopyWithImpl(this._self, this._then);

  final PublishGalleryResponse _self;
  final $Res Function(PublishGalleryResponse) _then;

/// Create a copy of PublishGalleryResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ok = null,Object? status = null,}) {
  return _then(_self.copyWith(
ok: null == ok ? _self.ok : ok // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProofGalleryStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [PublishGalleryResponse].
extension PublishGalleryResponsePatterns on PublishGalleryResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PublishGalleryResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PublishGalleryResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PublishGalleryResponse value)  $default,){
final _that = this;
switch (_that) {
case _PublishGalleryResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PublishGalleryResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PublishGalleryResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: PublishGalleryResponse.okKey_)  bool ok, @JsonKey(name: PublishGalleryResponse.statusKey_)  ProofGalleryStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PublishGalleryResponse() when $default != null:
return $default(_that.ok,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: PublishGalleryResponse.okKey_)  bool ok, @JsonKey(name: PublishGalleryResponse.statusKey_)  ProofGalleryStatus status)  $default,) {final _that = this;
switch (_that) {
case _PublishGalleryResponse():
return $default(_that.ok,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: PublishGalleryResponse.okKey_)  bool ok, @JsonKey(name: PublishGalleryResponse.statusKey_)  ProofGalleryStatus status)?  $default,) {final _that = this;
switch (_that) {
case _PublishGalleryResponse() when $default != null:
return $default(_that.ok,_that.status);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _PublishGalleryResponse extends PublishGalleryResponse {
  const _PublishGalleryResponse({@JsonKey(name: PublishGalleryResponse.okKey_) required this.ok, @JsonKey(name: PublishGalleryResponse.statusKey_) required this.status}): super._();
  factory _PublishGalleryResponse.fromJson(Map<String, dynamic> json) => _$PublishGalleryResponseFromJson(json);

/// ok
@override@JsonKey(name: PublishGalleryResponse.okKey_) final  bool ok;
/// status
@override@JsonKey(name: PublishGalleryResponse.statusKey_) final  ProofGalleryStatus status;

/// Create a copy of PublishGalleryResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PublishGalleryResponseCopyWith<_PublishGalleryResponse> get copyWith => __$PublishGalleryResponseCopyWithImpl<_PublishGalleryResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PublishGalleryResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PublishGalleryResponse&&(identical(other.ok, ok) || other.ok == ok)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ok,status);

@override
String toString() {
  return 'PublishGalleryResponse(ok: $ok, status: $status)';
}


}

/// @nodoc
abstract mixin class _$PublishGalleryResponseCopyWith<$Res> implements $PublishGalleryResponseCopyWith<$Res> {
  factory _$PublishGalleryResponseCopyWith(_PublishGalleryResponse value, $Res Function(_PublishGalleryResponse) _then) = __$PublishGalleryResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: PublishGalleryResponse.okKey_) bool ok,@JsonKey(name: PublishGalleryResponse.statusKey_) ProofGalleryStatus status
});




}
/// @nodoc
class __$PublishGalleryResponseCopyWithImpl<$Res>
    implements _$PublishGalleryResponseCopyWith<$Res> {
  __$PublishGalleryResponseCopyWithImpl(this._self, this._then);

  final _PublishGalleryResponse _self;
  final $Res Function(_PublishGalleryResponse) _then;

/// Create a copy of PublishGalleryResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ok = null,Object? status = null,}) {
  return _then(_PublishGalleryResponse(
ok: null == ok ? _self.ok : ok // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProofGalleryStatus,
  ));
}


}

// dart format on
