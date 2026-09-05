// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_message_create_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatMessageCreateRequest {

/// content
@JsonKey(name: ChatMessageCreateRequest.contentKey_) String get content;
/// Create a copy of ChatMessageCreateRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatMessageCreateRequestCopyWith<ChatMessageCreateRequest> get copyWith => _$ChatMessageCreateRequestCopyWithImpl<ChatMessageCreateRequest>(this as ChatMessageCreateRequest, _$identity);

  /// Serializes this ChatMessageCreateRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessageCreateRequest&&(identical(other.content, content) || other.content == content));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,content);

@override
String toString() {
  return 'ChatMessageCreateRequest(content: $content)';
}


}

/// @nodoc
abstract mixin class $ChatMessageCreateRequestCopyWith<$Res>  {
  factory $ChatMessageCreateRequestCopyWith(ChatMessageCreateRequest value, $Res Function(ChatMessageCreateRequest) _then) = _$ChatMessageCreateRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ChatMessageCreateRequest.contentKey_) String content
});




}
/// @nodoc
class _$ChatMessageCreateRequestCopyWithImpl<$Res>
    implements $ChatMessageCreateRequestCopyWith<$Res> {
  _$ChatMessageCreateRequestCopyWithImpl(this._self, this._then);

  final ChatMessageCreateRequest _self;
  final $Res Function(ChatMessageCreateRequest) _then;

/// Create a copy of ChatMessageCreateRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? content = null,}) {
  return _then(_self.copyWith(
content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatMessageCreateRequest].
extension ChatMessageCreateRequestPatterns on ChatMessageCreateRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatMessageCreateRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatMessageCreateRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatMessageCreateRequest value)  $default,){
final _that = this;
switch (_that) {
case _ChatMessageCreateRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatMessageCreateRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ChatMessageCreateRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ChatMessageCreateRequest.contentKey_)  String content)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatMessageCreateRequest() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ChatMessageCreateRequest.contentKey_)  String content)  $default,) {final _that = this;
switch (_that) {
case _ChatMessageCreateRequest():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ChatMessageCreateRequest.contentKey_)  String content)?  $default,) {final _that = this;
switch (_that) {
case _ChatMessageCreateRequest() when $default != null:
return $default(_that.content);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ChatMessageCreateRequest extends ChatMessageCreateRequest {
  const _ChatMessageCreateRequest({@JsonKey(name: ChatMessageCreateRequest.contentKey_) required this.content}): super._();
  factory _ChatMessageCreateRequest.fromJson(Map<String, dynamic> json) => _$ChatMessageCreateRequestFromJson(json);

/// content
@override@JsonKey(name: ChatMessageCreateRequest.contentKey_) final  String content;

/// Create a copy of ChatMessageCreateRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatMessageCreateRequestCopyWith<_ChatMessageCreateRequest> get copyWith => __$ChatMessageCreateRequestCopyWithImpl<_ChatMessageCreateRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatMessageCreateRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatMessageCreateRequest&&(identical(other.content, content) || other.content == content));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,content);

@override
String toString() {
  return 'ChatMessageCreateRequest(content: $content)';
}


}

/// @nodoc
abstract mixin class _$ChatMessageCreateRequestCopyWith<$Res> implements $ChatMessageCreateRequestCopyWith<$Res> {
  factory _$ChatMessageCreateRequestCopyWith(_ChatMessageCreateRequest value, $Res Function(_ChatMessageCreateRequest) _then) = __$ChatMessageCreateRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ChatMessageCreateRequest.contentKey_) String content
});




}
/// @nodoc
class __$ChatMessageCreateRequestCopyWithImpl<$Res>
    implements _$ChatMessageCreateRequestCopyWith<$Res> {
  __$ChatMessageCreateRequestCopyWithImpl(this._self, this._then);

  final _ChatMessageCreateRequest _self;
  final $Res Function(_ChatMessageCreateRequest) _then;

/// Create a copy of ChatMessageCreateRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? content = null,}) {
  return _then(_ChatMessageCreateRequest(
content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
