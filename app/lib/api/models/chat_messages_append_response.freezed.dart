// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_messages_append_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatMessagesAppendResponse {

/// threadId
@JsonKey(name: ChatMessagesAppendResponse.threadIdKey_) String get threadId;/// status
@JsonKey(name: ChatMessagesAppendResponse.statusKey_) ChatThreadStatus get status;/// appended
@JsonKey(name: ChatMessagesAppendResponse.appendedKey_) List<ChatMessageView> get appended;
/// Create a copy of ChatMessagesAppendResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatMessagesAppendResponseCopyWith<ChatMessagesAppendResponse> get copyWith => _$ChatMessagesAppendResponseCopyWithImpl<ChatMessagesAppendResponse>(this as ChatMessagesAppendResponse, _$identity);

  /// Serializes this ChatMessagesAppendResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessagesAppendResponse&&(identical(other.threadId, threadId) || other.threadId == threadId)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.appended, appended));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,threadId,status,const DeepCollectionEquality().hash(appended));

@override
String toString() {
  return 'ChatMessagesAppendResponse(threadId: $threadId, status: $status, appended: $appended)';
}


}

/// @nodoc
abstract mixin class $ChatMessagesAppendResponseCopyWith<$Res>  {
  factory $ChatMessagesAppendResponseCopyWith(ChatMessagesAppendResponse value, $Res Function(ChatMessagesAppendResponse) _then) = _$ChatMessagesAppendResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ChatMessagesAppendResponse.threadIdKey_) String threadId,@JsonKey(name: ChatMessagesAppendResponse.statusKey_) ChatThreadStatus status,@JsonKey(name: ChatMessagesAppendResponse.appendedKey_) List<ChatMessageView> appended
});




}
/// @nodoc
class _$ChatMessagesAppendResponseCopyWithImpl<$Res>
    implements $ChatMessagesAppendResponseCopyWith<$Res> {
  _$ChatMessagesAppendResponseCopyWithImpl(this._self, this._then);

  final ChatMessagesAppendResponse _self;
  final $Res Function(ChatMessagesAppendResponse) _then;

/// Create a copy of ChatMessagesAppendResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? threadId = null,Object? status = null,Object? appended = null,}) {
  return _then(_self.copyWith(
threadId: null == threadId ? _self.threadId : threadId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ChatThreadStatus,appended: null == appended ? _self.appended : appended // ignore: cast_nullable_to_non_nullable
as List<ChatMessageView>,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatMessagesAppendResponse].
extension ChatMessagesAppendResponsePatterns on ChatMessagesAppendResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatMessagesAppendResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatMessagesAppendResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatMessagesAppendResponse value)  $default,){
final _that = this;
switch (_that) {
case _ChatMessagesAppendResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatMessagesAppendResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ChatMessagesAppendResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ChatMessagesAppendResponse.threadIdKey_)  String threadId, @JsonKey(name: ChatMessagesAppendResponse.statusKey_)  ChatThreadStatus status, @JsonKey(name: ChatMessagesAppendResponse.appendedKey_)  List<ChatMessageView> appended)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatMessagesAppendResponse() when $default != null:
return $default(_that.threadId,_that.status,_that.appended);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ChatMessagesAppendResponse.threadIdKey_)  String threadId, @JsonKey(name: ChatMessagesAppendResponse.statusKey_)  ChatThreadStatus status, @JsonKey(name: ChatMessagesAppendResponse.appendedKey_)  List<ChatMessageView> appended)  $default,) {final _that = this;
switch (_that) {
case _ChatMessagesAppendResponse():
return $default(_that.threadId,_that.status,_that.appended);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ChatMessagesAppendResponse.threadIdKey_)  String threadId, @JsonKey(name: ChatMessagesAppendResponse.statusKey_)  ChatThreadStatus status, @JsonKey(name: ChatMessagesAppendResponse.appendedKey_)  List<ChatMessageView> appended)?  $default,) {final _that = this;
switch (_that) {
case _ChatMessagesAppendResponse() when $default != null:
return $default(_that.threadId,_that.status,_that.appended);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ChatMessagesAppendResponse extends ChatMessagesAppendResponse {
  const _ChatMessagesAppendResponse({@JsonKey(name: ChatMessagesAppendResponse.threadIdKey_) required this.threadId, @JsonKey(name: ChatMessagesAppendResponse.statusKey_) required this.status, @JsonKey(name: ChatMessagesAppendResponse.appendedKey_) required final  List<ChatMessageView> appended}): _appended = appended,super._();
  factory _ChatMessagesAppendResponse.fromJson(Map<String, dynamic> json) => _$ChatMessagesAppendResponseFromJson(json);

/// threadId
@override@JsonKey(name: ChatMessagesAppendResponse.threadIdKey_) final  String threadId;
/// status
@override@JsonKey(name: ChatMessagesAppendResponse.statusKey_) final  ChatThreadStatus status;
/// appended
 final  List<ChatMessageView> _appended;
/// appended
@override@JsonKey(name: ChatMessagesAppendResponse.appendedKey_) List<ChatMessageView> get appended {
  if (_appended is EqualUnmodifiableListView) return _appended;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_appended);
}


/// Create a copy of ChatMessagesAppendResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatMessagesAppendResponseCopyWith<_ChatMessagesAppendResponse> get copyWith => __$ChatMessagesAppendResponseCopyWithImpl<_ChatMessagesAppendResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatMessagesAppendResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatMessagesAppendResponse&&(identical(other.threadId, threadId) || other.threadId == threadId)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._appended, _appended));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,threadId,status,const DeepCollectionEquality().hash(_appended));

@override
String toString() {
  return 'ChatMessagesAppendResponse(threadId: $threadId, status: $status, appended: $appended)';
}


}

/// @nodoc
abstract mixin class _$ChatMessagesAppendResponseCopyWith<$Res> implements $ChatMessagesAppendResponseCopyWith<$Res> {
  factory _$ChatMessagesAppendResponseCopyWith(_ChatMessagesAppendResponse value, $Res Function(_ChatMessagesAppendResponse) _then) = __$ChatMessagesAppendResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ChatMessagesAppendResponse.threadIdKey_) String threadId,@JsonKey(name: ChatMessagesAppendResponse.statusKey_) ChatThreadStatus status,@JsonKey(name: ChatMessagesAppendResponse.appendedKey_) List<ChatMessageView> appended
});




}
/// @nodoc
class __$ChatMessagesAppendResponseCopyWithImpl<$Res>
    implements _$ChatMessagesAppendResponseCopyWith<$Res> {
  __$ChatMessagesAppendResponseCopyWithImpl(this._self, this._then);

  final _ChatMessagesAppendResponse _self;
  final $Res Function(_ChatMessagesAppendResponse) _then;

/// Create a copy of ChatMessagesAppendResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? threadId = null,Object? status = null,Object? appended = null,}) {
  return _then(_ChatMessagesAppendResponse(
threadId: null == threadId ? _self.threadId : threadId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ChatThreadStatus,appended: null == appended ? _self._appended : appended // ignore: cast_nullable_to_non_nullable
as List<ChatMessageView>,
  ));
}


}

// dart format on
