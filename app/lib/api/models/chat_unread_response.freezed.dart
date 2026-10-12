// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_unread_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatUnreadResponse {

/// threads
@JsonKey(name: ChatUnreadResponse.threadsKey_) int get threads;/// messages
@JsonKey(name: ChatUnreadResponse.messagesKey_) int get messages;
/// Create a copy of ChatUnreadResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatUnreadResponseCopyWith<ChatUnreadResponse> get copyWith => _$ChatUnreadResponseCopyWithImpl<ChatUnreadResponse>(this as ChatUnreadResponse, _$identity);

  /// Serializes this ChatUnreadResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatUnreadResponse&&(identical(other.threads, threads) || other.threads == threads)&&(identical(other.messages, messages) || other.messages == messages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,threads,messages);

@override
String toString() {
  return 'ChatUnreadResponse(threads: $threads, messages: $messages)';
}


}

/// @nodoc
abstract mixin class $ChatUnreadResponseCopyWith<$Res>  {
  factory $ChatUnreadResponseCopyWith(ChatUnreadResponse value, $Res Function(ChatUnreadResponse) _then) = _$ChatUnreadResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ChatUnreadResponse.threadsKey_) int threads,@JsonKey(name: ChatUnreadResponse.messagesKey_) int messages
});




}
/// @nodoc
class _$ChatUnreadResponseCopyWithImpl<$Res>
    implements $ChatUnreadResponseCopyWith<$Res> {
  _$ChatUnreadResponseCopyWithImpl(this._self, this._then);

  final ChatUnreadResponse _self;
  final $Res Function(ChatUnreadResponse) _then;

/// Create a copy of ChatUnreadResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? threads = null,Object? messages = null,}) {
  return _then(_self.copyWith(
threads: null == threads ? _self.threads : threads // ignore: cast_nullable_to_non_nullable
as int,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatUnreadResponse].
extension ChatUnreadResponsePatterns on ChatUnreadResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatUnreadResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatUnreadResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatUnreadResponse value)  $default,){
final _that = this;
switch (_that) {
case _ChatUnreadResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatUnreadResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ChatUnreadResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ChatUnreadResponse.threadsKey_)  int threads, @JsonKey(name: ChatUnreadResponse.messagesKey_)  int messages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatUnreadResponse() when $default != null:
return $default(_that.threads,_that.messages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ChatUnreadResponse.threadsKey_)  int threads, @JsonKey(name: ChatUnreadResponse.messagesKey_)  int messages)  $default,) {final _that = this;
switch (_that) {
case _ChatUnreadResponse():
return $default(_that.threads,_that.messages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ChatUnreadResponse.threadsKey_)  int threads, @JsonKey(name: ChatUnreadResponse.messagesKey_)  int messages)?  $default,) {final _that = this;
switch (_that) {
case _ChatUnreadResponse() when $default != null:
return $default(_that.threads,_that.messages);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ChatUnreadResponse extends ChatUnreadResponse {
  const _ChatUnreadResponse({@JsonKey(name: ChatUnreadResponse.threadsKey_) required this.threads, @JsonKey(name: ChatUnreadResponse.messagesKey_) required this.messages}): super._();
  factory _ChatUnreadResponse.fromJson(Map<String, dynamic> json) => _$ChatUnreadResponseFromJson(json);

/// threads
@override@JsonKey(name: ChatUnreadResponse.threadsKey_) final  int threads;
/// messages
@override@JsonKey(name: ChatUnreadResponse.messagesKey_) final  int messages;

/// Create a copy of ChatUnreadResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatUnreadResponseCopyWith<_ChatUnreadResponse> get copyWith => __$ChatUnreadResponseCopyWithImpl<_ChatUnreadResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatUnreadResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatUnreadResponse&&(identical(other.threads, threads) || other.threads == threads)&&(identical(other.messages, messages) || other.messages == messages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,threads,messages);

@override
String toString() {
  return 'ChatUnreadResponse(threads: $threads, messages: $messages)';
}


}

/// @nodoc
abstract mixin class _$ChatUnreadResponseCopyWith<$Res> implements $ChatUnreadResponseCopyWith<$Res> {
  factory _$ChatUnreadResponseCopyWith(_ChatUnreadResponse value, $Res Function(_ChatUnreadResponse) _then) = __$ChatUnreadResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ChatUnreadResponse.threadsKey_) int threads,@JsonKey(name: ChatUnreadResponse.messagesKey_) int messages
});




}
/// @nodoc
class __$ChatUnreadResponseCopyWithImpl<$Res>
    implements _$ChatUnreadResponseCopyWith<$Res> {
  __$ChatUnreadResponseCopyWithImpl(this._self, this._then);

  final _ChatUnreadResponse _self;
  final $Res Function(_ChatUnreadResponse) _then;

/// Create a copy of ChatUnreadResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? threads = null,Object? messages = null,}) {
  return _then(_ChatUnreadResponse(
threads: null == threads ? _self.threads : threads // ignore: cast_nullable_to_non_nullable
as int,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
