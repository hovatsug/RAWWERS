// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'niche_banner_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NicheBannerView {

/// style
@JsonKey(name: NicheBannerView.styleKey_) NicheBannerStyle get style;/// name
@JsonKey(name: NicheBannerView.nameKey_) String get name;/// tagline
@JsonKey(name: NicheBannerView.taglineKey_) String? get tagline;/// image
@JsonKey(name: NicheBannerView.imageKey_) NicheBannerImageView? get image;
/// Create a copy of NicheBannerView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NicheBannerViewCopyWith<NicheBannerView> get copyWith => _$NicheBannerViewCopyWithImpl<NicheBannerView>(this as NicheBannerView, _$identity);

  /// Serializes this NicheBannerView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NicheBannerView&&(identical(other.style, style) || other.style == style)&&(identical(other.name, name) || other.name == name)&&(identical(other.tagline, tagline) || other.tagline == tagline)&&(identical(other.image, image) || other.image == image));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,style,name,tagline,image);

@override
String toString() {
  return 'NicheBannerView(style: $style, name: $name, tagline: $tagline, image: $image)';
}


}

/// @nodoc
abstract mixin class $NicheBannerViewCopyWith<$Res>  {
  factory $NicheBannerViewCopyWith(NicheBannerView value, $Res Function(NicheBannerView) _then) = _$NicheBannerViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: NicheBannerView.styleKey_) NicheBannerStyle style,@JsonKey(name: NicheBannerView.nameKey_) String name,@JsonKey(name: NicheBannerView.taglineKey_) String? tagline,@JsonKey(name: NicheBannerView.imageKey_) NicheBannerImageView? image
});


$NicheBannerImageViewCopyWith<$Res>? get image;

}
/// @nodoc
class _$NicheBannerViewCopyWithImpl<$Res>
    implements $NicheBannerViewCopyWith<$Res> {
  _$NicheBannerViewCopyWithImpl(this._self, this._then);

  final NicheBannerView _self;
  final $Res Function(NicheBannerView) _then;

/// Create a copy of NicheBannerView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? style = null,Object? name = null,Object? tagline = freezed,Object? image = freezed,}) {
  return _then(_self.copyWith(
style: null == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as NicheBannerStyle,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,tagline: freezed == tagline ? _self.tagline : tagline // ignore: cast_nullable_to_non_nullable
as String?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as NicheBannerImageView?,
  ));
}
/// Create a copy of NicheBannerView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NicheBannerImageViewCopyWith<$Res>? get image {
    if (_self.image == null) {
    return null;
  }

  return $NicheBannerImageViewCopyWith<$Res>(_self.image!, (value) {
    return _then(_self.copyWith(image: value));
  });
}
}


/// Adds pattern-matching-related methods to [NicheBannerView].
extension NicheBannerViewPatterns on NicheBannerView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NicheBannerView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NicheBannerView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NicheBannerView value)  $default,){
final _that = this;
switch (_that) {
case _NicheBannerView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NicheBannerView value)?  $default,){
final _that = this;
switch (_that) {
case _NicheBannerView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: NicheBannerView.styleKey_)  NicheBannerStyle style, @JsonKey(name: NicheBannerView.nameKey_)  String name, @JsonKey(name: NicheBannerView.taglineKey_)  String? tagline, @JsonKey(name: NicheBannerView.imageKey_)  NicheBannerImageView? image)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NicheBannerView() when $default != null:
return $default(_that.style,_that.name,_that.tagline,_that.image);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: NicheBannerView.styleKey_)  NicheBannerStyle style, @JsonKey(name: NicheBannerView.nameKey_)  String name, @JsonKey(name: NicheBannerView.taglineKey_)  String? tagline, @JsonKey(name: NicheBannerView.imageKey_)  NicheBannerImageView? image)  $default,) {final _that = this;
switch (_that) {
case _NicheBannerView():
return $default(_that.style,_that.name,_that.tagline,_that.image);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: NicheBannerView.styleKey_)  NicheBannerStyle style, @JsonKey(name: NicheBannerView.nameKey_)  String name, @JsonKey(name: NicheBannerView.taglineKey_)  String? tagline, @JsonKey(name: NicheBannerView.imageKey_)  NicheBannerImageView? image)?  $default,) {final _that = this;
switch (_that) {
case _NicheBannerView() when $default != null:
return $default(_that.style,_that.name,_that.tagline,_that.image);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _NicheBannerView extends NicheBannerView {
  const _NicheBannerView({@JsonKey(name: NicheBannerView.styleKey_) required this.style, @JsonKey(name: NicheBannerView.nameKey_) required this.name, @JsonKey(name: NicheBannerView.taglineKey_) this.tagline, @JsonKey(name: NicheBannerView.imageKey_) this.image}): super._();
  factory _NicheBannerView.fromJson(Map<String, dynamic> json) => _$NicheBannerViewFromJson(json);

/// style
@override@JsonKey(name: NicheBannerView.styleKey_) final  NicheBannerStyle style;
/// name
@override@JsonKey(name: NicheBannerView.nameKey_) final  String name;
/// tagline
@override@JsonKey(name: NicheBannerView.taglineKey_) final  String? tagline;
/// image
@override@JsonKey(name: NicheBannerView.imageKey_) final  NicheBannerImageView? image;

/// Create a copy of NicheBannerView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NicheBannerViewCopyWith<_NicheBannerView> get copyWith => __$NicheBannerViewCopyWithImpl<_NicheBannerView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NicheBannerViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NicheBannerView&&(identical(other.style, style) || other.style == style)&&(identical(other.name, name) || other.name == name)&&(identical(other.tagline, tagline) || other.tagline == tagline)&&(identical(other.image, image) || other.image == image));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,style,name,tagline,image);

@override
String toString() {
  return 'NicheBannerView(style: $style, name: $name, tagline: $tagline, image: $image)';
}


}

/// @nodoc
abstract mixin class _$NicheBannerViewCopyWith<$Res> implements $NicheBannerViewCopyWith<$Res> {
  factory _$NicheBannerViewCopyWith(_NicheBannerView value, $Res Function(_NicheBannerView) _then) = __$NicheBannerViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: NicheBannerView.styleKey_) NicheBannerStyle style,@JsonKey(name: NicheBannerView.nameKey_) String name,@JsonKey(name: NicheBannerView.taglineKey_) String? tagline,@JsonKey(name: NicheBannerView.imageKey_) NicheBannerImageView? image
});


@override $NicheBannerImageViewCopyWith<$Res>? get image;

}
/// @nodoc
class __$NicheBannerViewCopyWithImpl<$Res>
    implements _$NicheBannerViewCopyWith<$Res> {
  __$NicheBannerViewCopyWithImpl(this._self, this._then);

  final _NicheBannerView _self;
  final $Res Function(_NicheBannerView) _then;

/// Create a copy of NicheBannerView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? style = null,Object? name = null,Object? tagline = freezed,Object? image = freezed,}) {
  return _then(_NicheBannerView(
style: null == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as NicheBannerStyle,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,tagline: freezed == tagline ? _self.tagline : tagline // ignore: cast_nullable_to_non_nullable
as String?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as NicheBannerImageView?,
  ));
}

/// Create a copy of NicheBannerView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NicheBannerImageViewCopyWith<$Res>? get image {
    if (_self.image == null) {
    return null;
  }

  return $NicheBannerImageViewCopyWith<$Res>(_self.image!, (value) {
    return _then(_self.copyWith(image: value));
  });
}
}

// dart format on
