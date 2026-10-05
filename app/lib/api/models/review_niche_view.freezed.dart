// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review_niche_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReviewNicheView {

/// slug
@JsonKey(name: ReviewNicheView.slugKey_) String get slug;/// name
@JsonKey(name: ReviewNicheView.nameKey_) String get name;
/// Create a copy of ReviewNicheView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReviewNicheViewCopyWith<ReviewNicheView> get copyWith => _$ReviewNicheViewCopyWithImpl<ReviewNicheView>(this as ReviewNicheView, _$identity);

  /// Serializes this ReviewNicheView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReviewNicheView&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slug,name);

@override
String toString() {
  return 'ReviewNicheView(slug: $slug, name: $name)';
}


}

/// @nodoc
abstract mixin class $ReviewNicheViewCopyWith<$Res>  {
  factory $ReviewNicheViewCopyWith(ReviewNicheView value, $Res Function(ReviewNicheView) _then) = _$ReviewNicheViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ReviewNicheView.slugKey_) String slug,@JsonKey(name: ReviewNicheView.nameKey_) String name
});




}
/// @nodoc
class _$ReviewNicheViewCopyWithImpl<$Res>
    implements $ReviewNicheViewCopyWith<$Res> {
  _$ReviewNicheViewCopyWithImpl(this._self, this._then);

  final ReviewNicheView _self;
  final $Res Function(ReviewNicheView) _then;

/// Create a copy of ReviewNicheView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? slug = null,Object? name = null,}) {
  return _then(_self.copyWith(
slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ReviewNicheView].
extension ReviewNicheViewPatterns on ReviewNicheView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReviewNicheView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReviewNicheView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReviewNicheView value)  $default,){
final _that = this;
switch (_that) {
case _ReviewNicheView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReviewNicheView value)?  $default,){
final _that = this;
switch (_that) {
case _ReviewNicheView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ReviewNicheView.slugKey_)  String slug, @JsonKey(name: ReviewNicheView.nameKey_)  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReviewNicheView() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ReviewNicheView.slugKey_)  String slug, @JsonKey(name: ReviewNicheView.nameKey_)  String name)  $default,) {final _that = this;
switch (_that) {
case _ReviewNicheView():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ReviewNicheView.slugKey_)  String slug, @JsonKey(name: ReviewNicheView.nameKey_)  String name)?  $default,) {final _that = this;
switch (_that) {
case _ReviewNicheView() when $default != null:
return $default(_that.slug,_that.name);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ReviewNicheView extends ReviewNicheView {
  const _ReviewNicheView({@JsonKey(name: ReviewNicheView.slugKey_) required this.slug, @JsonKey(name: ReviewNicheView.nameKey_) required this.name}): super._();
  factory _ReviewNicheView.fromJson(Map<String, dynamic> json) => _$ReviewNicheViewFromJson(json);

/// slug
@override@JsonKey(name: ReviewNicheView.slugKey_) final  String slug;
/// name
@override@JsonKey(name: ReviewNicheView.nameKey_) final  String name;

/// Create a copy of ReviewNicheView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReviewNicheViewCopyWith<_ReviewNicheView> get copyWith => __$ReviewNicheViewCopyWithImpl<_ReviewNicheView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReviewNicheViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReviewNicheView&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slug,name);

@override
String toString() {
  return 'ReviewNicheView(slug: $slug, name: $name)';
}


}

/// @nodoc
abstract mixin class _$ReviewNicheViewCopyWith<$Res> implements $ReviewNicheViewCopyWith<$Res> {
  factory _$ReviewNicheViewCopyWith(_ReviewNicheView value, $Res Function(_ReviewNicheView) _then) = __$ReviewNicheViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ReviewNicheView.slugKey_) String slug,@JsonKey(name: ReviewNicheView.nameKey_) String name
});




}
/// @nodoc
class __$ReviewNicheViewCopyWithImpl<$Res>
    implements _$ReviewNicheViewCopyWith<$Res> {
  __$ReviewNicheViewCopyWithImpl(this._self, this._then);

  final _ReviewNicheView _self;
  final $Res Function(_ReviewNicheView) _then;

/// Create a copy of ReviewNicheView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? slug = null,Object? name = null,}) {
  return _then(_ReviewNicheView(
slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
