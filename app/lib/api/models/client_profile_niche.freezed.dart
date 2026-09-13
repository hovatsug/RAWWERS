// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_profile_niche.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClientProfileNiche {

/// slug
@JsonKey(name: ClientProfileNiche.slugKey_) String get slug;/// name
@JsonKey(name: ClientProfileNiche.nameKey_) String get name;/// tier
@JsonKey(name: ClientProfileNiche.tierKey_) SkillTier get tier;/// photoCount
@JsonKey(name: ClientProfileNiche.photoCountKey_) int get photoCount;/// description
@JsonKey(name: ClientProfileNiche.descriptionKey_) String? get description;
/// Create a copy of ClientProfileNiche
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientProfileNicheCopyWith<ClientProfileNiche> get copyWith => _$ClientProfileNicheCopyWithImpl<ClientProfileNiche>(this as ClientProfileNiche, _$identity);

  /// Serializes this ClientProfileNiche to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientProfileNiche&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.photoCount, photoCount) || other.photoCount == photoCount)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slug,name,tier,photoCount,description);

@override
String toString() {
  return 'ClientProfileNiche(slug: $slug, name: $name, tier: $tier, photoCount: $photoCount, description: $description)';
}


}

/// @nodoc
abstract mixin class $ClientProfileNicheCopyWith<$Res>  {
  factory $ClientProfileNicheCopyWith(ClientProfileNiche value, $Res Function(ClientProfileNiche) _then) = _$ClientProfileNicheCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ClientProfileNiche.slugKey_) String slug,@JsonKey(name: ClientProfileNiche.nameKey_) String name,@JsonKey(name: ClientProfileNiche.tierKey_) SkillTier tier,@JsonKey(name: ClientProfileNiche.photoCountKey_) int photoCount,@JsonKey(name: ClientProfileNiche.descriptionKey_) String? description
});




}
/// @nodoc
class _$ClientProfileNicheCopyWithImpl<$Res>
    implements $ClientProfileNicheCopyWith<$Res> {
  _$ClientProfileNicheCopyWithImpl(this._self, this._then);

  final ClientProfileNiche _self;
  final $Res Function(ClientProfileNiche) _then;

/// Create a copy of ClientProfileNiche
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? slug = null,Object? name = null,Object? tier = null,Object? photoCount = null,Object? description = freezed,}) {
  return _then(_self.copyWith(
slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as SkillTier,photoCount: null == photoCount ? _self.photoCount : photoCount // ignore: cast_nullable_to_non_nullable
as int,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ClientProfileNiche].
extension ClientProfileNichePatterns on ClientProfileNiche {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientProfileNiche value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientProfileNiche() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientProfileNiche value)  $default,){
final _that = this;
switch (_that) {
case _ClientProfileNiche():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientProfileNiche value)?  $default,){
final _that = this;
switch (_that) {
case _ClientProfileNiche() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ClientProfileNiche.slugKey_)  String slug, @JsonKey(name: ClientProfileNiche.nameKey_)  String name, @JsonKey(name: ClientProfileNiche.tierKey_)  SkillTier tier, @JsonKey(name: ClientProfileNiche.photoCountKey_)  int photoCount, @JsonKey(name: ClientProfileNiche.descriptionKey_)  String? description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientProfileNiche() when $default != null:
return $default(_that.slug,_that.name,_that.tier,_that.photoCount,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ClientProfileNiche.slugKey_)  String slug, @JsonKey(name: ClientProfileNiche.nameKey_)  String name, @JsonKey(name: ClientProfileNiche.tierKey_)  SkillTier tier, @JsonKey(name: ClientProfileNiche.photoCountKey_)  int photoCount, @JsonKey(name: ClientProfileNiche.descriptionKey_)  String? description)  $default,) {final _that = this;
switch (_that) {
case _ClientProfileNiche():
return $default(_that.slug,_that.name,_that.tier,_that.photoCount,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ClientProfileNiche.slugKey_)  String slug, @JsonKey(name: ClientProfileNiche.nameKey_)  String name, @JsonKey(name: ClientProfileNiche.tierKey_)  SkillTier tier, @JsonKey(name: ClientProfileNiche.photoCountKey_)  int photoCount, @JsonKey(name: ClientProfileNiche.descriptionKey_)  String? description)?  $default,) {final _that = this;
switch (_that) {
case _ClientProfileNiche() when $default != null:
return $default(_that.slug,_that.name,_that.tier,_that.photoCount,_that.description);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ClientProfileNiche extends ClientProfileNiche {
  const _ClientProfileNiche({@JsonKey(name: ClientProfileNiche.slugKey_) required this.slug, @JsonKey(name: ClientProfileNiche.nameKey_) required this.name, @JsonKey(name: ClientProfileNiche.tierKey_) required this.tier, @JsonKey(name: ClientProfileNiche.photoCountKey_) required this.photoCount, @JsonKey(name: ClientProfileNiche.descriptionKey_) this.description}): super._();
  factory _ClientProfileNiche.fromJson(Map<String, dynamic> json) => _$ClientProfileNicheFromJson(json);

/// slug
@override@JsonKey(name: ClientProfileNiche.slugKey_) final  String slug;
/// name
@override@JsonKey(name: ClientProfileNiche.nameKey_) final  String name;
/// tier
@override@JsonKey(name: ClientProfileNiche.tierKey_) final  SkillTier tier;
/// photoCount
@override@JsonKey(name: ClientProfileNiche.photoCountKey_) final  int photoCount;
/// description
@override@JsonKey(name: ClientProfileNiche.descriptionKey_) final  String? description;

/// Create a copy of ClientProfileNiche
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientProfileNicheCopyWith<_ClientProfileNiche> get copyWith => __$ClientProfileNicheCopyWithImpl<_ClientProfileNiche>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientProfileNicheToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientProfileNiche&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.photoCount, photoCount) || other.photoCount == photoCount)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slug,name,tier,photoCount,description);

@override
String toString() {
  return 'ClientProfileNiche(slug: $slug, name: $name, tier: $tier, photoCount: $photoCount, description: $description)';
}


}

/// @nodoc
abstract mixin class _$ClientProfileNicheCopyWith<$Res> implements $ClientProfileNicheCopyWith<$Res> {
  factory _$ClientProfileNicheCopyWith(_ClientProfileNiche value, $Res Function(_ClientProfileNiche) _then) = __$ClientProfileNicheCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ClientProfileNiche.slugKey_) String slug,@JsonKey(name: ClientProfileNiche.nameKey_) String name,@JsonKey(name: ClientProfileNiche.tierKey_) SkillTier tier,@JsonKey(name: ClientProfileNiche.photoCountKey_) int photoCount,@JsonKey(name: ClientProfileNiche.descriptionKey_) String? description
});




}
/// @nodoc
class __$ClientProfileNicheCopyWithImpl<$Res>
    implements _$ClientProfileNicheCopyWith<$Res> {
  __$ClientProfileNicheCopyWithImpl(this._self, this._then);

  final _ClientProfileNiche _self;
  final $Res Function(_ClientProfileNiche) _then;

/// Create a copy of ClientProfileNiche
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? slug = null,Object? name = null,Object? tier = null,Object? photoCount = null,Object? description = freezed,}) {
  return _then(_ClientProfileNiche(
slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as SkillTier,photoCount: null == photoCount ? _self.photoCount : photoCount // ignore: cast_nullable_to_non_nullable
as int,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
