// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'call_session_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CallSessionView {

/// id
@JsonKey(name: CallSessionView.idKey_) String get id;/// provider
@JsonKey(name: CallSessionView.providerKey_) String get provider;/// proUserId
@JsonKey(name: CallSessionView.proUserIdKey_) String? get proUserId;/// recipientUserId
@JsonKey(name: CallSessionView.recipientUserIdKey_) String get recipientUserId;/// recipientPhoneE164
@JsonKey(name: CallSessionView.recipientPhoneE164Key_) String get recipientPhoneE164;/// purpose
@JsonKey(name: CallSessionView.purposeKey_) CallPurpose get purpose;/// status
@JsonKey(name: CallSessionView.statusKey_) CallSessionStatus get status;/// providerCallId
@JsonKey(name: CallSessionView.providerCallIdKey_) String? get providerCallId;/// outcome
@JsonKey(name: CallSessionView.outcomeKey_) CallOutcome get outcome;/// transcript
@JsonKey(name: CallSessionView.transcriptKey_) String? get transcript;/// summary
@JsonKey(name: CallSessionView.summaryKey_) String? get summary;/// metadata
@JsonKey(name: CallSessionView.metadataKey_) Map<String, dynamic>? get metadata;/// createdAt
@JsonKey(name: CallSessionView.createdAtKey_) DateTime get createdAt;/// updatedAt
@JsonKey(name: CallSessionView.updatedAtKey_) DateTime get updatedAt;
/// Create a copy of CallSessionView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CallSessionViewCopyWith<CallSessionView> get copyWith => _$CallSessionViewCopyWithImpl<CallSessionView>(this as CallSessionView, _$identity);

  /// Serializes this CallSessionView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CallSessionView&&(identical(other.id, id) || other.id == id)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.recipientUserId, recipientUserId) || other.recipientUserId == recipientUserId)&&(identical(other.recipientPhoneE164, recipientPhoneE164) || other.recipientPhoneE164 == recipientPhoneE164)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.status, status) || other.status == status)&&(identical(other.providerCallId, providerCallId) || other.providerCallId == providerCallId)&&(identical(other.outcome, outcome) || other.outcome == outcome)&&(identical(other.transcript, transcript) || other.transcript == transcript)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,provider,proUserId,recipientUserId,recipientPhoneE164,purpose,status,providerCallId,outcome,transcript,summary,const DeepCollectionEquality().hash(metadata),createdAt,updatedAt);

@override
String toString() {
  return 'CallSessionView(id: $id, provider: $provider, proUserId: $proUserId, recipientUserId: $recipientUserId, recipientPhoneE164: $recipientPhoneE164, purpose: $purpose, status: $status, providerCallId: $providerCallId, outcome: $outcome, transcript: $transcript, summary: $summary, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CallSessionViewCopyWith<$Res>  {
  factory $CallSessionViewCopyWith(CallSessionView value, $Res Function(CallSessionView) _then) = _$CallSessionViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: CallSessionView.idKey_) String id,@JsonKey(name: CallSessionView.providerKey_) String provider,@JsonKey(name: CallSessionView.proUserIdKey_) String? proUserId,@JsonKey(name: CallSessionView.recipientUserIdKey_) String recipientUserId,@JsonKey(name: CallSessionView.recipientPhoneE164Key_) String recipientPhoneE164,@JsonKey(name: CallSessionView.purposeKey_) CallPurpose purpose,@JsonKey(name: CallSessionView.statusKey_) CallSessionStatus status,@JsonKey(name: CallSessionView.providerCallIdKey_) String? providerCallId,@JsonKey(name: CallSessionView.outcomeKey_) CallOutcome outcome,@JsonKey(name: CallSessionView.transcriptKey_) String? transcript,@JsonKey(name: CallSessionView.summaryKey_) String? summary,@JsonKey(name: CallSessionView.metadataKey_) Map<String, dynamic>? metadata,@JsonKey(name: CallSessionView.createdAtKey_) DateTime createdAt,@JsonKey(name: CallSessionView.updatedAtKey_) DateTime updatedAt
});




}
/// @nodoc
class _$CallSessionViewCopyWithImpl<$Res>
    implements $CallSessionViewCopyWith<$Res> {
  _$CallSessionViewCopyWithImpl(this._self, this._then);

  final CallSessionView _self;
  final $Res Function(CallSessionView) _then;

/// Create a copy of CallSessionView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? provider = null,Object? proUserId = freezed,Object? recipientUserId = null,Object? recipientPhoneE164 = null,Object? purpose = null,Object? status = null,Object? providerCallId = freezed,Object? outcome = null,Object? transcript = freezed,Object? summary = freezed,Object? metadata = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,proUserId: freezed == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String?,recipientUserId: null == recipientUserId ? _self.recipientUserId : recipientUserId // ignore: cast_nullable_to_non_nullable
as String,recipientPhoneE164: null == recipientPhoneE164 ? _self.recipientPhoneE164 : recipientPhoneE164 // ignore: cast_nullable_to_non_nullable
as String,purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as CallPurpose,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CallSessionStatus,providerCallId: freezed == providerCallId ? _self.providerCallId : providerCallId // ignore: cast_nullable_to_non_nullable
as String?,outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as CallOutcome,transcript: freezed == transcript ? _self.transcript : transcript // ignore: cast_nullable_to_non_nullable
as String?,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CallSessionView].
extension CallSessionViewPatterns on CallSessionView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CallSessionView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CallSessionView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CallSessionView value)  $default,){
final _that = this;
switch (_that) {
case _CallSessionView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CallSessionView value)?  $default,){
final _that = this;
switch (_that) {
case _CallSessionView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: CallSessionView.idKey_)  String id, @JsonKey(name: CallSessionView.providerKey_)  String provider, @JsonKey(name: CallSessionView.proUserIdKey_)  String? proUserId, @JsonKey(name: CallSessionView.recipientUserIdKey_)  String recipientUserId, @JsonKey(name: CallSessionView.recipientPhoneE164Key_)  String recipientPhoneE164, @JsonKey(name: CallSessionView.purposeKey_)  CallPurpose purpose, @JsonKey(name: CallSessionView.statusKey_)  CallSessionStatus status, @JsonKey(name: CallSessionView.providerCallIdKey_)  String? providerCallId, @JsonKey(name: CallSessionView.outcomeKey_)  CallOutcome outcome, @JsonKey(name: CallSessionView.transcriptKey_)  String? transcript, @JsonKey(name: CallSessionView.summaryKey_)  String? summary, @JsonKey(name: CallSessionView.metadataKey_)  Map<String, dynamic>? metadata, @JsonKey(name: CallSessionView.createdAtKey_)  DateTime createdAt, @JsonKey(name: CallSessionView.updatedAtKey_)  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CallSessionView() when $default != null:
return $default(_that.id,_that.provider,_that.proUserId,_that.recipientUserId,_that.recipientPhoneE164,_that.purpose,_that.status,_that.providerCallId,_that.outcome,_that.transcript,_that.summary,_that.metadata,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: CallSessionView.idKey_)  String id, @JsonKey(name: CallSessionView.providerKey_)  String provider, @JsonKey(name: CallSessionView.proUserIdKey_)  String? proUserId, @JsonKey(name: CallSessionView.recipientUserIdKey_)  String recipientUserId, @JsonKey(name: CallSessionView.recipientPhoneE164Key_)  String recipientPhoneE164, @JsonKey(name: CallSessionView.purposeKey_)  CallPurpose purpose, @JsonKey(name: CallSessionView.statusKey_)  CallSessionStatus status, @JsonKey(name: CallSessionView.providerCallIdKey_)  String? providerCallId, @JsonKey(name: CallSessionView.outcomeKey_)  CallOutcome outcome, @JsonKey(name: CallSessionView.transcriptKey_)  String? transcript, @JsonKey(name: CallSessionView.summaryKey_)  String? summary, @JsonKey(name: CallSessionView.metadataKey_)  Map<String, dynamic>? metadata, @JsonKey(name: CallSessionView.createdAtKey_)  DateTime createdAt, @JsonKey(name: CallSessionView.updatedAtKey_)  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _CallSessionView():
return $default(_that.id,_that.provider,_that.proUserId,_that.recipientUserId,_that.recipientPhoneE164,_that.purpose,_that.status,_that.providerCallId,_that.outcome,_that.transcript,_that.summary,_that.metadata,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: CallSessionView.idKey_)  String id, @JsonKey(name: CallSessionView.providerKey_)  String provider, @JsonKey(name: CallSessionView.proUserIdKey_)  String? proUserId, @JsonKey(name: CallSessionView.recipientUserIdKey_)  String recipientUserId, @JsonKey(name: CallSessionView.recipientPhoneE164Key_)  String recipientPhoneE164, @JsonKey(name: CallSessionView.purposeKey_)  CallPurpose purpose, @JsonKey(name: CallSessionView.statusKey_)  CallSessionStatus status, @JsonKey(name: CallSessionView.providerCallIdKey_)  String? providerCallId, @JsonKey(name: CallSessionView.outcomeKey_)  CallOutcome outcome, @JsonKey(name: CallSessionView.transcriptKey_)  String? transcript, @JsonKey(name: CallSessionView.summaryKey_)  String? summary, @JsonKey(name: CallSessionView.metadataKey_)  Map<String, dynamic>? metadata, @JsonKey(name: CallSessionView.createdAtKey_)  DateTime createdAt, @JsonKey(name: CallSessionView.updatedAtKey_)  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _CallSessionView() when $default != null:
return $default(_that.id,_that.provider,_that.proUserId,_that.recipientUserId,_that.recipientPhoneE164,_that.purpose,_that.status,_that.providerCallId,_that.outcome,_that.transcript,_that.summary,_that.metadata,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _CallSessionView extends CallSessionView {
  const _CallSessionView({@JsonKey(name: CallSessionView.idKey_) required this.id, @JsonKey(name: CallSessionView.providerKey_) required this.provider, @JsonKey(name: CallSessionView.proUserIdKey_) this.proUserId, @JsonKey(name: CallSessionView.recipientUserIdKey_) required this.recipientUserId, @JsonKey(name: CallSessionView.recipientPhoneE164Key_) required this.recipientPhoneE164, @JsonKey(name: CallSessionView.purposeKey_) required this.purpose, @JsonKey(name: CallSessionView.statusKey_) required this.status, @JsonKey(name: CallSessionView.providerCallIdKey_) this.providerCallId, @JsonKey(name: CallSessionView.outcomeKey_) required this.outcome, @JsonKey(name: CallSessionView.transcriptKey_) this.transcript, @JsonKey(name: CallSessionView.summaryKey_) this.summary, @JsonKey(name: CallSessionView.metadataKey_) final  Map<String, dynamic>? metadata, @JsonKey(name: CallSessionView.createdAtKey_) required this.createdAt, @JsonKey(name: CallSessionView.updatedAtKey_) required this.updatedAt}): _metadata = metadata,super._();
  factory _CallSessionView.fromJson(Map<String, dynamic> json) => _$CallSessionViewFromJson(json);

/// id
@override@JsonKey(name: CallSessionView.idKey_) final  String id;
/// provider
@override@JsonKey(name: CallSessionView.providerKey_) final  String provider;
/// proUserId
@override@JsonKey(name: CallSessionView.proUserIdKey_) final  String? proUserId;
/// recipientUserId
@override@JsonKey(name: CallSessionView.recipientUserIdKey_) final  String recipientUserId;
/// recipientPhoneE164
@override@JsonKey(name: CallSessionView.recipientPhoneE164Key_) final  String recipientPhoneE164;
/// purpose
@override@JsonKey(name: CallSessionView.purposeKey_) final  CallPurpose purpose;
/// status
@override@JsonKey(name: CallSessionView.statusKey_) final  CallSessionStatus status;
/// providerCallId
@override@JsonKey(name: CallSessionView.providerCallIdKey_) final  String? providerCallId;
/// outcome
@override@JsonKey(name: CallSessionView.outcomeKey_) final  CallOutcome outcome;
/// transcript
@override@JsonKey(name: CallSessionView.transcriptKey_) final  String? transcript;
/// summary
@override@JsonKey(name: CallSessionView.summaryKey_) final  String? summary;
/// metadata
 final  Map<String, dynamic>? _metadata;
/// metadata
@override@JsonKey(name: CallSessionView.metadataKey_) Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// createdAt
@override@JsonKey(name: CallSessionView.createdAtKey_) final  DateTime createdAt;
/// updatedAt
@override@JsonKey(name: CallSessionView.updatedAtKey_) final  DateTime updatedAt;

/// Create a copy of CallSessionView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CallSessionViewCopyWith<_CallSessionView> get copyWith => __$CallSessionViewCopyWithImpl<_CallSessionView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CallSessionViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CallSessionView&&(identical(other.id, id) || other.id == id)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.recipientUserId, recipientUserId) || other.recipientUserId == recipientUserId)&&(identical(other.recipientPhoneE164, recipientPhoneE164) || other.recipientPhoneE164 == recipientPhoneE164)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.status, status) || other.status == status)&&(identical(other.providerCallId, providerCallId) || other.providerCallId == providerCallId)&&(identical(other.outcome, outcome) || other.outcome == outcome)&&(identical(other.transcript, transcript) || other.transcript == transcript)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,provider,proUserId,recipientUserId,recipientPhoneE164,purpose,status,providerCallId,outcome,transcript,summary,const DeepCollectionEquality().hash(_metadata),createdAt,updatedAt);

@override
String toString() {
  return 'CallSessionView(id: $id, provider: $provider, proUserId: $proUserId, recipientUserId: $recipientUserId, recipientPhoneE164: $recipientPhoneE164, purpose: $purpose, status: $status, providerCallId: $providerCallId, outcome: $outcome, transcript: $transcript, summary: $summary, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CallSessionViewCopyWith<$Res> implements $CallSessionViewCopyWith<$Res> {
  factory _$CallSessionViewCopyWith(_CallSessionView value, $Res Function(_CallSessionView) _then) = __$CallSessionViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: CallSessionView.idKey_) String id,@JsonKey(name: CallSessionView.providerKey_) String provider,@JsonKey(name: CallSessionView.proUserIdKey_) String? proUserId,@JsonKey(name: CallSessionView.recipientUserIdKey_) String recipientUserId,@JsonKey(name: CallSessionView.recipientPhoneE164Key_) String recipientPhoneE164,@JsonKey(name: CallSessionView.purposeKey_) CallPurpose purpose,@JsonKey(name: CallSessionView.statusKey_) CallSessionStatus status,@JsonKey(name: CallSessionView.providerCallIdKey_) String? providerCallId,@JsonKey(name: CallSessionView.outcomeKey_) CallOutcome outcome,@JsonKey(name: CallSessionView.transcriptKey_) String? transcript,@JsonKey(name: CallSessionView.summaryKey_) String? summary,@JsonKey(name: CallSessionView.metadataKey_) Map<String, dynamic>? metadata,@JsonKey(name: CallSessionView.createdAtKey_) DateTime createdAt,@JsonKey(name: CallSessionView.updatedAtKey_) DateTime updatedAt
});




}
/// @nodoc
class __$CallSessionViewCopyWithImpl<$Res>
    implements _$CallSessionViewCopyWith<$Res> {
  __$CallSessionViewCopyWithImpl(this._self, this._then);

  final _CallSessionView _self;
  final $Res Function(_CallSessionView) _then;

/// Create a copy of CallSessionView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? provider = null,Object? proUserId = freezed,Object? recipientUserId = null,Object? recipientPhoneE164 = null,Object? purpose = null,Object? status = null,Object? providerCallId = freezed,Object? outcome = null,Object? transcript = freezed,Object? summary = freezed,Object? metadata = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_CallSessionView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,proUserId: freezed == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String?,recipientUserId: null == recipientUserId ? _self.recipientUserId : recipientUserId // ignore: cast_nullable_to_non_nullable
as String,recipientPhoneE164: null == recipientPhoneE164 ? _self.recipientPhoneE164 : recipientPhoneE164 // ignore: cast_nullable_to_non_nullable
as String,purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as CallPurpose,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CallSessionStatus,providerCallId: freezed == providerCallId ? _self.providerCallId : providerCallId // ignore: cast_nullable_to_non_nullable
as String?,outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as CallOutcome,transcript: freezed == transcript ? _self.transcript : transcript // ignore: cast_nullable_to_non_nullable
as String?,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
