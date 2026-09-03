// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'my_milestone_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MyMilestoneItem {

/// milestone
@JsonKey(name: MyMilestoneItem.milestoneKey_) MilestoneView get milestone;/// progress
@JsonKey(name: MyMilestoneItem.progressKey_) MilestoneProgressView get progress;
/// Create a copy of MyMilestoneItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MyMilestoneItemCopyWith<MyMilestoneItem> get copyWith => _$MyMilestoneItemCopyWithImpl<MyMilestoneItem>(this as MyMilestoneItem, _$identity);

  /// Serializes this MyMilestoneItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MyMilestoneItem&&(identical(other.milestone, milestone) || other.milestone == milestone)&&(identical(other.progress, progress) || other.progress == progress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,milestone,progress);

@override
String toString() {
  return 'MyMilestoneItem(milestone: $milestone, progress: $progress)';
}


}

/// @nodoc
abstract mixin class $MyMilestoneItemCopyWith<$Res>  {
  factory $MyMilestoneItemCopyWith(MyMilestoneItem value, $Res Function(MyMilestoneItem) _then) = _$MyMilestoneItemCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: MyMilestoneItem.milestoneKey_) MilestoneView milestone,@JsonKey(name: MyMilestoneItem.progressKey_) MilestoneProgressView progress
});


$MilestoneViewCopyWith<$Res> get milestone;$MilestoneProgressViewCopyWith<$Res> get progress;

}
/// @nodoc
class _$MyMilestoneItemCopyWithImpl<$Res>
    implements $MyMilestoneItemCopyWith<$Res> {
  _$MyMilestoneItemCopyWithImpl(this._self, this._then);

  final MyMilestoneItem _self;
  final $Res Function(MyMilestoneItem) _then;

/// Create a copy of MyMilestoneItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? milestone = null,Object? progress = null,}) {
  return _then(_self.copyWith(
milestone: null == milestone ? _self.milestone : milestone // ignore: cast_nullable_to_non_nullable
as MilestoneView,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as MilestoneProgressView,
  ));
}
/// Create a copy of MyMilestoneItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MilestoneViewCopyWith<$Res> get milestone {
  
  return $MilestoneViewCopyWith<$Res>(_self.milestone, (value) {
    return _then(_self.copyWith(milestone: value));
  });
}/// Create a copy of MyMilestoneItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MilestoneProgressViewCopyWith<$Res> get progress {
  
  return $MilestoneProgressViewCopyWith<$Res>(_self.progress, (value) {
    return _then(_self.copyWith(progress: value));
  });
}
}


/// Adds pattern-matching-related methods to [MyMilestoneItem].
extension MyMilestoneItemPatterns on MyMilestoneItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MyMilestoneItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MyMilestoneItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MyMilestoneItem value)  $default,){
final _that = this;
switch (_that) {
case _MyMilestoneItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MyMilestoneItem value)?  $default,){
final _that = this;
switch (_that) {
case _MyMilestoneItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: MyMilestoneItem.milestoneKey_)  MilestoneView milestone, @JsonKey(name: MyMilestoneItem.progressKey_)  MilestoneProgressView progress)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MyMilestoneItem() when $default != null:
return $default(_that.milestone,_that.progress);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: MyMilestoneItem.milestoneKey_)  MilestoneView milestone, @JsonKey(name: MyMilestoneItem.progressKey_)  MilestoneProgressView progress)  $default,) {final _that = this;
switch (_that) {
case _MyMilestoneItem():
return $default(_that.milestone,_that.progress);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: MyMilestoneItem.milestoneKey_)  MilestoneView milestone, @JsonKey(name: MyMilestoneItem.progressKey_)  MilestoneProgressView progress)?  $default,) {final _that = this;
switch (_that) {
case _MyMilestoneItem() when $default != null:
return $default(_that.milestone,_that.progress);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _MyMilestoneItem extends MyMilestoneItem {
  const _MyMilestoneItem({@JsonKey(name: MyMilestoneItem.milestoneKey_) required this.milestone, @JsonKey(name: MyMilestoneItem.progressKey_) required this.progress}): super._();
  factory _MyMilestoneItem.fromJson(Map<String, dynamic> json) => _$MyMilestoneItemFromJson(json);

/// milestone
@override@JsonKey(name: MyMilestoneItem.milestoneKey_) final  MilestoneView milestone;
/// progress
@override@JsonKey(name: MyMilestoneItem.progressKey_) final  MilestoneProgressView progress;

/// Create a copy of MyMilestoneItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MyMilestoneItemCopyWith<_MyMilestoneItem> get copyWith => __$MyMilestoneItemCopyWithImpl<_MyMilestoneItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MyMilestoneItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MyMilestoneItem&&(identical(other.milestone, milestone) || other.milestone == milestone)&&(identical(other.progress, progress) || other.progress == progress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,milestone,progress);

@override
String toString() {
  return 'MyMilestoneItem(milestone: $milestone, progress: $progress)';
}


}

/// @nodoc
abstract mixin class _$MyMilestoneItemCopyWith<$Res> implements $MyMilestoneItemCopyWith<$Res> {
  factory _$MyMilestoneItemCopyWith(_MyMilestoneItem value, $Res Function(_MyMilestoneItem) _then) = __$MyMilestoneItemCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: MyMilestoneItem.milestoneKey_) MilestoneView milestone,@JsonKey(name: MyMilestoneItem.progressKey_) MilestoneProgressView progress
});


@override $MilestoneViewCopyWith<$Res> get milestone;@override $MilestoneProgressViewCopyWith<$Res> get progress;

}
/// @nodoc
class __$MyMilestoneItemCopyWithImpl<$Res>
    implements _$MyMilestoneItemCopyWith<$Res> {
  __$MyMilestoneItemCopyWithImpl(this._self, this._then);

  final _MyMilestoneItem _self;
  final $Res Function(_MyMilestoneItem) _then;

/// Create a copy of MyMilestoneItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? milestone = null,Object? progress = null,}) {
  return _then(_MyMilestoneItem(
milestone: null == milestone ? _self.milestone : milestone // ignore: cast_nullable_to_non_nullable
as MilestoneView,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as MilestoneProgressView,
  ));
}

/// Create a copy of MyMilestoneItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MilestoneViewCopyWith<$Res> get milestone {
  
  return $MilestoneViewCopyWith<$Res>(_self.milestone, (value) {
    return _then(_self.copyWith(milestone: value));
  });
}/// Create a copy of MyMilestoneItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MilestoneProgressViewCopyWith<$Res> get progress {
  
  return $MilestoneProgressViewCopyWith<$Res>(_self.progress, (value) {
    return _then(_self.copyWith(progress: value));
  });
}
}

// dart format on
