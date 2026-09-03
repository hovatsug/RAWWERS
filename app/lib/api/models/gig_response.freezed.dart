// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gig_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GigResponse {

/// id
@JsonKey(name: GigResponse.idKey_) String get id;/// clientUserId
@JsonKey(name: GigResponse.clientUserIdKey_) String get clientUserId;/// proUserId
@JsonKey(name: GigResponse.proUserIdKey_) String get proUserId;/// nicheId
@JsonKey(name: GigResponse.nicheIdKey_) String? get nicheId;/// status
@JsonKey(name: GigResponse.statusKey_) GigStatus get status;/// currency
@JsonKey(name: GigResponse.currencyKey_) String get currency;/// amountMinimum
@JsonKey(name: GigResponse.amountMinimumKey_) String get amountMinimum;/// amountFinal
@JsonKey(name: GigResponse.amountFinalKey_) String? get amountFinal;/// amountPlatformFee
@JsonKey(name: GigResponse.amountPlatformFeeKey_) String get amountPlatformFee;/// amountProGross
@JsonKey(name: GigResponse.amountProGrossKey_) String get amountProGross;/// locationText
@JsonKey(name: GigResponse.locationTextKey_) String? get locationText;/// scheduledStart
@JsonKey(name: GigResponse.scheduledStartKey_) DateTime? get scheduledStart;/// scheduledEnd
@JsonKey(name: GigResponse.scheduledEndKey_) DateTime? get scheduledEnd;/// metadata
@JsonKey(name: GigResponse.metadataKey_) Map<String, dynamic>? get metadata;/// createdAt
@JsonKey(name: GigResponse.createdAtKey_) DateTime get createdAt;/// updatedAt
@JsonKey(name: GigResponse.updatedAtKey_) DateTime get updatedAt;
/// Create a copy of GigResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GigResponseCopyWith<GigResponse> get copyWith => _$GigResponseCopyWithImpl<GigResponse>(this as GigResponse, _$identity);

  /// Serializes this GigResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GigResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.clientUserId, clientUserId) || other.clientUserId == clientUserId)&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.nicheId, nicheId) || other.nicheId == nicheId)&&(identical(other.status, status) || other.status == status)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.amountMinimum, amountMinimum) || other.amountMinimum == amountMinimum)&&(identical(other.amountFinal, amountFinal) || other.amountFinal == amountFinal)&&(identical(other.amountPlatformFee, amountPlatformFee) || other.amountPlatformFee == amountPlatformFee)&&(identical(other.amountProGross, amountProGross) || other.amountProGross == amountProGross)&&(identical(other.locationText, locationText) || other.locationText == locationText)&&(identical(other.scheduledStart, scheduledStart) || other.scheduledStart == scheduledStart)&&(identical(other.scheduledEnd, scheduledEnd) || other.scheduledEnd == scheduledEnd)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,clientUserId,proUserId,nicheId,status,currency,amountMinimum,amountFinal,amountPlatformFee,amountProGross,locationText,scheduledStart,scheduledEnd,const DeepCollectionEquality().hash(metadata),createdAt,updatedAt);

@override
String toString() {
  return 'GigResponse(id: $id, clientUserId: $clientUserId, proUserId: $proUserId, nicheId: $nicheId, status: $status, currency: $currency, amountMinimum: $amountMinimum, amountFinal: $amountFinal, amountPlatformFee: $amountPlatformFee, amountProGross: $amountProGross, locationText: $locationText, scheduledStart: $scheduledStart, scheduledEnd: $scheduledEnd, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $GigResponseCopyWith<$Res>  {
  factory $GigResponseCopyWith(GigResponse value, $Res Function(GigResponse) _then) = _$GigResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: GigResponse.idKey_) String id,@JsonKey(name: GigResponse.clientUserIdKey_) String clientUserId,@JsonKey(name: GigResponse.proUserIdKey_) String proUserId,@JsonKey(name: GigResponse.nicheIdKey_) String? nicheId,@JsonKey(name: GigResponse.statusKey_) GigStatus status,@JsonKey(name: GigResponse.currencyKey_) String currency,@JsonKey(name: GigResponse.amountMinimumKey_) String amountMinimum,@JsonKey(name: GigResponse.amountFinalKey_) String? amountFinal,@JsonKey(name: GigResponse.amountPlatformFeeKey_) String amountPlatformFee,@JsonKey(name: GigResponse.amountProGrossKey_) String amountProGross,@JsonKey(name: GigResponse.locationTextKey_) String? locationText,@JsonKey(name: GigResponse.scheduledStartKey_) DateTime? scheduledStart,@JsonKey(name: GigResponse.scheduledEndKey_) DateTime? scheduledEnd,@JsonKey(name: GigResponse.metadataKey_) Map<String, dynamic>? metadata,@JsonKey(name: GigResponse.createdAtKey_) DateTime createdAt,@JsonKey(name: GigResponse.updatedAtKey_) DateTime updatedAt
});




}
/// @nodoc
class _$GigResponseCopyWithImpl<$Res>
    implements $GigResponseCopyWith<$Res> {
  _$GigResponseCopyWithImpl(this._self, this._then);

  final GigResponse _self;
  final $Res Function(GigResponse) _then;

/// Create a copy of GigResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? clientUserId = null,Object? proUserId = null,Object? nicheId = freezed,Object? status = null,Object? currency = null,Object? amountMinimum = null,Object? amountFinal = freezed,Object? amountPlatformFee = null,Object? amountProGross = null,Object? locationText = freezed,Object? scheduledStart = freezed,Object? scheduledEnd = freezed,Object? metadata = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,clientUserId: null == clientUserId ? _self.clientUserId : clientUserId // ignore: cast_nullable_to_non_nullable
as String,proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,nicheId: freezed == nicheId ? _self.nicheId : nicheId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GigStatus,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,amountMinimum: null == amountMinimum ? _self.amountMinimum : amountMinimum // ignore: cast_nullable_to_non_nullable
as String,amountFinal: freezed == amountFinal ? _self.amountFinal : amountFinal // ignore: cast_nullable_to_non_nullable
as String?,amountPlatformFee: null == amountPlatformFee ? _self.amountPlatformFee : amountPlatformFee // ignore: cast_nullable_to_non_nullable
as String,amountProGross: null == amountProGross ? _self.amountProGross : amountProGross // ignore: cast_nullable_to_non_nullable
as String,locationText: freezed == locationText ? _self.locationText : locationText // ignore: cast_nullable_to_non_nullable
as String?,scheduledStart: freezed == scheduledStart ? _self.scheduledStart : scheduledStart // ignore: cast_nullable_to_non_nullable
as DateTime?,scheduledEnd: freezed == scheduledEnd ? _self.scheduledEnd : scheduledEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [GigResponse].
extension GigResponsePatterns on GigResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GigResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GigResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GigResponse value)  $default,){
final _that = this;
switch (_that) {
case _GigResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GigResponse value)?  $default,){
final _that = this;
switch (_that) {
case _GigResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: GigResponse.idKey_)  String id, @JsonKey(name: GigResponse.clientUserIdKey_)  String clientUserId, @JsonKey(name: GigResponse.proUserIdKey_)  String proUserId, @JsonKey(name: GigResponse.nicheIdKey_)  String? nicheId, @JsonKey(name: GigResponse.statusKey_)  GigStatus status, @JsonKey(name: GigResponse.currencyKey_)  String currency, @JsonKey(name: GigResponse.amountMinimumKey_)  String amountMinimum, @JsonKey(name: GigResponse.amountFinalKey_)  String? amountFinal, @JsonKey(name: GigResponse.amountPlatformFeeKey_)  String amountPlatformFee, @JsonKey(name: GigResponse.amountProGrossKey_)  String amountProGross, @JsonKey(name: GigResponse.locationTextKey_)  String? locationText, @JsonKey(name: GigResponse.scheduledStartKey_)  DateTime? scheduledStart, @JsonKey(name: GigResponse.scheduledEndKey_)  DateTime? scheduledEnd, @JsonKey(name: GigResponse.metadataKey_)  Map<String, dynamic>? metadata, @JsonKey(name: GigResponse.createdAtKey_)  DateTime createdAt, @JsonKey(name: GigResponse.updatedAtKey_)  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GigResponse() when $default != null:
return $default(_that.id,_that.clientUserId,_that.proUserId,_that.nicheId,_that.status,_that.currency,_that.amountMinimum,_that.amountFinal,_that.amountPlatformFee,_that.amountProGross,_that.locationText,_that.scheduledStart,_that.scheduledEnd,_that.metadata,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: GigResponse.idKey_)  String id, @JsonKey(name: GigResponse.clientUserIdKey_)  String clientUserId, @JsonKey(name: GigResponse.proUserIdKey_)  String proUserId, @JsonKey(name: GigResponse.nicheIdKey_)  String? nicheId, @JsonKey(name: GigResponse.statusKey_)  GigStatus status, @JsonKey(name: GigResponse.currencyKey_)  String currency, @JsonKey(name: GigResponse.amountMinimumKey_)  String amountMinimum, @JsonKey(name: GigResponse.amountFinalKey_)  String? amountFinal, @JsonKey(name: GigResponse.amountPlatformFeeKey_)  String amountPlatformFee, @JsonKey(name: GigResponse.amountProGrossKey_)  String amountProGross, @JsonKey(name: GigResponse.locationTextKey_)  String? locationText, @JsonKey(name: GigResponse.scheduledStartKey_)  DateTime? scheduledStart, @JsonKey(name: GigResponse.scheduledEndKey_)  DateTime? scheduledEnd, @JsonKey(name: GigResponse.metadataKey_)  Map<String, dynamic>? metadata, @JsonKey(name: GigResponse.createdAtKey_)  DateTime createdAt, @JsonKey(name: GigResponse.updatedAtKey_)  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _GigResponse():
return $default(_that.id,_that.clientUserId,_that.proUserId,_that.nicheId,_that.status,_that.currency,_that.amountMinimum,_that.amountFinal,_that.amountPlatformFee,_that.amountProGross,_that.locationText,_that.scheduledStart,_that.scheduledEnd,_that.metadata,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: GigResponse.idKey_)  String id, @JsonKey(name: GigResponse.clientUserIdKey_)  String clientUserId, @JsonKey(name: GigResponse.proUserIdKey_)  String proUserId, @JsonKey(name: GigResponse.nicheIdKey_)  String? nicheId, @JsonKey(name: GigResponse.statusKey_)  GigStatus status, @JsonKey(name: GigResponse.currencyKey_)  String currency, @JsonKey(name: GigResponse.amountMinimumKey_)  String amountMinimum, @JsonKey(name: GigResponse.amountFinalKey_)  String? amountFinal, @JsonKey(name: GigResponse.amountPlatformFeeKey_)  String amountPlatformFee, @JsonKey(name: GigResponse.amountProGrossKey_)  String amountProGross, @JsonKey(name: GigResponse.locationTextKey_)  String? locationText, @JsonKey(name: GigResponse.scheduledStartKey_)  DateTime? scheduledStart, @JsonKey(name: GigResponse.scheduledEndKey_)  DateTime? scheduledEnd, @JsonKey(name: GigResponse.metadataKey_)  Map<String, dynamic>? metadata, @JsonKey(name: GigResponse.createdAtKey_)  DateTime createdAt, @JsonKey(name: GigResponse.updatedAtKey_)  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _GigResponse() when $default != null:
return $default(_that.id,_that.clientUserId,_that.proUserId,_that.nicheId,_that.status,_that.currency,_that.amountMinimum,_that.amountFinal,_that.amountPlatformFee,_that.amountProGross,_that.locationText,_that.scheduledStart,_that.scheduledEnd,_that.metadata,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _GigResponse extends GigResponse {
  const _GigResponse({@JsonKey(name: GigResponse.idKey_) required this.id, @JsonKey(name: GigResponse.clientUserIdKey_) required this.clientUserId, @JsonKey(name: GigResponse.proUserIdKey_) required this.proUserId, @JsonKey(name: GigResponse.nicheIdKey_) this.nicheId, @JsonKey(name: GigResponse.statusKey_) required this.status, @JsonKey(name: GigResponse.currencyKey_) required this.currency, @JsonKey(name: GigResponse.amountMinimumKey_) required this.amountMinimum, @JsonKey(name: GigResponse.amountFinalKey_) this.amountFinal, @JsonKey(name: GigResponse.amountPlatformFeeKey_) required this.amountPlatformFee, @JsonKey(name: GigResponse.amountProGrossKey_) required this.amountProGross, @JsonKey(name: GigResponse.locationTextKey_) required this.locationText, @JsonKey(name: GigResponse.scheduledStartKey_) required this.scheduledStart, @JsonKey(name: GigResponse.scheduledEndKey_) required this.scheduledEnd, @JsonKey(name: GigResponse.metadataKey_) final  Map<String, dynamic>? metadata, @JsonKey(name: GigResponse.createdAtKey_) required this.createdAt, @JsonKey(name: GigResponse.updatedAtKey_) required this.updatedAt}): _metadata = metadata,super._();
  factory _GigResponse.fromJson(Map<String, dynamic> json) => _$GigResponseFromJson(json);

/// id
@override@JsonKey(name: GigResponse.idKey_) final  String id;
/// clientUserId
@override@JsonKey(name: GigResponse.clientUserIdKey_) final  String clientUserId;
/// proUserId
@override@JsonKey(name: GigResponse.proUserIdKey_) final  String proUserId;
/// nicheId
@override@JsonKey(name: GigResponse.nicheIdKey_) final  String? nicheId;
/// status
@override@JsonKey(name: GigResponse.statusKey_) final  GigStatus status;
/// currency
@override@JsonKey(name: GigResponse.currencyKey_) final  String currency;
/// amountMinimum
@override@JsonKey(name: GigResponse.amountMinimumKey_) final  String amountMinimum;
/// amountFinal
@override@JsonKey(name: GigResponse.amountFinalKey_) final  String? amountFinal;
/// amountPlatformFee
@override@JsonKey(name: GigResponse.amountPlatformFeeKey_) final  String amountPlatformFee;
/// amountProGross
@override@JsonKey(name: GigResponse.amountProGrossKey_) final  String amountProGross;
/// locationText
@override@JsonKey(name: GigResponse.locationTextKey_) final  String? locationText;
/// scheduledStart
@override@JsonKey(name: GigResponse.scheduledStartKey_) final  DateTime? scheduledStart;
/// scheduledEnd
@override@JsonKey(name: GigResponse.scheduledEndKey_) final  DateTime? scheduledEnd;
/// metadata
 final  Map<String, dynamic>? _metadata;
/// metadata
@override@JsonKey(name: GigResponse.metadataKey_) Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// createdAt
@override@JsonKey(name: GigResponse.createdAtKey_) final  DateTime createdAt;
/// updatedAt
@override@JsonKey(name: GigResponse.updatedAtKey_) final  DateTime updatedAt;

/// Create a copy of GigResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GigResponseCopyWith<_GigResponse> get copyWith => __$GigResponseCopyWithImpl<_GigResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GigResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GigResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.clientUserId, clientUserId) || other.clientUserId == clientUserId)&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.nicheId, nicheId) || other.nicheId == nicheId)&&(identical(other.status, status) || other.status == status)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.amountMinimum, amountMinimum) || other.amountMinimum == amountMinimum)&&(identical(other.amountFinal, amountFinal) || other.amountFinal == amountFinal)&&(identical(other.amountPlatformFee, amountPlatformFee) || other.amountPlatformFee == amountPlatformFee)&&(identical(other.amountProGross, amountProGross) || other.amountProGross == amountProGross)&&(identical(other.locationText, locationText) || other.locationText == locationText)&&(identical(other.scheduledStart, scheduledStart) || other.scheduledStart == scheduledStart)&&(identical(other.scheduledEnd, scheduledEnd) || other.scheduledEnd == scheduledEnd)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,clientUserId,proUserId,nicheId,status,currency,amountMinimum,amountFinal,amountPlatformFee,amountProGross,locationText,scheduledStart,scheduledEnd,const DeepCollectionEquality().hash(_metadata),createdAt,updatedAt);

@override
String toString() {
  return 'GigResponse(id: $id, clientUserId: $clientUserId, proUserId: $proUserId, nicheId: $nicheId, status: $status, currency: $currency, amountMinimum: $amountMinimum, amountFinal: $amountFinal, amountPlatformFee: $amountPlatformFee, amountProGross: $amountProGross, locationText: $locationText, scheduledStart: $scheduledStart, scheduledEnd: $scheduledEnd, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$GigResponseCopyWith<$Res> implements $GigResponseCopyWith<$Res> {
  factory _$GigResponseCopyWith(_GigResponse value, $Res Function(_GigResponse) _then) = __$GigResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: GigResponse.idKey_) String id,@JsonKey(name: GigResponse.clientUserIdKey_) String clientUserId,@JsonKey(name: GigResponse.proUserIdKey_) String proUserId,@JsonKey(name: GigResponse.nicheIdKey_) String? nicheId,@JsonKey(name: GigResponse.statusKey_) GigStatus status,@JsonKey(name: GigResponse.currencyKey_) String currency,@JsonKey(name: GigResponse.amountMinimumKey_) String amountMinimum,@JsonKey(name: GigResponse.amountFinalKey_) String? amountFinal,@JsonKey(name: GigResponse.amountPlatformFeeKey_) String amountPlatformFee,@JsonKey(name: GigResponse.amountProGrossKey_) String amountProGross,@JsonKey(name: GigResponse.locationTextKey_) String? locationText,@JsonKey(name: GigResponse.scheduledStartKey_) DateTime? scheduledStart,@JsonKey(name: GigResponse.scheduledEndKey_) DateTime? scheduledEnd,@JsonKey(name: GigResponse.metadataKey_) Map<String, dynamic>? metadata,@JsonKey(name: GigResponse.createdAtKey_) DateTime createdAt,@JsonKey(name: GigResponse.updatedAtKey_) DateTime updatedAt
});




}
/// @nodoc
class __$GigResponseCopyWithImpl<$Res>
    implements _$GigResponseCopyWith<$Res> {
  __$GigResponseCopyWithImpl(this._self, this._then);

  final _GigResponse _self;
  final $Res Function(_GigResponse) _then;

/// Create a copy of GigResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? clientUserId = null,Object? proUserId = null,Object? nicheId = freezed,Object? status = null,Object? currency = null,Object? amountMinimum = null,Object? amountFinal = freezed,Object? amountPlatformFee = null,Object? amountProGross = null,Object? locationText = freezed,Object? scheduledStart = freezed,Object? scheduledEnd = freezed,Object? metadata = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_GigResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,clientUserId: null == clientUserId ? _self.clientUserId : clientUserId // ignore: cast_nullable_to_non_nullable
as String,proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,nicheId: freezed == nicheId ? _self.nicheId : nicheId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GigStatus,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,amountMinimum: null == amountMinimum ? _self.amountMinimum : amountMinimum // ignore: cast_nullable_to_non_nullable
as String,amountFinal: freezed == amountFinal ? _self.amountFinal : amountFinal // ignore: cast_nullable_to_non_nullable
as String?,amountPlatformFee: null == amountPlatformFee ? _self.amountPlatformFee : amountPlatformFee // ignore: cast_nullable_to_non_nullable
as String,amountProGross: null == amountProGross ? _self.amountProGross : amountProGross // ignore: cast_nullable_to_non_nullable
as String,locationText: freezed == locationText ? _self.locationText : locationText // ignore: cast_nullable_to_non_nullable
as String?,scheduledStart: freezed == scheduledStart ? _self.scheduledStart : scheduledStart // ignore: cast_nullable_to_non_nullable
as DateTime?,scheduledEnd: freezed == scheduledEnd ? _self.scheduledEnd : scheduledEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
