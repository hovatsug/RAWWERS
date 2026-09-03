// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'media_object_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MediaObjectView {

/// variant
@JsonKey(name: MediaObjectView.variantKey_) String get variant;/// status
@JsonKey(name: MediaObjectView.statusKey_) String get status;/// width
@JsonKey(name: MediaObjectView.widthKey_) int? get width;/// height
@JsonKey(name: MediaObjectView.heightKey_) int? get height;/// url
@JsonKey(name: MediaObjectView.urlKey_) String? get url;
/// Create a copy of MediaObjectView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaObjectViewCopyWith<MediaObjectView> get copyWith => _$MediaObjectViewCopyWithImpl<MediaObjectView>(this as MediaObjectView, _$identity);

  /// Serializes this MediaObjectView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaObjectView&&(identical(other.variant, variant) || other.variant == variant)&&(identical(other.status, status) || other.status == status)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,variant,status,width,height,url);

@override
String toString() {
  return 'MediaObjectView(variant: $variant, status: $status, width: $width, height: $height, url: $url)';
}


}

/// @nodoc
abstract mixin class $MediaObjectViewCopyWith<$Res>  {
  factory $MediaObjectViewCopyWith(MediaObjectView value, $Res Function(MediaObjectView) _then) = _$MediaObjectViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: MediaObjectView.variantKey_) String variant,@JsonKey(name: MediaObjectView.statusKey_) String status,@JsonKey(name: MediaObjectView.widthKey_) int? width,@JsonKey(name: MediaObjectView.heightKey_) int? height,@JsonKey(name: MediaObjectView.urlKey_) String? url
});




}
/// @nodoc
class _$MediaObjectViewCopyWithImpl<$Res>
    implements $MediaObjectViewCopyWith<$Res> {
  _$MediaObjectViewCopyWithImpl(this._self, this._then);

  final MediaObjectView _self;
  final $Res Function(MediaObjectView) _then;

/// Create a copy of MediaObjectView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? variant = null,Object? status = null,Object? width = freezed,Object? height = freezed,Object? url = freezed,}) {
  return _then(_self.copyWith(
variant: null == variant ? _self.variant : variant // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MediaObjectView].
extension MediaObjectViewPatterns on MediaObjectView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MediaObjectView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MediaObjectView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MediaObjectView value)  $default,){
final _that = this;
switch (_that) {
case _MediaObjectView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MediaObjectView value)?  $default,){
final _that = this;
switch (_that) {
case _MediaObjectView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: MediaObjectView.variantKey_)  String variant, @JsonKey(name: MediaObjectView.statusKey_)  String status, @JsonKey(name: MediaObjectView.widthKey_)  int? width, @JsonKey(name: MediaObjectView.heightKey_)  int? height, @JsonKey(name: MediaObjectView.urlKey_)  String? url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MediaObjectView() when $default != null:
return $default(_that.variant,_that.status,_that.width,_that.height,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: MediaObjectView.variantKey_)  String variant, @JsonKey(name: MediaObjectView.statusKey_)  String status, @JsonKey(name: MediaObjectView.widthKey_)  int? width, @JsonKey(name: MediaObjectView.heightKey_)  int? height, @JsonKey(name: MediaObjectView.urlKey_)  String? url)  $default,) {final _that = this;
switch (_that) {
case _MediaObjectView():
return $default(_that.variant,_that.status,_that.width,_that.height,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: MediaObjectView.variantKey_)  String variant, @JsonKey(name: MediaObjectView.statusKey_)  String status, @JsonKey(name: MediaObjectView.widthKey_)  int? width, @JsonKey(name: MediaObjectView.heightKey_)  int? height, @JsonKey(name: MediaObjectView.urlKey_)  String? url)?  $default,) {final _that = this;
switch (_that) {
case _MediaObjectView() when $default != null:
return $default(_that.variant,_that.status,_that.width,_that.height,_that.url);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _MediaObjectView extends MediaObjectView {
  const _MediaObjectView({@JsonKey(name: MediaObjectView.variantKey_) required this.variant, @JsonKey(name: MediaObjectView.statusKey_) required this.status, @JsonKey(name: MediaObjectView.widthKey_) this.width, @JsonKey(name: MediaObjectView.heightKey_) this.height, @JsonKey(name: MediaObjectView.urlKey_) this.url}): super._();
  factory _MediaObjectView.fromJson(Map<String, dynamic> json) => _$MediaObjectViewFromJson(json);

/// variant
@override@JsonKey(name: MediaObjectView.variantKey_) final  String variant;
/// status
@override@JsonKey(name: MediaObjectView.statusKey_) final  String status;
/// width
@override@JsonKey(name: MediaObjectView.widthKey_) final  int? width;
/// height
@override@JsonKey(name: MediaObjectView.heightKey_) final  int? height;
/// url
@override@JsonKey(name: MediaObjectView.urlKey_) final  String? url;

/// Create a copy of MediaObjectView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaObjectViewCopyWith<_MediaObjectView> get copyWith => __$MediaObjectViewCopyWithImpl<_MediaObjectView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MediaObjectViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaObjectView&&(identical(other.variant, variant) || other.variant == variant)&&(identical(other.status, status) || other.status == status)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,variant,status,width,height,url);

@override
String toString() {
  return 'MediaObjectView(variant: $variant, status: $status, width: $width, height: $height, url: $url)';
}


}

/// @nodoc
abstract mixin class _$MediaObjectViewCopyWith<$Res> implements $MediaObjectViewCopyWith<$Res> {
  factory _$MediaObjectViewCopyWith(_MediaObjectView value, $Res Function(_MediaObjectView) _then) = __$MediaObjectViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: MediaObjectView.variantKey_) String variant,@JsonKey(name: MediaObjectView.statusKey_) String status,@JsonKey(name: MediaObjectView.widthKey_) int? width,@JsonKey(name: MediaObjectView.heightKey_) int? height,@JsonKey(name: MediaObjectView.urlKey_) String? url
});




}
/// @nodoc
class __$MediaObjectViewCopyWithImpl<$Res>
    implements _$MediaObjectViewCopyWith<$Res> {
  __$MediaObjectViewCopyWithImpl(this._self, this._then);

  final _MediaObjectView _self;
  final $Res Function(_MediaObjectView) _then;

/// Create a copy of MediaObjectView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? variant = null,Object? status = null,Object? width = freezed,Object? height = freezed,Object? url = freezed,}) {
  return _then(_MediaObjectView(
variant: null == variant ? _self.variant : variant // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
