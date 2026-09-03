// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_contact_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserContactView {

/// userId
@JsonKey(name: UserContactView.userIdKey_) String get userId;/// phoneE164
@JsonKey(name: UserContactView.phoneE164Key_) String? get phoneE164;/// timezone
@JsonKey(name: UserContactView.timezoneKey_) String get timezone;/// quietHoursStart
@JsonKey(name: UserContactView.quietHoursStartKey_) String get quietHoursStart;/// quietHoursEnd
@JsonKey(name: UserContactView.quietHoursEndKey_) String get quietHoursEnd;
/// Create a copy of UserContactView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserContactViewCopyWith<UserContactView> get copyWith => _$UserContactViewCopyWithImpl<UserContactView>(this as UserContactView, _$identity);

  /// Serializes this UserContactView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserContactView&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.phoneE164, phoneE164) || other.phoneE164 == phoneE164)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.quietHoursStart, quietHoursStart) || other.quietHoursStart == quietHoursStart)&&(identical(other.quietHoursEnd, quietHoursEnd) || other.quietHoursEnd == quietHoursEnd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,phoneE164,timezone,quietHoursStart,quietHoursEnd);

@override
String toString() {
  return 'UserContactView(userId: $userId, phoneE164: $phoneE164, timezone: $timezone, quietHoursStart: $quietHoursStart, quietHoursEnd: $quietHoursEnd)';
}


}

/// @nodoc
abstract mixin class $UserContactViewCopyWith<$Res>  {
  factory $UserContactViewCopyWith(UserContactView value, $Res Function(UserContactView) _then) = _$UserContactViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: UserContactView.userIdKey_) String userId,@JsonKey(name: UserContactView.phoneE164Key_) String? phoneE164,@JsonKey(name: UserContactView.timezoneKey_) String timezone,@JsonKey(name: UserContactView.quietHoursStartKey_) String quietHoursStart,@JsonKey(name: UserContactView.quietHoursEndKey_) String quietHoursEnd
});




}
/// @nodoc
class _$UserContactViewCopyWithImpl<$Res>
    implements $UserContactViewCopyWith<$Res> {
  _$UserContactViewCopyWithImpl(this._self, this._then);

  final UserContactView _self;
  final $Res Function(UserContactView) _then;

/// Create a copy of UserContactView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? phoneE164 = freezed,Object? timezone = null,Object? quietHoursStart = null,Object? quietHoursEnd = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,phoneE164: freezed == phoneE164 ? _self.phoneE164 : phoneE164 // ignore: cast_nullable_to_non_nullable
as String?,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,quietHoursStart: null == quietHoursStart ? _self.quietHoursStart : quietHoursStart // ignore: cast_nullable_to_non_nullable
as String,quietHoursEnd: null == quietHoursEnd ? _self.quietHoursEnd : quietHoursEnd // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UserContactView].
extension UserContactViewPatterns on UserContactView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserContactView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserContactView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserContactView value)  $default,){
final _that = this;
switch (_that) {
case _UserContactView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserContactView value)?  $default,){
final _that = this;
switch (_that) {
case _UserContactView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: UserContactView.userIdKey_)  String userId, @JsonKey(name: UserContactView.phoneE164Key_)  String? phoneE164, @JsonKey(name: UserContactView.timezoneKey_)  String timezone, @JsonKey(name: UserContactView.quietHoursStartKey_)  String quietHoursStart, @JsonKey(name: UserContactView.quietHoursEndKey_)  String quietHoursEnd)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserContactView() when $default != null:
return $default(_that.userId,_that.phoneE164,_that.timezone,_that.quietHoursStart,_that.quietHoursEnd);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: UserContactView.userIdKey_)  String userId, @JsonKey(name: UserContactView.phoneE164Key_)  String? phoneE164, @JsonKey(name: UserContactView.timezoneKey_)  String timezone, @JsonKey(name: UserContactView.quietHoursStartKey_)  String quietHoursStart, @JsonKey(name: UserContactView.quietHoursEndKey_)  String quietHoursEnd)  $default,) {final _that = this;
switch (_that) {
case _UserContactView():
return $default(_that.userId,_that.phoneE164,_that.timezone,_that.quietHoursStart,_that.quietHoursEnd);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: UserContactView.userIdKey_)  String userId, @JsonKey(name: UserContactView.phoneE164Key_)  String? phoneE164, @JsonKey(name: UserContactView.timezoneKey_)  String timezone, @JsonKey(name: UserContactView.quietHoursStartKey_)  String quietHoursStart, @JsonKey(name: UserContactView.quietHoursEndKey_)  String quietHoursEnd)?  $default,) {final _that = this;
switch (_that) {
case _UserContactView() when $default != null:
return $default(_that.userId,_that.phoneE164,_that.timezone,_that.quietHoursStart,_that.quietHoursEnd);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _UserContactView extends UserContactView {
  const _UserContactView({@JsonKey(name: UserContactView.userIdKey_) required this.userId, @JsonKey(name: UserContactView.phoneE164Key_) this.phoneE164, @JsonKey(name: UserContactView.timezoneKey_) required this.timezone, @JsonKey(name: UserContactView.quietHoursStartKey_) required this.quietHoursStart, @JsonKey(name: UserContactView.quietHoursEndKey_) required this.quietHoursEnd}): super._();
  factory _UserContactView.fromJson(Map<String, dynamic> json) => _$UserContactViewFromJson(json);

/// userId
@override@JsonKey(name: UserContactView.userIdKey_) final  String userId;
/// phoneE164
@override@JsonKey(name: UserContactView.phoneE164Key_) final  String? phoneE164;
/// timezone
@override@JsonKey(name: UserContactView.timezoneKey_) final  String timezone;
/// quietHoursStart
@override@JsonKey(name: UserContactView.quietHoursStartKey_) final  String quietHoursStart;
/// quietHoursEnd
@override@JsonKey(name: UserContactView.quietHoursEndKey_) final  String quietHoursEnd;

/// Create a copy of UserContactView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserContactViewCopyWith<_UserContactView> get copyWith => __$UserContactViewCopyWithImpl<_UserContactView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserContactViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserContactView&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.phoneE164, phoneE164) || other.phoneE164 == phoneE164)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.quietHoursStart, quietHoursStart) || other.quietHoursStart == quietHoursStart)&&(identical(other.quietHoursEnd, quietHoursEnd) || other.quietHoursEnd == quietHoursEnd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,phoneE164,timezone,quietHoursStart,quietHoursEnd);

@override
String toString() {
  return 'UserContactView(userId: $userId, phoneE164: $phoneE164, timezone: $timezone, quietHoursStart: $quietHoursStart, quietHoursEnd: $quietHoursEnd)';
}


}

/// @nodoc
abstract mixin class _$UserContactViewCopyWith<$Res> implements $UserContactViewCopyWith<$Res> {
  factory _$UserContactViewCopyWith(_UserContactView value, $Res Function(_UserContactView) _then) = __$UserContactViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: UserContactView.userIdKey_) String userId,@JsonKey(name: UserContactView.phoneE164Key_) String? phoneE164,@JsonKey(name: UserContactView.timezoneKey_) String timezone,@JsonKey(name: UserContactView.quietHoursStartKey_) String quietHoursStart,@JsonKey(name: UserContactView.quietHoursEndKey_) String quietHoursEnd
});




}
/// @nodoc
class __$UserContactViewCopyWithImpl<$Res>
    implements _$UserContactViewCopyWith<$Res> {
  __$UserContactViewCopyWithImpl(this._self, this._then);

  final _UserContactView _self;
  final $Res Function(_UserContactView) _then;

/// Create a copy of UserContactView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? phoneE164 = freezed,Object? timezone = null,Object? quietHoursStart = null,Object? quietHoursEnd = null,}) {
  return _then(_UserContactView(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,phoneE164: freezed == phoneE164 ? _self.phoneE164 : phoneE164 // ignore: cast_nullable_to_non_nullable
as String?,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,quietHoursStart: null == quietHoursStart ? _self.quietHoursStart : quietHoursStart // ignore: cast_nullable_to_non_nullable
as String,quietHoursEnd: null == quietHoursEnd ? _self.quietHoursEnd : quietHoursEnd // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
