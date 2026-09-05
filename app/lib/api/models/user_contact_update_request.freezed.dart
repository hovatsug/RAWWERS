// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_contact_update_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserContactUpdateRequest {

/// phoneE164
@JsonKey(name: UserContactUpdateRequest.phoneE164Key_) String? get phoneE164;/// timezone
@JsonKey(name: UserContactUpdateRequest.timezoneKey_) String? get timezone;/// quietHoursStart
@JsonKey(name: UserContactUpdateRequest.quietHoursStartKey_) String? get quietHoursStart;/// quietHoursEnd
@JsonKey(name: UserContactUpdateRequest.quietHoursEndKey_) String? get quietHoursEnd;
/// Create a copy of UserContactUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserContactUpdateRequestCopyWith<UserContactUpdateRequest> get copyWith => _$UserContactUpdateRequestCopyWithImpl<UserContactUpdateRequest>(this as UserContactUpdateRequest, _$identity);

  /// Serializes this UserContactUpdateRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserContactUpdateRequest&&(identical(other.phoneE164, phoneE164) || other.phoneE164 == phoneE164)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.quietHoursStart, quietHoursStart) || other.quietHoursStart == quietHoursStart)&&(identical(other.quietHoursEnd, quietHoursEnd) || other.quietHoursEnd == quietHoursEnd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,phoneE164,timezone,quietHoursStart,quietHoursEnd);

@override
String toString() {
  return 'UserContactUpdateRequest(phoneE164: $phoneE164, timezone: $timezone, quietHoursStart: $quietHoursStart, quietHoursEnd: $quietHoursEnd)';
}


}

/// @nodoc
abstract mixin class $UserContactUpdateRequestCopyWith<$Res>  {
  factory $UserContactUpdateRequestCopyWith(UserContactUpdateRequest value, $Res Function(UserContactUpdateRequest) _then) = _$UserContactUpdateRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: UserContactUpdateRequest.phoneE164Key_) String? phoneE164,@JsonKey(name: UserContactUpdateRequest.timezoneKey_) String? timezone,@JsonKey(name: UserContactUpdateRequest.quietHoursStartKey_) String? quietHoursStart,@JsonKey(name: UserContactUpdateRequest.quietHoursEndKey_) String? quietHoursEnd
});




}
/// @nodoc
class _$UserContactUpdateRequestCopyWithImpl<$Res>
    implements $UserContactUpdateRequestCopyWith<$Res> {
  _$UserContactUpdateRequestCopyWithImpl(this._self, this._then);

  final UserContactUpdateRequest _self;
  final $Res Function(UserContactUpdateRequest) _then;

/// Create a copy of UserContactUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phoneE164 = freezed,Object? timezone = freezed,Object? quietHoursStart = freezed,Object? quietHoursEnd = freezed,}) {
  return _then(_self.copyWith(
phoneE164: freezed == phoneE164 ? _self.phoneE164 : phoneE164 // ignore: cast_nullable_to_non_nullable
as String?,timezone: freezed == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String?,quietHoursStart: freezed == quietHoursStart ? _self.quietHoursStart : quietHoursStart // ignore: cast_nullable_to_non_nullable
as String?,quietHoursEnd: freezed == quietHoursEnd ? _self.quietHoursEnd : quietHoursEnd // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserContactUpdateRequest].
extension UserContactUpdateRequestPatterns on UserContactUpdateRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserContactUpdateRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserContactUpdateRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserContactUpdateRequest value)  $default,){
final _that = this;
switch (_that) {
case _UserContactUpdateRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserContactUpdateRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UserContactUpdateRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: UserContactUpdateRequest.phoneE164Key_)  String? phoneE164, @JsonKey(name: UserContactUpdateRequest.timezoneKey_)  String? timezone, @JsonKey(name: UserContactUpdateRequest.quietHoursStartKey_)  String? quietHoursStart, @JsonKey(name: UserContactUpdateRequest.quietHoursEndKey_)  String? quietHoursEnd)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserContactUpdateRequest() when $default != null:
return $default(_that.phoneE164,_that.timezone,_that.quietHoursStart,_that.quietHoursEnd);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: UserContactUpdateRequest.phoneE164Key_)  String? phoneE164, @JsonKey(name: UserContactUpdateRequest.timezoneKey_)  String? timezone, @JsonKey(name: UserContactUpdateRequest.quietHoursStartKey_)  String? quietHoursStart, @JsonKey(name: UserContactUpdateRequest.quietHoursEndKey_)  String? quietHoursEnd)  $default,) {final _that = this;
switch (_that) {
case _UserContactUpdateRequest():
return $default(_that.phoneE164,_that.timezone,_that.quietHoursStart,_that.quietHoursEnd);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: UserContactUpdateRequest.phoneE164Key_)  String? phoneE164, @JsonKey(name: UserContactUpdateRequest.timezoneKey_)  String? timezone, @JsonKey(name: UserContactUpdateRequest.quietHoursStartKey_)  String? quietHoursStart, @JsonKey(name: UserContactUpdateRequest.quietHoursEndKey_)  String? quietHoursEnd)?  $default,) {final _that = this;
switch (_that) {
case _UserContactUpdateRequest() when $default != null:
return $default(_that.phoneE164,_that.timezone,_that.quietHoursStart,_that.quietHoursEnd);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _UserContactUpdateRequest extends UserContactUpdateRequest {
  const _UserContactUpdateRequest({@JsonKey(name: UserContactUpdateRequest.phoneE164Key_) this.phoneE164, @JsonKey(name: UserContactUpdateRequest.timezoneKey_) this.timezone, @JsonKey(name: UserContactUpdateRequest.quietHoursStartKey_) this.quietHoursStart, @JsonKey(name: UserContactUpdateRequest.quietHoursEndKey_) this.quietHoursEnd}): super._();
  factory _UserContactUpdateRequest.fromJson(Map<String, dynamic> json) => _$UserContactUpdateRequestFromJson(json);

/// phoneE164
@override@JsonKey(name: UserContactUpdateRequest.phoneE164Key_) final  String? phoneE164;
/// timezone
@override@JsonKey(name: UserContactUpdateRequest.timezoneKey_) final  String? timezone;
/// quietHoursStart
@override@JsonKey(name: UserContactUpdateRequest.quietHoursStartKey_) final  String? quietHoursStart;
/// quietHoursEnd
@override@JsonKey(name: UserContactUpdateRequest.quietHoursEndKey_) final  String? quietHoursEnd;

/// Create a copy of UserContactUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserContactUpdateRequestCopyWith<_UserContactUpdateRequest> get copyWith => __$UserContactUpdateRequestCopyWithImpl<_UserContactUpdateRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserContactUpdateRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserContactUpdateRequest&&(identical(other.phoneE164, phoneE164) || other.phoneE164 == phoneE164)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.quietHoursStart, quietHoursStart) || other.quietHoursStart == quietHoursStart)&&(identical(other.quietHoursEnd, quietHoursEnd) || other.quietHoursEnd == quietHoursEnd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,phoneE164,timezone,quietHoursStart,quietHoursEnd);

@override
String toString() {
  return 'UserContactUpdateRequest(phoneE164: $phoneE164, timezone: $timezone, quietHoursStart: $quietHoursStart, quietHoursEnd: $quietHoursEnd)';
}


}

/// @nodoc
abstract mixin class _$UserContactUpdateRequestCopyWith<$Res> implements $UserContactUpdateRequestCopyWith<$Res> {
  factory _$UserContactUpdateRequestCopyWith(_UserContactUpdateRequest value, $Res Function(_UserContactUpdateRequest) _then) = __$UserContactUpdateRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: UserContactUpdateRequest.phoneE164Key_) String? phoneE164,@JsonKey(name: UserContactUpdateRequest.timezoneKey_) String? timezone,@JsonKey(name: UserContactUpdateRequest.quietHoursStartKey_) String? quietHoursStart,@JsonKey(name: UserContactUpdateRequest.quietHoursEndKey_) String? quietHoursEnd
});




}
/// @nodoc
class __$UserContactUpdateRequestCopyWithImpl<$Res>
    implements _$UserContactUpdateRequestCopyWith<$Res> {
  __$UserContactUpdateRequestCopyWithImpl(this._self, this._then);

  final _UserContactUpdateRequest _self;
  final $Res Function(_UserContactUpdateRequest) _then;

/// Create a copy of UserContactUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phoneE164 = freezed,Object? timezone = freezed,Object? quietHoursStart = freezed,Object? quietHoursEnd = freezed,}) {
  return _then(_UserContactUpdateRequest(
phoneE164: freezed == phoneE164 ? _self.phoneE164 : phoneE164 // ignore: cast_nullable_to_non_nullable
as String?,timezone: freezed == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String?,quietHoursStart: freezed == quietHoursStart ? _self.quietHoursStart : quietHoursStart // ignore: cast_nullable_to_non_nullable
as String?,quietHoursEnd: freezed == quietHoursEnd ? _self.quietHoursEnd : quietHoursEnd // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
