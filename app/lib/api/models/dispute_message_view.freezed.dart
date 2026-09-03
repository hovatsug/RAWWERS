// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dispute_message_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DisputeMessageView {

/// id
@JsonKey(name: DisputeMessageView.idKey_) String get id;/// disputeId
@JsonKey(name: DisputeMessageView.disputeIdKey_) String get disputeId;/// senderUserId
@JsonKey(name: DisputeMessageView.senderUserIdKey_) String get senderUserId;/// message
@JsonKey(name: DisputeMessageView.messageKey_) String get message;/// evidenceMediaAssetIds
@JsonKey(name: DisputeMessageView.evidenceMediaAssetIdsKey_) List<dynamic>? get evidenceMediaAssetIds;/// createdAt
@JsonKey(name: DisputeMessageView.createdAtKey_) DateTime get createdAt;
/// Create a copy of DisputeMessageView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DisputeMessageViewCopyWith<DisputeMessageView> get copyWith => _$DisputeMessageViewCopyWithImpl<DisputeMessageView>(this as DisputeMessageView, _$identity);

  /// Serializes this DisputeMessageView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DisputeMessageView&&(identical(other.id, id) || other.id == id)&&(identical(other.disputeId, disputeId) || other.disputeId == disputeId)&&(identical(other.senderUserId, senderUserId) || other.senderUserId == senderUserId)&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.evidenceMediaAssetIds, evidenceMediaAssetIds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,disputeId,senderUserId,message,const DeepCollectionEquality().hash(evidenceMediaAssetIds),createdAt);

@override
String toString() {
  return 'DisputeMessageView(id: $id, disputeId: $disputeId, senderUserId: $senderUserId, message: $message, evidenceMediaAssetIds: $evidenceMediaAssetIds, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $DisputeMessageViewCopyWith<$Res>  {
  factory $DisputeMessageViewCopyWith(DisputeMessageView value, $Res Function(DisputeMessageView) _then) = _$DisputeMessageViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: DisputeMessageView.idKey_) String id,@JsonKey(name: DisputeMessageView.disputeIdKey_) String disputeId,@JsonKey(name: DisputeMessageView.senderUserIdKey_) String senderUserId,@JsonKey(name: DisputeMessageView.messageKey_) String message,@JsonKey(name: DisputeMessageView.evidenceMediaAssetIdsKey_) List<dynamic>? evidenceMediaAssetIds,@JsonKey(name: DisputeMessageView.createdAtKey_) DateTime createdAt
});




}
/// @nodoc
class _$DisputeMessageViewCopyWithImpl<$Res>
    implements $DisputeMessageViewCopyWith<$Res> {
  _$DisputeMessageViewCopyWithImpl(this._self, this._then);

  final DisputeMessageView _self;
  final $Res Function(DisputeMessageView) _then;

/// Create a copy of DisputeMessageView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? disputeId = null,Object? senderUserId = null,Object? message = null,Object? evidenceMediaAssetIds = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,disputeId: null == disputeId ? _self.disputeId : disputeId // ignore: cast_nullable_to_non_nullable
as String,senderUserId: null == senderUserId ? _self.senderUserId : senderUserId // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,evidenceMediaAssetIds: freezed == evidenceMediaAssetIds ? _self.evidenceMediaAssetIds : evidenceMediaAssetIds // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [DisputeMessageView].
extension DisputeMessageViewPatterns on DisputeMessageView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DisputeMessageView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DisputeMessageView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DisputeMessageView value)  $default,){
final _that = this;
switch (_that) {
case _DisputeMessageView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DisputeMessageView value)?  $default,){
final _that = this;
switch (_that) {
case _DisputeMessageView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: DisputeMessageView.idKey_)  String id, @JsonKey(name: DisputeMessageView.disputeIdKey_)  String disputeId, @JsonKey(name: DisputeMessageView.senderUserIdKey_)  String senderUserId, @JsonKey(name: DisputeMessageView.messageKey_)  String message, @JsonKey(name: DisputeMessageView.evidenceMediaAssetIdsKey_)  List<dynamic>? evidenceMediaAssetIds, @JsonKey(name: DisputeMessageView.createdAtKey_)  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DisputeMessageView() when $default != null:
return $default(_that.id,_that.disputeId,_that.senderUserId,_that.message,_that.evidenceMediaAssetIds,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: DisputeMessageView.idKey_)  String id, @JsonKey(name: DisputeMessageView.disputeIdKey_)  String disputeId, @JsonKey(name: DisputeMessageView.senderUserIdKey_)  String senderUserId, @JsonKey(name: DisputeMessageView.messageKey_)  String message, @JsonKey(name: DisputeMessageView.evidenceMediaAssetIdsKey_)  List<dynamic>? evidenceMediaAssetIds, @JsonKey(name: DisputeMessageView.createdAtKey_)  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _DisputeMessageView():
return $default(_that.id,_that.disputeId,_that.senderUserId,_that.message,_that.evidenceMediaAssetIds,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: DisputeMessageView.idKey_)  String id, @JsonKey(name: DisputeMessageView.disputeIdKey_)  String disputeId, @JsonKey(name: DisputeMessageView.senderUserIdKey_)  String senderUserId, @JsonKey(name: DisputeMessageView.messageKey_)  String message, @JsonKey(name: DisputeMessageView.evidenceMediaAssetIdsKey_)  List<dynamic>? evidenceMediaAssetIds, @JsonKey(name: DisputeMessageView.createdAtKey_)  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _DisputeMessageView() when $default != null:
return $default(_that.id,_that.disputeId,_that.senderUserId,_that.message,_that.evidenceMediaAssetIds,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _DisputeMessageView extends DisputeMessageView {
  const _DisputeMessageView({@JsonKey(name: DisputeMessageView.idKey_) required this.id, @JsonKey(name: DisputeMessageView.disputeIdKey_) required this.disputeId, @JsonKey(name: DisputeMessageView.senderUserIdKey_) required this.senderUserId, @JsonKey(name: DisputeMessageView.messageKey_) required this.message, @JsonKey(name: DisputeMessageView.evidenceMediaAssetIdsKey_) final  List<dynamic>? evidenceMediaAssetIds, @JsonKey(name: DisputeMessageView.createdAtKey_) required this.createdAt}): _evidenceMediaAssetIds = evidenceMediaAssetIds,super._();
  factory _DisputeMessageView.fromJson(Map<String, dynamic> json) => _$DisputeMessageViewFromJson(json);

/// id
@override@JsonKey(name: DisputeMessageView.idKey_) final  String id;
/// disputeId
@override@JsonKey(name: DisputeMessageView.disputeIdKey_) final  String disputeId;
/// senderUserId
@override@JsonKey(name: DisputeMessageView.senderUserIdKey_) final  String senderUserId;
/// message
@override@JsonKey(name: DisputeMessageView.messageKey_) final  String message;
/// evidenceMediaAssetIds
 final  List<dynamic>? _evidenceMediaAssetIds;
/// evidenceMediaAssetIds
@override@JsonKey(name: DisputeMessageView.evidenceMediaAssetIdsKey_) List<dynamic>? get evidenceMediaAssetIds {
  final value = _evidenceMediaAssetIds;
  if (value == null) return null;
  if (_evidenceMediaAssetIds is EqualUnmodifiableListView) return _evidenceMediaAssetIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// createdAt
@override@JsonKey(name: DisputeMessageView.createdAtKey_) final  DateTime createdAt;

/// Create a copy of DisputeMessageView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DisputeMessageViewCopyWith<_DisputeMessageView> get copyWith => __$DisputeMessageViewCopyWithImpl<_DisputeMessageView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DisputeMessageViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DisputeMessageView&&(identical(other.id, id) || other.id == id)&&(identical(other.disputeId, disputeId) || other.disputeId == disputeId)&&(identical(other.senderUserId, senderUserId) || other.senderUserId == senderUserId)&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other._evidenceMediaAssetIds, _evidenceMediaAssetIds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,disputeId,senderUserId,message,const DeepCollectionEquality().hash(_evidenceMediaAssetIds),createdAt);

@override
String toString() {
  return 'DisputeMessageView(id: $id, disputeId: $disputeId, senderUserId: $senderUserId, message: $message, evidenceMediaAssetIds: $evidenceMediaAssetIds, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$DisputeMessageViewCopyWith<$Res> implements $DisputeMessageViewCopyWith<$Res> {
  factory _$DisputeMessageViewCopyWith(_DisputeMessageView value, $Res Function(_DisputeMessageView) _then) = __$DisputeMessageViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: DisputeMessageView.idKey_) String id,@JsonKey(name: DisputeMessageView.disputeIdKey_) String disputeId,@JsonKey(name: DisputeMessageView.senderUserIdKey_) String senderUserId,@JsonKey(name: DisputeMessageView.messageKey_) String message,@JsonKey(name: DisputeMessageView.evidenceMediaAssetIdsKey_) List<dynamic>? evidenceMediaAssetIds,@JsonKey(name: DisputeMessageView.createdAtKey_) DateTime createdAt
});




}
/// @nodoc
class __$DisputeMessageViewCopyWithImpl<$Res>
    implements _$DisputeMessageViewCopyWith<$Res> {
  __$DisputeMessageViewCopyWithImpl(this._self, this._then);

  final _DisputeMessageView _self;
  final $Res Function(_DisputeMessageView) _then;

/// Create a copy of DisputeMessageView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? disputeId = null,Object? senderUserId = null,Object? message = null,Object? evidenceMediaAssetIds = freezed,Object? createdAt = null,}) {
  return _then(_DisputeMessageView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,disputeId: null == disputeId ? _self.disputeId : disputeId // ignore: cast_nullable_to_non_nullable
as String,senderUserId: null == senderUserId ? _self.senderUserId : senderUserId // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,evidenceMediaAssetIds: freezed == evidenceMediaAssetIds ? _self._evidenceMediaAssetIds : evidenceMediaAssetIds // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
