// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_refund_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateRefundResponse {

/// refundId
@JsonKey(name: CreateRefundResponse.refundIdKey_) String get refundId;/// status
@JsonKey(name: CreateRefundResponse.statusKey_) String get status;/// refundIds
@JsonKey(name: CreateRefundResponse.refundIdsKey_) List<String> get refundIds;
/// Create a copy of CreateRefundResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateRefundResponseCopyWith<CreateRefundResponse> get copyWith => _$CreateRefundResponseCopyWithImpl<CreateRefundResponse>(this as CreateRefundResponse, _$identity);

  /// Serializes this CreateRefundResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateRefundResponse&&(identical(other.refundId, refundId) || other.refundId == refundId)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.refundIds, refundIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,refundId,status,const DeepCollectionEquality().hash(refundIds));

@override
String toString() {
  return 'CreateRefundResponse(refundId: $refundId, status: $status, refundIds: $refundIds)';
}


}

/// @nodoc
abstract mixin class $CreateRefundResponseCopyWith<$Res>  {
  factory $CreateRefundResponseCopyWith(CreateRefundResponse value, $Res Function(CreateRefundResponse) _then) = _$CreateRefundResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: CreateRefundResponse.refundIdKey_) String refundId,@JsonKey(name: CreateRefundResponse.statusKey_) String status,@JsonKey(name: CreateRefundResponse.refundIdsKey_) List<String> refundIds
});




}
/// @nodoc
class _$CreateRefundResponseCopyWithImpl<$Res>
    implements $CreateRefundResponseCopyWith<$Res> {
  _$CreateRefundResponseCopyWithImpl(this._self, this._then);

  final CreateRefundResponse _self;
  final $Res Function(CreateRefundResponse) _then;

/// Create a copy of CreateRefundResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? refundId = null,Object? status = null,Object? refundIds = null,}) {
  return _then(_self.copyWith(
refundId: null == refundId ? _self.refundId : refundId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,refundIds: null == refundIds ? _self.refundIds : refundIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateRefundResponse].
extension CreateRefundResponsePatterns on CreateRefundResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateRefundResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateRefundResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateRefundResponse value)  $default,){
final _that = this;
switch (_that) {
case _CreateRefundResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateRefundResponse value)?  $default,){
final _that = this;
switch (_that) {
case _CreateRefundResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: CreateRefundResponse.refundIdKey_)  String refundId, @JsonKey(name: CreateRefundResponse.statusKey_)  String status, @JsonKey(name: CreateRefundResponse.refundIdsKey_)  List<String> refundIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateRefundResponse() when $default != null:
return $default(_that.refundId,_that.status,_that.refundIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: CreateRefundResponse.refundIdKey_)  String refundId, @JsonKey(name: CreateRefundResponse.statusKey_)  String status, @JsonKey(name: CreateRefundResponse.refundIdsKey_)  List<String> refundIds)  $default,) {final _that = this;
switch (_that) {
case _CreateRefundResponse():
return $default(_that.refundId,_that.status,_that.refundIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: CreateRefundResponse.refundIdKey_)  String refundId, @JsonKey(name: CreateRefundResponse.statusKey_)  String status, @JsonKey(name: CreateRefundResponse.refundIdsKey_)  List<String> refundIds)?  $default,) {final _that = this;
switch (_that) {
case _CreateRefundResponse() when $default != null:
return $default(_that.refundId,_that.status,_that.refundIds);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _CreateRefundResponse extends CreateRefundResponse {
  const _CreateRefundResponse({@JsonKey(name: CreateRefundResponse.refundIdKey_) required this.refundId, @JsonKey(name: CreateRefundResponse.statusKey_) required this.status, @JsonKey(name: CreateRefundResponse.refundIdsKey_) final  List<String> refundIds = const []}): _refundIds = refundIds,super._();
  factory _CreateRefundResponse.fromJson(Map<String, dynamic> json) => _$CreateRefundResponseFromJson(json);

/// refundId
@override@JsonKey(name: CreateRefundResponse.refundIdKey_) final  String refundId;
/// status
@override@JsonKey(name: CreateRefundResponse.statusKey_) final  String status;
/// refundIds
 final  List<String> _refundIds;
/// refundIds
@override@JsonKey(name: CreateRefundResponse.refundIdsKey_) List<String> get refundIds {
  if (_refundIds is EqualUnmodifiableListView) return _refundIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_refundIds);
}


/// Create a copy of CreateRefundResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateRefundResponseCopyWith<_CreateRefundResponse> get copyWith => __$CreateRefundResponseCopyWithImpl<_CreateRefundResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateRefundResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateRefundResponse&&(identical(other.refundId, refundId) || other.refundId == refundId)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._refundIds, _refundIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,refundId,status,const DeepCollectionEquality().hash(_refundIds));

@override
String toString() {
  return 'CreateRefundResponse(refundId: $refundId, status: $status, refundIds: $refundIds)';
}


}

/// @nodoc
abstract mixin class _$CreateRefundResponseCopyWith<$Res> implements $CreateRefundResponseCopyWith<$Res> {
  factory _$CreateRefundResponseCopyWith(_CreateRefundResponse value, $Res Function(_CreateRefundResponse) _then) = __$CreateRefundResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: CreateRefundResponse.refundIdKey_) String refundId,@JsonKey(name: CreateRefundResponse.statusKey_) String status,@JsonKey(name: CreateRefundResponse.refundIdsKey_) List<String> refundIds
});




}
/// @nodoc
class __$CreateRefundResponseCopyWithImpl<$Res>
    implements _$CreateRefundResponseCopyWith<$Res> {
  __$CreateRefundResponseCopyWithImpl(this._self, this._then);

  final _CreateRefundResponse _self;
  final $Res Function(_CreateRefundResponse) _then;

/// Create a copy of CreateRefundResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? refundId = null,Object? status = null,Object? refundIds = null,}) {
  return _then(_CreateRefundResponse(
refundId: null == refundId ? _self.refundId : refundId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,refundIds: null == refundIds ? _self._refundIds : refundIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
