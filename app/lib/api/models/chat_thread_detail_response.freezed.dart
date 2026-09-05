// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_thread_detail_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatThreadDetailResponse {

/// thread
@JsonKey(name: ChatThreadDetailResponse.threadKey_) ChatThreadSummary get thread;/// messages
@JsonKey(name: ChatThreadDetailResponse.messagesKey_) List<ChatMessageV1View>? get messages;/// leadProfile
@JsonKey(name: ChatThreadDetailResponse.leadProfileKey_) Map<String, dynamic>? get leadProfile;
/// Create a copy of ChatThreadDetailResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatThreadDetailResponseCopyWith<ChatThreadDetailResponse> get copyWith => _$ChatThreadDetailResponseCopyWithImpl<ChatThreadDetailResponse>(this as ChatThreadDetailResponse, _$identity);

  /// Serializes this ChatThreadDetailResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatThreadDetailResponse&&(identical(other.thread, thread) || other.thread == thread)&&const DeepCollectionEquality().equals(other.messages, messages)&&const DeepCollectionEquality().equals(other.leadProfile, leadProfile));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,thread,const DeepCollectionEquality().hash(messages),const DeepCollectionEquality().hash(leadProfile));

@override
String toString() {
  return 'ChatThreadDetailResponse(thread: $thread, messages: $messages, leadProfile: $leadProfile)';
}


}

/// @nodoc
abstract mixin class $ChatThreadDetailResponseCopyWith<$Res>  {
  factory $ChatThreadDetailResponseCopyWith(ChatThreadDetailResponse value, $Res Function(ChatThreadDetailResponse) _then) = _$ChatThreadDetailResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ChatThreadDetailResponse.threadKey_) ChatThreadSummary thread,@JsonKey(name: ChatThreadDetailResponse.messagesKey_) List<ChatMessageV1View>? messages,@JsonKey(name: ChatThreadDetailResponse.leadProfileKey_) Map<String, dynamic>? leadProfile
});


$ChatThreadSummaryCopyWith<$Res> get thread;

}
/// @nodoc
class _$ChatThreadDetailResponseCopyWithImpl<$Res>
    implements $ChatThreadDetailResponseCopyWith<$Res> {
  _$ChatThreadDetailResponseCopyWithImpl(this._self, this._then);

  final ChatThreadDetailResponse _self;
  final $Res Function(ChatThreadDetailResponse) _then;

/// Create a copy of ChatThreadDetailResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? thread = null,Object? messages = freezed,Object? leadProfile = freezed,}) {
  return _then(_self.copyWith(
thread: null == thread ? _self.thread : thread // ignore: cast_nullable_to_non_nullable
as ChatThreadSummary,messages: freezed == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<ChatMessageV1View>?,leadProfile: freezed == leadProfile ? _self.leadProfile : leadProfile // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}
/// Create a copy of ChatThreadDetailResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatThreadSummaryCopyWith<$Res> get thread {
  
  return $ChatThreadSummaryCopyWith<$Res>(_self.thread, (value) {
    return _then(_self.copyWith(thread: value));
  });
}
}


/// Adds pattern-matching-related methods to [ChatThreadDetailResponse].
extension ChatThreadDetailResponsePatterns on ChatThreadDetailResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatThreadDetailResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatThreadDetailResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatThreadDetailResponse value)  $default,){
final _that = this;
switch (_that) {
case _ChatThreadDetailResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatThreadDetailResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ChatThreadDetailResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ChatThreadDetailResponse.threadKey_)  ChatThreadSummary thread, @JsonKey(name: ChatThreadDetailResponse.messagesKey_)  List<ChatMessageV1View>? messages, @JsonKey(name: ChatThreadDetailResponse.leadProfileKey_)  Map<String, dynamic>? leadProfile)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatThreadDetailResponse() when $default != null:
return $default(_that.thread,_that.messages,_that.leadProfile);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ChatThreadDetailResponse.threadKey_)  ChatThreadSummary thread, @JsonKey(name: ChatThreadDetailResponse.messagesKey_)  List<ChatMessageV1View>? messages, @JsonKey(name: ChatThreadDetailResponse.leadProfileKey_)  Map<String, dynamic>? leadProfile)  $default,) {final _that = this;
switch (_that) {
case _ChatThreadDetailResponse():
return $default(_that.thread,_that.messages,_that.leadProfile);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ChatThreadDetailResponse.threadKey_)  ChatThreadSummary thread, @JsonKey(name: ChatThreadDetailResponse.messagesKey_)  List<ChatMessageV1View>? messages, @JsonKey(name: ChatThreadDetailResponse.leadProfileKey_)  Map<String, dynamic>? leadProfile)?  $default,) {final _that = this;
switch (_that) {
case _ChatThreadDetailResponse() when $default != null:
return $default(_that.thread,_that.messages,_that.leadProfile);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ChatThreadDetailResponse extends ChatThreadDetailResponse {
  const _ChatThreadDetailResponse({@JsonKey(name: ChatThreadDetailResponse.threadKey_) required this.thread, @JsonKey(name: ChatThreadDetailResponse.messagesKey_) final  List<ChatMessageV1View>? messages, @JsonKey(name: ChatThreadDetailResponse.leadProfileKey_) final  Map<String, dynamic>? leadProfile}): _messages = messages,_leadProfile = leadProfile,super._();
  factory _ChatThreadDetailResponse.fromJson(Map<String, dynamic> json) => _$ChatThreadDetailResponseFromJson(json);

/// thread
@override@JsonKey(name: ChatThreadDetailResponse.threadKey_) final  ChatThreadSummary thread;
/// messages
 final  List<ChatMessageV1View>? _messages;
/// messages
@override@JsonKey(name: ChatThreadDetailResponse.messagesKey_) List<ChatMessageV1View>? get messages {
  final value = _messages;
  if (value == null) return null;
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// leadProfile
 final  Map<String, dynamic>? _leadProfile;
/// leadProfile
@override@JsonKey(name: ChatThreadDetailResponse.leadProfileKey_) Map<String, dynamic>? get leadProfile {
  final value = _leadProfile;
  if (value == null) return null;
  if (_leadProfile is EqualUnmodifiableMapView) return _leadProfile;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of ChatThreadDetailResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatThreadDetailResponseCopyWith<_ChatThreadDetailResponse> get copyWith => __$ChatThreadDetailResponseCopyWithImpl<_ChatThreadDetailResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatThreadDetailResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatThreadDetailResponse&&(identical(other.thread, thread) || other.thread == thread)&&const DeepCollectionEquality().equals(other._messages, _messages)&&const DeepCollectionEquality().equals(other._leadProfile, _leadProfile));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,thread,const DeepCollectionEquality().hash(_messages),const DeepCollectionEquality().hash(_leadProfile));

@override
String toString() {
  return 'ChatThreadDetailResponse(thread: $thread, messages: $messages, leadProfile: $leadProfile)';
}


}

/// @nodoc
abstract mixin class _$ChatThreadDetailResponseCopyWith<$Res> implements $ChatThreadDetailResponseCopyWith<$Res> {
  factory _$ChatThreadDetailResponseCopyWith(_ChatThreadDetailResponse value, $Res Function(_ChatThreadDetailResponse) _then) = __$ChatThreadDetailResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ChatThreadDetailResponse.threadKey_) ChatThreadSummary thread,@JsonKey(name: ChatThreadDetailResponse.messagesKey_) List<ChatMessageV1View>? messages,@JsonKey(name: ChatThreadDetailResponse.leadProfileKey_) Map<String, dynamic>? leadProfile
});


@override $ChatThreadSummaryCopyWith<$Res> get thread;

}
/// @nodoc
class __$ChatThreadDetailResponseCopyWithImpl<$Res>
    implements _$ChatThreadDetailResponseCopyWith<$Res> {
  __$ChatThreadDetailResponseCopyWithImpl(this._self, this._then);

  final _ChatThreadDetailResponse _self;
  final $Res Function(_ChatThreadDetailResponse) _then;

/// Create a copy of ChatThreadDetailResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? thread = null,Object? messages = freezed,Object? leadProfile = freezed,}) {
  return _then(_ChatThreadDetailResponse(
thread: null == thread ? _self.thread : thread // ignore: cast_nullable_to_non_nullable
as ChatThreadSummary,messages: freezed == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<ChatMessageV1View>?,leadProfile: freezed == leadProfile ? _self._leadProfile : leadProfile // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

/// Create a copy of ChatThreadDetailResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatThreadSummaryCopyWith<$Res> get thread {
  
  return $ChatThreadSummaryCopyWith<$Res>(_self.thread, (value) {
    return _then(_self.copyWith(thread: value));
  });
}
}

// dart format on
