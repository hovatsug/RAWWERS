// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'call_request_body.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CallRequestBody {

/// recipientUserId
@JsonKey(name: CallRequestBody.recipientUserIdKey_) String get recipientUserId;/// proUserId
@JsonKey(name: CallRequestBody.proUserIdKey_) String? get proUserId;/// purpose
@JsonKey(name: CallRequestBody.purposeKey_) CallPurpose get purpose;/// targetType
@JsonKey(name: CallRequestBody.targetTypeKey_) String? get targetType;/// targetId
@JsonKey(name: CallRequestBody.targetIdKey_) String? get targetId;/// source
@JsonKey(name: CallRequestBody.sourceKey_) String get source;/// metadata
@JsonKey(name: CallRequestBody.metadataKey_) Map<String, dynamic>? get metadata;
/// Create a copy of CallRequestBody
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CallRequestBodyCopyWith<CallRequestBody> get copyWith => _$CallRequestBodyCopyWithImpl<CallRequestBody>(this as CallRequestBody, _$identity);

  /// Serializes this CallRequestBody to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CallRequestBody&&(identical(other.recipientUserId, recipientUserId) || other.recipientUserId == recipientUserId)&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.targetType, targetType) || other.targetType == targetType)&&(identical(other.targetId, targetId) || other.targetId == targetId)&&(identical(other.source, source) || other.source == source)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recipientUserId,proUserId,purpose,targetType,targetId,source,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'CallRequestBody(recipientUserId: $recipientUserId, proUserId: $proUserId, purpose: $purpose, targetType: $targetType, targetId: $targetId, source: $source, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $CallRequestBodyCopyWith<$Res>  {
  factory $CallRequestBodyCopyWith(CallRequestBody value, $Res Function(CallRequestBody) _then) = _$CallRequestBodyCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: CallRequestBody.recipientUserIdKey_) String recipientUserId,@JsonKey(name: CallRequestBody.proUserIdKey_) String? proUserId,@JsonKey(name: CallRequestBody.purposeKey_) CallPurpose purpose,@JsonKey(name: CallRequestBody.targetTypeKey_) String? targetType,@JsonKey(name: CallRequestBody.targetIdKey_) String? targetId,@JsonKey(name: CallRequestBody.sourceKey_) String source,@JsonKey(name: CallRequestBody.metadataKey_) Map<String, dynamic>? metadata
});




}
/// @nodoc
class _$CallRequestBodyCopyWithImpl<$Res>
    implements $CallRequestBodyCopyWith<$Res> {
  _$CallRequestBodyCopyWithImpl(this._self, this._then);

  final CallRequestBody _self;
  final $Res Function(CallRequestBody) _then;

/// Create a copy of CallRequestBody
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? recipientUserId = null,Object? proUserId = freezed,Object? purpose = null,Object? targetType = freezed,Object? targetId = freezed,Object? source = null,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
recipientUserId: null == recipientUserId ? _self.recipientUserId : recipientUserId // ignore: cast_nullable_to_non_nullable
as String,proUserId: freezed == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String?,purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as CallPurpose,targetType: freezed == targetType ? _self.targetType : targetType // ignore: cast_nullable_to_non_nullable
as String?,targetId: freezed == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [CallRequestBody].
extension CallRequestBodyPatterns on CallRequestBody {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CallRequestBody value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CallRequestBody() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CallRequestBody value)  $default,){
final _that = this;
switch (_that) {
case _CallRequestBody():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CallRequestBody value)?  $default,){
final _that = this;
switch (_that) {
case _CallRequestBody() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: CallRequestBody.recipientUserIdKey_)  String recipientUserId, @JsonKey(name: CallRequestBody.proUserIdKey_)  String? proUserId, @JsonKey(name: CallRequestBody.purposeKey_)  CallPurpose purpose, @JsonKey(name: CallRequestBody.targetTypeKey_)  String? targetType, @JsonKey(name: CallRequestBody.targetIdKey_)  String? targetId, @JsonKey(name: CallRequestBody.sourceKey_)  String source, @JsonKey(name: CallRequestBody.metadataKey_)  Map<String, dynamic>? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CallRequestBody() when $default != null:
return $default(_that.recipientUserId,_that.proUserId,_that.purpose,_that.targetType,_that.targetId,_that.source,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: CallRequestBody.recipientUserIdKey_)  String recipientUserId, @JsonKey(name: CallRequestBody.proUserIdKey_)  String? proUserId, @JsonKey(name: CallRequestBody.purposeKey_)  CallPurpose purpose, @JsonKey(name: CallRequestBody.targetTypeKey_)  String? targetType, @JsonKey(name: CallRequestBody.targetIdKey_)  String? targetId, @JsonKey(name: CallRequestBody.sourceKey_)  String source, @JsonKey(name: CallRequestBody.metadataKey_)  Map<String, dynamic>? metadata)  $default,) {final _that = this;
switch (_that) {
case _CallRequestBody():
return $default(_that.recipientUserId,_that.proUserId,_that.purpose,_that.targetType,_that.targetId,_that.source,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: CallRequestBody.recipientUserIdKey_)  String recipientUserId, @JsonKey(name: CallRequestBody.proUserIdKey_)  String? proUserId, @JsonKey(name: CallRequestBody.purposeKey_)  CallPurpose purpose, @JsonKey(name: CallRequestBody.targetTypeKey_)  String? targetType, @JsonKey(name: CallRequestBody.targetIdKey_)  String? targetId, @JsonKey(name: CallRequestBody.sourceKey_)  String source, @JsonKey(name: CallRequestBody.metadataKey_)  Map<String, dynamic>? metadata)?  $default,) {final _that = this;
switch (_that) {
case _CallRequestBody() when $default != null:
return $default(_that.recipientUserId,_that.proUserId,_that.purpose,_that.targetType,_that.targetId,_that.source,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _CallRequestBody extends CallRequestBody {
  const _CallRequestBody({@JsonKey(name: CallRequestBody.recipientUserIdKey_) required this.recipientUserId, @JsonKey(name: CallRequestBody.proUserIdKey_) this.proUserId, @JsonKey(name: CallRequestBody.purposeKey_) required this.purpose, @JsonKey(name: CallRequestBody.targetTypeKey_) this.targetType, @JsonKey(name: CallRequestBody.targetIdKey_) this.targetId, @JsonKey(name: CallRequestBody.sourceKey_) this.source = 'in_app', @JsonKey(name: CallRequestBody.metadataKey_) final  Map<String, dynamic>? metadata}): _metadata = metadata,super._();
  factory _CallRequestBody.fromJson(Map<String, dynamic> json) => _$CallRequestBodyFromJson(json);

/// recipientUserId
@override@JsonKey(name: CallRequestBody.recipientUserIdKey_) final  String recipientUserId;
/// proUserId
@override@JsonKey(name: CallRequestBody.proUserIdKey_) final  String? proUserId;
/// purpose
@override@JsonKey(name: CallRequestBody.purposeKey_) final  CallPurpose purpose;
/// targetType
@override@JsonKey(name: CallRequestBody.targetTypeKey_) final  String? targetType;
/// targetId
@override@JsonKey(name: CallRequestBody.targetIdKey_) final  String? targetId;
/// source
@override@JsonKey(name: CallRequestBody.sourceKey_) final  String source;
/// metadata
 final  Map<String, dynamic>? _metadata;
/// metadata
@override@JsonKey(name: CallRequestBody.metadataKey_) Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of CallRequestBody
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CallRequestBodyCopyWith<_CallRequestBody> get copyWith => __$CallRequestBodyCopyWithImpl<_CallRequestBody>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CallRequestBodyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CallRequestBody&&(identical(other.recipientUserId, recipientUserId) || other.recipientUserId == recipientUserId)&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.targetType, targetType) || other.targetType == targetType)&&(identical(other.targetId, targetId) || other.targetId == targetId)&&(identical(other.source, source) || other.source == source)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recipientUserId,proUserId,purpose,targetType,targetId,source,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'CallRequestBody(recipientUserId: $recipientUserId, proUserId: $proUserId, purpose: $purpose, targetType: $targetType, targetId: $targetId, source: $source, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$CallRequestBodyCopyWith<$Res> implements $CallRequestBodyCopyWith<$Res> {
  factory _$CallRequestBodyCopyWith(_CallRequestBody value, $Res Function(_CallRequestBody) _then) = __$CallRequestBodyCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: CallRequestBody.recipientUserIdKey_) String recipientUserId,@JsonKey(name: CallRequestBody.proUserIdKey_) String? proUserId,@JsonKey(name: CallRequestBody.purposeKey_) CallPurpose purpose,@JsonKey(name: CallRequestBody.targetTypeKey_) String? targetType,@JsonKey(name: CallRequestBody.targetIdKey_) String? targetId,@JsonKey(name: CallRequestBody.sourceKey_) String source,@JsonKey(name: CallRequestBody.metadataKey_) Map<String, dynamic>? metadata
});




}
/// @nodoc
class __$CallRequestBodyCopyWithImpl<$Res>
    implements _$CallRequestBodyCopyWith<$Res> {
  __$CallRequestBodyCopyWithImpl(this._self, this._then);

  final _CallRequestBody _self;
  final $Res Function(_CallRequestBody) _then;

/// Create a copy of CallRequestBody
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recipientUserId = null,Object? proUserId = freezed,Object? purpose = null,Object? targetType = freezed,Object? targetId = freezed,Object? source = null,Object? metadata = freezed,}) {
  return _then(_CallRequestBody(
recipientUserId: null == recipientUserId ? _self.recipientUserId : recipientUserId // ignore: cast_nullable_to_non_nullable
as String,proUserId: freezed == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String?,purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as CallPurpose,targetType: freezed == targetType ? _self.targetType : targetType // ignore: cast_nullable_to_non_nullable
as String?,targetId: freezed == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
