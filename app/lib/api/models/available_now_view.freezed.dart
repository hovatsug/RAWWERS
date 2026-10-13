// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'available_now_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AvailableNowView {

/// switchedOn
@JsonKey(name: AvailableNowView.switchedOnKey_) bool get switchedOn;/// availableUntil
@JsonKey(name: AvailableNowView.availableUntilKey_) DateTime? get availableUntil;/// effective
@JsonKey(name: AvailableNowView.effectiveKey_) bool get effective;/// prepHours
@JsonKey(name: AvailableNowView.prepHoursKey_) int get prepHours;/// eligiblePackageIds
@JsonKey(name: AvailableNowView.eligiblePackageIdsKey_) List<String>? get eligiblePackageIds;/// lastsHours
@JsonKey(name: AvailableNowView.lastsHoursKey_) int get lastsHours;
/// Create a copy of AvailableNowView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AvailableNowViewCopyWith<AvailableNowView> get copyWith => _$AvailableNowViewCopyWithImpl<AvailableNowView>(this as AvailableNowView, _$identity);

  /// Serializes this AvailableNowView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AvailableNowView&&(identical(other.switchedOn, switchedOn) || other.switchedOn == switchedOn)&&(identical(other.availableUntil, availableUntil) || other.availableUntil == availableUntil)&&(identical(other.effective, effective) || other.effective == effective)&&(identical(other.prepHours, prepHours) || other.prepHours == prepHours)&&const DeepCollectionEquality().equals(other.eligiblePackageIds, eligiblePackageIds)&&(identical(other.lastsHours, lastsHours) || other.lastsHours == lastsHours));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,switchedOn,availableUntil,effective,prepHours,const DeepCollectionEquality().hash(eligiblePackageIds),lastsHours);

@override
String toString() {
  return 'AvailableNowView(switchedOn: $switchedOn, availableUntil: $availableUntil, effective: $effective, prepHours: $prepHours, eligiblePackageIds: $eligiblePackageIds, lastsHours: $lastsHours)';
}


}

/// @nodoc
abstract mixin class $AvailableNowViewCopyWith<$Res>  {
  factory $AvailableNowViewCopyWith(AvailableNowView value, $Res Function(AvailableNowView) _then) = _$AvailableNowViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: AvailableNowView.switchedOnKey_) bool switchedOn,@JsonKey(name: AvailableNowView.availableUntilKey_) DateTime? availableUntil,@JsonKey(name: AvailableNowView.effectiveKey_) bool effective,@JsonKey(name: AvailableNowView.prepHoursKey_) int prepHours,@JsonKey(name: AvailableNowView.eligiblePackageIdsKey_) List<String>? eligiblePackageIds,@JsonKey(name: AvailableNowView.lastsHoursKey_) int lastsHours
});




}
/// @nodoc
class _$AvailableNowViewCopyWithImpl<$Res>
    implements $AvailableNowViewCopyWith<$Res> {
  _$AvailableNowViewCopyWithImpl(this._self, this._then);

  final AvailableNowView _self;
  final $Res Function(AvailableNowView) _then;

/// Create a copy of AvailableNowView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? switchedOn = null,Object? availableUntil = freezed,Object? effective = null,Object? prepHours = null,Object? eligiblePackageIds = freezed,Object? lastsHours = null,}) {
  return _then(_self.copyWith(
switchedOn: null == switchedOn ? _self.switchedOn : switchedOn // ignore: cast_nullable_to_non_nullable
as bool,availableUntil: freezed == availableUntil ? _self.availableUntil : availableUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,effective: null == effective ? _self.effective : effective // ignore: cast_nullable_to_non_nullable
as bool,prepHours: null == prepHours ? _self.prepHours : prepHours // ignore: cast_nullable_to_non_nullable
as int,eligiblePackageIds: freezed == eligiblePackageIds ? _self.eligiblePackageIds : eligiblePackageIds // ignore: cast_nullable_to_non_nullable
as List<String>?,lastsHours: null == lastsHours ? _self.lastsHours : lastsHours // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AvailableNowView].
extension AvailableNowViewPatterns on AvailableNowView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AvailableNowView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AvailableNowView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AvailableNowView value)  $default,){
final _that = this;
switch (_that) {
case _AvailableNowView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AvailableNowView value)?  $default,){
final _that = this;
switch (_that) {
case _AvailableNowView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: AvailableNowView.switchedOnKey_)  bool switchedOn, @JsonKey(name: AvailableNowView.availableUntilKey_)  DateTime? availableUntil, @JsonKey(name: AvailableNowView.effectiveKey_)  bool effective, @JsonKey(name: AvailableNowView.prepHoursKey_)  int prepHours, @JsonKey(name: AvailableNowView.eligiblePackageIdsKey_)  List<String>? eligiblePackageIds, @JsonKey(name: AvailableNowView.lastsHoursKey_)  int lastsHours)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AvailableNowView() when $default != null:
return $default(_that.switchedOn,_that.availableUntil,_that.effective,_that.prepHours,_that.eligiblePackageIds,_that.lastsHours);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: AvailableNowView.switchedOnKey_)  bool switchedOn, @JsonKey(name: AvailableNowView.availableUntilKey_)  DateTime? availableUntil, @JsonKey(name: AvailableNowView.effectiveKey_)  bool effective, @JsonKey(name: AvailableNowView.prepHoursKey_)  int prepHours, @JsonKey(name: AvailableNowView.eligiblePackageIdsKey_)  List<String>? eligiblePackageIds, @JsonKey(name: AvailableNowView.lastsHoursKey_)  int lastsHours)  $default,) {final _that = this;
switch (_that) {
case _AvailableNowView():
return $default(_that.switchedOn,_that.availableUntil,_that.effective,_that.prepHours,_that.eligiblePackageIds,_that.lastsHours);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: AvailableNowView.switchedOnKey_)  bool switchedOn, @JsonKey(name: AvailableNowView.availableUntilKey_)  DateTime? availableUntil, @JsonKey(name: AvailableNowView.effectiveKey_)  bool effective, @JsonKey(name: AvailableNowView.prepHoursKey_)  int prepHours, @JsonKey(name: AvailableNowView.eligiblePackageIdsKey_)  List<String>? eligiblePackageIds, @JsonKey(name: AvailableNowView.lastsHoursKey_)  int lastsHours)?  $default,) {final _that = this;
switch (_that) {
case _AvailableNowView() when $default != null:
return $default(_that.switchedOn,_that.availableUntil,_that.effective,_that.prepHours,_that.eligiblePackageIds,_that.lastsHours);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _AvailableNowView extends AvailableNowView {
  const _AvailableNowView({@JsonKey(name: AvailableNowView.switchedOnKey_) required this.switchedOn, @JsonKey(name: AvailableNowView.availableUntilKey_) this.availableUntil, @JsonKey(name: AvailableNowView.effectiveKey_) required this.effective, @JsonKey(name: AvailableNowView.prepHoursKey_) required this.prepHours, @JsonKey(name: AvailableNowView.eligiblePackageIdsKey_) final  List<String>? eligiblePackageIds, @JsonKey(name: AvailableNowView.lastsHoursKey_) required this.lastsHours}): _eligiblePackageIds = eligiblePackageIds,super._();
  factory _AvailableNowView.fromJson(Map<String, dynamic> json) => _$AvailableNowViewFromJson(json);

/// switchedOn
@override@JsonKey(name: AvailableNowView.switchedOnKey_) final  bool switchedOn;
/// availableUntil
@override@JsonKey(name: AvailableNowView.availableUntilKey_) final  DateTime? availableUntil;
/// effective
@override@JsonKey(name: AvailableNowView.effectiveKey_) final  bool effective;
/// prepHours
@override@JsonKey(name: AvailableNowView.prepHoursKey_) final  int prepHours;
/// eligiblePackageIds
 final  List<String>? _eligiblePackageIds;
/// eligiblePackageIds
@override@JsonKey(name: AvailableNowView.eligiblePackageIdsKey_) List<String>? get eligiblePackageIds {
  final value = _eligiblePackageIds;
  if (value == null) return null;
  if (_eligiblePackageIds is EqualUnmodifiableListView) return _eligiblePackageIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// lastsHours
@override@JsonKey(name: AvailableNowView.lastsHoursKey_) final  int lastsHours;

/// Create a copy of AvailableNowView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AvailableNowViewCopyWith<_AvailableNowView> get copyWith => __$AvailableNowViewCopyWithImpl<_AvailableNowView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AvailableNowViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AvailableNowView&&(identical(other.switchedOn, switchedOn) || other.switchedOn == switchedOn)&&(identical(other.availableUntil, availableUntil) || other.availableUntil == availableUntil)&&(identical(other.effective, effective) || other.effective == effective)&&(identical(other.prepHours, prepHours) || other.prepHours == prepHours)&&const DeepCollectionEquality().equals(other._eligiblePackageIds, _eligiblePackageIds)&&(identical(other.lastsHours, lastsHours) || other.lastsHours == lastsHours));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,switchedOn,availableUntil,effective,prepHours,const DeepCollectionEquality().hash(_eligiblePackageIds),lastsHours);

@override
String toString() {
  return 'AvailableNowView(switchedOn: $switchedOn, availableUntil: $availableUntil, effective: $effective, prepHours: $prepHours, eligiblePackageIds: $eligiblePackageIds, lastsHours: $lastsHours)';
}


}

/// @nodoc
abstract mixin class _$AvailableNowViewCopyWith<$Res> implements $AvailableNowViewCopyWith<$Res> {
  factory _$AvailableNowViewCopyWith(_AvailableNowView value, $Res Function(_AvailableNowView) _then) = __$AvailableNowViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: AvailableNowView.switchedOnKey_) bool switchedOn,@JsonKey(name: AvailableNowView.availableUntilKey_) DateTime? availableUntil,@JsonKey(name: AvailableNowView.effectiveKey_) bool effective,@JsonKey(name: AvailableNowView.prepHoursKey_) int prepHours,@JsonKey(name: AvailableNowView.eligiblePackageIdsKey_) List<String>? eligiblePackageIds,@JsonKey(name: AvailableNowView.lastsHoursKey_) int lastsHours
});




}
/// @nodoc
class __$AvailableNowViewCopyWithImpl<$Res>
    implements _$AvailableNowViewCopyWith<$Res> {
  __$AvailableNowViewCopyWithImpl(this._self, this._then);

  final _AvailableNowView _self;
  final $Res Function(_AvailableNowView) _then;

/// Create a copy of AvailableNowView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? switchedOn = null,Object? availableUntil = freezed,Object? effective = null,Object? prepHours = null,Object? eligiblePackageIds = freezed,Object? lastsHours = null,}) {
  return _then(_AvailableNowView(
switchedOn: null == switchedOn ? _self.switchedOn : switchedOn // ignore: cast_nullable_to_non_nullable
as bool,availableUntil: freezed == availableUntil ? _self.availableUntil : availableUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,effective: null == effective ? _self.effective : effective // ignore: cast_nullable_to_non_nullable
as bool,prepHours: null == prepHours ? _self.prepHours : prepHours // ignore: cast_nullable_to_non_nullable
as int,eligiblePackageIds: freezed == eligiblePackageIds ? _self._eligiblePackageIds : eligiblePackageIds // ignore: cast_nullable_to_non_nullable
as List<String>?,lastsHours: null == lastsHours ? _self.lastsHours : lastsHours // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
