// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_home_niche.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClientHomeNiche {

/// slug
@JsonKey(name: ClientHomeNiche.slugKey_) String get slug;/// name
@JsonKey(name: ClientHomeNiche.nameKey_) String get name;
/// Create a copy of ClientHomeNiche
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientHomeNicheCopyWith<ClientHomeNiche> get copyWith => _$ClientHomeNicheCopyWithImpl<ClientHomeNiche>(this as ClientHomeNiche, _$identity);

  /// Serializes this ClientHomeNiche to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientHomeNiche&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slug,name);

@override
String toString() {
  return 'ClientHomeNiche(slug: $slug, name: $name)';
}


}

/// @nodoc
abstract mixin class $ClientHomeNicheCopyWith<$Res>  {
  factory $ClientHomeNicheCopyWith(ClientHomeNiche value, $Res Function(ClientHomeNiche) _then) = _$ClientHomeNicheCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ClientHomeNiche.slugKey_) String slug,@JsonKey(name: ClientHomeNiche.nameKey_) String name
});




}
/// @nodoc
class _$ClientHomeNicheCopyWithImpl<$Res>
    implements $ClientHomeNicheCopyWith<$Res> {
  _$ClientHomeNicheCopyWithImpl(this._self, this._then);

  final ClientHomeNiche _self;
  final $Res Function(ClientHomeNiche) _then;

/// Create a copy of ClientHomeNiche
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? slug = null,Object? name = null,}) {
  return _then(_self.copyWith(
slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ClientHomeNiche].
extension ClientHomeNichePatterns on ClientHomeNiche {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientHomeNiche value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientHomeNiche() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientHomeNiche value)  $default,){
final _that = this;
switch (_that) {
case _ClientHomeNiche():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientHomeNiche value)?  $default,){
final _that = this;
switch (_that) {
case _ClientHomeNiche() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ClientHomeNiche.slugKey_)  String slug, @JsonKey(name: ClientHomeNiche.nameKey_)  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientHomeNiche() when $default != null:
return $default(_that.slug,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ClientHomeNiche.slugKey_)  String slug, @JsonKey(name: ClientHomeNiche.nameKey_)  String name)  $default,) {final _that = this;
switch (_that) {
case _ClientHomeNiche():
return $default(_that.slug,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ClientHomeNiche.slugKey_)  String slug, @JsonKey(name: ClientHomeNiche.nameKey_)  String name)?  $default,) {final _that = this;
switch (_that) {
case _ClientHomeNiche() when $default != null:
return $default(_that.slug,_that.name);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ClientHomeNiche extends ClientHomeNiche {
  const _ClientHomeNiche({@JsonKey(name: ClientHomeNiche.slugKey_) required this.slug, @JsonKey(name: ClientHomeNiche.nameKey_) required this.name}): super._();
  factory _ClientHomeNiche.fromJson(Map<String, dynamic> json) => _$ClientHomeNicheFromJson(json);

/// slug
@override@JsonKey(name: ClientHomeNiche.slugKey_) final  String slug;
/// name
@override@JsonKey(name: ClientHomeNiche.nameKey_) final  String name;

/// Create a copy of ClientHomeNiche
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientHomeNicheCopyWith<_ClientHomeNiche> get copyWith => __$ClientHomeNicheCopyWithImpl<_ClientHomeNiche>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientHomeNicheToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientHomeNiche&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slug,name);

@override
String toString() {
  return 'ClientHomeNiche(slug: $slug, name: $name)';
}


}

/// @nodoc
abstract mixin class _$ClientHomeNicheCopyWith<$Res> implements $ClientHomeNicheCopyWith<$Res> {
  factory _$ClientHomeNicheCopyWith(_ClientHomeNiche value, $Res Function(_ClientHomeNiche) _then) = __$ClientHomeNicheCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ClientHomeNiche.slugKey_) String slug,@JsonKey(name: ClientHomeNiche.nameKey_) String name
});




}
/// @nodoc
class __$ClientHomeNicheCopyWithImpl<$Res>
    implements _$ClientHomeNicheCopyWith<$Res> {
  __$ClientHomeNicheCopyWithImpl(this._self, this._then);

  final _ClientHomeNiche _self;
  final $Res Function(_ClientHomeNiche) _then;

/// Create a copy of ClientHomeNiche
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? slug = null,Object? name = null,}) {
  return _then(_ClientHomeNiche(
slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
