// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shelf_camera_model_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ShelfCameraModelView {

/// normalisedModel
@JsonKey(name: ShelfCameraModelView.normalisedModelKey_) String get normalisedModel;/// make
@JsonKey(name: ShelfCameraModelView.makeKey_) String? get make;/// displayName
@JsonKey(name: ShelfCameraModelView.displayNameKey_) String get displayName;
/// Create a copy of ShelfCameraModelView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShelfCameraModelViewCopyWith<ShelfCameraModelView> get copyWith => _$ShelfCameraModelViewCopyWithImpl<ShelfCameraModelView>(this as ShelfCameraModelView, _$identity);

  /// Serializes this ShelfCameraModelView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShelfCameraModelView&&(identical(other.normalisedModel, normalisedModel) || other.normalisedModel == normalisedModel)&&(identical(other.make, make) || other.make == make)&&(identical(other.displayName, displayName) || other.displayName == displayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,normalisedModel,make,displayName);

@override
String toString() {
  return 'ShelfCameraModelView(normalisedModel: $normalisedModel, make: $make, displayName: $displayName)';
}


}

/// @nodoc
abstract mixin class $ShelfCameraModelViewCopyWith<$Res>  {
  factory $ShelfCameraModelViewCopyWith(ShelfCameraModelView value, $Res Function(ShelfCameraModelView) _then) = _$ShelfCameraModelViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ShelfCameraModelView.normalisedModelKey_) String normalisedModel,@JsonKey(name: ShelfCameraModelView.makeKey_) String? make,@JsonKey(name: ShelfCameraModelView.displayNameKey_) String displayName
});




}
/// @nodoc
class _$ShelfCameraModelViewCopyWithImpl<$Res>
    implements $ShelfCameraModelViewCopyWith<$Res> {
  _$ShelfCameraModelViewCopyWithImpl(this._self, this._then);

  final ShelfCameraModelView _self;
  final $Res Function(ShelfCameraModelView) _then;

/// Create a copy of ShelfCameraModelView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? normalisedModel = null,Object? make = freezed,Object? displayName = null,}) {
  return _then(_self.copyWith(
normalisedModel: null == normalisedModel ? _self.normalisedModel : normalisedModel // ignore: cast_nullable_to_non_nullable
as String,make: freezed == make ? _self.make : make // ignore: cast_nullable_to_non_nullable
as String?,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ShelfCameraModelView].
extension ShelfCameraModelViewPatterns on ShelfCameraModelView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShelfCameraModelView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShelfCameraModelView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShelfCameraModelView value)  $default,){
final _that = this;
switch (_that) {
case _ShelfCameraModelView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShelfCameraModelView value)?  $default,){
final _that = this;
switch (_that) {
case _ShelfCameraModelView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ShelfCameraModelView.normalisedModelKey_)  String normalisedModel, @JsonKey(name: ShelfCameraModelView.makeKey_)  String? make, @JsonKey(name: ShelfCameraModelView.displayNameKey_)  String displayName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShelfCameraModelView() when $default != null:
return $default(_that.normalisedModel,_that.make,_that.displayName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ShelfCameraModelView.normalisedModelKey_)  String normalisedModel, @JsonKey(name: ShelfCameraModelView.makeKey_)  String? make, @JsonKey(name: ShelfCameraModelView.displayNameKey_)  String displayName)  $default,) {final _that = this;
switch (_that) {
case _ShelfCameraModelView():
return $default(_that.normalisedModel,_that.make,_that.displayName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ShelfCameraModelView.normalisedModelKey_)  String normalisedModel, @JsonKey(name: ShelfCameraModelView.makeKey_)  String? make, @JsonKey(name: ShelfCameraModelView.displayNameKey_)  String displayName)?  $default,) {final _that = this;
switch (_that) {
case _ShelfCameraModelView() when $default != null:
return $default(_that.normalisedModel,_that.make,_that.displayName);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ShelfCameraModelView extends ShelfCameraModelView {
  const _ShelfCameraModelView({@JsonKey(name: ShelfCameraModelView.normalisedModelKey_) required this.normalisedModel, @JsonKey(name: ShelfCameraModelView.makeKey_) this.make, @JsonKey(name: ShelfCameraModelView.displayNameKey_) required this.displayName}): super._();
  factory _ShelfCameraModelView.fromJson(Map<String, dynamic> json) => _$ShelfCameraModelViewFromJson(json);

/// normalisedModel
@override@JsonKey(name: ShelfCameraModelView.normalisedModelKey_) final  String normalisedModel;
/// make
@override@JsonKey(name: ShelfCameraModelView.makeKey_) final  String? make;
/// displayName
@override@JsonKey(name: ShelfCameraModelView.displayNameKey_) final  String displayName;

/// Create a copy of ShelfCameraModelView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShelfCameraModelViewCopyWith<_ShelfCameraModelView> get copyWith => __$ShelfCameraModelViewCopyWithImpl<_ShelfCameraModelView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShelfCameraModelViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShelfCameraModelView&&(identical(other.normalisedModel, normalisedModel) || other.normalisedModel == normalisedModel)&&(identical(other.make, make) || other.make == make)&&(identical(other.displayName, displayName) || other.displayName == displayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,normalisedModel,make,displayName);

@override
String toString() {
  return 'ShelfCameraModelView(normalisedModel: $normalisedModel, make: $make, displayName: $displayName)';
}


}

/// @nodoc
abstract mixin class _$ShelfCameraModelViewCopyWith<$Res> implements $ShelfCameraModelViewCopyWith<$Res> {
  factory _$ShelfCameraModelViewCopyWith(_ShelfCameraModelView value, $Res Function(_ShelfCameraModelView) _then) = __$ShelfCameraModelViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ShelfCameraModelView.normalisedModelKey_) String normalisedModel,@JsonKey(name: ShelfCameraModelView.makeKey_) String? make,@JsonKey(name: ShelfCameraModelView.displayNameKey_) String displayName
});




}
/// @nodoc
class __$ShelfCameraModelViewCopyWithImpl<$Res>
    implements _$ShelfCameraModelViewCopyWith<$Res> {
  __$ShelfCameraModelViewCopyWithImpl(this._self, this._then);

  final _ShelfCameraModelView _self;
  final $Res Function(_ShelfCameraModelView) _then;

/// Create a copy of ShelfCameraModelView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? normalisedModel = null,Object? make = freezed,Object? displayName = null,}) {
  return _then(_ShelfCameraModelView(
normalisedModel: null == normalisedModel ? _self.normalisedModel : normalisedModel // ignore: cast_nullable_to_non_nullable
as String,make: freezed == make ? _self.make : make // ignore: cast_nullable_to_non_nullable
as String?,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
