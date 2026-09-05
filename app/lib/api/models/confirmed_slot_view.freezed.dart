// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'confirmed_slot_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConfirmedSlotView {

/// id
@JsonKey(name: ConfirmedSlotView.idKey_) String get id;/// gigId
@JsonKey(name: ConfirmedSlotView.gigIdKey_) String get gigId;/// proUserId
@JsonKey(name: ConfirmedSlotView.proUserIdKey_) String get proUserId;/// clientUserId
@JsonKey(name: ConfirmedSlotView.clientUserIdKey_) String get clientUserId;/// startAtUtc
@JsonKey(name: ConfirmedSlotView.startAtUtcKey_) DateTime get startAtUtc;/// endAtUtc
@JsonKey(name: ConfirmedSlotView.endAtUtcKey_) DateTime get endAtUtc;/// status
@JsonKey(name: ConfirmedSlotView.statusKey_) ConfirmedSlotStatus get status;/// cancellationReason
@JsonKey(name: ConfirmedSlotView.cancellationReasonKey_) String? get cancellationReason;/// createdAt
@JsonKey(name: ConfirmedSlotView.createdAtKey_) DateTime get createdAt;/// updatedAt
@JsonKey(name: ConfirmedSlotView.updatedAtKey_) DateTime get updatedAt;
/// Create a copy of ConfirmedSlotView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConfirmedSlotViewCopyWith<ConfirmedSlotView> get copyWith => _$ConfirmedSlotViewCopyWithImpl<ConfirmedSlotView>(this as ConfirmedSlotView, _$identity);

  /// Serializes this ConfirmedSlotView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConfirmedSlotView&&(identical(other.id, id) || other.id == id)&&(identical(other.gigId, gigId) || other.gigId == gigId)&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.clientUserId, clientUserId) || other.clientUserId == clientUserId)&&(identical(other.startAtUtc, startAtUtc) || other.startAtUtc == startAtUtc)&&(identical(other.endAtUtc, endAtUtc) || other.endAtUtc == endAtUtc)&&(identical(other.status, status) || other.status == status)&&(identical(other.cancellationReason, cancellationReason) || other.cancellationReason == cancellationReason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,gigId,proUserId,clientUserId,startAtUtc,endAtUtc,status,cancellationReason,createdAt,updatedAt);

@override
String toString() {
  return 'ConfirmedSlotView(id: $id, gigId: $gigId, proUserId: $proUserId, clientUserId: $clientUserId, startAtUtc: $startAtUtc, endAtUtc: $endAtUtc, status: $status, cancellationReason: $cancellationReason, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ConfirmedSlotViewCopyWith<$Res>  {
  factory $ConfirmedSlotViewCopyWith(ConfirmedSlotView value, $Res Function(ConfirmedSlotView) _then) = _$ConfirmedSlotViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ConfirmedSlotView.idKey_) String id,@JsonKey(name: ConfirmedSlotView.gigIdKey_) String gigId,@JsonKey(name: ConfirmedSlotView.proUserIdKey_) String proUserId,@JsonKey(name: ConfirmedSlotView.clientUserIdKey_) String clientUserId,@JsonKey(name: ConfirmedSlotView.startAtUtcKey_) DateTime startAtUtc,@JsonKey(name: ConfirmedSlotView.endAtUtcKey_) DateTime endAtUtc,@JsonKey(name: ConfirmedSlotView.statusKey_) ConfirmedSlotStatus status,@JsonKey(name: ConfirmedSlotView.cancellationReasonKey_) String? cancellationReason,@JsonKey(name: ConfirmedSlotView.createdAtKey_) DateTime createdAt,@JsonKey(name: ConfirmedSlotView.updatedAtKey_) DateTime updatedAt
});




}
/// @nodoc
class _$ConfirmedSlotViewCopyWithImpl<$Res>
    implements $ConfirmedSlotViewCopyWith<$Res> {
  _$ConfirmedSlotViewCopyWithImpl(this._self, this._then);

  final ConfirmedSlotView _self;
  final $Res Function(ConfirmedSlotView) _then;

/// Create a copy of ConfirmedSlotView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? gigId = null,Object? proUserId = null,Object? clientUserId = null,Object? startAtUtc = null,Object? endAtUtc = null,Object? status = null,Object? cancellationReason = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gigId: null == gigId ? _self.gigId : gigId // ignore: cast_nullable_to_non_nullable
as String,proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,clientUserId: null == clientUserId ? _self.clientUserId : clientUserId // ignore: cast_nullable_to_non_nullable
as String,startAtUtc: null == startAtUtc ? _self.startAtUtc : startAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,endAtUtc: null == endAtUtc ? _self.endAtUtc : endAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConfirmedSlotStatus,cancellationReason: freezed == cancellationReason ? _self.cancellationReason : cancellationReason // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ConfirmedSlotView].
extension ConfirmedSlotViewPatterns on ConfirmedSlotView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConfirmedSlotView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConfirmedSlotView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConfirmedSlotView value)  $default,){
final _that = this;
switch (_that) {
case _ConfirmedSlotView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConfirmedSlotView value)?  $default,){
final _that = this;
switch (_that) {
case _ConfirmedSlotView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ConfirmedSlotView.idKey_)  String id, @JsonKey(name: ConfirmedSlotView.gigIdKey_)  String gigId, @JsonKey(name: ConfirmedSlotView.proUserIdKey_)  String proUserId, @JsonKey(name: ConfirmedSlotView.clientUserIdKey_)  String clientUserId, @JsonKey(name: ConfirmedSlotView.startAtUtcKey_)  DateTime startAtUtc, @JsonKey(name: ConfirmedSlotView.endAtUtcKey_)  DateTime endAtUtc, @JsonKey(name: ConfirmedSlotView.statusKey_)  ConfirmedSlotStatus status, @JsonKey(name: ConfirmedSlotView.cancellationReasonKey_)  String? cancellationReason, @JsonKey(name: ConfirmedSlotView.createdAtKey_)  DateTime createdAt, @JsonKey(name: ConfirmedSlotView.updatedAtKey_)  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConfirmedSlotView() when $default != null:
return $default(_that.id,_that.gigId,_that.proUserId,_that.clientUserId,_that.startAtUtc,_that.endAtUtc,_that.status,_that.cancellationReason,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ConfirmedSlotView.idKey_)  String id, @JsonKey(name: ConfirmedSlotView.gigIdKey_)  String gigId, @JsonKey(name: ConfirmedSlotView.proUserIdKey_)  String proUserId, @JsonKey(name: ConfirmedSlotView.clientUserIdKey_)  String clientUserId, @JsonKey(name: ConfirmedSlotView.startAtUtcKey_)  DateTime startAtUtc, @JsonKey(name: ConfirmedSlotView.endAtUtcKey_)  DateTime endAtUtc, @JsonKey(name: ConfirmedSlotView.statusKey_)  ConfirmedSlotStatus status, @JsonKey(name: ConfirmedSlotView.cancellationReasonKey_)  String? cancellationReason, @JsonKey(name: ConfirmedSlotView.createdAtKey_)  DateTime createdAt, @JsonKey(name: ConfirmedSlotView.updatedAtKey_)  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ConfirmedSlotView():
return $default(_that.id,_that.gigId,_that.proUserId,_that.clientUserId,_that.startAtUtc,_that.endAtUtc,_that.status,_that.cancellationReason,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ConfirmedSlotView.idKey_)  String id, @JsonKey(name: ConfirmedSlotView.gigIdKey_)  String gigId, @JsonKey(name: ConfirmedSlotView.proUserIdKey_)  String proUserId, @JsonKey(name: ConfirmedSlotView.clientUserIdKey_)  String clientUserId, @JsonKey(name: ConfirmedSlotView.startAtUtcKey_)  DateTime startAtUtc, @JsonKey(name: ConfirmedSlotView.endAtUtcKey_)  DateTime endAtUtc, @JsonKey(name: ConfirmedSlotView.statusKey_)  ConfirmedSlotStatus status, @JsonKey(name: ConfirmedSlotView.cancellationReasonKey_)  String? cancellationReason, @JsonKey(name: ConfirmedSlotView.createdAtKey_)  DateTime createdAt, @JsonKey(name: ConfirmedSlotView.updatedAtKey_)  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ConfirmedSlotView() when $default != null:
return $default(_that.id,_that.gigId,_that.proUserId,_that.clientUserId,_that.startAtUtc,_that.endAtUtc,_that.status,_that.cancellationReason,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ConfirmedSlotView extends ConfirmedSlotView {
  const _ConfirmedSlotView({@JsonKey(name: ConfirmedSlotView.idKey_) required this.id, @JsonKey(name: ConfirmedSlotView.gigIdKey_) required this.gigId, @JsonKey(name: ConfirmedSlotView.proUserIdKey_) required this.proUserId, @JsonKey(name: ConfirmedSlotView.clientUserIdKey_) required this.clientUserId, @JsonKey(name: ConfirmedSlotView.startAtUtcKey_) required this.startAtUtc, @JsonKey(name: ConfirmedSlotView.endAtUtcKey_) required this.endAtUtc, @JsonKey(name: ConfirmedSlotView.statusKey_) required this.status, @JsonKey(name: ConfirmedSlotView.cancellationReasonKey_) this.cancellationReason, @JsonKey(name: ConfirmedSlotView.createdAtKey_) required this.createdAt, @JsonKey(name: ConfirmedSlotView.updatedAtKey_) required this.updatedAt}): super._();
  factory _ConfirmedSlotView.fromJson(Map<String, dynamic> json) => _$ConfirmedSlotViewFromJson(json);

/// id
@override@JsonKey(name: ConfirmedSlotView.idKey_) final  String id;
/// gigId
@override@JsonKey(name: ConfirmedSlotView.gigIdKey_) final  String gigId;
/// proUserId
@override@JsonKey(name: ConfirmedSlotView.proUserIdKey_) final  String proUserId;
/// clientUserId
@override@JsonKey(name: ConfirmedSlotView.clientUserIdKey_) final  String clientUserId;
/// startAtUtc
@override@JsonKey(name: ConfirmedSlotView.startAtUtcKey_) final  DateTime startAtUtc;
/// endAtUtc
@override@JsonKey(name: ConfirmedSlotView.endAtUtcKey_) final  DateTime endAtUtc;
/// status
@override@JsonKey(name: ConfirmedSlotView.statusKey_) final  ConfirmedSlotStatus status;
/// cancellationReason
@override@JsonKey(name: ConfirmedSlotView.cancellationReasonKey_) final  String? cancellationReason;
/// createdAt
@override@JsonKey(name: ConfirmedSlotView.createdAtKey_) final  DateTime createdAt;
/// updatedAt
@override@JsonKey(name: ConfirmedSlotView.updatedAtKey_) final  DateTime updatedAt;

/// Create a copy of ConfirmedSlotView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConfirmedSlotViewCopyWith<_ConfirmedSlotView> get copyWith => __$ConfirmedSlotViewCopyWithImpl<_ConfirmedSlotView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConfirmedSlotViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConfirmedSlotView&&(identical(other.id, id) || other.id == id)&&(identical(other.gigId, gigId) || other.gigId == gigId)&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.clientUserId, clientUserId) || other.clientUserId == clientUserId)&&(identical(other.startAtUtc, startAtUtc) || other.startAtUtc == startAtUtc)&&(identical(other.endAtUtc, endAtUtc) || other.endAtUtc == endAtUtc)&&(identical(other.status, status) || other.status == status)&&(identical(other.cancellationReason, cancellationReason) || other.cancellationReason == cancellationReason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,gigId,proUserId,clientUserId,startAtUtc,endAtUtc,status,cancellationReason,createdAt,updatedAt);

@override
String toString() {
  return 'ConfirmedSlotView(id: $id, gigId: $gigId, proUserId: $proUserId, clientUserId: $clientUserId, startAtUtc: $startAtUtc, endAtUtc: $endAtUtc, status: $status, cancellationReason: $cancellationReason, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ConfirmedSlotViewCopyWith<$Res> implements $ConfirmedSlotViewCopyWith<$Res> {
  factory _$ConfirmedSlotViewCopyWith(_ConfirmedSlotView value, $Res Function(_ConfirmedSlotView) _then) = __$ConfirmedSlotViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ConfirmedSlotView.idKey_) String id,@JsonKey(name: ConfirmedSlotView.gigIdKey_) String gigId,@JsonKey(name: ConfirmedSlotView.proUserIdKey_) String proUserId,@JsonKey(name: ConfirmedSlotView.clientUserIdKey_) String clientUserId,@JsonKey(name: ConfirmedSlotView.startAtUtcKey_) DateTime startAtUtc,@JsonKey(name: ConfirmedSlotView.endAtUtcKey_) DateTime endAtUtc,@JsonKey(name: ConfirmedSlotView.statusKey_) ConfirmedSlotStatus status,@JsonKey(name: ConfirmedSlotView.cancellationReasonKey_) String? cancellationReason,@JsonKey(name: ConfirmedSlotView.createdAtKey_) DateTime createdAt,@JsonKey(name: ConfirmedSlotView.updatedAtKey_) DateTime updatedAt
});




}
/// @nodoc
class __$ConfirmedSlotViewCopyWithImpl<$Res>
    implements _$ConfirmedSlotViewCopyWith<$Res> {
  __$ConfirmedSlotViewCopyWithImpl(this._self, this._then);

  final _ConfirmedSlotView _self;
  final $Res Function(_ConfirmedSlotView) _then;

/// Create a copy of ConfirmedSlotView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? gigId = null,Object? proUserId = null,Object? clientUserId = null,Object? startAtUtc = null,Object? endAtUtc = null,Object? status = null,Object? cancellationReason = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_ConfirmedSlotView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gigId: null == gigId ? _self.gigId : gigId // ignore: cast_nullable_to_non_nullable
as String,proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,clientUserId: null == clientUserId ? _self.clientUserId : clientUserId // ignore: cast_nullable_to_non_nullable
as String,startAtUtc: null == startAtUtc ? _self.startAtUtc : startAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,endAtUtc: null == endAtUtc ? _self.endAtUtc : endAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConfirmedSlotStatus,cancellationReason: freezed == cancellationReason ? _self.cancellationReason : cancellationReason // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
