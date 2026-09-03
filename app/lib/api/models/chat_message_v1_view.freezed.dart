// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_message_v1_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatMessageV1View {

/// id
@JsonKey(name: ChatMessageV1View.idKey_) String get id;/// threadId
@JsonKey(name: ChatMessageV1View.threadIdKey_) String get threadId;/// senderType
@JsonKey(name: ChatMessageV1View.senderTypeKey_) ChatSenderType get senderType;/// senderUserId
@JsonKey(name: ChatMessageV1View.senderUserIdKey_) String? get senderUserId;/// content
@JsonKey(name: ChatMessageV1View.contentKey_) String get content;/// metadata
@JsonKey(name: ChatMessageV1View.metadataKey_) Map<String, dynamic>? get metadata;/// createdAt
@JsonKey(name: ChatMessageV1View.createdAtKey_) DateTime get createdAt;
/// Create a copy of ChatMessageV1View
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatMessageV1ViewCopyWith<ChatMessageV1View> get copyWith => _$ChatMessageV1ViewCopyWithImpl<ChatMessageV1View>(this as ChatMessageV1View, _$identity);

  /// Serializes this ChatMessageV1View to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessageV1View&&(identical(other.id, id) || other.id == id)&&(identical(other.threadId, threadId) || other.threadId == threadId)&&(identical(other.senderType, senderType) || other.senderType == senderType)&&(identical(other.senderUserId, senderUserId) || other.senderUserId == senderUserId)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,threadId,senderType,senderUserId,content,const DeepCollectionEquality().hash(metadata),createdAt);

@override
String toString() {
  return 'ChatMessageV1View(id: $id, threadId: $threadId, senderType: $senderType, senderUserId: $senderUserId, content: $content, metadata: $metadata, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ChatMessageV1ViewCopyWith<$Res>  {
  factory $ChatMessageV1ViewCopyWith(ChatMessageV1View value, $Res Function(ChatMessageV1View) _then) = _$ChatMessageV1ViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ChatMessageV1View.idKey_) String id,@JsonKey(name: ChatMessageV1View.threadIdKey_) String threadId,@JsonKey(name: ChatMessageV1View.senderTypeKey_) ChatSenderType senderType,@JsonKey(name: ChatMessageV1View.senderUserIdKey_) String? senderUserId,@JsonKey(name: ChatMessageV1View.contentKey_) String content,@JsonKey(name: ChatMessageV1View.metadataKey_) Map<String, dynamic>? metadata,@JsonKey(name: ChatMessageV1View.createdAtKey_) DateTime createdAt
});




}
/// @nodoc
class _$ChatMessageV1ViewCopyWithImpl<$Res>
    implements $ChatMessageV1ViewCopyWith<$Res> {
  _$ChatMessageV1ViewCopyWithImpl(this._self, this._then);

  final ChatMessageV1View _self;
  final $Res Function(ChatMessageV1View) _then;

/// Create a copy of ChatMessageV1View
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? threadId = null,Object? senderType = null,Object? senderUserId = freezed,Object? content = null,Object? metadata = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,threadId: null == threadId ? _self.threadId : threadId // ignore: cast_nullable_to_non_nullable
as String,senderType: null == senderType ? _self.senderType : senderType // ignore: cast_nullable_to_non_nullable
as ChatSenderType,senderUserId: freezed == senderUserId ? _self.senderUserId : senderUserId // ignore: cast_nullable_to_non_nullable
as String?,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatMessageV1View].
extension ChatMessageV1ViewPatterns on ChatMessageV1View {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatMessageV1View value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatMessageV1View() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatMessageV1View value)  $default,){
final _that = this;
switch (_that) {
case _ChatMessageV1View():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatMessageV1View value)?  $default,){
final _that = this;
switch (_that) {
case _ChatMessageV1View() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ChatMessageV1View.idKey_)  String id, @JsonKey(name: ChatMessageV1View.threadIdKey_)  String threadId, @JsonKey(name: ChatMessageV1View.senderTypeKey_)  ChatSenderType senderType, @JsonKey(name: ChatMessageV1View.senderUserIdKey_)  String? senderUserId, @JsonKey(name: ChatMessageV1View.contentKey_)  String content, @JsonKey(name: ChatMessageV1View.metadataKey_)  Map<String, dynamic>? metadata, @JsonKey(name: ChatMessageV1View.createdAtKey_)  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatMessageV1View() when $default != null:
return $default(_that.id,_that.threadId,_that.senderType,_that.senderUserId,_that.content,_that.metadata,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ChatMessageV1View.idKey_)  String id, @JsonKey(name: ChatMessageV1View.threadIdKey_)  String threadId, @JsonKey(name: ChatMessageV1View.senderTypeKey_)  ChatSenderType senderType, @JsonKey(name: ChatMessageV1View.senderUserIdKey_)  String? senderUserId, @JsonKey(name: ChatMessageV1View.contentKey_)  String content, @JsonKey(name: ChatMessageV1View.metadataKey_)  Map<String, dynamic>? metadata, @JsonKey(name: ChatMessageV1View.createdAtKey_)  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _ChatMessageV1View():
return $default(_that.id,_that.threadId,_that.senderType,_that.senderUserId,_that.content,_that.metadata,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ChatMessageV1View.idKey_)  String id, @JsonKey(name: ChatMessageV1View.threadIdKey_)  String threadId, @JsonKey(name: ChatMessageV1View.senderTypeKey_)  ChatSenderType senderType, @JsonKey(name: ChatMessageV1View.senderUserIdKey_)  String? senderUserId, @JsonKey(name: ChatMessageV1View.contentKey_)  String content, @JsonKey(name: ChatMessageV1View.metadataKey_)  Map<String, dynamic>? metadata, @JsonKey(name: ChatMessageV1View.createdAtKey_)  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ChatMessageV1View() when $default != null:
return $default(_that.id,_that.threadId,_that.senderType,_that.senderUserId,_that.content,_that.metadata,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ChatMessageV1View extends ChatMessageV1View {
  const _ChatMessageV1View({@JsonKey(name: ChatMessageV1View.idKey_) required this.id, @JsonKey(name: ChatMessageV1View.threadIdKey_) required this.threadId, @JsonKey(name: ChatMessageV1View.senderTypeKey_) required this.senderType, @JsonKey(name: ChatMessageV1View.senderUserIdKey_) this.senderUserId, @JsonKey(name: ChatMessageV1View.contentKey_) required this.content, @JsonKey(name: ChatMessageV1View.metadataKey_) final  Map<String, dynamic>? metadata, @JsonKey(name: ChatMessageV1View.createdAtKey_) required this.createdAt}): _metadata = metadata,super._();
  factory _ChatMessageV1View.fromJson(Map<String, dynamic> json) => _$ChatMessageV1ViewFromJson(json);

/// id
@override@JsonKey(name: ChatMessageV1View.idKey_) final  String id;
/// threadId
@override@JsonKey(name: ChatMessageV1View.threadIdKey_) final  String threadId;
/// senderType
@override@JsonKey(name: ChatMessageV1View.senderTypeKey_) final  ChatSenderType senderType;
/// senderUserId
@override@JsonKey(name: ChatMessageV1View.senderUserIdKey_) final  String? senderUserId;
/// content
@override@JsonKey(name: ChatMessageV1View.contentKey_) final  String content;
/// metadata
 final  Map<String, dynamic>? _metadata;
/// metadata
@override@JsonKey(name: ChatMessageV1View.metadataKey_) Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// createdAt
@override@JsonKey(name: ChatMessageV1View.createdAtKey_) final  DateTime createdAt;

/// Create a copy of ChatMessageV1View
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatMessageV1ViewCopyWith<_ChatMessageV1View> get copyWith => __$ChatMessageV1ViewCopyWithImpl<_ChatMessageV1View>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatMessageV1ViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatMessageV1View&&(identical(other.id, id) || other.id == id)&&(identical(other.threadId, threadId) || other.threadId == threadId)&&(identical(other.senderType, senderType) || other.senderType == senderType)&&(identical(other.senderUserId, senderUserId) || other.senderUserId == senderUserId)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,threadId,senderType,senderUserId,content,const DeepCollectionEquality().hash(_metadata),createdAt);

@override
String toString() {
  return 'ChatMessageV1View(id: $id, threadId: $threadId, senderType: $senderType, senderUserId: $senderUserId, content: $content, metadata: $metadata, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ChatMessageV1ViewCopyWith<$Res> implements $ChatMessageV1ViewCopyWith<$Res> {
  factory _$ChatMessageV1ViewCopyWith(_ChatMessageV1View value, $Res Function(_ChatMessageV1View) _then) = __$ChatMessageV1ViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ChatMessageV1View.idKey_) String id,@JsonKey(name: ChatMessageV1View.threadIdKey_) String threadId,@JsonKey(name: ChatMessageV1View.senderTypeKey_) ChatSenderType senderType,@JsonKey(name: ChatMessageV1View.senderUserIdKey_) String? senderUserId,@JsonKey(name: ChatMessageV1View.contentKey_) String content,@JsonKey(name: ChatMessageV1View.metadataKey_) Map<String, dynamic>? metadata,@JsonKey(name: ChatMessageV1View.createdAtKey_) DateTime createdAt
});




}
/// @nodoc
class __$ChatMessageV1ViewCopyWithImpl<$Res>
    implements _$ChatMessageV1ViewCopyWith<$Res> {
  __$ChatMessageV1ViewCopyWithImpl(this._self, this._then);

  final _ChatMessageV1View _self;
  final $Res Function(_ChatMessageV1View) _then;

/// Create a copy of ChatMessageV1View
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? threadId = null,Object? senderType = null,Object? senderUserId = freezed,Object? content = null,Object? metadata = freezed,Object? createdAt = null,}) {
  return _then(_ChatMessageV1View(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,threadId: null == threadId ? _self.threadId : threadId // ignore: cast_nullable_to_non_nullable
as String,senderType: null == senderType ? _self.senderType : senderType // ignore: cast_nullable_to_non_nullable
as ChatSenderType,senderUserId: freezed == senderUserId ? _self.senderUserId : senderUserId // ignore: cast_nullable_to_non_nullable
as String?,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
