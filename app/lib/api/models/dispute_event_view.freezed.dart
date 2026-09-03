// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dispute_event_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DisputeEventView {

/// id
@JsonKey(name: DisputeEventView.idKey_) String get id;/// disputeId
@JsonKey(name: DisputeEventView.disputeIdKey_) String get disputeId;/// fromStatus
@JsonKey(name: DisputeEventView.fromStatusKey_) String? get fromStatus;/// toStatus
@JsonKey(name: DisputeEventView.toStatusKey_) String get toStatus;/// actorType
@JsonKey(name: DisputeEventView.actorTypeKey_) String get actorType;/// actorUserId
@JsonKey(name: DisputeEventView.actorUserIdKey_) String? get actorUserId;/// note
@JsonKey(name: DisputeEventView.noteKey_) String? get note;/// payload
@JsonKey(name: DisputeEventView.payloadKey_) Map<String, dynamic>? get payload;/// createdAt
@JsonKey(name: DisputeEventView.createdAtKey_) DateTime get createdAt;
/// Create a copy of DisputeEventView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DisputeEventViewCopyWith<DisputeEventView> get copyWith => _$DisputeEventViewCopyWithImpl<DisputeEventView>(this as DisputeEventView, _$identity);

  /// Serializes this DisputeEventView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DisputeEventView&&(identical(other.id, id) || other.id == id)&&(identical(other.disputeId, disputeId) || other.disputeId == disputeId)&&(identical(other.fromStatus, fromStatus) || other.fromStatus == fromStatus)&&(identical(other.toStatus, toStatus) || other.toStatus == toStatus)&&(identical(other.actorType, actorType) || other.actorType == actorType)&&(identical(other.actorUserId, actorUserId) || other.actorUserId == actorUserId)&&(identical(other.note, note) || other.note == note)&&const DeepCollectionEquality().equals(other.payload, payload)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,disputeId,fromStatus,toStatus,actorType,actorUserId,note,const DeepCollectionEquality().hash(payload),createdAt);

@override
String toString() {
  return 'DisputeEventView(id: $id, disputeId: $disputeId, fromStatus: $fromStatus, toStatus: $toStatus, actorType: $actorType, actorUserId: $actorUserId, note: $note, payload: $payload, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $DisputeEventViewCopyWith<$Res>  {
  factory $DisputeEventViewCopyWith(DisputeEventView value, $Res Function(DisputeEventView) _then) = _$DisputeEventViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: DisputeEventView.idKey_) String id,@JsonKey(name: DisputeEventView.disputeIdKey_) String disputeId,@JsonKey(name: DisputeEventView.fromStatusKey_) String? fromStatus,@JsonKey(name: DisputeEventView.toStatusKey_) String toStatus,@JsonKey(name: DisputeEventView.actorTypeKey_) String actorType,@JsonKey(name: DisputeEventView.actorUserIdKey_) String? actorUserId,@JsonKey(name: DisputeEventView.noteKey_) String? note,@JsonKey(name: DisputeEventView.payloadKey_) Map<String, dynamic>? payload,@JsonKey(name: DisputeEventView.createdAtKey_) DateTime createdAt
});




}
/// @nodoc
class _$DisputeEventViewCopyWithImpl<$Res>
    implements $DisputeEventViewCopyWith<$Res> {
  _$DisputeEventViewCopyWithImpl(this._self, this._then);

  final DisputeEventView _self;
  final $Res Function(DisputeEventView) _then;

/// Create a copy of DisputeEventView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? disputeId = null,Object? fromStatus = freezed,Object? toStatus = null,Object? actorType = null,Object? actorUserId = freezed,Object? note = freezed,Object? payload = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,disputeId: null == disputeId ? _self.disputeId : disputeId // ignore: cast_nullable_to_non_nullable
as String,fromStatus: freezed == fromStatus ? _self.fromStatus : fromStatus // ignore: cast_nullable_to_non_nullable
as String?,toStatus: null == toStatus ? _self.toStatus : toStatus // ignore: cast_nullable_to_non_nullable
as String,actorType: null == actorType ? _self.actorType : actorType // ignore: cast_nullable_to_non_nullable
as String,actorUserId: freezed == actorUserId ? _self.actorUserId : actorUserId // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,payload: freezed == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [DisputeEventView].
extension DisputeEventViewPatterns on DisputeEventView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DisputeEventView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DisputeEventView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DisputeEventView value)  $default,){
final _that = this;
switch (_that) {
case _DisputeEventView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DisputeEventView value)?  $default,){
final _that = this;
switch (_that) {
case _DisputeEventView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: DisputeEventView.idKey_)  String id, @JsonKey(name: DisputeEventView.disputeIdKey_)  String disputeId, @JsonKey(name: DisputeEventView.fromStatusKey_)  String? fromStatus, @JsonKey(name: DisputeEventView.toStatusKey_)  String toStatus, @JsonKey(name: DisputeEventView.actorTypeKey_)  String actorType, @JsonKey(name: DisputeEventView.actorUserIdKey_)  String? actorUserId, @JsonKey(name: DisputeEventView.noteKey_)  String? note, @JsonKey(name: DisputeEventView.payloadKey_)  Map<String, dynamic>? payload, @JsonKey(name: DisputeEventView.createdAtKey_)  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DisputeEventView() when $default != null:
return $default(_that.id,_that.disputeId,_that.fromStatus,_that.toStatus,_that.actorType,_that.actorUserId,_that.note,_that.payload,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: DisputeEventView.idKey_)  String id, @JsonKey(name: DisputeEventView.disputeIdKey_)  String disputeId, @JsonKey(name: DisputeEventView.fromStatusKey_)  String? fromStatus, @JsonKey(name: DisputeEventView.toStatusKey_)  String toStatus, @JsonKey(name: DisputeEventView.actorTypeKey_)  String actorType, @JsonKey(name: DisputeEventView.actorUserIdKey_)  String? actorUserId, @JsonKey(name: DisputeEventView.noteKey_)  String? note, @JsonKey(name: DisputeEventView.payloadKey_)  Map<String, dynamic>? payload, @JsonKey(name: DisputeEventView.createdAtKey_)  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _DisputeEventView():
return $default(_that.id,_that.disputeId,_that.fromStatus,_that.toStatus,_that.actorType,_that.actorUserId,_that.note,_that.payload,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: DisputeEventView.idKey_)  String id, @JsonKey(name: DisputeEventView.disputeIdKey_)  String disputeId, @JsonKey(name: DisputeEventView.fromStatusKey_)  String? fromStatus, @JsonKey(name: DisputeEventView.toStatusKey_)  String toStatus, @JsonKey(name: DisputeEventView.actorTypeKey_)  String actorType, @JsonKey(name: DisputeEventView.actorUserIdKey_)  String? actorUserId, @JsonKey(name: DisputeEventView.noteKey_)  String? note, @JsonKey(name: DisputeEventView.payloadKey_)  Map<String, dynamic>? payload, @JsonKey(name: DisputeEventView.createdAtKey_)  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _DisputeEventView() when $default != null:
return $default(_that.id,_that.disputeId,_that.fromStatus,_that.toStatus,_that.actorType,_that.actorUserId,_that.note,_that.payload,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _DisputeEventView extends DisputeEventView {
  const _DisputeEventView({@JsonKey(name: DisputeEventView.idKey_) required this.id, @JsonKey(name: DisputeEventView.disputeIdKey_) required this.disputeId, @JsonKey(name: DisputeEventView.fromStatusKey_) this.fromStatus, @JsonKey(name: DisputeEventView.toStatusKey_) required this.toStatus, @JsonKey(name: DisputeEventView.actorTypeKey_) required this.actorType, @JsonKey(name: DisputeEventView.actorUserIdKey_) this.actorUserId, @JsonKey(name: DisputeEventView.noteKey_) this.note, @JsonKey(name: DisputeEventView.payloadKey_) final  Map<String, dynamic>? payload, @JsonKey(name: DisputeEventView.createdAtKey_) required this.createdAt}): _payload = payload,super._();
  factory _DisputeEventView.fromJson(Map<String, dynamic> json) => _$DisputeEventViewFromJson(json);

/// id
@override@JsonKey(name: DisputeEventView.idKey_) final  String id;
/// disputeId
@override@JsonKey(name: DisputeEventView.disputeIdKey_) final  String disputeId;
/// fromStatus
@override@JsonKey(name: DisputeEventView.fromStatusKey_) final  String? fromStatus;
/// toStatus
@override@JsonKey(name: DisputeEventView.toStatusKey_) final  String toStatus;
/// actorType
@override@JsonKey(name: DisputeEventView.actorTypeKey_) final  String actorType;
/// actorUserId
@override@JsonKey(name: DisputeEventView.actorUserIdKey_) final  String? actorUserId;
/// note
@override@JsonKey(name: DisputeEventView.noteKey_) final  String? note;
/// payload
 final  Map<String, dynamic>? _payload;
/// payload
@override@JsonKey(name: DisputeEventView.payloadKey_) Map<String, dynamic>? get payload {
  final value = _payload;
  if (value == null) return null;
  if (_payload is EqualUnmodifiableMapView) return _payload;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// createdAt
@override@JsonKey(name: DisputeEventView.createdAtKey_) final  DateTime createdAt;

/// Create a copy of DisputeEventView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DisputeEventViewCopyWith<_DisputeEventView> get copyWith => __$DisputeEventViewCopyWithImpl<_DisputeEventView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DisputeEventViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DisputeEventView&&(identical(other.id, id) || other.id == id)&&(identical(other.disputeId, disputeId) || other.disputeId == disputeId)&&(identical(other.fromStatus, fromStatus) || other.fromStatus == fromStatus)&&(identical(other.toStatus, toStatus) || other.toStatus == toStatus)&&(identical(other.actorType, actorType) || other.actorType == actorType)&&(identical(other.actorUserId, actorUserId) || other.actorUserId == actorUserId)&&(identical(other.note, note) || other.note == note)&&const DeepCollectionEquality().equals(other._payload, _payload)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,disputeId,fromStatus,toStatus,actorType,actorUserId,note,const DeepCollectionEquality().hash(_payload),createdAt);

@override
String toString() {
  return 'DisputeEventView(id: $id, disputeId: $disputeId, fromStatus: $fromStatus, toStatus: $toStatus, actorType: $actorType, actorUserId: $actorUserId, note: $note, payload: $payload, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$DisputeEventViewCopyWith<$Res> implements $DisputeEventViewCopyWith<$Res> {
  factory _$DisputeEventViewCopyWith(_DisputeEventView value, $Res Function(_DisputeEventView) _then) = __$DisputeEventViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: DisputeEventView.idKey_) String id,@JsonKey(name: DisputeEventView.disputeIdKey_) String disputeId,@JsonKey(name: DisputeEventView.fromStatusKey_) String? fromStatus,@JsonKey(name: DisputeEventView.toStatusKey_) String toStatus,@JsonKey(name: DisputeEventView.actorTypeKey_) String actorType,@JsonKey(name: DisputeEventView.actorUserIdKey_) String? actorUserId,@JsonKey(name: DisputeEventView.noteKey_) String? note,@JsonKey(name: DisputeEventView.payloadKey_) Map<String, dynamic>? payload,@JsonKey(name: DisputeEventView.createdAtKey_) DateTime createdAt
});




}
/// @nodoc
class __$DisputeEventViewCopyWithImpl<$Res>
    implements _$DisputeEventViewCopyWith<$Res> {
  __$DisputeEventViewCopyWithImpl(this._self, this._then);

  final _DisputeEventView _self;
  final $Res Function(_DisputeEventView) _then;

/// Create a copy of DisputeEventView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? disputeId = null,Object? fromStatus = freezed,Object? toStatus = null,Object? actorType = null,Object? actorUserId = freezed,Object? note = freezed,Object? payload = freezed,Object? createdAt = null,}) {
  return _then(_DisputeEventView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,disputeId: null == disputeId ? _self.disputeId : disputeId // ignore: cast_nullable_to_non_nullable
as String,fromStatus: freezed == fromStatus ? _self.fromStatus : fromStatus // ignore: cast_nullable_to_non_nullable
as String?,toStatus: null == toStatus ? _self.toStatus : toStatus // ignore: cast_nullable_to_non_nullable
as String,actorType: null == actorType ? _self.actorType : actorType // ignore: cast_nullable_to_non_nullable
as String,actorUserId: freezed == actorUserId ? _self.actorUserId : actorUserId // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,payload: freezed == payload ? _self._payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
