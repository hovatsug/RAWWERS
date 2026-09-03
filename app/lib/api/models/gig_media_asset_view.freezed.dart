// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gig_media_asset_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GigMediaAssetView {

/// mediaAssetId
@JsonKey(name: GigMediaAssetView.mediaAssetIdKey_) String get mediaAssetId;/// kind
@JsonKey(name: GigMediaAssetView.kindKey_) String get kind;/// purpose
@JsonKey(name: GigMediaAssetView.purposeKey_) String get purpose;/// derivatives
@JsonKey(name: GigMediaAssetView.derivativesKey_) List<MediaDerivativeView>? get derivatives;
/// Create a copy of GigMediaAssetView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GigMediaAssetViewCopyWith<GigMediaAssetView> get copyWith => _$GigMediaAssetViewCopyWithImpl<GigMediaAssetView>(this as GigMediaAssetView, _$identity);

  /// Serializes this GigMediaAssetView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GigMediaAssetView&&(identical(other.mediaAssetId, mediaAssetId) || other.mediaAssetId == mediaAssetId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&const DeepCollectionEquality().equals(other.derivatives, derivatives));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaAssetId,kind,purpose,const DeepCollectionEquality().hash(derivatives));

@override
String toString() {
  return 'GigMediaAssetView(mediaAssetId: $mediaAssetId, kind: $kind, purpose: $purpose, derivatives: $derivatives)';
}


}

/// @nodoc
abstract mixin class $GigMediaAssetViewCopyWith<$Res>  {
  factory $GigMediaAssetViewCopyWith(GigMediaAssetView value, $Res Function(GigMediaAssetView) _then) = _$GigMediaAssetViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: GigMediaAssetView.mediaAssetIdKey_) String mediaAssetId,@JsonKey(name: GigMediaAssetView.kindKey_) String kind,@JsonKey(name: GigMediaAssetView.purposeKey_) String purpose,@JsonKey(name: GigMediaAssetView.derivativesKey_) List<MediaDerivativeView>? derivatives
});




}
/// @nodoc
class _$GigMediaAssetViewCopyWithImpl<$Res>
    implements $GigMediaAssetViewCopyWith<$Res> {
  _$GigMediaAssetViewCopyWithImpl(this._self, this._then);

  final GigMediaAssetView _self;
  final $Res Function(GigMediaAssetView) _then;

/// Create a copy of GigMediaAssetView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mediaAssetId = null,Object? kind = null,Object? purpose = null,Object? derivatives = freezed,}) {
  return _then(_self.copyWith(
mediaAssetId: null == mediaAssetId ? _self.mediaAssetId : mediaAssetId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String,derivatives: freezed == derivatives ? _self.derivatives : derivatives // ignore: cast_nullable_to_non_nullable
as List<MediaDerivativeView>?,
  ));
}

}


/// Adds pattern-matching-related methods to [GigMediaAssetView].
extension GigMediaAssetViewPatterns on GigMediaAssetView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GigMediaAssetView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GigMediaAssetView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GigMediaAssetView value)  $default,){
final _that = this;
switch (_that) {
case _GigMediaAssetView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GigMediaAssetView value)?  $default,){
final _that = this;
switch (_that) {
case _GigMediaAssetView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: GigMediaAssetView.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: GigMediaAssetView.kindKey_)  String kind, @JsonKey(name: GigMediaAssetView.purposeKey_)  String purpose, @JsonKey(name: GigMediaAssetView.derivativesKey_)  List<MediaDerivativeView>? derivatives)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GigMediaAssetView() when $default != null:
return $default(_that.mediaAssetId,_that.kind,_that.purpose,_that.derivatives);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: GigMediaAssetView.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: GigMediaAssetView.kindKey_)  String kind, @JsonKey(name: GigMediaAssetView.purposeKey_)  String purpose, @JsonKey(name: GigMediaAssetView.derivativesKey_)  List<MediaDerivativeView>? derivatives)  $default,) {final _that = this;
switch (_that) {
case _GigMediaAssetView():
return $default(_that.mediaAssetId,_that.kind,_that.purpose,_that.derivatives);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: GigMediaAssetView.mediaAssetIdKey_)  String mediaAssetId, @JsonKey(name: GigMediaAssetView.kindKey_)  String kind, @JsonKey(name: GigMediaAssetView.purposeKey_)  String purpose, @JsonKey(name: GigMediaAssetView.derivativesKey_)  List<MediaDerivativeView>? derivatives)?  $default,) {final _that = this;
switch (_that) {
case _GigMediaAssetView() when $default != null:
return $default(_that.mediaAssetId,_that.kind,_that.purpose,_that.derivatives);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _GigMediaAssetView extends GigMediaAssetView {
  const _GigMediaAssetView({@JsonKey(name: GigMediaAssetView.mediaAssetIdKey_) required this.mediaAssetId, @JsonKey(name: GigMediaAssetView.kindKey_) required this.kind, @JsonKey(name: GigMediaAssetView.purposeKey_) required this.purpose, @JsonKey(name: GigMediaAssetView.derivativesKey_) final  List<MediaDerivativeView>? derivatives}): _derivatives = derivatives,super._();
  factory _GigMediaAssetView.fromJson(Map<String, dynamic> json) => _$GigMediaAssetViewFromJson(json);

/// mediaAssetId
@override@JsonKey(name: GigMediaAssetView.mediaAssetIdKey_) final  String mediaAssetId;
/// kind
@override@JsonKey(name: GigMediaAssetView.kindKey_) final  String kind;
/// purpose
@override@JsonKey(name: GigMediaAssetView.purposeKey_) final  String purpose;
/// derivatives
 final  List<MediaDerivativeView>? _derivatives;
/// derivatives
@override@JsonKey(name: GigMediaAssetView.derivativesKey_) List<MediaDerivativeView>? get derivatives {
  final value = _derivatives;
  if (value == null) return null;
  if (_derivatives is EqualUnmodifiableListView) return _derivatives;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of GigMediaAssetView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GigMediaAssetViewCopyWith<_GigMediaAssetView> get copyWith => __$GigMediaAssetViewCopyWithImpl<_GigMediaAssetView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GigMediaAssetViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GigMediaAssetView&&(identical(other.mediaAssetId, mediaAssetId) || other.mediaAssetId == mediaAssetId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&const DeepCollectionEquality().equals(other._derivatives, _derivatives));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaAssetId,kind,purpose,const DeepCollectionEquality().hash(_derivatives));

@override
String toString() {
  return 'GigMediaAssetView(mediaAssetId: $mediaAssetId, kind: $kind, purpose: $purpose, derivatives: $derivatives)';
}


}

/// @nodoc
abstract mixin class _$GigMediaAssetViewCopyWith<$Res> implements $GigMediaAssetViewCopyWith<$Res> {
  factory _$GigMediaAssetViewCopyWith(_GigMediaAssetView value, $Res Function(_GigMediaAssetView) _then) = __$GigMediaAssetViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: GigMediaAssetView.mediaAssetIdKey_) String mediaAssetId,@JsonKey(name: GigMediaAssetView.kindKey_) String kind,@JsonKey(name: GigMediaAssetView.purposeKey_) String purpose,@JsonKey(name: GigMediaAssetView.derivativesKey_) List<MediaDerivativeView>? derivatives
});




}
/// @nodoc
class __$GigMediaAssetViewCopyWithImpl<$Res>
    implements _$GigMediaAssetViewCopyWith<$Res> {
  __$GigMediaAssetViewCopyWithImpl(this._self, this._then);

  final _GigMediaAssetView _self;
  final $Res Function(_GigMediaAssetView) _then;

/// Create a copy of GigMediaAssetView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mediaAssetId = null,Object? kind = null,Object? purpose = null,Object? derivatives = freezed,}) {
  return _then(_GigMediaAssetView(
mediaAssetId: null == mediaAssetId ? _self.mediaAssetId : mediaAssetId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String,derivatives: freezed == derivatives ? _self._derivatives : derivatives // ignore: cast_nullable_to_non_nullable
as List<MediaDerivativeView>?,
  ));
}


}

// dart format on
