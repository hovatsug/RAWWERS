// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cycle_event_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CycleEventView {

/// id
@JsonKey(name: CycleEventView.idKey_) String get id;/// cycleId
@JsonKey(name: CycleEventView.cycleIdKey_) String get cycleId;/// userId
@JsonKey(name: CycleEventView.userIdKey_) String get userId;/// eventType
@JsonKey(name: CycleEventView.eventTypeKey_) String get eventType;/// pointsDelta
@JsonKey(name: CycleEventView.pointsDeltaKey_) int get pointsDelta;/// referenceType
@JsonKey(name: CycleEventView.referenceTypeKey_) String? get referenceType;/// referenceId
@JsonKey(name: CycleEventView.referenceIdKey_) String? get referenceId;/// createdAt
@JsonKey(name: CycleEventView.createdAtKey_) DateTime get createdAt;
/// Create a copy of CycleEventView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CycleEventViewCopyWith<CycleEventView> get copyWith => _$CycleEventViewCopyWithImpl<CycleEventView>(this as CycleEventView, _$identity);

  /// Serializes this CycleEventView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CycleEventView&&(identical(other.id, id) || other.id == id)&&(identical(other.cycleId, cycleId) || other.cycleId == cycleId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.pointsDelta, pointsDelta) || other.pointsDelta == pointsDelta)&&(identical(other.referenceType, referenceType) || other.referenceType == referenceType)&&(identical(other.referenceId, referenceId) || other.referenceId == referenceId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,cycleId,userId,eventType,pointsDelta,referenceType,referenceId,createdAt);

@override
String toString() {
  return 'CycleEventView(id: $id, cycleId: $cycleId, userId: $userId, eventType: $eventType, pointsDelta: $pointsDelta, referenceType: $referenceType, referenceId: $referenceId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $CycleEventViewCopyWith<$Res>  {
  factory $CycleEventViewCopyWith(CycleEventView value, $Res Function(CycleEventView) _then) = _$CycleEventViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: CycleEventView.idKey_) String id,@JsonKey(name: CycleEventView.cycleIdKey_) String cycleId,@JsonKey(name: CycleEventView.userIdKey_) String userId,@JsonKey(name: CycleEventView.eventTypeKey_) String eventType,@JsonKey(name: CycleEventView.pointsDeltaKey_) int pointsDelta,@JsonKey(name: CycleEventView.referenceTypeKey_) String? referenceType,@JsonKey(name: CycleEventView.referenceIdKey_) String? referenceId,@JsonKey(name: CycleEventView.createdAtKey_) DateTime createdAt
});




}
/// @nodoc
class _$CycleEventViewCopyWithImpl<$Res>
    implements $CycleEventViewCopyWith<$Res> {
  _$CycleEventViewCopyWithImpl(this._self, this._then);

  final CycleEventView _self;
  final $Res Function(CycleEventView) _then;

/// Create a copy of CycleEventView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? cycleId = null,Object? userId = null,Object? eventType = null,Object? pointsDelta = null,Object? referenceType = freezed,Object? referenceId = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,cycleId: null == cycleId ? _self.cycleId : cycleId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as String,pointsDelta: null == pointsDelta ? _self.pointsDelta : pointsDelta // ignore: cast_nullable_to_non_nullable
as int,referenceType: freezed == referenceType ? _self.referenceType : referenceType // ignore: cast_nullable_to_non_nullable
as String?,referenceId: freezed == referenceId ? _self.referenceId : referenceId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CycleEventView].
extension CycleEventViewPatterns on CycleEventView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CycleEventView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CycleEventView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CycleEventView value)  $default,){
final _that = this;
switch (_that) {
case _CycleEventView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CycleEventView value)?  $default,){
final _that = this;
switch (_that) {
case _CycleEventView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: CycleEventView.idKey_)  String id, @JsonKey(name: CycleEventView.cycleIdKey_)  String cycleId, @JsonKey(name: CycleEventView.userIdKey_)  String userId, @JsonKey(name: CycleEventView.eventTypeKey_)  String eventType, @JsonKey(name: CycleEventView.pointsDeltaKey_)  int pointsDelta, @JsonKey(name: CycleEventView.referenceTypeKey_)  String? referenceType, @JsonKey(name: CycleEventView.referenceIdKey_)  String? referenceId, @JsonKey(name: CycleEventView.createdAtKey_)  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CycleEventView() when $default != null:
return $default(_that.id,_that.cycleId,_that.userId,_that.eventType,_that.pointsDelta,_that.referenceType,_that.referenceId,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: CycleEventView.idKey_)  String id, @JsonKey(name: CycleEventView.cycleIdKey_)  String cycleId, @JsonKey(name: CycleEventView.userIdKey_)  String userId, @JsonKey(name: CycleEventView.eventTypeKey_)  String eventType, @JsonKey(name: CycleEventView.pointsDeltaKey_)  int pointsDelta, @JsonKey(name: CycleEventView.referenceTypeKey_)  String? referenceType, @JsonKey(name: CycleEventView.referenceIdKey_)  String? referenceId, @JsonKey(name: CycleEventView.createdAtKey_)  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _CycleEventView():
return $default(_that.id,_that.cycleId,_that.userId,_that.eventType,_that.pointsDelta,_that.referenceType,_that.referenceId,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: CycleEventView.idKey_)  String id, @JsonKey(name: CycleEventView.cycleIdKey_)  String cycleId, @JsonKey(name: CycleEventView.userIdKey_)  String userId, @JsonKey(name: CycleEventView.eventTypeKey_)  String eventType, @JsonKey(name: CycleEventView.pointsDeltaKey_)  int pointsDelta, @JsonKey(name: CycleEventView.referenceTypeKey_)  String? referenceType, @JsonKey(name: CycleEventView.referenceIdKey_)  String? referenceId, @JsonKey(name: CycleEventView.createdAtKey_)  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _CycleEventView() when $default != null:
return $default(_that.id,_that.cycleId,_that.userId,_that.eventType,_that.pointsDelta,_that.referenceType,_that.referenceId,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _CycleEventView extends CycleEventView {
  const _CycleEventView({@JsonKey(name: CycleEventView.idKey_) required this.id, @JsonKey(name: CycleEventView.cycleIdKey_) required this.cycleId, @JsonKey(name: CycleEventView.userIdKey_) required this.userId, @JsonKey(name: CycleEventView.eventTypeKey_) required this.eventType, @JsonKey(name: CycleEventView.pointsDeltaKey_) required this.pointsDelta, @JsonKey(name: CycleEventView.referenceTypeKey_) this.referenceType, @JsonKey(name: CycleEventView.referenceIdKey_) this.referenceId, @JsonKey(name: CycleEventView.createdAtKey_) required this.createdAt}): super._();
  factory _CycleEventView.fromJson(Map<String, dynamic> json) => _$CycleEventViewFromJson(json);

/// id
@override@JsonKey(name: CycleEventView.idKey_) final  String id;
/// cycleId
@override@JsonKey(name: CycleEventView.cycleIdKey_) final  String cycleId;
/// userId
@override@JsonKey(name: CycleEventView.userIdKey_) final  String userId;
/// eventType
@override@JsonKey(name: CycleEventView.eventTypeKey_) final  String eventType;
/// pointsDelta
@override@JsonKey(name: CycleEventView.pointsDeltaKey_) final  int pointsDelta;
/// referenceType
@override@JsonKey(name: CycleEventView.referenceTypeKey_) final  String? referenceType;
/// referenceId
@override@JsonKey(name: CycleEventView.referenceIdKey_) final  String? referenceId;
/// createdAt
@override@JsonKey(name: CycleEventView.createdAtKey_) final  DateTime createdAt;

/// Create a copy of CycleEventView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CycleEventViewCopyWith<_CycleEventView> get copyWith => __$CycleEventViewCopyWithImpl<_CycleEventView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CycleEventViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CycleEventView&&(identical(other.id, id) || other.id == id)&&(identical(other.cycleId, cycleId) || other.cycleId == cycleId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.pointsDelta, pointsDelta) || other.pointsDelta == pointsDelta)&&(identical(other.referenceType, referenceType) || other.referenceType == referenceType)&&(identical(other.referenceId, referenceId) || other.referenceId == referenceId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,cycleId,userId,eventType,pointsDelta,referenceType,referenceId,createdAt);

@override
String toString() {
  return 'CycleEventView(id: $id, cycleId: $cycleId, userId: $userId, eventType: $eventType, pointsDelta: $pointsDelta, referenceType: $referenceType, referenceId: $referenceId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$CycleEventViewCopyWith<$Res> implements $CycleEventViewCopyWith<$Res> {
  factory _$CycleEventViewCopyWith(_CycleEventView value, $Res Function(_CycleEventView) _then) = __$CycleEventViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: CycleEventView.idKey_) String id,@JsonKey(name: CycleEventView.cycleIdKey_) String cycleId,@JsonKey(name: CycleEventView.userIdKey_) String userId,@JsonKey(name: CycleEventView.eventTypeKey_) String eventType,@JsonKey(name: CycleEventView.pointsDeltaKey_) int pointsDelta,@JsonKey(name: CycleEventView.referenceTypeKey_) String? referenceType,@JsonKey(name: CycleEventView.referenceIdKey_) String? referenceId,@JsonKey(name: CycleEventView.createdAtKey_) DateTime createdAt
});




}
/// @nodoc
class __$CycleEventViewCopyWithImpl<$Res>
    implements _$CycleEventViewCopyWith<$Res> {
  __$CycleEventViewCopyWithImpl(this._self, this._then);

  final _CycleEventView _self;
  final $Res Function(_CycleEventView) _then;

/// Create a copy of CycleEventView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? cycleId = null,Object? userId = null,Object? eventType = null,Object? pointsDelta = null,Object? referenceType = freezed,Object? referenceId = freezed,Object? createdAt = null,}) {
  return _then(_CycleEventView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,cycleId: null == cycleId ? _self.cycleId : cycleId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as String,pointsDelta: null == pointsDelta ? _self.pointsDelta : pointsDelta // ignore: cast_nullable_to_non_nullable
as int,referenceType: freezed == referenceType ? _self.referenceType : referenceType // ignore: cast_nullable_to_non_nullable
as String?,referenceId: freezed == referenceId ? _self.referenceId : referenceId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
