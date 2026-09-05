// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_thread_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatThreadView {

/// id
@JsonKey(name: ChatThreadView.idKey_) String get id;/// proUserId
@JsonKey(name: ChatThreadView.proUserIdKey_) String get proUserId;/// clientUserId
@JsonKey(name: ChatThreadView.clientUserIdKey_) String get clientUserId;/// status
@JsonKey(name: ChatThreadView.statusKey_) ChatThreadStatus get status;/// contextSnapshot
@JsonKey(name: ChatThreadView.contextSnapshotKey_) Map<String, dynamic> get contextSnapshot;/// tokenBudgetUsed
@JsonKey(name: ChatThreadView.tokenBudgetUsedKey_) int get tokenBudgetUsed;/// createdAt
@JsonKey(name: ChatThreadView.createdAtKey_) DateTime get createdAt;/// updatedAt
@JsonKey(name: ChatThreadView.updatedAtKey_) DateTime get updatedAt;/// messages
@JsonKey(name: ChatThreadView.messagesKey_) List<ChatMessageView>? get messages;
/// Create a copy of ChatThreadView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatThreadViewCopyWith<ChatThreadView> get copyWith => _$ChatThreadViewCopyWithImpl<ChatThreadView>(this as ChatThreadView, _$identity);

  /// Serializes this ChatThreadView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatThreadView&&(identical(other.id, id) || other.id == id)&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.clientUserId, clientUserId) || other.clientUserId == clientUserId)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.contextSnapshot, contextSnapshot)&&(identical(other.tokenBudgetUsed, tokenBudgetUsed) || other.tokenBudgetUsed == tokenBudgetUsed)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.messages, messages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,proUserId,clientUserId,status,const DeepCollectionEquality().hash(contextSnapshot),tokenBudgetUsed,createdAt,updatedAt,const DeepCollectionEquality().hash(messages));

@override
String toString() {
  return 'ChatThreadView(id: $id, proUserId: $proUserId, clientUserId: $clientUserId, status: $status, contextSnapshot: $contextSnapshot, tokenBudgetUsed: $tokenBudgetUsed, createdAt: $createdAt, updatedAt: $updatedAt, messages: $messages)';
}


}

/// @nodoc
abstract mixin class $ChatThreadViewCopyWith<$Res>  {
  factory $ChatThreadViewCopyWith(ChatThreadView value, $Res Function(ChatThreadView) _then) = _$ChatThreadViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ChatThreadView.idKey_) String id,@JsonKey(name: ChatThreadView.proUserIdKey_) String proUserId,@JsonKey(name: ChatThreadView.clientUserIdKey_) String clientUserId,@JsonKey(name: ChatThreadView.statusKey_) ChatThreadStatus status,@JsonKey(name: ChatThreadView.contextSnapshotKey_) Map<String, dynamic> contextSnapshot,@JsonKey(name: ChatThreadView.tokenBudgetUsedKey_) int tokenBudgetUsed,@JsonKey(name: ChatThreadView.createdAtKey_) DateTime createdAt,@JsonKey(name: ChatThreadView.updatedAtKey_) DateTime updatedAt,@JsonKey(name: ChatThreadView.messagesKey_) List<ChatMessageView>? messages
});




}
/// @nodoc
class _$ChatThreadViewCopyWithImpl<$Res>
    implements $ChatThreadViewCopyWith<$Res> {
  _$ChatThreadViewCopyWithImpl(this._self, this._then);

  final ChatThreadView _self;
  final $Res Function(ChatThreadView) _then;

/// Create a copy of ChatThreadView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? proUserId = null,Object? clientUserId = null,Object? status = null,Object? contextSnapshot = null,Object? tokenBudgetUsed = null,Object? createdAt = null,Object? updatedAt = null,Object? messages = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,clientUserId: null == clientUserId ? _self.clientUserId : clientUserId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ChatThreadStatus,contextSnapshot: null == contextSnapshot ? _self.contextSnapshot : contextSnapshot // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,tokenBudgetUsed: null == tokenBudgetUsed ? _self.tokenBudgetUsed : tokenBudgetUsed // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,messages: freezed == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<ChatMessageView>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatThreadView].
extension ChatThreadViewPatterns on ChatThreadView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatThreadView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatThreadView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatThreadView value)  $default,){
final _that = this;
switch (_that) {
case _ChatThreadView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatThreadView value)?  $default,){
final _that = this;
switch (_that) {
case _ChatThreadView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ChatThreadView.idKey_)  String id, @JsonKey(name: ChatThreadView.proUserIdKey_)  String proUserId, @JsonKey(name: ChatThreadView.clientUserIdKey_)  String clientUserId, @JsonKey(name: ChatThreadView.statusKey_)  ChatThreadStatus status, @JsonKey(name: ChatThreadView.contextSnapshotKey_)  Map<String, dynamic> contextSnapshot, @JsonKey(name: ChatThreadView.tokenBudgetUsedKey_)  int tokenBudgetUsed, @JsonKey(name: ChatThreadView.createdAtKey_)  DateTime createdAt, @JsonKey(name: ChatThreadView.updatedAtKey_)  DateTime updatedAt, @JsonKey(name: ChatThreadView.messagesKey_)  List<ChatMessageView>? messages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatThreadView() when $default != null:
return $default(_that.id,_that.proUserId,_that.clientUserId,_that.status,_that.contextSnapshot,_that.tokenBudgetUsed,_that.createdAt,_that.updatedAt,_that.messages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ChatThreadView.idKey_)  String id, @JsonKey(name: ChatThreadView.proUserIdKey_)  String proUserId, @JsonKey(name: ChatThreadView.clientUserIdKey_)  String clientUserId, @JsonKey(name: ChatThreadView.statusKey_)  ChatThreadStatus status, @JsonKey(name: ChatThreadView.contextSnapshotKey_)  Map<String, dynamic> contextSnapshot, @JsonKey(name: ChatThreadView.tokenBudgetUsedKey_)  int tokenBudgetUsed, @JsonKey(name: ChatThreadView.createdAtKey_)  DateTime createdAt, @JsonKey(name: ChatThreadView.updatedAtKey_)  DateTime updatedAt, @JsonKey(name: ChatThreadView.messagesKey_)  List<ChatMessageView>? messages)  $default,) {final _that = this;
switch (_that) {
case _ChatThreadView():
return $default(_that.id,_that.proUserId,_that.clientUserId,_that.status,_that.contextSnapshot,_that.tokenBudgetUsed,_that.createdAt,_that.updatedAt,_that.messages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ChatThreadView.idKey_)  String id, @JsonKey(name: ChatThreadView.proUserIdKey_)  String proUserId, @JsonKey(name: ChatThreadView.clientUserIdKey_)  String clientUserId, @JsonKey(name: ChatThreadView.statusKey_)  ChatThreadStatus status, @JsonKey(name: ChatThreadView.contextSnapshotKey_)  Map<String, dynamic> contextSnapshot, @JsonKey(name: ChatThreadView.tokenBudgetUsedKey_)  int tokenBudgetUsed, @JsonKey(name: ChatThreadView.createdAtKey_)  DateTime createdAt, @JsonKey(name: ChatThreadView.updatedAtKey_)  DateTime updatedAt, @JsonKey(name: ChatThreadView.messagesKey_)  List<ChatMessageView>? messages)?  $default,) {final _that = this;
switch (_that) {
case _ChatThreadView() when $default != null:
return $default(_that.id,_that.proUserId,_that.clientUserId,_that.status,_that.contextSnapshot,_that.tokenBudgetUsed,_that.createdAt,_that.updatedAt,_that.messages);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ChatThreadView extends ChatThreadView {
  const _ChatThreadView({@JsonKey(name: ChatThreadView.idKey_) required this.id, @JsonKey(name: ChatThreadView.proUserIdKey_) required this.proUserId, @JsonKey(name: ChatThreadView.clientUserIdKey_) required this.clientUserId, @JsonKey(name: ChatThreadView.statusKey_) required this.status, @JsonKey(name: ChatThreadView.contextSnapshotKey_) required final  Map<String, dynamic> contextSnapshot, @JsonKey(name: ChatThreadView.tokenBudgetUsedKey_) required this.tokenBudgetUsed, @JsonKey(name: ChatThreadView.createdAtKey_) required this.createdAt, @JsonKey(name: ChatThreadView.updatedAtKey_) required this.updatedAt, @JsonKey(name: ChatThreadView.messagesKey_) final  List<ChatMessageView>? messages}): _contextSnapshot = contextSnapshot,_messages = messages,super._();
  factory _ChatThreadView.fromJson(Map<String, dynamic> json) => _$ChatThreadViewFromJson(json);

/// id
@override@JsonKey(name: ChatThreadView.idKey_) final  String id;
/// proUserId
@override@JsonKey(name: ChatThreadView.proUserIdKey_) final  String proUserId;
/// clientUserId
@override@JsonKey(name: ChatThreadView.clientUserIdKey_) final  String clientUserId;
/// status
@override@JsonKey(name: ChatThreadView.statusKey_) final  ChatThreadStatus status;
/// contextSnapshot
 final  Map<String, dynamic> _contextSnapshot;
/// contextSnapshot
@override@JsonKey(name: ChatThreadView.contextSnapshotKey_) Map<String, dynamic> get contextSnapshot {
  if (_contextSnapshot is EqualUnmodifiableMapView) return _contextSnapshot;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_contextSnapshot);
}

/// tokenBudgetUsed
@override@JsonKey(name: ChatThreadView.tokenBudgetUsedKey_) final  int tokenBudgetUsed;
/// createdAt
@override@JsonKey(name: ChatThreadView.createdAtKey_) final  DateTime createdAt;
/// updatedAt
@override@JsonKey(name: ChatThreadView.updatedAtKey_) final  DateTime updatedAt;
/// messages
 final  List<ChatMessageView>? _messages;
/// messages
@override@JsonKey(name: ChatThreadView.messagesKey_) List<ChatMessageView>? get messages {
  final value = _messages;
  if (value == null) return null;
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ChatThreadView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatThreadViewCopyWith<_ChatThreadView> get copyWith => __$ChatThreadViewCopyWithImpl<_ChatThreadView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatThreadViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatThreadView&&(identical(other.id, id) || other.id == id)&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.clientUserId, clientUserId) || other.clientUserId == clientUserId)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._contextSnapshot, _contextSnapshot)&&(identical(other.tokenBudgetUsed, tokenBudgetUsed) || other.tokenBudgetUsed == tokenBudgetUsed)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._messages, _messages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,proUserId,clientUserId,status,const DeepCollectionEquality().hash(_contextSnapshot),tokenBudgetUsed,createdAt,updatedAt,const DeepCollectionEquality().hash(_messages));

@override
String toString() {
  return 'ChatThreadView(id: $id, proUserId: $proUserId, clientUserId: $clientUserId, status: $status, contextSnapshot: $contextSnapshot, tokenBudgetUsed: $tokenBudgetUsed, createdAt: $createdAt, updatedAt: $updatedAt, messages: $messages)';
}


}

/// @nodoc
abstract mixin class _$ChatThreadViewCopyWith<$Res> implements $ChatThreadViewCopyWith<$Res> {
  factory _$ChatThreadViewCopyWith(_ChatThreadView value, $Res Function(_ChatThreadView) _then) = __$ChatThreadViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ChatThreadView.idKey_) String id,@JsonKey(name: ChatThreadView.proUserIdKey_) String proUserId,@JsonKey(name: ChatThreadView.clientUserIdKey_) String clientUserId,@JsonKey(name: ChatThreadView.statusKey_) ChatThreadStatus status,@JsonKey(name: ChatThreadView.contextSnapshotKey_) Map<String, dynamic> contextSnapshot,@JsonKey(name: ChatThreadView.tokenBudgetUsedKey_) int tokenBudgetUsed,@JsonKey(name: ChatThreadView.createdAtKey_) DateTime createdAt,@JsonKey(name: ChatThreadView.updatedAtKey_) DateTime updatedAt,@JsonKey(name: ChatThreadView.messagesKey_) List<ChatMessageView>? messages
});




}
/// @nodoc
class __$ChatThreadViewCopyWithImpl<$Res>
    implements _$ChatThreadViewCopyWith<$Res> {
  __$ChatThreadViewCopyWithImpl(this._self, this._then);

  final _ChatThreadView _self;
  final $Res Function(_ChatThreadView) _then;

/// Create a copy of ChatThreadView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? proUserId = null,Object? clientUserId = null,Object? status = null,Object? contextSnapshot = null,Object? tokenBudgetUsed = null,Object? createdAt = null,Object? updatedAt = null,Object? messages = freezed,}) {
  return _then(_ChatThreadView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,clientUserId: null == clientUserId ? _self.clientUserId : clientUserId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ChatThreadStatus,contextSnapshot: null == contextSnapshot ? _self._contextSnapshot : contextSnapshot // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,tokenBudgetUsed: null == tokenBudgetUsed ? _self.tokenBudgetUsed : tokenBudgetUsed // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,messages: freezed == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<ChatMessageView>?,
  ));
}


}

// dart format on
