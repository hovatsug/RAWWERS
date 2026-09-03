// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payout_request_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PayoutRequestView {

/// id
@JsonKey(name: PayoutRequestView.idKey_) String get id;/// proUserId
@JsonKey(name: PayoutRequestView.proUserIdKey_) String get proUserId;/// amountEur
@JsonKey(name: PayoutRequestView.amountEurKey_) String get amountEur;/// status
@JsonKey(name: PayoutRequestView.statusKey_) PayoutRequestStatus get status;/// requestedAt
@JsonKey(name: PayoutRequestView.requestedAtKey_) DateTime get requestedAt;/// approvedByAdminId
@JsonKey(name: PayoutRequestView.approvedByAdminIdKey_) String? get approvedByAdminId;/// approvedAt
@JsonKey(name: PayoutRequestView.approvedAtKey_) DateTime? get approvedAt;/// paidAt
@JsonKey(name: PayoutRequestView.paidAtKey_) DateTime? get paidAt;/// failureReason
@JsonKey(name: PayoutRequestView.failureReasonKey_) String? get failureReason;/// reference
@JsonKey(name: PayoutRequestView.referenceKey_) Map<String, dynamic>? get reference;/// createdAt
@JsonKey(name: PayoutRequestView.createdAtKey_) DateTime get createdAt;/// updatedAt
@JsonKey(name: PayoutRequestView.updatedAtKey_) DateTime get updatedAt;
/// Create a copy of PayoutRequestView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PayoutRequestViewCopyWith<PayoutRequestView> get copyWith => _$PayoutRequestViewCopyWithImpl<PayoutRequestView>(this as PayoutRequestView, _$identity);

  /// Serializes this PayoutRequestView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PayoutRequestView&&(identical(other.id, id) || other.id == id)&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.amountEur, amountEur) || other.amountEur == amountEur)&&(identical(other.status, status) || other.status == status)&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt)&&(identical(other.approvedByAdminId, approvedByAdminId) || other.approvedByAdminId == approvedByAdminId)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.failureReason, failureReason) || other.failureReason == failureReason)&&const DeepCollectionEquality().equals(other.reference, reference)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,proUserId,amountEur,status,requestedAt,approvedByAdminId,approvedAt,paidAt,failureReason,const DeepCollectionEquality().hash(reference),createdAt,updatedAt);

@override
String toString() {
  return 'PayoutRequestView(id: $id, proUserId: $proUserId, amountEur: $amountEur, status: $status, requestedAt: $requestedAt, approvedByAdminId: $approvedByAdminId, approvedAt: $approvedAt, paidAt: $paidAt, failureReason: $failureReason, reference: $reference, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PayoutRequestViewCopyWith<$Res>  {
  factory $PayoutRequestViewCopyWith(PayoutRequestView value, $Res Function(PayoutRequestView) _then) = _$PayoutRequestViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: PayoutRequestView.idKey_) String id,@JsonKey(name: PayoutRequestView.proUserIdKey_) String proUserId,@JsonKey(name: PayoutRequestView.amountEurKey_) String amountEur,@JsonKey(name: PayoutRequestView.statusKey_) PayoutRequestStatus status,@JsonKey(name: PayoutRequestView.requestedAtKey_) DateTime requestedAt,@JsonKey(name: PayoutRequestView.approvedByAdminIdKey_) String? approvedByAdminId,@JsonKey(name: PayoutRequestView.approvedAtKey_) DateTime? approvedAt,@JsonKey(name: PayoutRequestView.paidAtKey_) DateTime? paidAt,@JsonKey(name: PayoutRequestView.failureReasonKey_) String? failureReason,@JsonKey(name: PayoutRequestView.referenceKey_) Map<String, dynamic>? reference,@JsonKey(name: PayoutRequestView.createdAtKey_) DateTime createdAt,@JsonKey(name: PayoutRequestView.updatedAtKey_) DateTime updatedAt
});




}
/// @nodoc
class _$PayoutRequestViewCopyWithImpl<$Res>
    implements $PayoutRequestViewCopyWith<$Res> {
  _$PayoutRequestViewCopyWithImpl(this._self, this._then);

  final PayoutRequestView _self;
  final $Res Function(PayoutRequestView) _then;

/// Create a copy of PayoutRequestView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? proUserId = null,Object? amountEur = null,Object? status = null,Object? requestedAt = null,Object? approvedByAdminId = freezed,Object? approvedAt = freezed,Object? paidAt = freezed,Object? failureReason = freezed,Object? reference = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,amountEur: null == amountEur ? _self.amountEur : amountEur // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PayoutRequestStatus,requestedAt: null == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as DateTime,approvedByAdminId: freezed == approvedByAdminId ? _self.approvedByAdminId : approvedByAdminId // ignore: cast_nullable_to_non_nullable
as String?,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,failureReason: freezed == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String?,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PayoutRequestView].
extension PayoutRequestViewPatterns on PayoutRequestView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PayoutRequestView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PayoutRequestView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PayoutRequestView value)  $default,){
final _that = this;
switch (_that) {
case _PayoutRequestView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PayoutRequestView value)?  $default,){
final _that = this;
switch (_that) {
case _PayoutRequestView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: PayoutRequestView.idKey_)  String id, @JsonKey(name: PayoutRequestView.proUserIdKey_)  String proUserId, @JsonKey(name: PayoutRequestView.amountEurKey_)  String amountEur, @JsonKey(name: PayoutRequestView.statusKey_)  PayoutRequestStatus status, @JsonKey(name: PayoutRequestView.requestedAtKey_)  DateTime requestedAt, @JsonKey(name: PayoutRequestView.approvedByAdminIdKey_)  String? approvedByAdminId, @JsonKey(name: PayoutRequestView.approvedAtKey_)  DateTime? approvedAt, @JsonKey(name: PayoutRequestView.paidAtKey_)  DateTime? paidAt, @JsonKey(name: PayoutRequestView.failureReasonKey_)  String? failureReason, @JsonKey(name: PayoutRequestView.referenceKey_)  Map<String, dynamic>? reference, @JsonKey(name: PayoutRequestView.createdAtKey_)  DateTime createdAt, @JsonKey(name: PayoutRequestView.updatedAtKey_)  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PayoutRequestView() when $default != null:
return $default(_that.id,_that.proUserId,_that.amountEur,_that.status,_that.requestedAt,_that.approvedByAdminId,_that.approvedAt,_that.paidAt,_that.failureReason,_that.reference,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: PayoutRequestView.idKey_)  String id, @JsonKey(name: PayoutRequestView.proUserIdKey_)  String proUserId, @JsonKey(name: PayoutRequestView.amountEurKey_)  String amountEur, @JsonKey(name: PayoutRequestView.statusKey_)  PayoutRequestStatus status, @JsonKey(name: PayoutRequestView.requestedAtKey_)  DateTime requestedAt, @JsonKey(name: PayoutRequestView.approvedByAdminIdKey_)  String? approvedByAdminId, @JsonKey(name: PayoutRequestView.approvedAtKey_)  DateTime? approvedAt, @JsonKey(name: PayoutRequestView.paidAtKey_)  DateTime? paidAt, @JsonKey(name: PayoutRequestView.failureReasonKey_)  String? failureReason, @JsonKey(name: PayoutRequestView.referenceKey_)  Map<String, dynamic>? reference, @JsonKey(name: PayoutRequestView.createdAtKey_)  DateTime createdAt, @JsonKey(name: PayoutRequestView.updatedAtKey_)  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PayoutRequestView():
return $default(_that.id,_that.proUserId,_that.amountEur,_that.status,_that.requestedAt,_that.approvedByAdminId,_that.approvedAt,_that.paidAt,_that.failureReason,_that.reference,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: PayoutRequestView.idKey_)  String id, @JsonKey(name: PayoutRequestView.proUserIdKey_)  String proUserId, @JsonKey(name: PayoutRequestView.amountEurKey_)  String amountEur, @JsonKey(name: PayoutRequestView.statusKey_)  PayoutRequestStatus status, @JsonKey(name: PayoutRequestView.requestedAtKey_)  DateTime requestedAt, @JsonKey(name: PayoutRequestView.approvedByAdminIdKey_)  String? approvedByAdminId, @JsonKey(name: PayoutRequestView.approvedAtKey_)  DateTime? approvedAt, @JsonKey(name: PayoutRequestView.paidAtKey_)  DateTime? paidAt, @JsonKey(name: PayoutRequestView.failureReasonKey_)  String? failureReason, @JsonKey(name: PayoutRequestView.referenceKey_)  Map<String, dynamic>? reference, @JsonKey(name: PayoutRequestView.createdAtKey_)  DateTime createdAt, @JsonKey(name: PayoutRequestView.updatedAtKey_)  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PayoutRequestView() when $default != null:
return $default(_that.id,_that.proUserId,_that.amountEur,_that.status,_that.requestedAt,_that.approvedByAdminId,_that.approvedAt,_that.paidAt,_that.failureReason,_that.reference,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _PayoutRequestView extends PayoutRequestView {
  const _PayoutRequestView({@JsonKey(name: PayoutRequestView.idKey_) required this.id, @JsonKey(name: PayoutRequestView.proUserIdKey_) required this.proUserId, @JsonKey(name: PayoutRequestView.amountEurKey_) required this.amountEur, @JsonKey(name: PayoutRequestView.statusKey_) required this.status, @JsonKey(name: PayoutRequestView.requestedAtKey_) required this.requestedAt, @JsonKey(name: PayoutRequestView.approvedByAdminIdKey_) this.approvedByAdminId, @JsonKey(name: PayoutRequestView.approvedAtKey_) this.approvedAt, @JsonKey(name: PayoutRequestView.paidAtKey_) this.paidAt, @JsonKey(name: PayoutRequestView.failureReasonKey_) this.failureReason, @JsonKey(name: PayoutRequestView.referenceKey_) final  Map<String, dynamic>? reference, @JsonKey(name: PayoutRequestView.createdAtKey_) required this.createdAt, @JsonKey(name: PayoutRequestView.updatedAtKey_) required this.updatedAt}): _reference = reference,super._();
  factory _PayoutRequestView.fromJson(Map<String, dynamic> json) => _$PayoutRequestViewFromJson(json);

/// id
@override@JsonKey(name: PayoutRequestView.idKey_) final  String id;
/// proUserId
@override@JsonKey(name: PayoutRequestView.proUserIdKey_) final  String proUserId;
/// amountEur
@override@JsonKey(name: PayoutRequestView.amountEurKey_) final  String amountEur;
/// status
@override@JsonKey(name: PayoutRequestView.statusKey_) final  PayoutRequestStatus status;
/// requestedAt
@override@JsonKey(name: PayoutRequestView.requestedAtKey_) final  DateTime requestedAt;
/// approvedByAdminId
@override@JsonKey(name: PayoutRequestView.approvedByAdminIdKey_) final  String? approvedByAdminId;
/// approvedAt
@override@JsonKey(name: PayoutRequestView.approvedAtKey_) final  DateTime? approvedAt;
/// paidAt
@override@JsonKey(name: PayoutRequestView.paidAtKey_) final  DateTime? paidAt;
/// failureReason
@override@JsonKey(name: PayoutRequestView.failureReasonKey_) final  String? failureReason;
/// reference
 final  Map<String, dynamic>? _reference;
/// reference
@override@JsonKey(name: PayoutRequestView.referenceKey_) Map<String, dynamic>? get reference {
  final value = _reference;
  if (value == null) return null;
  if (_reference is EqualUnmodifiableMapView) return _reference;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// createdAt
@override@JsonKey(name: PayoutRequestView.createdAtKey_) final  DateTime createdAt;
/// updatedAt
@override@JsonKey(name: PayoutRequestView.updatedAtKey_) final  DateTime updatedAt;

/// Create a copy of PayoutRequestView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PayoutRequestViewCopyWith<_PayoutRequestView> get copyWith => __$PayoutRequestViewCopyWithImpl<_PayoutRequestView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PayoutRequestViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PayoutRequestView&&(identical(other.id, id) || other.id == id)&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.amountEur, amountEur) || other.amountEur == amountEur)&&(identical(other.status, status) || other.status == status)&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt)&&(identical(other.approvedByAdminId, approvedByAdminId) || other.approvedByAdminId == approvedByAdminId)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.failureReason, failureReason) || other.failureReason == failureReason)&&const DeepCollectionEquality().equals(other._reference, _reference)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,proUserId,amountEur,status,requestedAt,approvedByAdminId,approvedAt,paidAt,failureReason,const DeepCollectionEquality().hash(_reference),createdAt,updatedAt);

@override
String toString() {
  return 'PayoutRequestView(id: $id, proUserId: $proUserId, amountEur: $amountEur, status: $status, requestedAt: $requestedAt, approvedByAdminId: $approvedByAdminId, approvedAt: $approvedAt, paidAt: $paidAt, failureReason: $failureReason, reference: $reference, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PayoutRequestViewCopyWith<$Res> implements $PayoutRequestViewCopyWith<$Res> {
  factory _$PayoutRequestViewCopyWith(_PayoutRequestView value, $Res Function(_PayoutRequestView) _then) = __$PayoutRequestViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: PayoutRequestView.idKey_) String id,@JsonKey(name: PayoutRequestView.proUserIdKey_) String proUserId,@JsonKey(name: PayoutRequestView.amountEurKey_) String amountEur,@JsonKey(name: PayoutRequestView.statusKey_) PayoutRequestStatus status,@JsonKey(name: PayoutRequestView.requestedAtKey_) DateTime requestedAt,@JsonKey(name: PayoutRequestView.approvedByAdminIdKey_) String? approvedByAdminId,@JsonKey(name: PayoutRequestView.approvedAtKey_) DateTime? approvedAt,@JsonKey(name: PayoutRequestView.paidAtKey_) DateTime? paidAt,@JsonKey(name: PayoutRequestView.failureReasonKey_) String? failureReason,@JsonKey(name: PayoutRequestView.referenceKey_) Map<String, dynamic>? reference,@JsonKey(name: PayoutRequestView.createdAtKey_) DateTime createdAt,@JsonKey(name: PayoutRequestView.updatedAtKey_) DateTime updatedAt
});




}
/// @nodoc
class __$PayoutRequestViewCopyWithImpl<$Res>
    implements _$PayoutRequestViewCopyWith<$Res> {
  __$PayoutRequestViewCopyWithImpl(this._self, this._then);

  final _PayoutRequestView _self;
  final $Res Function(_PayoutRequestView) _then;

/// Create a copy of PayoutRequestView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? proUserId = null,Object? amountEur = null,Object? status = null,Object? requestedAt = null,Object? approvedByAdminId = freezed,Object? approvedAt = freezed,Object? paidAt = freezed,Object? failureReason = freezed,Object? reference = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_PayoutRequestView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,amountEur: null == amountEur ? _self.amountEur : amountEur // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PayoutRequestStatus,requestedAt: null == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as DateTime,approvedByAdminId: freezed == approvedByAdminId ? _self.approvedByAdminId : approvedByAdminId // ignore: cast_nullable_to_non_nullable
as String?,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,failureReason: freezed == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String?,reference: freezed == reference ? _self._reference : reference // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
