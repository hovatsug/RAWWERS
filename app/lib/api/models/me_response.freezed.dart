// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'me_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MeResponse {

/// userId
@JsonKey(name: MeResponse.userIdKey_) String get userId;/// email
@JsonKey(name: MeResponse.emailKey_) String? get email;/// emailVerifiedAt
@JsonKey(name: MeResponse.emailVerifiedAtKey_) DateTime? get emailVerifiedAt;/// status
@JsonKey(name: MeResponse.statusKey_) String get status;/// roles
@JsonKey(name: MeResponse.rolesKey_) List<UserRoleType>? get roles;/// locale
@JsonKey(name: MeResponse.localeKey_) String get locale;/// isImpersonating
@JsonKey(name: MeResponse.isImpersonatingKey_) bool get isImpersonating;/// impersonationAdminUserId
@JsonKey(name: MeResponse.impersonationAdminUserIdKey_) String? get impersonationAdminUserId;
/// Create a copy of MeResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeResponseCopyWith<MeResponse> get copyWith => _$MeResponseCopyWithImpl<MeResponse>(this as MeResponse, _$identity);

  /// Serializes this MeResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MeResponse&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.email, email) || other.email == email)&&(identical(other.emailVerifiedAt, emailVerifiedAt) || other.emailVerifiedAt == emailVerifiedAt)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.roles, roles)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.isImpersonating, isImpersonating) || other.isImpersonating == isImpersonating)&&(identical(other.impersonationAdminUserId, impersonationAdminUserId) || other.impersonationAdminUserId == impersonationAdminUserId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,email,emailVerifiedAt,status,const DeepCollectionEquality().hash(roles),locale,isImpersonating,impersonationAdminUserId);

@override
String toString() {
  return 'MeResponse(userId: $userId, email: $email, emailVerifiedAt: $emailVerifiedAt, status: $status, roles: $roles, locale: $locale, isImpersonating: $isImpersonating, impersonationAdminUserId: $impersonationAdminUserId)';
}


}

/// @nodoc
abstract mixin class $MeResponseCopyWith<$Res>  {
  factory $MeResponseCopyWith(MeResponse value, $Res Function(MeResponse) _then) = _$MeResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: MeResponse.userIdKey_) String userId,@JsonKey(name: MeResponse.emailKey_) String? email,@JsonKey(name: MeResponse.emailVerifiedAtKey_) DateTime? emailVerifiedAt,@JsonKey(name: MeResponse.statusKey_) String status,@JsonKey(name: MeResponse.rolesKey_) List<UserRoleType>? roles,@JsonKey(name: MeResponse.localeKey_) String locale,@JsonKey(name: MeResponse.isImpersonatingKey_) bool isImpersonating,@JsonKey(name: MeResponse.impersonationAdminUserIdKey_) String? impersonationAdminUserId
});




}
/// @nodoc
class _$MeResponseCopyWithImpl<$Res>
    implements $MeResponseCopyWith<$Res> {
  _$MeResponseCopyWithImpl(this._self, this._then);

  final MeResponse _self;
  final $Res Function(MeResponse) _then;

/// Create a copy of MeResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? email = freezed,Object? emailVerifiedAt = freezed,Object? status = null,Object? roles = freezed,Object? locale = null,Object? isImpersonating = null,Object? impersonationAdminUserId = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,emailVerifiedAt: freezed == emailVerifiedAt ? _self.emailVerifiedAt : emailVerifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,roles: freezed == roles ? _self.roles : roles // ignore: cast_nullable_to_non_nullable
as List<UserRoleType>?,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,isImpersonating: null == isImpersonating ? _self.isImpersonating : isImpersonating // ignore: cast_nullable_to_non_nullable
as bool,impersonationAdminUserId: freezed == impersonationAdminUserId ? _self.impersonationAdminUserId : impersonationAdminUserId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MeResponse].
extension MeResponsePatterns on MeResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MeResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MeResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MeResponse value)  $default,){
final _that = this;
switch (_that) {
case _MeResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MeResponse value)?  $default,){
final _that = this;
switch (_that) {
case _MeResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: MeResponse.userIdKey_)  String userId, @JsonKey(name: MeResponse.emailKey_)  String? email, @JsonKey(name: MeResponse.emailVerifiedAtKey_)  DateTime? emailVerifiedAt, @JsonKey(name: MeResponse.statusKey_)  String status, @JsonKey(name: MeResponse.rolesKey_)  List<UserRoleType>? roles, @JsonKey(name: MeResponse.localeKey_)  String locale, @JsonKey(name: MeResponse.isImpersonatingKey_)  bool isImpersonating, @JsonKey(name: MeResponse.impersonationAdminUserIdKey_)  String? impersonationAdminUserId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MeResponse() when $default != null:
return $default(_that.userId,_that.email,_that.emailVerifiedAt,_that.status,_that.roles,_that.locale,_that.isImpersonating,_that.impersonationAdminUserId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: MeResponse.userIdKey_)  String userId, @JsonKey(name: MeResponse.emailKey_)  String? email, @JsonKey(name: MeResponse.emailVerifiedAtKey_)  DateTime? emailVerifiedAt, @JsonKey(name: MeResponse.statusKey_)  String status, @JsonKey(name: MeResponse.rolesKey_)  List<UserRoleType>? roles, @JsonKey(name: MeResponse.localeKey_)  String locale, @JsonKey(name: MeResponse.isImpersonatingKey_)  bool isImpersonating, @JsonKey(name: MeResponse.impersonationAdminUserIdKey_)  String? impersonationAdminUserId)  $default,) {final _that = this;
switch (_that) {
case _MeResponse():
return $default(_that.userId,_that.email,_that.emailVerifiedAt,_that.status,_that.roles,_that.locale,_that.isImpersonating,_that.impersonationAdminUserId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: MeResponse.userIdKey_)  String userId, @JsonKey(name: MeResponse.emailKey_)  String? email, @JsonKey(name: MeResponse.emailVerifiedAtKey_)  DateTime? emailVerifiedAt, @JsonKey(name: MeResponse.statusKey_)  String status, @JsonKey(name: MeResponse.rolesKey_)  List<UserRoleType>? roles, @JsonKey(name: MeResponse.localeKey_)  String locale, @JsonKey(name: MeResponse.isImpersonatingKey_)  bool isImpersonating, @JsonKey(name: MeResponse.impersonationAdminUserIdKey_)  String? impersonationAdminUserId)?  $default,) {final _that = this;
switch (_that) {
case _MeResponse() when $default != null:
return $default(_that.userId,_that.email,_that.emailVerifiedAt,_that.status,_that.roles,_that.locale,_that.isImpersonating,_that.impersonationAdminUserId);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _MeResponse extends MeResponse {
  const _MeResponse({@JsonKey(name: MeResponse.userIdKey_) required this.userId, @JsonKey(name: MeResponse.emailKey_) this.email, @JsonKey(name: MeResponse.emailVerifiedAtKey_) this.emailVerifiedAt, @JsonKey(name: MeResponse.statusKey_) required this.status, @JsonKey(name: MeResponse.rolesKey_) final  List<UserRoleType>? roles, @JsonKey(name: MeResponse.localeKey_) this.locale = 'en-GB', @JsonKey(name: MeResponse.isImpersonatingKey_) this.isImpersonating = false, @JsonKey(name: MeResponse.impersonationAdminUserIdKey_) this.impersonationAdminUserId}): _roles = roles,super._();
  factory _MeResponse.fromJson(Map<String, dynamic> json) => _$MeResponseFromJson(json);

/// userId
@override@JsonKey(name: MeResponse.userIdKey_) final  String userId;
/// email
@override@JsonKey(name: MeResponse.emailKey_) final  String? email;
/// emailVerifiedAt
@override@JsonKey(name: MeResponse.emailVerifiedAtKey_) final  DateTime? emailVerifiedAt;
/// status
@override@JsonKey(name: MeResponse.statusKey_) final  String status;
/// roles
 final  List<UserRoleType>? _roles;
/// roles
@override@JsonKey(name: MeResponse.rolesKey_) List<UserRoleType>? get roles {
  final value = _roles;
  if (value == null) return null;
  if (_roles is EqualUnmodifiableListView) return _roles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// locale
@override@JsonKey(name: MeResponse.localeKey_) final  String locale;
/// isImpersonating
@override@JsonKey(name: MeResponse.isImpersonatingKey_) final  bool isImpersonating;
/// impersonationAdminUserId
@override@JsonKey(name: MeResponse.impersonationAdminUserIdKey_) final  String? impersonationAdminUserId;

/// Create a copy of MeResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MeResponseCopyWith<_MeResponse> get copyWith => __$MeResponseCopyWithImpl<_MeResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MeResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MeResponse&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.email, email) || other.email == email)&&(identical(other.emailVerifiedAt, emailVerifiedAt) || other.emailVerifiedAt == emailVerifiedAt)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._roles, _roles)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.isImpersonating, isImpersonating) || other.isImpersonating == isImpersonating)&&(identical(other.impersonationAdminUserId, impersonationAdminUserId) || other.impersonationAdminUserId == impersonationAdminUserId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,email,emailVerifiedAt,status,const DeepCollectionEquality().hash(_roles),locale,isImpersonating,impersonationAdminUserId);

@override
String toString() {
  return 'MeResponse(userId: $userId, email: $email, emailVerifiedAt: $emailVerifiedAt, status: $status, roles: $roles, locale: $locale, isImpersonating: $isImpersonating, impersonationAdminUserId: $impersonationAdminUserId)';
}


}

/// @nodoc
abstract mixin class _$MeResponseCopyWith<$Res> implements $MeResponseCopyWith<$Res> {
  factory _$MeResponseCopyWith(_MeResponse value, $Res Function(_MeResponse) _then) = __$MeResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: MeResponse.userIdKey_) String userId,@JsonKey(name: MeResponse.emailKey_) String? email,@JsonKey(name: MeResponse.emailVerifiedAtKey_) DateTime? emailVerifiedAt,@JsonKey(name: MeResponse.statusKey_) String status,@JsonKey(name: MeResponse.rolesKey_) List<UserRoleType>? roles,@JsonKey(name: MeResponse.localeKey_) String locale,@JsonKey(name: MeResponse.isImpersonatingKey_) bool isImpersonating,@JsonKey(name: MeResponse.impersonationAdminUserIdKey_) String? impersonationAdminUserId
});




}
/// @nodoc
class __$MeResponseCopyWithImpl<$Res>
    implements _$MeResponseCopyWith<$Res> {
  __$MeResponseCopyWithImpl(this._self, this._then);

  final _MeResponse _self;
  final $Res Function(_MeResponse) _then;

/// Create a copy of MeResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? email = freezed,Object? emailVerifiedAt = freezed,Object? status = null,Object? roles = freezed,Object? locale = null,Object? isImpersonating = null,Object? impersonationAdminUserId = freezed,}) {
  return _then(_MeResponse(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,emailVerifiedAt: freezed == emailVerifiedAt ? _self.emailVerifiedAt : emailVerifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,roles: freezed == roles ? _self._roles : roles // ignore: cast_nullable_to_non_nullable
as List<UserRoleType>?,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,isImpersonating: null == isImpersonating ? _self.isImpersonating : isImpersonating // ignore: cast_nullable_to_non_nullable
as bool,impersonationAdminUserId: freezed == impersonationAdminUserId ? _self.impersonationAdminUserId : impersonationAdminUserId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
