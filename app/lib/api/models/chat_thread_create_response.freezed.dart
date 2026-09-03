// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_thread_create_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatThreadCreateResponse {

/// threadId
@JsonKey(name: ChatThreadCreateResponse.threadIdKey_) String get threadId;/// status
@JsonKey(name: ChatThreadCreateResponse.statusKey_) ChatThreadStatus get status;
/// Create a copy of ChatThreadCreateResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatThreadCreateResponseCopyWith<ChatThreadCreateResponse> get copyWith => _$ChatThreadCreateResponseCopyWithImpl<ChatThreadCreateResponse>(this as ChatThreadCreateResponse, _$identity);

  /// Serializes this ChatThreadCreateResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatThreadCreateResponse&&(identical(other.threadId, threadId) || other.threadId == threadId)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,threadId,status);

@override
String toString() {
  return 'ChatThreadCreateResponse(threadId: $threadId, status: $status)';
}


}

/// @nodoc
abstract mixin class $ChatThreadCreateResponseCopyWith<$Res>  {
  factory $ChatThreadCreateResponseCopyWith(ChatThreadCreateResponse value, $Res Function(ChatThreadCreateResponse) _then) = _$ChatThreadCreateResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ChatThreadCreateResponse.threadIdKey_) String threadId,@JsonKey(name: ChatThreadCreateResponse.statusKey_) ChatThreadStatus status
});




}
/// @nodoc
class _$ChatThreadCreateResponseCopyWithImpl<$Res>
    implements $ChatThreadCreateResponseCopyWith<$Res> {
  _$ChatThreadCreateResponseCopyWithImpl(this._self, this._then);

  final ChatThreadCreateResponse _self;
  final $Res Function(ChatThreadCreateResponse) _then;

/// Create a copy of ChatThreadCreateResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? threadId = null,Object? status = null,}) {
  return _then(_self.copyWith(
threadId: null == threadId ? _self.threadId : threadId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ChatThreadStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatThreadCreateResponse].
extension ChatThreadCreateResponsePatterns on ChatThreadCreateResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatThreadCreateResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatThreadCreateResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatThreadCreateResponse value)  $default,){
final _that = this;
switch (_that) {
case _ChatThreadCreateResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatThreadCreateResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ChatThreadCreateResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ChatThreadCreateResponse.threadIdKey_)  String threadId, @JsonKey(name: ChatThreadCreateResponse.statusKey_)  ChatThreadStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatThreadCreateResponse() when $default != null:
return $default(_that.threadId,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ChatThreadCreateResponse.threadIdKey_)  String threadId, @JsonKey(name: ChatThreadCreateResponse.statusKey_)  ChatThreadStatus status)  $default,) {final _that = this;
switch (_that) {
case _ChatThreadCreateResponse():
return $default(_that.threadId,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ChatThreadCreateResponse.threadIdKey_)  String threadId, @JsonKey(name: ChatThreadCreateResponse.statusKey_)  ChatThreadStatus status)?  $default,) {final _that = this;
switch (_that) {
case _ChatThreadCreateResponse() when $default != null:
return $default(_that.threadId,_that.status);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ChatThreadCreateResponse extends ChatThreadCreateResponse {
  const _ChatThreadCreateResponse({@JsonKey(name: ChatThreadCreateResponse.threadIdKey_) required this.threadId, @JsonKey(name: ChatThreadCreateResponse.statusKey_) required this.status}): super._();
  factory _ChatThreadCreateResponse.fromJson(Map<String, dynamic> json) => _$ChatThreadCreateResponseFromJson(json);

/// threadId
@override@JsonKey(name: ChatThreadCreateResponse.threadIdKey_) final  String threadId;
/// status
@override@JsonKey(name: ChatThreadCreateResponse.statusKey_) final  ChatThreadStatus status;

/// Create a copy of ChatThreadCreateResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatThreadCreateResponseCopyWith<_ChatThreadCreateResponse> get copyWith => __$ChatThreadCreateResponseCopyWithImpl<_ChatThreadCreateResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatThreadCreateResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatThreadCreateResponse&&(identical(other.threadId, threadId) || other.threadId == threadId)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,threadId,status);

@override
String toString() {
  return 'ChatThreadCreateResponse(threadId: $threadId, status: $status)';
}


}

/// @nodoc
abstract mixin class _$ChatThreadCreateResponseCopyWith<$Res> implements $ChatThreadCreateResponseCopyWith<$Res> {
  factory _$ChatThreadCreateResponseCopyWith(_ChatThreadCreateResponse value, $Res Function(_ChatThreadCreateResponse) _then) = __$ChatThreadCreateResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ChatThreadCreateResponse.threadIdKey_) String threadId,@JsonKey(name: ChatThreadCreateResponse.statusKey_) ChatThreadStatus status
});




}
/// @nodoc
class __$ChatThreadCreateResponseCopyWithImpl<$Res>
    implements _$ChatThreadCreateResponseCopyWith<$Res> {
  __$ChatThreadCreateResponseCopyWithImpl(this._self, this._then);

  final _ChatThreadCreateResponse _self;
  final $Res Function(_ChatThreadCreateResponse) _then;

/// Create a copy of ChatThreadCreateResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? threadId = null,Object? status = null,}) {
  return _then(_ChatThreadCreateResponse(
threadId: null == threadId ? _self.threadId : threadId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ChatThreadStatus,
  ));
}


}

// dart format on
