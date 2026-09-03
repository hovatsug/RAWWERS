// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credential_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CredentialView {

/// id
@JsonKey(name: CredentialView.idKey_) String get id;/// proUserId
@JsonKey(name: CredentialView.proUserIdKey_) String get proUserId;/// nicheId
@JsonKey(name: CredentialView.nicheIdKey_) String get nicheId;/// credentialCode
@JsonKey(name: CredentialView.credentialCodeKey_) String get credentialCode;/// displayName
@JsonKey(name: CredentialView.displayNameKey_) String get displayName;/// tier
@JsonKey(name: CredentialView.tierKey_) SkillTier get tier;/// mode
@JsonKey(name: CredentialView.modeKey_) CredentialMode get mode;/// awardedAt
@JsonKey(name: CredentialView.awardedAtKey_) DateTime get awardedAt;/// meta
@JsonKey(name: CredentialView.metaKey_) Map<String, dynamic>? get meta;
/// Create a copy of CredentialView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CredentialViewCopyWith<CredentialView> get copyWith => _$CredentialViewCopyWithImpl<CredentialView>(this as CredentialView, _$identity);

  /// Serializes this CredentialView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CredentialView&&(identical(other.id, id) || other.id == id)&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.nicheId, nicheId) || other.nicheId == nicheId)&&(identical(other.credentialCode, credentialCode) || other.credentialCode == credentialCode)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.awardedAt, awardedAt) || other.awardedAt == awardedAt)&&const DeepCollectionEquality().equals(other.meta, meta));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,proUserId,nicheId,credentialCode,displayName,tier,mode,awardedAt,const DeepCollectionEquality().hash(meta));

@override
String toString() {
  return 'CredentialView(id: $id, proUserId: $proUserId, nicheId: $nicheId, credentialCode: $credentialCode, displayName: $displayName, tier: $tier, mode: $mode, awardedAt: $awardedAt, meta: $meta)';
}


}

/// @nodoc
abstract mixin class $CredentialViewCopyWith<$Res>  {
  factory $CredentialViewCopyWith(CredentialView value, $Res Function(CredentialView) _then) = _$CredentialViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: CredentialView.idKey_) String id,@JsonKey(name: CredentialView.proUserIdKey_) String proUserId,@JsonKey(name: CredentialView.nicheIdKey_) String nicheId,@JsonKey(name: CredentialView.credentialCodeKey_) String credentialCode,@JsonKey(name: CredentialView.displayNameKey_) String displayName,@JsonKey(name: CredentialView.tierKey_) SkillTier tier,@JsonKey(name: CredentialView.modeKey_) CredentialMode mode,@JsonKey(name: CredentialView.awardedAtKey_) DateTime awardedAt,@JsonKey(name: CredentialView.metaKey_) Map<String, dynamic>? meta
});




}
/// @nodoc
class _$CredentialViewCopyWithImpl<$Res>
    implements $CredentialViewCopyWith<$Res> {
  _$CredentialViewCopyWithImpl(this._self, this._then);

  final CredentialView _self;
  final $Res Function(CredentialView) _then;

/// Create a copy of CredentialView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? proUserId = null,Object? nicheId = null,Object? credentialCode = null,Object? displayName = null,Object? tier = null,Object? mode = null,Object? awardedAt = null,Object? meta = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,nicheId: null == nicheId ? _self.nicheId : nicheId // ignore: cast_nullable_to_non_nullable
as String,credentialCode: null == credentialCode ? _self.credentialCode : credentialCode // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as SkillTier,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as CredentialMode,awardedAt: null == awardedAt ? _self.awardedAt : awardedAt // ignore: cast_nullable_to_non_nullable
as DateTime,meta: freezed == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [CredentialView].
extension CredentialViewPatterns on CredentialView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CredentialView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CredentialView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CredentialView value)  $default,){
final _that = this;
switch (_that) {
case _CredentialView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CredentialView value)?  $default,){
final _that = this;
switch (_that) {
case _CredentialView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: CredentialView.idKey_)  String id, @JsonKey(name: CredentialView.proUserIdKey_)  String proUserId, @JsonKey(name: CredentialView.nicheIdKey_)  String nicheId, @JsonKey(name: CredentialView.credentialCodeKey_)  String credentialCode, @JsonKey(name: CredentialView.displayNameKey_)  String displayName, @JsonKey(name: CredentialView.tierKey_)  SkillTier tier, @JsonKey(name: CredentialView.modeKey_)  CredentialMode mode, @JsonKey(name: CredentialView.awardedAtKey_)  DateTime awardedAt, @JsonKey(name: CredentialView.metaKey_)  Map<String, dynamic>? meta)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CredentialView() when $default != null:
return $default(_that.id,_that.proUserId,_that.nicheId,_that.credentialCode,_that.displayName,_that.tier,_that.mode,_that.awardedAt,_that.meta);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: CredentialView.idKey_)  String id, @JsonKey(name: CredentialView.proUserIdKey_)  String proUserId, @JsonKey(name: CredentialView.nicheIdKey_)  String nicheId, @JsonKey(name: CredentialView.credentialCodeKey_)  String credentialCode, @JsonKey(name: CredentialView.displayNameKey_)  String displayName, @JsonKey(name: CredentialView.tierKey_)  SkillTier tier, @JsonKey(name: CredentialView.modeKey_)  CredentialMode mode, @JsonKey(name: CredentialView.awardedAtKey_)  DateTime awardedAt, @JsonKey(name: CredentialView.metaKey_)  Map<String, dynamic>? meta)  $default,) {final _that = this;
switch (_that) {
case _CredentialView():
return $default(_that.id,_that.proUserId,_that.nicheId,_that.credentialCode,_that.displayName,_that.tier,_that.mode,_that.awardedAt,_that.meta);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: CredentialView.idKey_)  String id, @JsonKey(name: CredentialView.proUserIdKey_)  String proUserId, @JsonKey(name: CredentialView.nicheIdKey_)  String nicheId, @JsonKey(name: CredentialView.credentialCodeKey_)  String credentialCode, @JsonKey(name: CredentialView.displayNameKey_)  String displayName, @JsonKey(name: CredentialView.tierKey_)  SkillTier tier, @JsonKey(name: CredentialView.modeKey_)  CredentialMode mode, @JsonKey(name: CredentialView.awardedAtKey_)  DateTime awardedAt, @JsonKey(name: CredentialView.metaKey_)  Map<String, dynamic>? meta)?  $default,) {final _that = this;
switch (_that) {
case _CredentialView() when $default != null:
return $default(_that.id,_that.proUserId,_that.nicheId,_that.credentialCode,_that.displayName,_that.tier,_that.mode,_that.awardedAt,_that.meta);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _CredentialView extends CredentialView {
  const _CredentialView({@JsonKey(name: CredentialView.idKey_) required this.id, @JsonKey(name: CredentialView.proUserIdKey_) required this.proUserId, @JsonKey(name: CredentialView.nicheIdKey_) required this.nicheId, @JsonKey(name: CredentialView.credentialCodeKey_) required this.credentialCode, @JsonKey(name: CredentialView.displayNameKey_) required this.displayName, @JsonKey(name: CredentialView.tierKey_) required this.tier, @JsonKey(name: CredentialView.modeKey_) required this.mode, @JsonKey(name: CredentialView.awardedAtKey_) required this.awardedAt, @JsonKey(name: CredentialView.metaKey_) final  Map<String, dynamic>? meta}): _meta = meta,super._();
  factory _CredentialView.fromJson(Map<String, dynamic> json) => _$CredentialViewFromJson(json);

/// id
@override@JsonKey(name: CredentialView.idKey_) final  String id;
/// proUserId
@override@JsonKey(name: CredentialView.proUserIdKey_) final  String proUserId;
/// nicheId
@override@JsonKey(name: CredentialView.nicheIdKey_) final  String nicheId;
/// credentialCode
@override@JsonKey(name: CredentialView.credentialCodeKey_) final  String credentialCode;
/// displayName
@override@JsonKey(name: CredentialView.displayNameKey_) final  String displayName;
/// tier
@override@JsonKey(name: CredentialView.tierKey_) final  SkillTier tier;
/// mode
@override@JsonKey(name: CredentialView.modeKey_) final  CredentialMode mode;
/// awardedAt
@override@JsonKey(name: CredentialView.awardedAtKey_) final  DateTime awardedAt;
/// meta
 final  Map<String, dynamic>? _meta;
/// meta
@override@JsonKey(name: CredentialView.metaKey_) Map<String, dynamic>? get meta {
  final value = _meta;
  if (value == null) return null;
  if (_meta is EqualUnmodifiableMapView) return _meta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of CredentialView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CredentialViewCopyWith<_CredentialView> get copyWith => __$CredentialViewCopyWithImpl<_CredentialView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CredentialViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CredentialView&&(identical(other.id, id) || other.id == id)&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.nicheId, nicheId) || other.nicheId == nicheId)&&(identical(other.credentialCode, credentialCode) || other.credentialCode == credentialCode)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.awardedAt, awardedAt) || other.awardedAt == awardedAt)&&const DeepCollectionEquality().equals(other._meta, _meta));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,proUserId,nicheId,credentialCode,displayName,tier,mode,awardedAt,const DeepCollectionEquality().hash(_meta));

@override
String toString() {
  return 'CredentialView(id: $id, proUserId: $proUserId, nicheId: $nicheId, credentialCode: $credentialCode, displayName: $displayName, tier: $tier, mode: $mode, awardedAt: $awardedAt, meta: $meta)';
}


}

/// @nodoc
abstract mixin class _$CredentialViewCopyWith<$Res> implements $CredentialViewCopyWith<$Res> {
  factory _$CredentialViewCopyWith(_CredentialView value, $Res Function(_CredentialView) _then) = __$CredentialViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: CredentialView.idKey_) String id,@JsonKey(name: CredentialView.proUserIdKey_) String proUserId,@JsonKey(name: CredentialView.nicheIdKey_) String nicheId,@JsonKey(name: CredentialView.credentialCodeKey_) String credentialCode,@JsonKey(name: CredentialView.displayNameKey_) String displayName,@JsonKey(name: CredentialView.tierKey_) SkillTier tier,@JsonKey(name: CredentialView.modeKey_) CredentialMode mode,@JsonKey(name: CredentialView.awardedAtKey_) DateTime awardedAt,@JsonKey(name: CredentialView.metaKey_) Map<String, dynamic>? meta
});




}
/// @nodoc
class __$CredentialViewCopyWithImpl<$Res>
    implements _$CredentialViewCopyWith<$Res> {
  __$CredentialViewCopyWithImpl(this._self, this._then);

  final _CredentialView _self;
  final $Res Function(_CredentialView) _then;

/// Create a copy of CredentialView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? proUserId = null,Object? nicheId = null,Object? credentialCode = null,Object? displayName = null,Object? tier = null,Object? mode = null,Object? awardedAt = null,Object? meta = freezed,}) {
  return _then(_CredentialView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,nicheId: null == nicheId ? _self.nicheId : nicheId // ignore: cast_nullable_to_non_nullable
as String,credentialCode: null == credentialCode ? _self.credentialCode : credentialCode // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as SkillTier,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as CredentialMode,awardedAt: null == awardedAt ? _self.awardedAt : awardedAt // ignore: cast_nullable_to_non_nullable
as DateTime,meta: freezed == meta ? _self._meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
