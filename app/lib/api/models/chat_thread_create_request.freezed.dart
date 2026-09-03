// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_thread_create_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatThreadCreateRequest {

/// proUserId
@JsonKey(name: ChatThreadCreateRequest.proUserIdKey_) String get proUserId;/// sessionId
@JsonKey(name: ChatThreadCreateRequest.sessionIdKey_) String? get sessionId;
/// Create a copy of ChatThreadCreateRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatThreadCreateRequestCopyWith<ChatThreadCreateRequest> get copyWith => _$ChatThreadCreateRequestCopyWithImpl<ChatThreadCreateRequest>(this as ChatThreadCreateRequest, _$identity);

  /// Serializes this ChatThreadCreateRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatThreadCreateRequest&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,proUserId,sessionId);

@override
String toString() {
  return 'ChatThreadCreateRequest(proUserId: $proUserId, sessionId: $sessionId)';
}


}

/// @nodoc
abstract mixin class $ChatThreadCreateRequestCopyWith<$Res>  {
  factory $ChatThreadCreateRequestCopyWith(ChatThreadCreateRequest value, $Res Function(ChatThreadCreateRequest) _then) = _$ChatThreadCreateRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ChatThreadCreateRequest.proUserIdKey_) String proUserId,@JsonKey(name: ChatThreadCreateRequest.sessionIdKey_) String? sessionId
});




}
/// @nodoc
class _$ChatThreadCreateRequestCopyWithImpl<$Res>
    implements $ChatThreadCreateRequestCopyWith<$Res> {
  _$ChatThreadCreateRequestCopyWithImpl(this._self, this._then);

  final ChatThreadCreateRequest _self;
  final $Res Function(ChatThreadCreateRequest) _then;

/// Create a copy of ChatThreadCreateRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? proUserId = null,Object? sessionId = freezed,}) {
  return _then(_self.copyWith(
proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatThreadCreateRequest].
extension ChatThreadCreateRequestPatterns on ChatThreadCreateRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatThreadCreateRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatThreadCreateRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatThreadCreateRequest value)  $default,){
final _that = this;
switch (_that) {
case _ChatThreadCreateRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatThreadCreateRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ChatThreadCreateRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ChatThreadCreateRequest.proUserIdKey_)  String proUserId, @JsonKey(name: ChatThreadCreateRequest.sessionIdKey_)  String? sessionId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatThreadCreateRequest() when $default != null:
return $default(_that.proUserId,_that.sessionId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ChatThreadCreateRequest.proUserIdKey_)  String proUserId, @JsonKey(name: ChatThreadCreateRequest.sessionIdKey_)  String? sessionId)  $default,) {final _that = this;
switch (_that) {
case _ChatThreadCreateRequest():
return $default(_that.proUserId,_that.sessionId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ChatThreadCreateRequest.proUserIdKey_)  String proUserId, @JsonKey(name: ChatThreadCreateRequest.sessionIdKey_)  String? sessionId)?  $default,) {final _that = this;
switch (_that) {
case _ChatThreadCreateRequest() when $default != null:
return $default(_that.proUserId,_that.sessionId);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ChatThreadCreateRequest extends ChatThreadCreateRequest {
  const _ChatThreadCreateRequest({@JsonKey(name: ChatThreadCreateRequest.proUserIdKey_) required this.proUserId, @JsonKey(name: ChatThreadCreateRequest.sessionIdKey_) this.sessionId}): super._();
  factory _ChatThreadCreateRequest.fromJson(Map<String, dynamic> json) => _$ChatThreadCreateRequestFromJson(json);

/// proUserId
@override@JsonKey(name: ChatThreadCreateRequest.proUserIdKey_) final  String proUserId;
/// sessionId
@override@JsonKey(name: ChatThreadCreateRequest.sessionIdKey_) final  String? sessionId;

/// Create a copy of ChatThreadCreateRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatThreadCreateRequestCopyWith<_ChatThreadCreateRequest> get copyWith => __$ChatThreadCreateRequestCopyWithImpl<_ChatThreadCreateRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatThreadCreateRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatThreadCreateRequest&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,proUserId,sessionId);

@override
String toString() {
  return 'ChatThreadCreateRequest(proUserId: $proUserId, sessionId: $sessionId)';
}


}

/// @nodoc
abstract mixin class _$ChatThreadCreateRequestCopyWith<$Res> implements $ChatThreadCreateRequestCopyWith<$Res> {
  factory _$ChatThreadCreateRequestCopyWith(_ChatThreadCreateRequest value, $Res Function(_ChatThreadCreateRequest) _then) = __$ChatThreadCreateRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ChatThreadCreateRequest.proUserIdKey_) String proUserId,@JsonKey(name: ChatThreadCreateRequest.sessionIdKey_) String? sessionId
});




}
/// @nodoc
class __$ChatThreadCreateRequestCopyWithImpl<$Res>
    implements _$ChatThreadCreateRequestCopyWith<$Res> {
  __$ChatThreadCreateRequestCopyWithImpl(this._self, this._then);

  final _ChatThreadCreateRequest _self;
  final $Res Function(_ChatThreadCreateRequest) _then;

/// Create a copy of ChatThreadCreateRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? proUserId = null,Object? sessionId = freezed,}) {
  return _then(_ChatThreadCreateRequest(
proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
