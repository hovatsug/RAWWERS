// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_message_create_v1_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatMessageCreateV1Request {

/// content
@JsonKey(name: ChatMessageCreateV1Request.contentKey_) String get content;
/// Create a copy of ChatMessageCreateV1Request
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatMessageCreateV1RequestCopyWith<ChatMessageCreateV1Request> get copyWith => _$ChatMessageCreateV1RequestCopyWithImpl<ChatMessageCreateV1Request>(this as ChatMessageCreateV1Request, _$identity);

  /// Serializes this ChatMessageCreateV1Request to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessageCreateV1Request&&(identical(other.content, content) || other.content == content));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,content);

@override
String toString() {
  return 'ChatMessageCreateV1Request(content: $content)';
}


}

/// @nodoc
abstract mixin class $ChatMessageCreateV1RequestCopyWith<$Res>  {
  factory $ChatMessageCreateV1RequestCopyWith(ChatMessageCreateV1Request value, $Res Function(ChatMessageCreateV1Request) _then) = _$ChatMessageCreateV1RequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ChatMessageCreateV1Request.contentKey_) String content
});




}
/// @nodoc
class _$ChatMessageCreateV1RequestCopyWithImpl<$Res>
    implements $ChatMessageCreateV1RequestCopyWith<$Res> {
  _$ChatMessageCreateV1RequestCopyWithImpl(this._self, this._then);

  final ChatMessageCreateV1Request _self;
  final $Res Function(ChatMessageCreateV1Request) _then;

/// Create a copy of ChatMessageCreateV1Request
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? content = null,}) {
  return _then(_self.copyWith(
content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatMessageCreateV1Request].
extension ChatMessageCreateV1RequestPatterns on ChatMessageCreateV1Request {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatMessageCreateV1Request value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatMessageCreateV1Request() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatMessageCreateV1Request value)  $default,){
final _that = this;
switch (_that) {
case _ChatMessageCreateV1Request():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatMessageCreateV1Request value)?  $default,){
final _that = this;
switch (_that) {
case _ChatMessageCreateV1Request() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ChatMessageCreateV1Request.contentKey_)  String content)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatMessageCreateV1Request() when $default != null:
return $default(_that.content);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ChatMessageCreateV1Request.contentKey_)  String content)  $default,) {final _that = this;
switch (_that) {
case _ChatMessageCreateV1Request():
return $default(_that.content);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ChatMessageCreateV1Request.contentKey_)  String content)?  $default,) {final _that = this;
switch (_that) {
case _ChatMessageCreateV1Request() when $default != null:
return $default(_that.content);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ChatMessageCreateV1Request extends ChatMessageCreateV1Request {
  const _ChatMessageCreateV1Request({@JsonKey(name: ChatMessageCreateV1Request.contentKey_) required this.content}): super._();
  factory _ChatMessageCreateV1Request.fromJson(Map<String, dynamic> json) => _$ChatMessageCreateV1RequestFromJson(json);

/// content
@override@JsonKey(name: ChatMessageCreateV1Request.contentKey_) final  String content;

/// Create a copy of ChatMessageCreateV1Request
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatMessageCreateV1RequestCopyWith<_ChatMessageCreateV1Request> get copyWith => __$ChatMessageCreateV1RequestCopyWithImpl<_ChatMessageCreateV1Request>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatMessageCreateV1RequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatMessageCreateV1Request&&(identical(other.content, content) || other.content == content));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,content);

@override
String toString() {
  return 'ChatMessageCreateV1Request(content: $content)';
}


}

/// @nodoc
abstract mixin class _$ChatMessageCreateV1RequestCopyWith<$Res> implements $ChatMessageCreateV1RequestCopyWith<$Res> {
  factory _$ChatMessageCreateV1RequestCopyWith(_ChatMessageCreateV1Request value, $Res Function(_ChatMessageCreateV1Request) _then) = __$ChatMessageCreateV1RequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ChatMessageCreateV1Request.contentKey_) String content
});




}
/// @nodoc
class __$ChatMessageCreateV1RequestCopyWithImpl<$Res>
    implements _$ChatMessageCreateV1RequestCopyWith<$Res> {
  __$ChatMessageCreateV1RequestCopyWithImpl(this._self, this._then);

  final _ChatMessageCreateV1Request _self;
  final $Res Function(_ChatMessageCreateV1Request) _then;

/// Create a copy of ChatMessageCreateV1Request
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? content = null,}) {
  return _then(_ChatMessageCreateV1Request(
content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
