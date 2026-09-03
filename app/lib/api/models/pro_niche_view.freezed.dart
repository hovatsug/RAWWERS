// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pro_niche_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProNicheView {

/// slug
@JsonKey(name: ProNicheView.slugKey_) String get slug;/// name
@JsonKey(name: ProNicheView.nameKey_) String get name;/// declaredLevel
@JsonKey(name: ProNicheView.declaredLevelKey_) DeclaredLevel? get declaredLevel;/// isPrimary
@JsonKey(name: ProNicheView.isPrimaryKey_) bool get isPrimary;
/// Create a copy of ProNicheView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProNicheViewCopyWith<ProNicheView> get copyWith => _$ProNicheViewCopyWithImpl<ProNicheView>(this as ProNicheView, _$identity);

  /// Serializes this ProNicheView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProNicheView&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.declaredLevel, declaredLevel) || other.declaredLevel == declaredLevel)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slug,name,declaredLevel,isPrimary);

@override
String toString() {
  return 'ProNicheView(slug: $slug, name: $name, declaredLevel: $declaredLevel, isPrimary: $isPrimary)';
}


}

/// @nodoc
abstract mixin class $ProNicheViewCopyWith<$Res>  {
  factory $ProNicheViewCopyWith(ProNicheView value, $Res Function(ProNicheView) _then) = _$ProNicheViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ProNicheView.slugKey_) String slug,@JsonKey(name: ProNicheView.nameKey_) String name,@JsonKey(name: ProNicheView.declaredLevelKey_) DeclaredLevel? declaredLevel,@JsonKey(name: ProNicheView.isPrimaryKey_) bool isPrimary
});




}
/// @nodoc
class _$ProNicheViewCopyWithImpl<$Res>
    implements $ProNicheViewCopyWith<$Res> {
  _$ProNicheViewCopyWithImpl(this._self, this._then);

  final ProNicheView _self;
  final $Res Function(ProNicheView) _then;

/// Create a copy of ProNicheView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? slug = null,Object? name = null,Object? declaredLevel = freezed,Object? isPrimary = null,}) {
  return _then(_self.copyWith(
slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,declaredLevel: freezed == declaredLevel ? _self.declaredLevel : declaredLevel // ignore: cast_nullable_to_non_nullable
as DeclaredLevel?,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ProNicheView].
extension ProNicheViewPatterns on ProNicheView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProNicheView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProNicheView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProNicheView value)  $default,){
final _that = this;
switch (_that) {
case _ProNicheView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProNicheView value)?  $default,){
final _that = this;
switch (_that) {
case _ProNicheView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ProNicheView.slugKey_)  String slug, @JsonKey(name: ProNicheView.nameKey_)  String name, @JsonKey(name: ProNicheView.declaredLevelKey_)  DeclaredLevel? declaredLevel, @JsonKey(name: ProNicheView.isPrimaryKey_)  bool isPrimary)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProNicheView() when $default != null:
return $default(_that.slug,_that.name,_that.declaredLevel,_that.isPrimary);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ProNicheView.slugKey_)  String slug, @JsonKey(name: ProNicheView.nameKey_)  String name, @JsonKey(name: ProNicheView.declaredLevelKey_)  DeclaredLevel? declaredLevel, @JsonKey(name: ProNicheView.isPrimaryKey_)  bool isPrimary)  $default,) {final _that = this;
switch (_that) {
case _ProNicheView():
return $default(_that.slug,_that.name,_that.declaredLevel,_that.isPrimary);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ProNicheView.slugKey_)  String slug, @JsonKey(name: ProNicheView.nameKey_)  String name, @JsonKey(name: ProNicheView.declaredLevelKey_)  DeclaredLevel? declaredLevel, @JsonKey(name: ProNicheView.isPrimaryKey_)  bool isPrimary)?  $default,) {final _that = this;
switch (_that) {
case _ProNicheView() when $default != null:
return $default(_that.slug,_that.name,_that.declaredLevel,_that.isPrimary);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ProNicheView extends ProNicheView {
  const _ProNicheView({@JsonKey(name: ProNicheView.slugKey_) required this.slug, @JsonKey(name: ProNicheView.nameKey_) required this.name, @JsonKey(name: ProNicheView.declaredLevelKey_) this.declaredLevel, @JsonKey(name: ProNicheView.isPrimaryKey_) required this.isPrimary}): super._();
  factory _ProNicheView.fromJson(Map<String, dynamic> json) => _$ProNicheViewFromJson(json);

/// slug
@override@JsonKey(name: ProNicheView.slugKey_) final  String slug;
/// name
@override@JsonKey(name: ProNicheView.nameKey_) final  String name;
/// declaredLevel
@override@JsonKey(name: ProNicheView.declaredLevelKey_) final  DeclaredLevel? declaredLevel;
/// isPrimary
@override@JsonKey(name: ProNicheView.isPrimaryKey_) final  bool isPrimary;

/// Create a copy of ProNicheView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProNicheViewCopyWith<_ProNicheView> get copyWith => __$ProNicheViewCopyWithImpl<_ProNicheView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProNicheViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProNicheView&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.declaredLevel, declaredLevel) || other.declaredLevel == declaredLevel)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slug,name,declaredLevel,isPrimary);

@override
String toString() {
  return 'ProNicheView(slug: $slug, name: $name, declaredLevel: $declaredLevel, isPrimary: $isPrimary)';
}


}

/// @nodoc
abstract mixin class _$ProNicheViewCopyWith<$Res> implements $ProNicheViewCopyWith<$Res> {
  factory _$ProNicheViewCopyWith(_ProNicheView value, $Res Function(_ProNicheView) _then) = __$ProNicheViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ProNicheView.slugKey_) String slug,@JsonKey(name: ProNicheView.nameKey_) String name,@JsonKey(name: ProNicheView.declaredLevelKey_) DeclaredLevel? declaredLevel,@JsonKey(name: ProNicheView.isPrimaryKey_) bool isPrimary
});




}
/// @nodoc
class __$ProNicheViewCopyWithImpl<$Res>
    implements _$ProNicheViewCopyWith<$Res> {
  __$ProNicheViewCopyWithImpl(this._self, this._then);

  final _ProNicheView _self;
  final $Res Function(_ProNicheView) _then;

/// Create a copy of ProNicheView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? slug = null,Object? name = null,Object? declaredLevel = freezed,Object? isPrimary = null,}) {
  return _then(_ProNicheView(
slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,declaredLevel: freezed == declaredLevel ? _self.declaredLevel : declaredLevel // ignore: cast_nullable_to_non_nullable
as DeclaredLevel?,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
