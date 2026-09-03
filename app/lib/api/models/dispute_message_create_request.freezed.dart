// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dispute_message_create_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DisputeMessageCreateRequest {

/// message
@JsonKey(name: DisputeMessageCreateRequest.messageKey_) String get message;/// evidenceMediaAssetIds
@JsonKey(name: DisputeMessageCreateRequest.evidenceMediaAssetIdsKey_) List<String>? get evidenceMediaAssetIds;
/// Create a copy of DisputeMessageCreateRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DisputeMessageCreateRequestCopyWith<DisputeMessageCreateRequest> get copyWith => _$DisputeMessageCreateRequestCopyWithImpl<DisputeMessageCreateRequest>(this as DisputeMessageCreateRequest, _$identity);

  /// Serializes this DisputeMessageCreateRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DisputeMessageCreateRequest&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.evidenceMediaAssetIds, evidenceMediaAssetIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message,const DeepCollectionEquality().hash(evidenceMediaAssetIds));

@override
String toString() {
  return 'DisputeMessageCreateRequest(message: $message, evidenceMediaAssetIds: $evidenceMediaAssetIds)';
}


}

/// @nodoc
abstract mixin class $DisputeMessageCreateRequestCopyWith<$Res>  {
  factory $DisputeMessageCreateRequestCopyWith(DisputeMessageCreateRequest value, $Res Function(DisputeMessageCreateRequest) _then) = _$DisputeMessageCreateRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: DisputeMessageCreateRequest.messageKey_) String message,@JsonKey(name: DisputeMessageCreateRequest.evidenceMediaAssetIdsKey_) List<String>? evidenceMediaAssetIds
});




}
/// @nodoc
class _$DisputeMessageCreateRequestCopyWithImpl<$Res>
    implements $DisputeMessageCreateRequestCopyWith<$Res> {
  _$DisputeMessageCreateRequestCopyWithImpl(this._self, this._then);

  final DisputeMessageCreateRequest _self;
  final $Res Function(DisputeMessageCreateRequest) _then;

/// Create a copy of DisputeMessageCreateRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,Object? evidenceMediaAssetIds = freezed,}) {
  return _then(_self.copyWith(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,evidenceMediaAssetIds: freezed == evidenceMediaAssetIds ? _self.evidenceMediaAssetIds : evidenceMediaAssetIds // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [DisputeMessageCreateRequest].
extension DisputeMessageCreateRequestPatterns on DisputeMessageCreateRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DisputeMessageCreateRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DisputeMessageCreateRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DisputeMessageCreateRequest value)  $default,){
final _that = this;
switch (_that) {
case _DisputeMessageCreateRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DisputeMessageCreateRequest value)?  $default,){
final _that = this;
switch (_that) {
case _DisputeMessageCreateRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: DisputeMessageCreateRequest.messageKey_)  String message, @JsonKey(name: DisputeMessageCreateRequest.evidenceMediaAssetIdsKey_)  List<String>? evidenceMediaAssetIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DisputeMessageCreateRequest() when $default != null:
return $default(_that.message,_that.evidenceMediaAssetIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: DisputeMessageCreateRequest.messageKey_)  String message, @JsonKey(name: DisputeMessageCreateRequest.evidenceMediaAssetIdsKey_)  List<String>? evidenceMediaAssetIds)  $default,) {final _that = this;
switch (_that) {
case _DisputeMessageCreateRequest():
return $default(_that.message,_that.evidenceMediaAssetIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: DisputeMessageCreateRequest.messageKey_)  String message, @JsonKey(name: DisputeMessageCreateRequest.evidenceMediaAssetIdsKey_)  List<String>? evidenceMediaAssetIds)?  $default,) {final _that = this;
switch (_that) {
case _DisputeMessageCreateRequest() when $default != null:
return $default(_that.message,_that.evidenceMediaAssetIds);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _DisputeMessageCreateRequest extends DisputeMessageCreateRequest {
  const _DisputeMessageCreateRequest({@JsonKey(name: DisputeMessageCreateRequest.messageKey_) required this.message, @JsonKey(name: DisputeMessageCreateRequest.evidenceMediaAssetIdsKey_) final  List<String>? evidenceMediaAssetIds}): _evidenceMediaAssetIds = evidenceMediaAssetIds,super._();
  factory _DisputeMessageCreateRequest.fromJson(Map<String, dynamic> json) => _$DisputeMessageCreateRequestFromJson(json);

/// message
@override@JsonKey(name: DisputeMessageCreateRequest.messageKey_) final  String message;
/// evidenceMediaAssetIds
 final  List<String>? _evidenceMediaAssetIds;
/// evidenceMediaAssetIds
@override@JsonKey(name: DisputeMessageCreateRequest.evidenceMediaAssetIdsKey_) List<String>? get evidenceMediaAssetIds {
  final value = _evidenceMediaAssetIds;
  if (value == null) return null;
  if (_evidenceMediaAssetIds is EqualUnmodifiableListView) return _evidenceMediaAssetIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of DisputeMessageCreateRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DisputeMessageCreateRequestCopyWith<_DisputeMessageCreateRequest> get copyWith => __$DisputeMessageCreateRequestCopyWithImpl<_DisputeMessageCreateRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DisputeMessageCreateRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DisputeMessageCreateRequest&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other._evidenceMediaAssetIds, _evidenceMediaAssetIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message,const DeepCollectionEquality().hash(_evidenceMediaAssetIds));

@override
String toString() {
  return 'DisputeMessageCreateRequest(message: $message, evidenceMediaAssetIds: $evidenceMediaAssetIds)';
}


}

/// @nodoc
abstract mixin class _$DisputeMessageCreateRequestCopyWith<$Res> implements $DisputeMessageCreateRequestCopyWith<$Res> {
  factory _$DisputeMessageCreateRequestCopyWith(_DisputeMessageCreateRequest value, $Res Function(_DisputeMessageCreateRequest) _then) = __$DisputeMessageCreateRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: DisputeMessageCreateRequest.messageKey_) String message,@JsonKey(name: DisputeMessageCreateRequest.evidenceMediaAssetIdsKey_) List<String>? evidenceMediaAssetIds
});




}
/// @nodoc
class __$DisputeMessageCreateRequestCopyWithImpl<$Res>
    implements _$DisputeMessageCreateRequestCopyWith<$Res> {
  __$DisputeMessageCreateRequestCopyWithImpl(this._self, this._then);

  final _DisputeMessageCreateRequest _self;
  final $Res Function(_DisputeMessageCreateRequest) _then;

/// Create a copy of DisputeMessageCreateRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? evidenceMediaAssetIds = freezed,}) {
  return _then(_DisputeMessageCreateRequest(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,evidenceMediaAssetIds: freezed == evidenceMediaAssetIds ? _self._evidenceMediaAssetIds : evidenceMediaAssetIds // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
