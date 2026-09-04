// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'public_availability_rule_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PublicAvailabilityRuleView {

/// id
@JsonKey(name: PublicAvailabilityRuleView.idKey_) String get id;/// dayOfWeek
@JsonKey(name: PublicAvailabilityRuleView.dayOfWeekKey_) int get dayOfWeek;/// startTime
@JsonKey(name: PublicAvailabilityRuleView.startTimeKey_) String get startTime;/// endTime
@JsonKey(name: PublicAvailabilityRuleView.endTimeKey_) String get endTime;
/// Create a copy of PublicAvailabilityRuleView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PublicAvailabilityRuleViewCopyWith<PublicAvailabilityRuleView> get copyWith => _$PublicAvailabilityRuleViewCopyWithImpl<PublicAvailabilityRuleView>(this as PublicAvailabilityRuleView, _$identity);

  /// Serializes this PublicAvailabilityRuleView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PublicAvailabilityRuleView&&(identical(other.id, id) || other.id == id)&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,dayOfWeek,startTime,endTime);

@override
String toString() {
  return 'PublicAvailabilityRuleView(id: $id, dayOfWeek: $dayOfWeek, startTime: $startTime, endTime: $endTime)';
}


}

/// @nodoc
abstract mixin class $PublicAvailabilityRuleViewCopyWith<$Res>  {
  factory $PublicAvailabilityRuleViewCopyWith(PublicAvailabilityRuleView value, $Res Function(PublicAvailabilityRuleView) _then) = _$PublicAvailabilityRuleViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: PublicAvailabilityRuleView.idKey_) String id,@JsonKey(name: PublicAvailabilityRuleView.dayOfWeekKey_) int dayOfWeek,@JsonKey(name: PublicAvailabilityRuleView.startTimeKey_) String startTime,@JsonKey(name: PublicAvailabilityRuleView.endTimeKey_) String endTime
});




}
/// @nodoc
class _$PublicAvailabilityRuleViewCopyWithImpl<$Res>
    implements $PublicAvailabilityRuleViewCopyWith<$Res> {
  _$PublicAvailabilityRuleViewCopyWithImpl(this._self, this._then);

  final PublicAvailabilityRuleView _self;
  final $Res Function(PublicAvailabilityRuleView) _then;

/// Create a copy of PublicAvailabilityRuleView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? dayOfWeek = null,Object? startTime = null,Object? endTime = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as int,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PublicAvailabilityRuleView].
extension PublicAvailabilityRuleViewPatterns on PublicAvailabilityRuleView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PublicAvailabilityRuleView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PublicAvailabilityRuleView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PublicAvailabilityRuleView value)  $default,){
final _that = this;
switch (_that) {
case _PublicAvailabilityRuleView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PublicAvailabilityRuleView value)?  $default,){
final _that = this;
switch (_that) {
case _PublicAvailabilityRuleView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: PublicAvailabilityRuleView.idKey_)  String id, @JsonKey(name: PublicAvailabilityRuleView.dayOfWeekKey_)  int dayOfWeek, @JsonKey(name: PublicAvailabilityRuleView.startTimeKey_)  String startTime, @JsonKey(name: PublicAvailabilityRuleView.endTimeKey_)  String endTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PublicAvailabilityRuleView() when $default != null:
return $default(_that.id,_that.dayOfWeek,_that.startTime,_that.endTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: PublicAvailabilityRuleView.idKey_)  String id, @JsonKey(name: PublicAvailabilityRuleView.dayOfWeekKey_)  int dayOfWeek, @JsonKey(name: PublicAvailabilityRuleView.startTimeKey_)  String startTime, @JsonKey(name: PublicAvailabilityRuleView.endTimeKey_)  String endTime)  $default,) {final _that = this;
switch (_that) {
case _PublicAvailabilityRuleView():
return $default(_that.id,_that.dayOfWeek,_that.startTime,_that.endTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: PublicAvailabilityRuleView.idKey_)  String id, @JsonKey(name: PublicAvailabilityRuleView.dayOfWeekKey_)  int dayOfWeek, @JsonKey(name: PublicAvailabilityRuleView.startTimeKey_)  String startTime, @JsonKey(name: PublicAvailabilityRuleView.endTimeKey_)  String endTime)?  $default,) {final _that = this;
switch (_that) {
case _PublicAvailabilityRuleView() when $default != null:
return $default(_that.id,_that.dayOfWeek,_that.startTime,_that.endTime);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _PublicAvailabilityRuleView extends PublicAvailabilityRuleView {
  const _PublicAvailabilityRuleView({@JsonKey(name: PublicAvailabilityRuleView.idKey_) required this.id, @JsonKey(name: PublicAvailabilityRuleView.dayOfWeekKey_) required this.dayOfWeek, @JsonKey(name: PublicAvailabilityRuleView.startTimeKey_) required this.startTime, @JsonKey(name: PublicAvailabilityRuleView.endTimeKey_) required this.endTime}): super._();
  factory _PublicAvailabilityRuleView.fromJson(Map<String, dynamic> json) => _$PublicAvailabilityRuleViewFromJson(json);

/// id
@override@JsonKey(name: PublicAvailabilityRuleView.idKey_) final  String id;
/// dayOfWeek
@override@JsonKey(name: PublicAvailabilityRuleView.dayOfWeekKey_) final  int dayOfWeek;
/// startTime
@override@JsonKey(name: PublicAvailabilityRuleView.startTimeKey_) final  String startTime;
/// endTime
@override@JsonKey(name: PublicAvailabilityRuleView.endTimeKey_) final  String endTime;

/// Create a copy of PublicAvailabilityRuleView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PublicAvailabilityRuleViewCopyWith<_PublicAvailabilityRuleView> get copyWith => __$PublicAvailabilityRuleViewCopyWithImpl<_PublicAvailabilityRuleView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PublicAvailabilityRuleViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PublicAvailabilityRuleView&&(identical(other.id, id) || other.id == id)&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,dayOfWeek,startTime,endTime);

@override
String toString() {
  return 'PublicAvailabilityRuleView(id: $id, dayOfWeek: $dayOfWeek, startTime: $startTime, endTime: $endTime)';
}


}

/// @nodoc
abstract mixin class _$PublicAvailabilityRuleViewCopyWith<$Res> implements $PublicAvailabilityRuleViewCopyWith<$Res> {
  factory _$PublicAvailabilityRuleViewCopyWith(_PublicAvailabilityRuleView value, $Res Function(_PublicAvailabilityRuleView) _then) = __$PublicAvailabilityRuleViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: PublicAvailabilityRuleView.idKey_) String id,@JsonKey(name: PublicAvailabilityRuleView.dayOfWeekKey_) int dayOfWeek,@JsonKey(name: PublicAvailabilityRuleView.startTimeKey_) String startTime,@JsonKey(name: PublicAvailabilityRuleView.endTimeKey_) String endTime
});




}
/// @nodoc
class __$PublicAvailabilityRuleViewCopyWithImpl<$Res>
    implements _$PublicAvailabilityRuleViewCopyWith<$Res> {
  __$PublicAvailabilityRuleViewCopyWithImpl(this._self, this._then);

  final _PublicAvailabilityRuleView _self;
  final $Res Function(_PublicAvailabilityRuleView) _then;

/// Create a copy of PublicAvailabilityRuleView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? dayOfWeek = null,Object? startTime = null,Object? endTime = null,}) {
  return _then(_PublicAvailabilityRuleView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as int,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
