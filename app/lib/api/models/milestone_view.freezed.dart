// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'milestone_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MilestoneView {

/// id
@JsonKey(name: MilestoneView.idKey_) String get id;/// code
@JsonKey(name: MilestoneView.codeKey_) String get code;/// name
@JsonKey(name: MilestoneView.nameKey_) String get name;/// description
@JsonKey(name: MilestoneView.descriptionKey_) String get description;/// nameKey
@JsonKey(name: MilestoneView.nameKeyKey_) String? get nameKey;/// descriptionKey
@JsonKey(name: MilestoneView.descriptionKeyKey_) String? get descriptionKey;/// scope
@JsonKey(name: MilestoneView.scopeKey_) MilestoneScope get scope;/// nicheId
@JsonKey(name: MilestoneView.nicheIdKey_) String? get nicheId;/// difficulty
@JsonKey(name: MilestoneView.difficultyKey_) MilestoneDifficulty get difficulty;/// audience
@JsonKey(name: MilestoneView.audienceKey_) MilestoneAudience get audience;/// isRepeatable
@JsonKey(name: MilestoneView.isRepeatableKey_) bool get isRepeatable;/// cooldownDays
@JsonKey(name: MilestoneView.cooldownDaysKey_) int? get cooldownDays;/// startAt
@JsonKey(name: MilestoneView.startAtKey_) DateTime? get startAt;/// endAt
@JsonKey(name: MilestoneView.endAtKey_) DateTime? get endAt;/// criteria
@JsonKey(name: MilestoneView.criteriaKey_) Map<String, dynamic>? get criteria;/// rewardRuleCode
@JsonKey(name: MilestoneView.rewardRuleCodeKey_) String? get rewardRuleCode;/// isActive
@JsonKey(name: MilestoneView.isActiveKey_) bool get isActive;/// createdAt
@JsonKey(name: MilestoneView.createdAtKey_) DateTime get createdAt;/// updatedAt
@JsonKey(name: MilestoneView.updatedAtKey_) DateTime get updatedAt;
/// Create a copy of MilestoneView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MilestoneViewCopyWith<MilestoneView> get copyWith => _$MilestoneViewCopyWithImpl<MilestoneView>(this as MilestoneView, _$identity);

  /// Serializes this MilestoneView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MilestoneView&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.nameKey, nameKey) || other.nameKey == nameKey)&&(identical(other.descriptionKey, descriptionKey) || other.descriptionKey == descriptionKey)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.nicheId, nicheId) || other.nicheId == nicheId)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.audience, audience) || other.audience == audience)&&(identical(other.isRepeatable, isRepeatable) || other.isRepeatable == isRepeatable)&&(identical(other.cooldownDays, cooldownDays) || other.cooldownDays == cooldownDays)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&const DeepCollectionEquality().equals(other.criteria, criteria)&&(identical(other.rewardRuleCode, rewardRuleCode) || other.rewardRuleCode == rewardRuleCode)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,code,name,description,nameKey,descriptionKey,scope,nicheId,difficulty,audience,isRepeatable,cooldownDays,startAt,endAt,const DeepCollectionEquality().hash(criteria),rewardRuleCode,isActive,createdAt,updatedAt]);

@override
String toString() {
  return 'MilestoneView(id: $id, code: $code, name: $name, description: $description, nameKey: $nameKey, descriptionKey: $descriptionKey, scope: $scope, nicheId: $nicheId, difficulty: $difficulty, audience: $audience, isRepeatable: $isRepeatable, cooldownDays: $cooldownDays, startAt: $startAt, endAt: $endAt, criteria: $criteria, rewardRuleCode: $rewardRuleCode, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $MilestoneViewCopyWith<$Res>  {
  factory $MilestoneViewCopyWith(MilestoneView value, $Res Function(MilestoneView) _then) = _$MilestoneViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: MilestoneView.idKey_) String id,@JsonKey(name: MilestoneView.codeKey_) String code,@JsonKey(name: MilestoneView.nameKey_) String name,@JsonKey(name: MilestoneView.descriptionKey_) String description,@JsonKey(name: MilestoneView.nameKeyKey_) String? nameKey,@JsonKey(name: MilestoneView.descriptionKeyKey_) String? descriptionKey,@JsonKey(name: MilestoneView.scopeKey_) MilestoneScope scope,@JsonKey(name: MilestoneView.nicheIdKey_) String? nicheId,@JsonKey(name: MilestoneView.difficultyKey_) MilestoneDifficulty difficulty,@JsonKey(name: MilestoneView.audienceKey_) MilestoneAudience audience,@JsonKey(name: MilestoneView.isRepeatableKey_) bool isRepeatable,@JsonKey(name: MilestoneView.cooldownDaysKey_) int? cooldownDays,@JsonKey(name: MilestoneView.startAtKey_) DateTime? startAt,@JsonKey(name: MilestoneView.endAtKey_) DateTime? endAt,@JsonKey(name: MilestoneView.criteriaKey_) Map<String, dynamic>? criteria,@JsonKey(name: MilestoneView.rewardRuleCodeKey_) String? rewardRuleCode,@JsonKey(name: MilestoneView.isActiveKey_) bool isActive,@JsonKey(name: MilestoneView.createdAtKey_) DateTime createdAt,@JsonKey(name: MilestoneView.updatedAtKey_) DateTime updatedAt
});




}
/// @nodoc
class _$MilestoneViewCopyWithImpl<$Res>
    implements $MilestoneViewCopyWith<$Res> {
  _$MilestoneViewCopyWithImpl(this._self, this._then);

  final MilestoneView _self;
  final $Res Function(MilestoneView) _then;

/// Create a copy of MilestoneView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? name = null,Object? description = null,Object? nameKey = freezed,Object? descriptionKey = freezed,Object? scope = null,Object? nicheId = freezed,Object? difficulty = null,Object? audience = null,Object? isRepeatable = null,Object? cooldownDays = freezed,Object? startAt = freezed,Object? endAt = freezed,Object? criteria = freezed,Object? rewardRuleCode = freezed,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,nameKey: freezed == nameKey ? _self.nameKey : nameKey // ignore: cast_nullable_to_non_nullable
as String?,descriptionKey: freezed == descriptionKey ? _self.descriptionKey : descriptionKey // ignore: cast_nullable_to_non_nullable
as String?,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as MilestoneScope,nicheId: freezed == nicheId ? _self.nicheId : nicheId // ignore: cast_nullable_to_non_nullable
as String?,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as MilestoneDifficulty,audience: null == audience ? _self.audience : audience // ignore: cast_nullable_to_non_nullable
as MilestoneAudience,isRepeatable: null == isRepeatable ? _self.isRepeatable : isRepeatable // ignore: cast_nullable_to_non_nullable
as bool,cooldownDays: freezed == cooldownDays ? _self.cooldownDays : cooldownDays // ignore: cast_nullable_to_non_nullable
as int?,startAt: freezed == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endAt: freezed == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime?,criteria: freezed == criteria ? _self.criteria : criteria // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,rewardRuleCode: freezed == rewardRuleCode ? _self.rewardRuleCode : rewardRuleCode // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [MilestoneView].
extension MilestoneViewPatterns on MilestoneView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MilestoneView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MilestoneView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MilestoneView value)  $default,){
final _that = this;
switch (_that) {
case _MilestoneView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MilestoneView value)?  $default,){
final _that = this;
switch (_that) {
case _MilestoneView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: MilestoneView.idKey_)  String id, @JsonKey(name: MilestoneView.codeKey_)  String code, @JsonKey(name: MilestoneView.nameKey_)  String name, @JsonKey(name: MilestoneView.descriptionKey_)  String description, @JsonKey(name: MilestoneView.nameKeyKey_)  String? nameKey, @JsonKey(name: MilestoneView.descriptionKeyKey_)  String? descriptionKey, @JsonKey(name: MilestoneView.scopeKey_)  MilestoneScope scope, @JsonKey(name: MilestoneView.nicheIdKey_)  String? nicheId, @JsonKey(name: MilestoneView.difficultyKey_)  MilestoneDifficulty difficulty, @JsonKey(name: MilestoneView.audienceKey_)  MilestoneAudience audience, @JsonKey(name: MilestoneView.isRepeatableKey_)  bool isRepeatable, @JsonKey(name: MilestoneView.cooldownDaysKey_)  int? cooldownDays, @JsonKey(name: MilestoneView.startAtKey_)  DateTime? startAt, @JsonKey(name: MilestoneView.endAtKey_)  DateTime? endAt, @JsonKey(name: MilestoneView.criteriaKey_)  Map<String, dynamic>? criteria, @JsonKey(name: MilestoneView.rewardRuleCodeKey_)  String? rewardRuleCode, @JsonKey(name: MilestoneView.isActiveKey_)  bool isActive, @JsonKey(name: MilestoneView.createdAtKey_)  DateTime createdAt, @JsonKey(name: MilestoneView.updatedAtKey_)  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MilestoneView() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.description,_that.nameKey,_that.descriptionKey,_that.scope,_that.nicheId,_that.difficulty,_that.audience,_that.isRepeatable,_that.cooldownDays,_that.startAt,_that.endAt,_that.criteria,_that.rewardRuleCode,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: MilestoneView.idKey_)  String id, @JsonKey(name: MilestoneView.codeKey_)  String code, @JsonKey(name: MilestoneView.nameKey_)  String name, @JsonKey(name: MilestoneView.descriptionKey_)  String description, @JsonKey(name: MilestoneView.nameKeyKey_)  String? nameKey, @JsonKey(name: MilestoneView.descriptionKeyKey_)  String? descriptionKey, @JsonKey(name: MilestoneView.scopeKey_)  MilestoneScope scope, @JsonKey(name: MilestoneView.nicheIdKey_)  String? nicheId, @JsonKey(name: MilestoneView.difficultyKey_)  MilestoneDifficulty difficulty, @JsonKey(name: MilestoneView.audienceKey_)  MilestoneAudience audience, @JsonKey(name: MilestoneView.isRepeatableKey_)  bool isRepeatable, @JsonKey(name: MilestoneView.cooldownDaysKey_)  int? cooldownDays, @JsonKey(name: MilestoneView.startAtKey_)  DateTime? startAt, @JsonKey(name: MilestoneView.endAtKey_)  DateTime? endAt, @JsonKey(name: MilestoneView.criteriaKey_)  Map<String, dynamic>? criteria, @JsonKey(name: MilestoneView.rewardRuleCodeKey_)  String? rewardRuleCode, @JsonKey(name: MilestoneView.isActiveKey_)  bool isActive, @JsonKey(name: MilestoneView.createdAtKey_)  DateTime createdAt, @JsonKey(name: MilestoneView.updatedAtKey_)  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _MilestoneView():
return $default(_that.id,_that.code,_that.name,_that.description,_that.nameKey,_that.descriptionKey,_that.scope,_that.nicheId,_that.difficulty,_that.audience,_that.isRepeatable,_that.cooldownDays,_that.startAt,_that.endAt,_that.criteria,_that.rewardRuleCode,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: MilestoneView.idKey_)  String id, @JsonKey(name: MilestoneView.codeKey_)  String code, @JsonKey(name: MilestoneView.nameKey_)  String name, @JsonKey(name: MilestoneView.descriptionKey_)  String description, @JsonKey(name: MilestoneView.nameKeyKey_)  String? nameKey, @JsonKey(name: MilestoneView.descriptionKeyKey_)  String? descriptionKey, @JsonKey(name: MilestoneView.scopeKey_)  MilestoneScope scope, @JsonKey(name: MilestoneView.nicheIdKey_)  String? nicheId, @JsonKey(name: MilestoneView.difficultyKey_)  MilestoneDifficulty difficulty, @JsonKey(name: MilestoneView.audienceKey_)  MilestoneAudience audience, @JsonKey(name: MilestoneView.isRepeatableKey_)  bool isRepeatable, @JsonKey(name: MilestoneView.cooldownDaysKey_)  int? cooldownDays, @JsonKey(name: MilestoneView.startAtKey_)  DateTime? startAt, @JsonKey(name: MilestoneView.endAtKey_)  DateTime? endAt, @JsonKey(name: MilestoneView.criteriaKey_)  Map<String, dynamic>? criteria, @JsonKey(name: MilestoneView.rewardRuleCodeKey_)  String? rewardRuleCode, @JsonKey(name: MilestoneView.isActiveKey_)  bool isActive, @JsonKey(name: MilestoneView.createdAtKey_)  DateTime createdAt, @JsonKey(name: MilestoneView.updatedAtKey_)  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _MilestoneView() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.description,_that.nameKey,_that.descriptionKey,_that.scope,_that.nicheId,_that.difficulty,_that.audience,_that.isRepeatable,_that.cooldownDays,_that.startAt,_that.endAt,_that.criteria,_that.rewardRuleCode,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _MilestoneView extends MilestoneView {
  const _MilestoneView({@JsonKey(name: MilestoneView.idKey_) required this.id, @JsonKey(name: MilestoneView.codeKey_) required this.code, @JsonKey(name: MilestoneView.nameKey_) required this.name, @JsonKey(name: MilestoneView.descriptionKey_) required this.description, @JsonKey(name: MilestoneView.nameKeyKey_) this.nameKey, @JsonKey(name: MilestoneView.descriptionKeyKey_) this.descriptionKey, @JsonKey(name: MilestoneView.scopeKey_) required this.scope, @JsonKey(name: MilestoneView.nicheIdKey_) this.nicheId, @JsonKey(name: MilestoneView.difficultyKey_) required this.difficulty, @JsonKey(name: MilestoneView.audienceKey_) required this.audience, @JsonKey(name: MilestoneView.isRepeatableKey_) required this.isRepeatable, @JsonKey(name: MilestoneView.cooldownDaysKey_) this.cooldownDays, @JsonKey(name: MilestoneView.startAtKey_) this.startAt, @JsonKey(name: MilestoneView.endAtKey_) this.endAt, @JsonKey(name: MilestoneView.criteriaKey_) final  Map<String, dynamic>? criteria, @JsonKey(name: MilestoneView.rewardRuleCodeKey_) this.rewardRuleCode, @JsonKey(name: MilestoneView.isActiveKey_) required this.isActive, @JsonKey(name: MilestoneView.createdAtKey_) required this.createdAt, @JsonKey(name: MilestoneView.updatedAtKey_) required this.updatedAt}): _criteria = criteria,super._();
  factory _MilestoneView.fromJson(Map<String, dynamic> json) => _$MilestoneViewFromJson(json);

/// id
@override@JsonKey(name: MilestoneView.idKey_) final  String id;
/// code
@override@JsonKey(name: MilestoneView.codeKey_) final  String code;
/// name
@override@JsonKey(name: MilestoneView.nameKey_) final  String name;
/// description
@override@JsonKey(name: MilestoneView.descriptionKey_) final  String description;
/// nameKey
@override@JsonKey(name: MilestoneView.nameKeyKey_) final  String? nameKey;
/// descriptionKey
@override@JsonKey(name: MilestoneView.descriptionKeyKey_) final  String? descriptionKey;
/// scope
@override@JsonKey(name: MilestoneView.scopeKey_) final  MilestoneScope scope;
/// nicheId
@override@JsonKey(name: MilestoneView.nicheIdKey_) final  String? nicheId;
/// difficulty
@override@JsonKey(name: MilestoneView.difficultyKey_) final  MilestoneDifficulty difficulty;
/// audience
@override@JsonKey(name: MilestoneView.audienceKey_) final  MilestoneAudience audience;
/// isRepeatable
@override@JsonKey(name: MilestoneView.isRepeatableKey_) final  bool isRepeatable;
/// cooldownDays
@override@JsonKey(name: MilestoneView.cooldownDaysKey_) final  int? cooldownDays;
/// startAt
@override@JsonKey(name: MilestoneView.startAtKey_) final  DateTime? startAt;
/// endAt
@override@JsonKey(name: MilestoneView.endAtKey_) final  DateTime? endAt;
/// criteria
 final  Map<String, dynamic>? _criteria;
/// criteria
@override@JsonKey(name: MilestoneView.criteriaKey_) Map<String, dynamic>? get criteria {
  final value = _criteria;
  if (value == null) return null;
  if (_criteria is EqualUnmodifiableMapView) return _criteria;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// rewardRuleCode
@override@JsonKey(name: MilestoneView.rewardRuleCodeKey_) final  String? rewardRuleCode;
/// isActive
@override@JsonKey(name: MilestoneView.isActiveKey_) final  bool isActive;
/// createdAt
@override@JsonKey(name: MilestoneView.createdAtKey_) final  DateTime createdAt;
/// updatedAt
@override@JsonKey(name: MilestoneView.updatedAtKey_) final  DateTime updatedAt;

/// Create a copy of MilestoneView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MilestoneViewCopyWith<_MilestoneView> get copyWith => __$MilestoneViewCopyWithImpl<_MilestoneView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MilestoneViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MilestoneView&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.nameKey, nameKey) || other.nameKey == nameKey)&&(identical(other.descriptionKey, descriptionKey) || other.descriptionKey == descriptionKey)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.nicheId, nicheId) || other.nicheId == nicheId)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.audience, audience) || other.audience == audience)&&(identical(other.isRepeatable, isRepeatable) || other.isRepeatable == isRepeatable)&&(identical(other.cooldownDays, cooldownDays) || other.cooldownDays == cooldownDays)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&const DeepCollectionEquality().equals(other._criteria, _criteria)&&(identical(other.rewardRuleCode, rewardRuleCode) || other.rewardRuleCode == rewardRuleCode)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,code,name,description,nameKey,descriptionKey,scope,nicheId,difficulty,audience,isRepeatable,cooldownDays,startAt,endAt,const DeepCollectionEquality().hash(_criteria),rewardRuleCode,isActive,createdAt,updatedAt]);

@override
String toString() {
  return 'MilestoneView(id: $id, code: $code, name: $name, description: $description, nameKey: $nameKey, descriptionKey: $descriptionKey, scope: $scope, nicheId: $nicheId, difficulty: $difficulty, audience: $audience, isRepeatable: $isRepeatable, cooldownDays: $cooldownDays, startAt: $startAt, endAt: $endAt, criteria: $criteria, rewardRuleCode: $rewardRuleCode, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$MilestoneViewCopyWith<$Res> implements $MilestoneViewCopyWith<$Res> {
  factory _$MilestoneViewCopyWith(_MilestoneView value, $Res Function(_MilestoneView) _then) = __$MilestoneViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: MilestoneView.idKey_) String id,@JsonKey(name: MilestoneView.codeKey_) String code,@JsonKey(name: MilestoneView.nameKey_) String name,@JsonKey(name: MilestoneView.descriptionKey_) String description,@JsonKey(name: MilestoneView.nameKeyKey_) String? nameKey,@JsonKey(name: MilestoneView.descriptionKeyKey_) String? descriptionKey,@JsonKey(name: MilestoneView.scopeKey_) MilestoneScope scope,@JsonKey(name: MilestoneView.nicheIdKey_) String? nicheId,@JsonKey(name: MilestoneView.difficultyKey_) MilestoneDifficulty difficulty,@JsonKey(name: MilestoneView.audienceKey_) MilestoneAudience audience,@JsonKey(name: MilestoneView.isRepeatableKey_) bool isRepeatable,@JsonKey(name: MilestoneView.cooldownDaysKey_) int? cooldownDays,@JsonKey(name: MilestoneView.startAtKey_) DateTime? startAt,@JsonKey(name: MilestoneView.endAtKey_) DateTime? endAt,@JsonKey(name: MilestoneView.criteriaKey_) Map<String, dynamic>? criteria,@JsonKey(name: MilestoneView.rewardRuleCodeKey_) String? rewardRuleCode,@JsonKey(name: MilestoneView.isActiveKey_) bool isActive,@JsonKey(name: MilestoneView.createdAtKey_) DateTime createdAt,@JsonKey(name: MilestoneView.updatedAtKey_) DateTime updatedAt
});




}
/// @nodoc
class __$MilestoneViewCopyWithImpl<$Res>
    implements _$MilestoneViewCopyWith<$Res> {
  __$MilestoneViewCopyWithImpl(this._self, this._then);

  final _MilestoneView _self;
  final $Res Function(_MilestoneView) _then;

/// Create a copy of MilestoneView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? name = null,Object? description = null,Object? nameKey = freezed,Object? descriptionKey = freezed,Object? scope = null,Object? nicheId = freezed,Object? difficulty = null,Object? audience = null,Object? isRepeatable = null,Object? cooldownDays = freezed,Object? startAt = freezed,Object? endAt = freezed,Object? criteria = freezed,Object? rewardRuleCode = freezed,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_MilestoneView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,nameKey: freezed == nameKey ? _self.nameKey : nameKey // ignore: cast_nullable_to_non_nullable
as String?,descriptionKey: freezed == descriptionKey ? _self.descriptionKey : descriptionKey // ignore: cast_nullable_to_non_nullable
as String?,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as MilestoneScope,nicheId: freezed == nicheId ? _self.nicheId : nicheId // ignore: cast_nullable_to_non_nullable
as String?,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as MilestoneDifficulty,audience: null == audience ? _self.audience : audience // ignore: cast_nullable_to_non_nullable
as MilestoneAudience,isRepeatable: null == isRepeatable ? _self.isRepeatable : isRepeatable // ignore: cast_nullable_to_non_nullable
as bool,cooldownDays: freezed == cooldownDays ? _self.cooldownDays : cooldownDays // ignore: cast_nullable_to_non_nullable
as int?,startAt: freezed == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endAt: freezed == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime?,criteria: freezed == criteria ? _self._criteria : criteria // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,rewardRuleCode: freezed == rewardRuleCode ? _self.rewardRuleCode : rewardRuleCode // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
