// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shelf_browse_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ShelfBrowseResponse {

/// tier
@JsonKey(name: ShelfBrowseResponse.tierKey_) String get tier;/// maxLevel
@JsonKey(name: ShelfBrowseResponse.maxLevelKey_) int get maxLevel;/// spendable
@JsonKey(name: ShelfBrowseResponse.spendableKey_) int get spendable;/// hasCamera
@JsonKey(name: ShelfBrowseResponse.hasCameraKey_) bool get hasCamera;/// wishlistMax
@JsonKey(name: ShelfBrowseResponse.wishlistMaxKey_) int get wishlistMax;/// termsText
@JsonKey(name: ShelfBrowseResponse.termsTextKey_) String get termsText;/// termsDraft
@JsonKey(name: ShelfBrowseResponse.termsDraftKey_) bool get termsDraft;/// levels
@JsonKey(name: ShelfBrowseResponse.levelsKey_) List<ShelfBrowseLevel> get levels;
/// Create a copy of ShelfBrowseResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShelfBrowseResponseCopyWith<ShelfBrowseResponse> get copyWith => _$ShelfBrowseResponseCopyWithImpl<ShelfBrowseResponse>(this as ShelfBrowseResponse, _$identity);

  /// Serializes this ShelfBrowseResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShelfBrowseResponse&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.maxLevel, maxLevel) || other.maxLevel == maxLevel)&&(identical(other.spendable, spendable) || other.spendable == spendable)&&(identical(other.hasCamera, hasCamera) || other.hasCamera == hasCamera)&&(identical(other.wishlistMax, wishlistMax) || other.wishlistMax == wishlistMax)&&(identical(other.termsText, termsText) || other.termsText == termsText)&&(identical(other.termsDraft, termsDraft) || other.termsDraft == termsDraft)&&const DeepCollectionEquality().equals(other.levels, levels));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tier,maxLevel,spendable,hasCamera,wishlistMax,termsText,termsDraft,const DeepCollectionEquality().hash(levels));

@override
String toString() {
  return 'ShelfBrowseResponse(tier: $tier, maxLevel: $maxLevel, spendable: $spendable, hasCamera: $hasCamera, wishlistMax: $wishlistMax, termsText: $termsText, termsDraft: $termsDraft, levels: $levels)';
}


}

/// @nodoc
abstract mixin class $ShelfBrowseResponseCopyWith<$Res>  {
  factory $ShelfBrowseResponseCopyWith(ShelfBrowseResponse value, $Res Function(ShelfBrowseResponse) _then) = _$ShelfBrowseResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ShelfBrowseResponse.tierKey_) String tier,@JsonKey(name: ShelfBrowseResponse.maxLevelKey_) int maxLevel,@JsonKey(name: ShelfBrowseResponse.spendableKey_) int spendable,@JsonKey(name: ShelfBrowseResponse.hasCameraKey_) bool hasCamera,@JsonKey(name: ShelfBrowseResponse.wishlistMaxKey_) int wishlistMax,@JsonKey(name: ShelfBrowseResponse.termsTextKey_) String termsText,@JsonKey(name: ShelfBrowseResponse.termsDraftKey_) bool termsDraft,@JsonKey(name: ShelfBrowseResponse.levelsKey_) List<ShelfBrowseLevel> levels
});




}
/// @nodoc
class _$ShelfBrowseResponseCopyWithImpl<$Res>
    implements $ShelfBrowseResponseCopyWith<$Res> {
  _$ShelfBrowseResponseCopyWithImpl(this._self, this._then);

  final ShelfBrowseResponse _self;
  final $Res Function(ShelfBrowseResponse) _then;

/// Create a copy of ShelfBrowseResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tier = null,Object? maxLevel = null,Object? spendable = null,Object? hasCamera = null,Object? wishlistMax = null,Object? termsText = null,Object? termsDraft = null,Object? levels = null,}) {
  return _then(_self.copyWith(
tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as String,maxLevel: null == maxLevel ? _self.maxLevel : maxLevel // ignore: cast_nullable_to_non_nullable
as int,spendable: null == spendable ? _self.spendable : spendable // ignore: cast_nullable_to_non_nullable
as int,hasCamera: null == hasCamera ? _self.hasCamera : hasCamera // ignore: cast_nullable_to_non_nullable
as bool,wishlistMax: null == wishlistMax ? _self.wishlistMax : wishlistMax // ignore: cast_nullable_to_non_nullable
as int,termsText: null == termsText ? _self.termsText : termsText // ignore: cast_nullable_to_non_nullable
as String,termsDraft: null == termsDraft ? _self.termsDraft : termsDraft // ignore: cast_nullable_to_non_nullable
as bool,levels: null == levels ? _self.levels : levels // ignore: cast_nullable_to_non_nullable
as List<ShelfBrowseLevel>,
  ));
}

}


/// Adds pattern-matching-related methods to [ShelfBrowseResponse].
extension ShelfBrowseResponsePatterns on ShelfBrowseResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShelfBrowseResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShelfBrowseResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShelfBrowseResponse value)  $default,){
final _that = this;
switch (_that) {
case _ShelfBrowseResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShelfBrowseResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ShelfBrowseResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ShelfBrowseResponse.tierKey_)  String tier, @JsonKey(name: ShelfBrowseResponse.maxLevelKey_)  int maxLevel, @JsonKey(name: ShelfBrowseResponse.spendableKey_)  int spendable, @JsonKey(name: ShelfBrowseResponse.hasCameraKey_)  bool hasCamera, @JsonKey(name: ShelfBrowseResponse.wishlistMaxKey_)  int wishlistMax, @JsonKey(name: ShelfBrowseResponse.termsTextKey_)  String termsText, @JsonKey(name: ShelfBrowseResponse.termsDraftKey_)  bool termsDraft, @JsonKey(name: ShelfBrowseResponse.levelsKey_)  List<ShelfBrowseLevel> levels)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShelfBrowseResponse() when $default != null:
return $default(_that.tier,_that.maxLevel,_that.spendable,_that.hasCamera,_that.wishlistMax,_that.termsText,_that.termsDraft,_that.levels);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ShelfBrowseResponse.tierKey_)  String tier, @JsonKey(name: ShelfBrowseResponse.maxLevelKey_)  int maxLevel, @JsonKey(name: ShelfBrowseResponse.spendableKey_)  int spendable, @JsonKey(name: ShelfBrowseResponse.hasCameraKey_)  bool hasCamera, @JsonKey(name: ShelfBrowseResponse.wishlistMaxKey_)  int wishlistMax, @JsonKey(name: ShelfBrowseResponse.termsTextKey_)  String termsText, @JsonKey(name: ShelfBrowseResponse.termsDraftKey_)  bool termsDraft, @JsonKey(name: ShelfBrowseResponse.levelsKey_)  List<ShelfBrowseLevel> levels)  $default,) {final _that = this;
switch (_that) {
case _ShelfBrowseResponse():
return $default(_that.tier,_that.maxLevel,_that.spendable,_that.hasCamera,_that.wishlistMax,_that.termsText,_that.termsDraft,_that.levels);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ShelfBrowseResponse.tierKey_)  String tier, @JsonKey(name: ShelfBrowseResponse.maxLevelKey_)  int maxLevel, @JsonKey(name: ShelfBrowseResponse.spendableKey_)  int spendable, @JsonKey(name: ShelfBrowseResponse.hasCameraKey_)  bool hasCamera, @JsonKey(name: ShelfBrowseResponse.wishlistMaxKey_)  int wishlistMax, @JsonKey(name: ShelfBrowseResponse.termsTextKey_)  String termsText, @JsonKey(name: ShelfBrowseResponse.termsDraftKey_)  bool termsDraft, @JsonKey(name: ShelfBrowseResponse.levelsKey_)  List<ShelfBrowseLevel> levels)?  $default,) {final _that = this;
switch (_that) {
case _ShelfBrowseResponse() when $default != null:
return $default(_that.tier,_that.maxLevel,_that.spendable,_that.hasCamera,_that.wishlistMax,_that.termsText,_that.termsDraft,_that.levels);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ShelfBrowseResponse extends ShelfBrowseResponse {
  const _ShelfBrowseResponse({@JsonKey(name: ShelfBrowseResponse.tierKey_) required this.tier, @JsonKey(name: ShelfBrowseResponse.maxLevelKey_) required this.maxLevel, @JsonKey(name: ShelfBrowseResponse.spendableKey_) required this.spendable, @JsonKey(name: ShelfBrowseResponse.hasCameraKey_) required this.hasCamera, @JsonKey(name: ShelfBrowseResponse.wishlistMaxKey_) required this.wishlistMax, @JsonKey(name: ShelfBrowseResponse.termsTextKey_) required this.termsText, @JsonKey(name: ShelfBrowseResponse.termsDraftKey_) required this.termsDraft, @JsonKey(name: ShelfBrowseResponse.levelsKey_) required final  List<ShelfBrowseLevel> levels}): _levels = levels,super._();
  factory _ShelfBrowseResponse.fromJson(Map<String, dynamic> json) => _$ShelfBrowseResponseFromJson(json);

/// tier
@override@JsonKey(name: ShelfBrowseResponse.tierKey_) final  String tier;
/// maxLevel
@override@JsonKey(name: ShelfBrowseResponse.maxLevelKey_) final  int maxLevel;
/// spendable
@override@JsonKey(name: ShelfBrowseResponse.spendableKey_) final  int spendable;
/// hasCamera
@override@JsonKey(name: ShelfBrowseResponse.hasCameraKey_) final  bool hasCamera;
/// wishlistMax
@override@JsonKey(name: ShelfBrowseResponse.wishlistMaxKey_) final  int wishlistMax;
/// termsText
@override@JsonKey(name: ShelfBrowseResponse.termsTextKey_) final  String termsText;
/// termsDraft
@override@JsonKey(name: ShelfBrowseResponse.termsDraftKey_) final  bool termsDraft;
/// levels
 final  List<ShelfBrowseLevel> _levels;
/// levels
@override@JsonKey(name: ShelfBrowseResponse.levelsKey_) List<ShelfBrowseLevel> get levels {
  if (_levels is EqualUnmodifiableListView) return _levels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_levels);
}


/// Create a copy of ShelfBrowseResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShelfBrowseResponseCopyWith<_ShelfBrowseResponse> get copyWith => __$ShelfBrowseResponseCopyWithImpl<_ShelfBrowseResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShelfBrowseResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShelfBrowseResponse&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.maxLevel, maxLevel) || other.maxLevel == maxLevel)&&(identical(other.spendable, spendable) || other.spendable == spendable)&&(identical(other.hasCamera, hasCamera) || other.hasCamera == hasCamera)&&(identical(other.wishlistMax, wishlistMax) || other.wishlistMax == wishlistMax)&&(identical(other.termsText, termsText) || other.termsText == termsText)&&(identical(other.termsDraft, termsDraft) || other.termsDraft == termsDraft)&&const DeepCollectionEquality().equals(other._levels, _levels));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tier,maxLevel,spendable,hasCamera,wishlistMax,termsText,termsDraft,const DeepCollectionEquality().hash(_levels));

@override
String toString() {
  return 'ShelfBrowseResponse(tier: $tier, maxLevel: $maxLevel, spendable: $spendable, hasCamera: $hasCamera, wishlistMax: $wishlistMax, termsText: $termsText, termsDraft: $termsDraft, levels: $levels)';
}


}

/// @nodoc
abstract mixin class _$ShelfBrowseResponseCopyWith<$Res> implements $ShelfBrowseResponseCopyWith<$Res> {
  factory _$ShelfBrowseResponseCopyWith(_ShelfBrowseResponse value, $Res Function(_ShelfBrowseResponse) _then) = __$ShelfBrowseResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ShelfBrowseResponse.tierKey_) String tier,@JsonKey(name: ShelfBrowseResponse.maxLevelKey_) int maxLevel,@JsonKey(name: ShelfBrowseResponse.spendableKey_) int spendable,@JsonKey(name: ShelfBrowseResponse.hasCameraKey_) bool hasCamera,@JsonKey(name: ShelfBrowseResponse.wishlistMaxKey_) int wishlistMax,@JsonKey(name: ShelfBrowseResponse.termsTextKey_) String termsText,@JsonKey(name: ShelfBrowseResponse.termsDraftKey_) bool termsDraft,@JsonKey(name: ShelfBrowseResponse.levelsKey_) List<ShelfBrowseLevel> levels
});




}
/// @nodoc
class __$ShelfBrowseResponseCopyWithImpl<$Res>
    implements _$ShelfBrowseResponseCopyWith<$Res> {
  __$ShelfBrowseResponseCopyWithImpl(this._self, this._then);

  final _ShelfBrowseResponse _self;
  final $Res Function(_ShelfBrowseResponse) _then;

/// Create a copy of ShelfBrowseResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tier = null,Object? maxLevel = null,Object? spendable = null,Object? hasCamera = null,Object? wishlistMax = null,Object? termsText = null,Object? termsDraft = null,Object? levels = null,}) {
  return _then(_ShelfBrowseResponse(
tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as String,maxLevel: null == maxLevel ? _self.maxLevel : maxLevel // ignore: cast_nullable_to_non_nullable
as int,spendable: null == spendable ? _self.spendable : spendable // ignore: cast_nullable_to_non_nullable
as int,hasCamera: null == hasCamera ? _self.hasCamera : hasCamera // ignore: cast_nullable_to_non_nullable
as bool,wishlistMax: null == wishlistMax ? _self.wishlistMax : wishlistMax // ignore: cast_nullable_to_non_nullable
as int,termsText: null == termsText ? _self.termsText : termsText // ignore: cast_nullable_to_non_nullable
as String,termsDraft: null == termsDraft ? _self.termsDraft : termsDraft // ignore: cast_nullable_to_non_nullable
as bool,levels: null == levels ? _self._levels : levels // ignore: cast_nullable_to_non_nullable
as List<ShelfBrowseLevel>,
  ));
}


}

// dart format on
