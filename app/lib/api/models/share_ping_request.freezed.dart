// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'share_ping_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SharePingRequest {

/// secondsViewed
@JsonKey(name: SharePingRequest.secondsViewedKey_) int get secondsViewed;
/// Create a copy of SharePingRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SharePingRequestCopyWith<SharePingRequest> get copyWith => _$SharePingRequestCopyWithImpl<SharePingRequest>(this as SharePingRequest, _$identity);

  /// Serializes this SharePingRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SharePingRequest&&(identical(other.secondsViewed, secondsViewed) || other.secondsViewed == secondsViewed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,secondsViewed);

@override
String toString() {
  return 'SharePingRequest(secondsViewed: $secondsViewed)';
}


}

/// @nodoc
abstract mixin class $SharePingRequestCopyWith<$Res>  {
  factory $SharePingRequestCopyWith(SharePingRequest value, $Res Function(SharePingRequest) _then) = _$SharePingRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: SharePingRequest.secondsViewedKey_) int secondsViewed
});




}
/// @nodoc
class _$SharePingRequestCopyWithImpl<$Res>
    implements $SharePingRequestCopyWith<$Res> {
  _$SharePingRequestCopyWithImpl(this._self, this._then);

  final SharePingRequest _self;
  final $Res Function(SharePingRequest) _then;

/// Create a copy of SharePingRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? secondsViewed = null,}) {
  return _then(_self.copyWith(
secondsViewed: null == secondsViewed ? _self.secondsViewed : secondsViewed // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SharePingRequest].
extension SharePingRequestPatterns on SharePingRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SharePingRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SharePingRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SharePingRequest value)  $default,){
final _that = this;
switch (_that) {
case _SharePingRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SharePingRequest value)?  $default,){
final _that = this;
switch (_that) {
case _SharePingRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: SharePingRequest.secondsViewedKey_)  int secondsViewed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SharePingRequest() when $default != null:
return $default(_that.secondsViewed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: SharePingRequest.secondsViewedKey_)  int secondsViewed)  $default,) {final _that = this;
switch (_that) {
case _SharePingRequest():
return $default(_that.secondsViewed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: SharePingRequest.secondsViewedKey_)  int secondsViewed)?  $default,) {final _that = this;
switch (_that) {
case _SharePingRequest() when $default != null:
return $default(_that.secondsViewed);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _SharePingRequest extends SharePingRequest {
  const _SharePingRequest({@JsonKey(name: SharePingRequest.secondsViewedKey_) this.secondsViewed = 1}): super._();
  factory _SharePingRequest.fromJson(Map<String, dynamic> json) => _$SharePingRequestFromJson(json);

/// secondsViewed
@override@JsonKey(name: SharePingRequest.secondsViewedKey_) final  int secondsViewed;

/// Create a copy of SharePingRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SharePingRequestCopyWith<_SharePingRequest> get copyWith => __$SharePingRequestCopyWithImpl<_SharePingRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SharePingRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SharePingRequest&&(identical(other.secondsViewed, secondsViewed) || other.secondsViewed == secondsViewed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,secondsViewed);

@override
String toString() {
  return 'SharePingRequest(secondsViewed: $secondsViewed)';
}


}

/// @nodoc
abstract mixin class _$SharePingRequestCopyWith<$Res> implements $SharePingRequestCopyWith<$Res> {
  factory _$SharePingRequestCopyWith(_SharePingRequest value, $Res Function(_SharePingRequest) _then) = __$SharePingRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: SharePingRequest.secondsViewedKey_) int secondsViewed
});




}
/// @nodoc
class __$SharePingRequestCopyWithImpl<$Res>
    implements _$SharePingRequestCopyWith<$Res> {
  __$SharePingRequestCopyWithImpl(this._self, this._then);

  final _SharePingRequest _self;
  final $Res Function(_SharePingRequest) _then;

/// Create a copy of SharePingRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? secondsViewed = null,}) {
  return _then(_SharePingRequest(
secondsViewed: null == secondsViewed ? _self.secondsViewed : secondsViewed // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
