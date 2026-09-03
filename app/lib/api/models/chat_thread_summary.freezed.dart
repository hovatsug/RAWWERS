// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_thread_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatThreadSummary {

/// id
@JsonKey(name: ChatThreadSummary.idKey_) String get id;/// proUserId
@JsonKey(name: ChatThreadSummary.proUserIdKey_) String get proUserId;/// clientUserId
@JsonKey(name: ChatThreadSummary.clientUserIdKey_) String? get clientUserId;/// sessionId
@JsonKey(name: ChatThreadSummary.sessionIdKey_) String? get sessionId;/// status
@JsonKey(name: ChatThreadSummary.statusKey_) ChatThreadStatus get status;/// createdAt
@JsonKey(name: ChatThreadSummary.createdAtKey_) DateTime get createdAt;/// updatedAt
@JsonKey(name: ChatThreadSummary.updatedAtKey_) DateTime get updatedAt;
/// Create a copy of ChatThreadSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatThreadSummaryCopyWith<ChatThreadSummary> get copyWith => _$ChatThreadSummaryCopyWithImpl<ChatThreadSummary>(this as ChatThreadSummary, _$identity);

  /// Serializes this ChatThreadSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatThreadSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.clientUserId, clientUserId) || other.clientUserId == clientUserId)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,proUserId,clientUserId,sessionId,status,createdAt,updatedAt);

@override
String toString() {
  return 'ChatThreadSummary(id: $id, proUserId: $proUserId, clientUserId: $clientUserId, sessionId: $sessionId, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ChatThreadSummaryCopyWith<$Res>  {
  factory $ChatThreadSummaryCopyWith(ChatThreadSummary value, $Res Function(ChatThreadSummary) _then) = _$ChatThreadSummaryCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ChatThreadSummary.idKey_) String id,@JsonKey(name: ChatThreadSummary.proUserIdKey_) String proUserId,@JsonKey(name: ChatThreadSummary.clientUserIdKey_) String? clientUserId,@JsonKey(name: ChatThreadSummary.sessionIdKey_) String? sessionId,@JsonKey(name: ChatThreadSummary.statusKey_) ChatThreadStatus status,@JsonKey(name: ChatThreadSummary.createdAtKey_) DateTime createdAt,@JsonKey(name: ChatThreadSummary.updatedAtKey_) DateTime updatedAt
});




}
/// @nodoc
class _$ChatThreadSummaryCopyWithImpl<$Res>
    implements $ChatThreadSummaryCopyWith<$Res> {
  _$ChatThreadSummaryCopyWithImpl(this._self, this._then);

  final ChatThreadSummary _self;
  final $Res Function(ChatThreadSummary) _then;

/// Create a copy of ChatThreadSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? proUserId = null,Object? clientUserId = freezed,Object? sessionId = freezed,Object? status = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,clientUserId: freezed == clientUserId ? _self.clientUserId : clientUserId // ignore: cast_nullable_to_non_nullable
as String?,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ChatThreadStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatThreadSummary].
extension ChatThreadSummaryPatterns on ChatThreadSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatThreadSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatThreadSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatThreadSummary value)  $default,){
final _that = this;
switch (_that) {
case _ChatThreadSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatThreadSummary value)?  $default,){
final _that = this;
switch (_that) {
case _ChatThreadSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ChatThreadSummary.idKey_)  String id, @JsonKey(name: ChatThreadSummary.proUserIdKey_)  String proUserId, @JsonKey(name: ChatThreadSummary.clientUserIdKey_)  String? clientUserId, @JsonKey(name: ChatThreadSummary.sessionIdKey_)  String? sessionId, @JsonKey(name: ChatThreadSummary.statusKey_)  ChatThreadStatus status, @JsonKey(name: ChatThreadSummary.createdAtKey_)  DateTime createdAt, @JsonKey(name: ChatThreadSummary.updatedAtKey_)  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatThreadSummary() when $default != null:
return $default(_that.id,_that.proUserId,_that.clientUserId,_that.sessionId,_that.status,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ChatThreadSummary.idKey_)  String id, @JsonKey(name: ChatThreadSummary.proUserIdKey_)  String proUserId, @JsonKey(name: ChatThreadSummary.clientUserIdKey_)  String? clientUserId, @JsonKey(name: ChatThreadSummary.sessionIdKey_)  String? sessionId, @JsonKey(name: ChatThreadSummary.statusKey_)  ChatThreadStatus status, @JsonKey(name: ChatThreadSummary.createdAtKey_)  DateTime createdAt, @JsonKey(name: ChatThreadSummary.updatedAtKey_)  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ChatThreadSummary():
return $default(_that.id,_that.proUserId,_that.clientUserId,_that.sessionId,_that.status,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ChatThreadSummary.idKey_)  String id, @JsonKey(name: ChatThreadSummary.proUserIdKey_)  String proUserId, @JsonKey(name: ChatThreadSummary.clientUserIdKey_)  String? clientUserId, @JsonKey(name: ChatThreadSummary.sessionIdKey_)  String? sessionId, @JsonKey(name: ChatThreadSummary.statusKey_)  ChatThreadStatus status, @JsonKey(name: ChatThreadSummary.createdAtKey_)  DateTime createdAt, @JsonKey(name: ChatThreadSummary.updatedAtKey_)  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ChatThreadSummary() when $default != null:
return $default(_that.id,_that.proUserId,_that.clientUserId,_that.sessionId,_that.status,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ChatThreadSummary extends ChatThreadSummary {
  const _ChatThreadSummary({@JsonKey(name: ChatThreadSummary.idKey_) required this.id, @JsonKey(name: ChatThreadSummary.proUserIdKey_) required this.proUserId, @JsonKey(name: ChatThreadSummary.clientUserIdKey_) this.clientUserId, @JsonKey(name: ChatThreadSummary.sessionIdKey_) this.sessionId, @JsonKey(name: ChatThreadSummary.statusKey_) required this.status, @JsonKey(name: ChatThreadSummary.createdAtKey_) required this.createdAt, @JsonKey(name: ChatThreadSummary.updatedAtKey_) required this.updatedAt}): super._();
  factory _ChatThreadSummary.fromJson(Map<String, dynamic> json) => _$ChatThreadSummaryFromJson(json);

/// id
@override@JsonKey(name: ChatThreadSummary.idKey_) final  String id;
/// proUserId
@override@JsonKey(name: ChatThreadSummary.proUserIdKey_) final  String proUserId;
/// clientUserId
@override@JsonKey(name: ChatThreadSummary.clientUserIdKey_) final  String? clientUserId;
/// sessionId
@override@JsonKey(name: ChatThreadSummary.sessionIdKey_) final  String? sessionId;
/// status
@override@JsonKey(name: ChatThreadSummary.statusKey_) final  ChatThreadStatus status;
/// createdAt
@override@JsonKey(name: ChatThreadSummary.createdAtKey_) final  DateTime createdAt;
/// updatedAt
@override@JsonKey(name: ChatThreadSummary.updatedAtKey_) final  DateTime updatedAt;

/// Create a copy of ChatThreadSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatThreadSummaryCopyWith<_ChatThreadSummary> get copyWith => __$ChatThreadSummaryCopyWithImpl<_ChatThreadSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatThreadSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatThreadSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.clientUserId, clientUserId) || other.clientUserId == clientUserId)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,proUserId,clientUserId,sessionId,status,createdAt,updatedAt);

@override
String toString() {
  return 'ChatThreadSummary(id: $id, proUserId: $proUserId, clientUserId: $clientUserId, sessionId: $sessionId, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ChatThreadSummaryCopyWith<$Res> implements $ChatThreadSummaryCopyWith<$Res> {
  factory _$ChatThreadSummaryCopyWith(_ChatThreadSummary value, $Res Function(_ChatThreadSummary) _then) = __$ChatThreadSummaryCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ChatThreadSummary.idKey_) String id,@JsonKey(name: ChatThreadSummary.proUserIdKey_) String proUserId,@JsonKey(name: ChatThreadSummary.clientUserIdKey_) String? clientUserId,@JsonKey(name: ChatThreadSummary.sessionIdKey_) String? sessionId,@JsonKey(name: ChatThreadSummary.statusKey_) ChatThreadStatus status,@JsonKey(name: ChatThreadSummary.createdAtKey_) DateTime createdAt,@JsonKey(name: ChatThreadSummary.updatedAtKey_) DateTime updatedAt
});




}
/// @nodoc
class __$ChatThreadSummaryCopyWithImpl<$Res>
    implements _$ChatThreadSummaryCopyWith<$Res> {
  __$ChatThreadSummaryCopyWithImpl(this._self, this._then);

  final _ChatThreadSummary _self;
  final $Res Function(_ChatThreadSummary) _then;

/// Create a copy of ChatThreadSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? proUserId = null,Object? clientUserId = freezed,Object? sessionId = freezed,Object? status = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_ChatThreadSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,clientUserId: freezed == clientUserId ? _self.clientUserId : clientUserId // ignore: cast_nullable_to_non_nullable
as String?,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ChatThreadStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
