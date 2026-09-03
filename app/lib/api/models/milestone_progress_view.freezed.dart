// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'milestone_progress_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MilestoneProgressView {

/// milestoneId
@JsonKey(name: MilestoneProgressView.milestoneIdKey_) String get milestoneId;/// status
@JsonKey(name: MilestoneProgressView.statusKey_) MilestoneProgressStatus get status;/// progressValue
@JsonKey(name: MilestoneProgressView.progressValueKey_) String get progressValue;/// progressMeta
@JsonKey(name: MilestoneProgressView.progressMetaKey_) Map<String, dynamic>? get progressMeta;/// startedAt
@JsonKey(name: MilestoneProgressView.startedAtKey_) DateTime get startedAt;/// completedAt
@JsonKey(name: MilestoneProgressView.completedAtKey_) DateTime? get completedAt;/// lastEvaluatedAt
@JsonKey(name: MilestoneProgressView.lastEvaluatedAtKey_) DateTime? get lastEvaluatedAt;/// completionsCount
@JsonKey(name: MilestoneProgressView.completionsCountKey_) int get completionsCount;/// lastCompletedAt
@JsonKey(name: MilestoneProgressView.lastCompletedAtKey_) DateTime? get lastCompletedAt;
/// Create a copy of MilestoneProgressView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MilestoneProgressViewCopyWith<MilestoneProgressView> get copyWith => _$MilestoneProgressViewCopyWithImpl<MilestoneProgressView>(this as MilestoneProgressView, _$identity);

  /// Serializes this MilestoneProgressView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MilestoneProgressView&&(identical(other.milestoneId, milestoneId) || other.milestoneId == milestoneId)&&(identical(other.status, status) || other.status == status)&&(identical(other.progressValue, progressValue) || other.progressValue == progressValue)&&const DeepCollectionEquality().equals(other.progressMeta, progressMeta)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.lastEvaluatedAt, lastEvaluatedAt) || other.lastEvaluatedAt == lastEvaluatedAt)&&(identical(other.completionsCount, completionsCount) || other.completionsCount == completionsCount)&&(identical(other.lastCompletedAt, lastCompletedAt) || other.lastCompletedAt == lastCompletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,milestoneId,status,progressValue,const DeepCollectionEquality().hash(progressMeta),startedAt,completedAt,lastEvaluatedAt,completionsCount,lastCompletedAt);

@override
String toString() {
  return 'MilestoneProgressView(milestoneId: $milestoneId, status: $status, progressValue: $progressValue, progressMeta: $progressMeta, startedAt: $startedAt, completedAt: $completedAt, lastEvaluatedAt: $lastEvaluatedAt, completionsCount: $completionsCount, lastCompletedAt: $lastCompletedAt)';
}


}

/// @nodoc
abstract mixin class $MilestoneProgressViewCopyWith<$Res>  {
  factory $MilestoneProgressViewCopyWith(MilestoneProgressView value, $Res Function(MilestoneProgressView) _then) = _$MilestoneProgressViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: MilestoneProgressView.milestoneIdKey_) String milestoneId,@JsonKey(name: MilestoneProgressView.statusKey_) MilestoneProgressStatus status,@JsonKey(name: MilestoneProgressView.progressValueKey_) String progressValue,@JsonKey(name: MilestoneProgressView.progressMetaKey_) Map<String, dynamic>? progressMeta,@JsonKey(name: MilestoneProgressView.startedAtKey_) DateTime startedAt,@JsonKey(name: MilestoneProgressView.completedAtKey_) DateTime? completedAt,@JsonKey(name: MilestoneProgressView.lastEvaluatedAtKey_) DateTime? lastEvaluatedAt,@JsonKey(name: MilestoneProgressView.completionsCountKey_) int completionsCount,@JsonKey(name: MilestoneProgressView.lastCompletedAtKey_) DateTime? lastCompletedAt
});




}
/// @nodoc
class _$MilestoneProgressViewCopyWithImpl<$Res>
    implements $MilestoneProgressViewCopyWith<$Res> {
  _$MilestoneProgressViewCopyWithImpl(this._self, this._then);

  final MilestoneProgressView _self;
  final $Res Function(MilestoneProgressView) _then;

/// Create a copy of MilestoneProgressView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? milestoneId = null,Object? status = null,Object? progressValue = null,Object? progressMeta = freezed,Object? startedAt = null,Object? completedAt = freezed,Object? lastEvaluatedAt = freezed,Object? completionsCount = null,Object? lastCompletedAt = freezed,}) {
  return _then(_self.copyWith(
milestoneId: null == milestoneId ? _self.milestoneId : milestoneId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MilestoneProgressStatus,progressValue: null == progressValue ? _self.progressValue : progressValue // ignore: cast_nullable_to_non_nullable
as String,progressMeta: freezed == progressMeta ? _self.progressMeta : progressMeta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastEvaluatedAt: freezed == lastEvaluatedAt ? _self.lastEvaluatedAt : lastEvaluatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completionsCount: null == completionsCount ? _self.completionsCount : completionsCount // ignore: cast_nullable_to_non_nullable
as int,lastCompletedAt: freezed == lastCompletedAt ? _self.lastCompletedAt : lastCompletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [MilestoneProgressView].
extension MilestoneProgressViewPatterns on MilestoneProgressView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MilestoneProgressView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MilestoneProgressView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MilestoneProgressView value)  $default,){
final _that = this;
switch (_that) {
case _MilestoneProgressView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MilestoneProgressView value)?  $default,){
final _that = this;
switch (_that) {
case _MilestoneProgressView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: MilestoneProgressView.milestoneIdKey_)  String milestoneId, @JsonKey(name: MilestoneProgressView.statusKey_)  MilestoneProgressStatus status, @JsonKey(name: MilestoneProgressView.progressValueKey_)  String progressValue, @JsonKey(name: MilestoneProgressView.progressMetaKey_)  Map<String, dynamic>? progressMeta, @JsonKey(name: MilestoneProgressView.startedAtKey_)  DateTime startedAt, @JsonKey(name: MilestoneProgressView.completedAtKey_)  DateTime? completedAt, @JsonKey(name: MilestoneProgressView.lastEvaluatedAtKey_)  DateTime? lastEvaluatedAt, @JsonKey(name: MilestoneProgressView.completionsCountKey_)  int completionsCount, @JsonKey(name: MilestoneProgressView.lastCompletedAtKey_)  DateTime? lastCompletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MilestoneProgressView() when $default != null:
return $default(_that.milestoneId,_that.status,_that.progressValue,_that.progressMeta,_that.startedAt,_that.completedAt,_that.lastEvaluatedAt,_that.completionsCount,_that.lastCompletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: MilestoneProgressView.milestoneIdKey_)  String milestoneId, @JsonKey(name: MilestoneProgressView.statusKey_)  MilestoneProgressStatus status, @JsonKey(name: MilestoneProgressView.progressValueKey_)  String progressValue, @JsonKey(name: MilestoneProgressView.progressMetaKey_)  Map<String, dynamic>? progressMeta, @JsonKey(name: MilestoneProgressView.startedAtKey_)  DateTime startedAt, @JsonKey(name: MilestoneProgressView.completedAtKey_)  DateTime? completedAt, @JsonKey(name: MilestoneProgressView.lastEvaluatedAtKey_)  DateTime? lastEvaluatedAt, @JsonKey(name: MilestoneProgressView.completionsCountKey_)  int completionsCount, @JsonKey(name: MilestoneProgressView.lastCompletedAtKey_)  DateTime? lastCompletedAt)  $default,) {final _that = this;
switch (_that) {
case _MilestoneProgressView():
return $default(_that.milestoneId,_that.status,_that.progressValue,_that.progressMeta,_that.startedAt,_that.completedAt,_that.lastEvaluatedAt,_that.completionsCount,_that.lastCompletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: MilestoneProgressView.milestoneIdKey_)  String milestoneId, @JsonKey(name: MilestoneProgressView.statusKey_)  MilestoneProgressStatus status, @JsonKey(name: MilestoneProgressView.progressValueKey_)  String progressValue, @JsonKey(name: MilestoneProgressView.progressMetaKey_)  Map<String, dynamic>? progressMeta, @JsonKey(name: MilestoneProgressView.startedAtKey_)  DateTime startedAt, @JsonKey(name: MilestoneProgressView.completedAtKey_)  DateTime? completedAt, @JsonKey(name: MilestoneProgressView.lastEvaluatedAtKey_)  DateTime? lastEvaluatedAt, @JsonKey(name: MilestoneProgressView.completionsCountKey_)  int completionsCount, @JsonKey(name: MilestoneProgressView.lastCompletedAtKey_)  DateTime? lastCompletedAt)?  $default,) {final _that = this;
switch (_that) {
case _MilestoneProgressView() when $default != null:
return $default(_that.milestoneId,_that.status,_that.progressValue,_that.progressMeta,_that.startedAt,_that.completedAt,_that.lastEvaluatedAt,_that.completionsCount,_that.lastCompletedAt);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _MilestoneProgressView extends MilestoneProgressView {
  const _MilestoneProgressView({@JsonKey(name: MilestoneProgressView.milestoneIdKey_) required this.milestoneId, @JsonKey(name: MilestoneProgressView.statusKey_) required this.status, @JsonKey(name: MilestoneProgressView.progressValueKey_) required this.progressValue, @JsonKey(name: MilestoneProgressView.progressMetaKey_) final  Map<String, dynamic>? progressMeta, @JsonKey(name: MilestoneProgressView.startedAtKey_) required this.startedAt, @JsonKey(name: MilestoneProgressView.completedAtKey_) this.completedAt, @JsonKey(name: MilestoneProgressView.lastEvaluatedAtKey_) this.lastEvaluatedAt, @JsonKey(name: MilestoneProgressView.completionsCountKey_) this.completionsCount = 0, @JsonKey(name: MilestoneProgressView.lastCompletedAtKey_) this.lastCompletedAt}): _progressMeta = progressMeta,super._();
  factory _MilestoneProgressView.fromJson(Map<String, dynamic> json) => _$MilestoneProgressViewFromJson(json);

/// milestoneId
@override@JsonKey(name: MilestoneProgressView.milestoneIdKey_) final  String milestoneId;
/// status
@override@JsonKey(name: MilestoneProgressView.statusKey_) final  MilestoneProgressStatus status;
/// progressValue
@override@JsonKey(name: MilestoneProgressView.progressValueKey_) final  String progressValue;
/// progressMeta
 final  Map<String, dynamic>? _progressMeta;
/// progressMeta
@override@JsonKey(name: MilestoneProgressView.progressMetaKey_) Map<String, dynamic>? get progressMeta {
  final value = _progressMeta;
  if (value == null) return null;
  if (_progressMeta is EqualUnmodifiableMapView) return _progressMeta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// startedAt
@override@JsonKey(name: MilestoneProgressView.startedAtKey_) final  DateTime startedAt;
/// completedAt
@override@JsonKey(name: MilestoneProgressView.completedAtKey_) final  DateTime? completedAt;
/// lastEvaluatedAt
@override@JsonKey(name: MilestoneProgressView.lastEvaluatedAtKey_) final  DateTime? lastEvaluatedAt;
/// completionsCount
@override@JsonKey(name: MilestoneProgressView.completionsCountKey_) final  int completionsCount;
/// lastCompletedAt
@override@JsonKey(name: MilestoneProgressView.lastCompletedAtKey_) final  DateTime? lastCompletedAt;

/// Create a copy of MilestoneProgressView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MilestoneProgressViewCopyWith<_MilestoneProgressView> get copyWith => __$MilestoneProgressViewCopyWithImpl<_MilestoneProgressView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MilestoneProgressViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MilestoneProgressView&&(identical(other.milestoneId, milestoneId) || other.milestoneId == milestoneId)&&(identical(other.status, status) || other.status == status)&&(identical(other.progressValue, progressValue) || other.progressValue == progressValue)&&const DeepCollectionEquality().equals(other._progressMeta, _progressMeta)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.lastEvaluatedAt, lastEvaluatedAt) || other.lastEvaluatedAt == lastEvaluatedAt)&&(identical(other.completionsCount, completionsCount) || other.completionsCount == completionsCount)&&(identical(other.lastCompletedAt, lastCompletedAt) || other.lastCompletedAt == lastCompletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,milestoneId,status,progressValue,const DeepCollectionEquality().hash(_progressMeta),startedAt,completedAt,lastEvaluatedAt,completionsCount,lastCompletedAt);

@override
String toString() {
  return 'MilestoneProgressView(milestoneId: $milestoneId, status: $status, progressValue: $progressValue, progressMeta: $progressMeta, startedAt: $startedAt, completedAt: $completedAt, lastEvaluatedAt: $lastEvaluatedAt, completionsCount: $completionsCount, lastCompletedAt: $lastCompletedAt)';
}


}

/// @nodoc
abstract mixin class _$MilestoneProgressViewCopyWith<$Res> implements $MilestoneProgressViewCopyWith<$Res> {
  factory _$MilestoneProgressViewCopyWith(_MilestoneProgressView value, $Res Function(_MilestoneProgressView) _then) = __$MilestoneProgressViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: MilestoneProgressView.milestoneIdKey_) String milestoneId,@JsonKey(name: MilestoneProgressView.statusKey_) MilestoneProgressStatus status,@JsonKey(name: MilestoneProgressView.progressValueKey_) String progressValue,@JsonKey(name: MilestoneProgressView.progressMetaKey_) Map<String, dynamic>? progressMeta,@JsonKey(name: MilestoneProgressView.startedAtKey_) DateTime startedAt,@JsonKey(name: MilestoneProgressView.completedAtKey_) DateTime? completedAt,@JsonKey(name: MilestoneProgressView.lastEvaluatedAtKey_) DateTime? lastEvaluatedAt,@JsonKey(name: MilestoneProgressView.completionsCountKey_) int completionsCount,@JsonKey(name: MilestoneProgressView.lastCompletedAtKey_) DateTime? lastCompletedAt
});




}
/// @nodoc
class __$MilestoneProgressViewCopyWithImpl<$Res>
    implements _$MilestoneProgressViewCopyWith<$Res> {
  __$MilestoneProgressViewCopyWithImpl(this._self, this._then);

  final _MilestoneProgressView _self;
  final $Res Function(_MilestoneProgressView) _then;

/// Create a copy of MilestoneProgressView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? milestoneId = null,Object? status = null,Object? progressValue = null,Object? progressMeta = freezed,Object? startedAt = null,Object? completedAt = freezed,Object? lastEvaluatedAt = freezed,Object? completionsCount = null,Object? lastCompletedAt = freezed,}) {
  return _then(_MilestoneProgressView(
milestoneId: null == milestoneId ? _self.milestoneId : milestoneId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MilestoneProgressStatus,progressValue: null == progressValue ? _self.progressValue : progressValue // ignore: cast_nullable_to_non_nullable
as String,progressMeta: freezed == progressMeta ? _self._progressMeta : progressMeta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastEvaluatedAt: freezed == lastEvaluatedAt ? _self.lastEvaluatedAt : lastEvaluatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completionsCount: null == completionsCount ? _self.completionsCount : completionsCount // ignore: cast_nullable_to_non_nullable
as int,lastCompletedAt: freezed == lastCompletedAt ? _self.lastCompletedAt : lastCompletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
