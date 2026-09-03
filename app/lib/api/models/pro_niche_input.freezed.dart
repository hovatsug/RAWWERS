// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pro_niche_input.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProNicheInput {

/// slug
@JsonKey(name: ProNicheInput.slugKey_) String get slug;/// declaredLevel
@JsonKey(name: ProNicheInput.declaredLevelKey_) DeclaredLevel? get declaredLevel;/// isPrimary
@JsonKey(name: ProNicheInput.isPrimaryKey_) bool get isPrimary;
/// Create a copy of ProNicheInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProNicheInputCopyWith<ProNicheInput> get copyWith => _$ProNicheInputCopyWithImpl<ProNicheInput>(this as ProNicheInput, _$identity);

  /// Serializes this ProNicheInput to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProNicheInput&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.declaredLevel, declaredLevel) || other.declaredLevel == declaredLevel)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slug,declaredLevel,isPrimary);

@override
String toString() {
  return 'ProNicheInput(slug: $slug, declaredLevel: $declaredLevel, isPrimary: $isPrimary)';
}


}

/// @nodoc
abstract mixin class $ProNicheInputCopyWith<$Res>  {
  factory $ProNicheInputCopyWith(ProNicheInput value, $Res Function(ProNicheInput) _then) = _$ProNicheInputCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ProNicheInput.slugKey_) String slug,@JsonKey(name: ProNicheInput.declaredLevelKey_) DeclaredLevel? declaredLevel,@JsonKey(name: ProNicheInput.isPrimaryKey_) bool isPrimary
});




}
/// @nodoc
class _$ProNicheInputCopyWithImpl<$Res>
    implements $ProNicheInputCopyWith<$Res> {
  _$ProNicheInputCopyWithImpl(this._self, this._then);

  final ProNicheInput _self;
  final $Res Function(ProNicheInput) _then;

/// Create a copy of ProNicheInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? slug = null,Object? declaredLevel = freezed,Object? isPrimary = null,}) {
  return _then(_self.copyWith(
slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,declaredLevel: freezed == declaredLevel ? _self.declaredLevel : declaredLevel // ignore: cast_nullable_to_non_nullable
as DeclaredLevel?,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ProNicheInput].
extension ProNicheInputPatterns on ProNicheInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProNicheInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProNicheInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProNicheInput value)  $default,){
final _that = this;
switch (_that) {
case _ProNicheInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProNicheInput value)?  $default,){
final _that = this;
switch (_that) {
case _ProNicheInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ProNicheInput.slugKey_)  String slug, @JsonKey(name: ProNicheInput.declaredLevelKey_)  DeclaredLevel? declaredLevel, @JsonKey(name: ProNicheInput.isPrimaryKey_)  bool isPrimary)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProNicheInput() when $default != null:
return $default(_that.slug,_that.declaredLevel,_that.isPrimary);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ProNicheInput.slugKey_)  String slug, @JsonKey(name: ProNicheInput.declaredLevelKey_)  DeclaredLevel? declaredLevel, @JsonKey(name: ProNicheInput.isPrimaryKey_)  bool isPrimary)  $default,) {final _that = this;
switch (_that) {
case _ProNicheInput():
return $default(_that.slug,_that.declaredLevel,_that.isPrimary);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ProNicheInput.slugKey_)  String slug, @JsonKey(name: ProNicheInput.declaredLevelKey_)  DeclaredLevel? declaredLevel, @JsonKey(name: ProNicheInput.isPrimaryKey_)  bool isPrimary)?  $default,) {final _that = this;
switch (_that) {
case _ProNicheInput() when $default != null:
return $default(_that.slug,_that.declaredLevel,_that.isPrimary);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ProNicheInput extends ProNicheInput {
  const _ProNicheInput({@JsonKey(name: ProNicheInput.slugKey_) required this.slug, @JsonKey(name: ProNicheInput.declaredLevelKey_) this.declaredLevel, @JsonKey(name: ProNicheInput.isPrimaryKey_) this.isPrimary = false}): super._();
  factory _ProNicheInput.fromJson(Map<String, dynamic> json) => _$ProNicheInputFromJson(json);

/// slug
@override@JsonKey(name: ProNicheInput.slugKey_) final  String slug;
/// declaredLevel
@override@JsonKey(name: ProNicheInput.declaredLevelKey_) final  DeclaredLevel? declaredLevel;
/// isPrimary
@override@JsonKey(name: ProNicheInput.isPrimaryKey_) final  bool isPrimary;

/// Create a copy of ProNicheInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProNicheInputCopyWith<_ProNicheInput> get copyWith => __$ProNicheInputCopyWithImpl<_ProNicheInput>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProNicheInputToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProNicheInput&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.declaredLevel, declaredLevel) || other.declaredLevel == declaredLevel)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slug,declaredLevel,isPrimary);

@override
String toString() {
  return 'ProNicheInput(slug: $slug, declaredLevel: $declaredLevel, isPrimary: $isPrimary)';
}


}

/// @nodoc
abstract mixin class _$ProNicheInputCopyWith<$Res> implements $ProNicheInputCopyWith<$Res> {
  factory _$ProNicheInputCopyWith(_ProNicheInput value, $Res Function(_ProNicheInput) _then) = __$ProNicheInputCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ProNicheInput.slugKey_) String slug,@JsonKey(name: ProNicheInput.declaredLevelKey_) DeclaredLevel? declaredLevel,@JsonKey(name: ProNicheInput.isPrimaryKey_) bool isPrimary
});




}
/// @nodoc
class __$ProNicheInputCopyWithImpl<$Res>
    implements _$ProNicheInputCopyWith<$Res> {
  __$ProNicheInputCopyWithImpl(this._self, this._then);

  final _ProNicheInput _self;
  final $Res Function(_ProNicheInput) _then;

/// Create a copy of ProNicheInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? slug = null,Object? declaredLevel = freezed,Object? isPrimary = null,}) {
  return _then(_ProNicheInput(
slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,declaredLevel: freezed == declaredLevel ? _self.declaredLevel : declaredLevel // ignore: cast_nullable_to_non_nullable
as DeclaredLevel?,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
