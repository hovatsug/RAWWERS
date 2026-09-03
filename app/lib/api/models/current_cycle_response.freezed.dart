// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'current_cycle_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CurrentCycleResponse {

/// cycleId
@JsonKey(name: CurrentCycleResponse.cycleIdKey_) String? get cycleId;/// code
@JsonKey(name: CurrentCycleResponse.codeKey_) String? get code;/// name
@JsonKey(name: CurrentCycleResponse.nameKey_) String? get name;/// nameKey
@JsonKey(name: CurrentCycleResponse.nameKeyKey_) String? get nameKey;/// startAt
@JsonKey(name: CurrentCycleResponse.startAtKey_) DateTime? get startAt;/// endAt
@JsonKey(name: CurrentCycleResponse.endAtKey_) DateTime? get endAt;/// myPoints
@JsonKey(name: CurrentCycleResponse.myPointsKey_) int get myPoints;/// leaderboard
@JsonKey(name: CurrentCycleResponse.leaderboardKey_) List<CyclePointsView>? get leaderboard;/// recentEvents
@JsonKey(name: CurrentCycleResponse.recentEventsKey_) List<CycleEventView>? get recentEvents;
/// Create a copy of CurrentCycleResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CurrentCycleResponseCopyWith<CurrentCycleResponse> get copyWith => _$CurrentCycleResponseCopyWithImpl<CurrentCycleResponse>(this as CurrentCycleResponse, _$identity);

  /// Serializes this CurrentCycleResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CurrentCycleResponse&&(identical(other.cycleId, cycleId) || other.cycleId == cycleId)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.nameKey, nameKey) || other.nameKey == nameKey)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.myPoints, myPoints) || other.myPoints == myPoints)&&const DeepCollectionEquality().equals(other.leaderboard, leaderboard)&&const DeepCollectionEquality().equals(other.recentEvents, recentEvents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cycleId,code,name,nameKey,startAt,endAt,myPoints,const DeepCollectionEquality().hash(leaderboard),const DeepCollectionEquality().hash(recentEvents));

@override
String toString() {
  return 'CurrentCycleResponse(cycleId: $cycleId, code: $code, name: $name, nameKey: $nameKey, startAt: $startAt, endAt: $endAt, myPoints: $myPoints, leaderboard: $leaderboard, recentEvents: $recentEvents)';
}


}

/// @nodoc
abstract mixin class $CurrentCycleResponseCopyWith<$Res>  {
  factory $CurrentCycleResponseCopyWith(CurrentCycleResponse value, $Res Function(CurrentCycleResponse) _then) = _$CurrentCycleResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: CurrentCycleResponse.cycleIdKey_) String? cycleId,@JsonKey(name: CurrentCycleResponse.codeKey_) String? code,@JsonKey(name: CurrentCycleResponse.nameKey_) String? name,@JsonKey(name: CurrentCycleResponse.nameKeyKey_) String? nameKey,@JsonKey(name: CurrentCycleResponse.startAtKey_) DateTime? startAt,@JsonKey(name: CurrentCycleResponse.endAtKey_) DateTime? endAt,@JsonKey(name: CurrentCycleResponse.myPointsKey_) int myPoints,@JsonKey(name: CurrentCycleResponse.leaderboardKey_) List<CyclePointsView>? leaderboard,@JsonKey(name: CurrentCycleResponse.recentEventsKey_) List<CycleEventView>? recentEvents
});




}
/// @nodoc
class _$CurrentCycleResponseCopyWithImpl<$Res>
    implements $CurrentCycleResponseCopyWith<$Res> {
  _$CurrentCycleResponseCopyWithImpl(this._self, this._then);

  final CurrentCycleResponse _self;
  final $Res Function(CurrentCycleResponse) _then;

/// Create a copy of CurrentCycleResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cycleId = freezed,Object? code = freezed,Object? name = freezed,Object? nameKey = freezed,Object? startAt = freezed,Object? endAt = freezed,Object? myPoints = null,Object? leaderboard = freezed,Object? recentEvents = freezed,}) {
  return _then(_self.copyWith(
cycleId: freezed == cycleId ? _self.cycleId : cycleId // ignore: cast_nullable_to_non_nullable
as String?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,nameKey: freezed == nameKey ? _self.nameKey : nameKey // ignore: cast_nullable_to_non_nullable
as String?,startAt: freezed == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endAt: freezed == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime?,myPoints: null == myPoints ? _self.myPoints : myPoints // ignore: cast_nullable_to_non_nullable
as int,leaderboard: freezed == leaderboard ? _self.leaderboard : leaderboard // ignore: cast_nullable_to_non_nullable
as List<CyclePointsView>?,recentEvents: freezed == recentEvents ? _self.recentEvents : recentEvents // ignore: cast_nullable_to_non_nullable
as List<CycleEventView>?,
  ));
}

}


/// Adds pattern-matching-related methods to [CurrentCycleResponse].
extension CurrentCycleResponsePatterns on CurrentCycleResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CurrentCycleResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CurrentCycleResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CurrentCycleResponse value)  $default,){
final _that = this;
switch (_that) {
case _CurrentCycleResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CurrentCycleResponse value)?  $default,){
final _that = this;
switch (_that) {
case _CurrentCycleResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: CurrentCycleResponse.cycleIdKey_)  String? cycleId, @JsonKey(name: CurrentCycleResponse.codeKey_)  String? code, @JsonKey(name: CurrentCycleResponse.nameKey_)  String? name, @JsonKey(name: CurrentCycleResponse.nameKeyKey_)  String? nameKey, @JsonKey(name: CurrentCycleResponse.startAtKey_)  DateTime? startAt, @JsonKey(name: CurrentCycleResponse.endAtKey_)  DateTime? endAt, @JsonKey(name: CurrentCycleResponse.myPointsKey_)  int myPoints, @JsonKey(name: CurrentCycleResponse.leaderboardKey_)  List<CyclePointsView>? leaderboard, @JsonKey(name: CurrentCycleResponse.recentEventsKey_)  List<CycleEventView>? recentEvents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CurrentCycleResponse() when $default != null:
return $default(_that.cycleId,_that.code,_that.name,_that.nameKey,_that.startAt,_that.endAt,_that.myPoints,_that.leaderboard,_that.recentEvents);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: CurrentCycleResponse.cycleIdKey_)  String? cycleId, @JsonKey(name: CurrentCycleResponse.codeKey_)  String? code, @JsonKey(name: CurrentCycleResponse.nameKey_)  String? name, @JsonKey(name: CurrentCycleResponse.nameKeyKey_)  String? nameKey, @JsonKey(name: CurrentCycleResponse.startAtKey_)  DateTime? startAt, @JsonKey(name: CurrentCycleResponse.endAtKey_)  DateTime? endAt, @JsonKey(name: CurrentCycleResponse.myPointsKey_)  int myPoints, @JsonKey(name: CurrentCycleResponse.leaderboardKey_)  List<CyclePointsView>? leaderboard, @JsonKey(name: CurrentCycleResponse.recentEventsKey_)  List<CycleEventView>? recentEvents)  $default,) {final _that = this;
switch (_that) {
case _CurrentCycleResponse():
return $default(_that.cycleId,_that.code,_that.name,_that.nameKey,_that.startAt,_that.endAt,_that.myPoints,_that.leaderboard,_that.recentEvents);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: CurrentCycleResponse.cycleIdKey_)  String? cycleId, @JsonKey(name: CurrentCycleResponse.codeKey_)  String? code, @JsonKey(name: CurrentCycleResponse.nameKey_)  String? name, @JsonKey(name: CurrentCycleResponse.nameKeyKey_)  String? nameKey, @JsonKey(name: CurrentCycleResponse.startAtKey_)  DateTime? startAt, @JsonKey(name: CurrentCycleResponse.endAtKey_)  DateTime? endAt, @JsonKey(name: CurrentCycleResponse.myPointsKey_)  int myPoints, @JsonKey(name: CurrentCycleResponse.leaderboardKey_)  List<CyclePointsView>? leaderboard, @JsonKey(name: CurrentCycleResponse.recentEventsKey_)  List<CycleEventView>? recentEvents)?  $default,) {final _that = this;
switch (_that) {
case _CurrentCycleResponse() when $default != null:
return $default(_that.cycleId,_that.code,_that.name,_that.nameKey,_that.startAt,_that.endAt,_that.myPoints,_that.leaderboard,_that.recentEvents);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _CurrentCycleResponse extends CurrentCycleResponse {
  const _CurrentCycleResponse({@JsonKey(name: CurrentCycleResponse.cycleIdKey_) this.cycleId, @JsonKey(name: CurrentCycleResponse.codeKey_) this.code, @JsonKey(name: CurrentCycleResponse.nameKey_) this.name, @JsonKey(name: CurrentCycleResponse.nameKeyKey_) this.nameKey, @JsonKey(name: CurrentCycleResponse.startAtKey_) this.startAt, @JsonKey(name: CurrentCycleResponse.endAtKey_) this.endAt, @JsonKey(name: CurrentCycleResponse.myPointsKey_) this.myPoints = 0, @JsonKey(name: CurrentCycleResponse.leaderboardKey_) final  List<CyclePointsView>? leaderboard, @JsonKey(name: CurrentCycleResponse.recentEventsKey_) final  List<CycleEventView>? recentEvents}): _leaderboard = leaderboard,_recentEvents = recentEvents,super._();
  factory _CurrentCycleResponse.fromJson(Map<String, dynamic> json) => _$CurrentCycleResponseFromJson(json);

/// cycleId
@override@JsonKey(name: CurrentCycleResponse.cycleIdKey_) final  String? cycleId;
/// code
@override@JsonKey(name: CurrentCycleResponse.codeKey_) final  String? code;
/// name
@override@JsonKey(name: CurrentCycleResponse.nameKey_) final  String? name;
/// nameKey
@override@JsonKey(name: CurrentCycleResponse.nameKeyKey_) final  String? nameKey;
/// startAt
@override@JsonKey(name: CurrentCycleResponse.startAtKey_) final  DateTime? startAt;
/// endAt
@override@JsonKey(name: CurrentCycleResponse.endAtKey_) final  DateTime? endAt;
/// myPoints
@override@JsonKey(name: CurrentCycleResponse.myPointsKey_) final  int myPoints;
/// leaderboard
 final  List<CyclePointsView>? _leaderboard;
/// leaderboard
@override@JsonKey(name: CurrentCycleResponse.leaderboardKey_) List<CyclePointsView>? get leaderboard {
  final value = _leaderboard;
  if (value == null) return null;
  if (_leaderboard is EqualUnmodifiableListView) return _leaderboard;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// recentEvents
 final  List<CycleEventView>? _recentEvents;
/// recentEvents
@override@JsonKey(name: CurrentCycleResponse.recentEventsKey_) List<CycleEventView>? get recentEvents {
  final value = _recentEvents;
  if (value == null) return null;
  if (_recentEvents is EqualUnmodifiableListView) return _recentEvents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of CurrentCycleResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CurrentCycleResponseCopyWith<_CurrentCycleResponse> get copyWith => __$CurrentCycleResponseCopyWithImpl<_CurrentCycleResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CurrentCycleResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CurrentCycleResponse&&(identical(other.cycleId, cycleId) || other.cycleId == cycleId)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.nameKey, nameKey) || other.nameKey == nameKey)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.myPoints, myPoints) || other.myPoints == myPoints)&&const DeepCollectionEquality().equals(other._leaderboard, _leaderboard)&&const DeepCollectionEquality().equals(other._recentEvents, _recentEvents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cycleId,code,name,nameKey,startAt,endAt,myPoints,const DeepCollectionEquality().hash(_leaderboard),const DeepCollectionEquality().hash(_recentEvents));

@override
String toString() {
  return 'CurrentCycleResponse(cycleId: $cycleId, code: $code, name: $name, nameKey: $nameKey, startAt: $startAt, endAt: $endAt, myPoints: $myPoints, leaderboard: $leaderboard, recentEvents: $recentEvents)';
}


}

/// @nodoc
abstract mixin class _$CurrentCycleResponseCopyWith<$Res> implements $CurrentCycleResponseCopyWith<$Res> {
  factory _$CurrentCycleResponseCopyWith(_CurrentCycleResponse value, $Res Function(_CurrentCycleResponse) _then) = __$CurrentCycleResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: CurrentCycleResponse.cycleIdKey_) String? cycleId,@JsonKey(name: CurrentCycleResponse.codeKey_) String? code,@JsonKey(name: CurrentCycleResponse.nameKey_) String? name,@JsonKey(name: CurrentCycleResponse.nameKeyKey_) String? nameKey,@JsonKey(name: CurrentCycleResponse.startAtKey_) DateTime? startAt,@JsonKey(name: CurrentCycleResponse.endAtKey_) DateTime? endAt,@JsonKey(name: CurrentCycleResponse.myPointsKey_) int myPoints,@JsonKey(name: CurrentCycleResponse.leaderboardKey_) List<CyclePointsView>? leaderboard,@JsonKey(name: CurrentCycleResponse.recentEventsKey_) List<CycleEventView>? recentEvents
});




}
/// @nodoc
class __$CurrentCycleResponseCopyWithImpl<$Res>
    implements _$CurrentCycleResponseCopyWith<$Res> {
  __$CurrentCycleResponseCopyWithImpl(this._self, this._then);

  final _CurrentCycleResponse _self;
  final $Res Function(_CurrentCycleResponse) _then;

/// Create a copy of CurrentCycleResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cycleId = freezed,Object? code = freezed,Object? name = freezed,Object? nameKey = freezed,Object? startAt = freezed,Object? endAt = freezed,Object? myPoints = null,Object? leaderboard = freezed,Object? recentEvents = freezed,}) {
  return _then(_CurrentCycleResponse(
cycleId: freezed == cycleId ? _self.cycleId : cycleId // ignore: cast_nullable_to_non_nullable
as String?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,nameKey: freezed == nameKey ? _self.nameKey : nameKey // ignore: cast_nullable_to_non_nullable
as String?,startAt: freezed == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endAt: freezed == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime?,myPoints: null == myPoints ? _self.myPoints : myPoints // ignore: cast_nullable_to_non_nullable
as int,leaderboard: freezed == leaderboard ? _self._leaderboard : leaderboard // ignore: cast_nullable_to_non_nullable
as List<CyclePointsView>?,recentEvents: freezed == recentEvents ? _self._recentEvents : recentEvents // ignore: cast_nullable_to_non_nullable
as List<CycleEventView>?,
  ));
}


}

// dart format on
