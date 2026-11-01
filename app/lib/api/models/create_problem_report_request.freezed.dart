// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_problem_report_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateProblemReportRequest {

/// reason
@JsonKey(name: CreateProblemReportRequest.reasonKey_) ProblemReportReason get reason;/// note
@JsonKey(name: CreateProblemReportRequest.noteKey_) String? get note;
/// Create a copy of CreateProblemReportRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateProblemReportRequestCopyWith<CreateProblemReportRequest> get copyWith => _$CreateProblemReportRequestCopyWithImpl<CreateProblemReportRequest>(this as CreateProblemReportRequest, _$identity);

  /// Serializes this CreateProblemReportRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateProblemReportRequest&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reason,note);

@override
String toString() {
  return 'CreateProblemReportRequest(reason: $reason, note: $note)';
}


}

/// @nodoc
abstract mixin class $CreateProblemReportRequestCopyWith<$Res>  {
  factory $CreateProblemReportRequestCopyWith(CreateProblemReportRequest value, $Res Function(CreateProblemReportRequest) _then) = _$CreateProblemReportRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: CreateProblemReportRequest.reasonKey_) ProblemReportReason reason,@JsonKey(name: CreateProblemReportRequest.noteKey_) String? note
});




}
/// @nodoc
class _$CreateProblemReportRequestCopyWithImpl<$Res>
    implements $CreateProblemReportRequestCopyWith<$Res> {
  _$CreateProblemReportRequestCopyWithImpl(this._self, this._then);

  final CreateProblemReportRequest _self;
  final $Res Function(CreateProblemReportRequest) _then;

/// Create a copy of CreateProblemReportRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reason = null,Object? note = freezed,}) {
  return _then(_self.copyWith(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as ProblemReportReason,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateProblemReportRequest].
extension CreateProblemReportRequestPatterns on CreateProblemReportRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateProblemReportRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateProblemReportRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateProblemReportRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateProblemReportRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateProblemReportRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateProblemReportRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: CreateProblemReportRequest.reasonKey_)  ProblemReportReason reason, @JsonKey(name: CreateProblemReportRequest.noteKey_)  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateProblemReportRequest() when $default != null:
return $default(_that.reason,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: CreateProblemReportRequest.reasonKey_)  ProblemReportReason reason, @JsonKey(name: CreateProblemReportRequest.noteKey_)  String? note)  $default,) {final _that = this;
switch (_that) {
case _CreateProblemReportRequest():
return $default(_that.reason,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: CreateProblemReportRequest.reasonKey_)  ProblemReportReason reason, @JsonKey(name: CreateProblemReportRequest.noteKey_)  String? note)?  $default,) {final _that = this;
switch (_that) {
case _CreateProblemReportRequest() when $default != null:
return $default(_that.reason,_that.note);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _CreateProblemReportRequest extends CreateProblemReportRequest {
  const _CreateProblemReportRequest({@JsonKey(name: CreateProblemReportRequest.reasonKey_) required this.reason, @JsonKey(name: CreateProblemReportRequest.noteKey_) this.note}): super._();
  factory _CreateProblemReportRequest.fromJson(Map<String, dynamic> json) => _$CreateProblemReportRequestFromJson(json);

/// reason
@override@JsonKey(name: CreateProblemReportRequest.reasonKey_) final  ProblemReportReason reason;
/// note
@override@JsonKey(name: CreateProblemReportRequest.noteKey_) final  String? note;

/// Create a copy of CreateProblemReportRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateProblemReportRequestCopyWith<_CreateProblemReportRequest> get copyWith => __$CreateProblemReportRequestCopyWithImpl<_CreateProblemReportRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateProblemReportRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateProblemReportRequest&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reason,note);

@override
String toString() {
  return 'CreateProblemReportRequest(reason: $reason, note: $note)';
}


}

/// @nodoc
abstract mixin class _$CreateProblemReportRequestCopyWith<$Res> implements $CreateProblemReportRequestCopyWith<$Res> {
  factory _$CreateProblemReportRequestCopyWith(_CreateProblemReportRequest value, $Res Function(_CreateProblemReportRequest) _then) = __$CreateProblemReportRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: CreateProblemReportRequest.reasonKey_) ProblemReportReason reason,@JsonKey(name: CreateProblemReportRequest.noteKey_) String? note
});




}
/// @nodoc
class __$CreateProblemReportRequestCopyWithImpl<$Res>
    implements _$CreateProblemReportRequestCopyWith<$Res> {
  __$CreateProblemReportRequestCopyWithImpl(this._self, this._then);

  final _CreateProblemReportRequest _self;
  final $Res Function(_CreateProblemReportRequest) _then;

/// Create a copy of CreateProblemReportRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reason = null,Object? note = freezed,}) {
  return _then(_CreateProblemReportRequest(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as ProblemReportReason,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
