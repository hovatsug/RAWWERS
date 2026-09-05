// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'earnings_balance_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EarningsBalanceView {

/// pendingEur
@JsonKey(name: EarningsBalanceView.pendingEurKey_) String get pendingEur;/// availableEur
@JsonKey(name: EarningsBalanceView.availableEurKey_) String get availableEur;/// heldEur
@JsonKey(name: EarningsBalanceView.heldEurKey_) String get heldEur;/// reservedEur
@JsonKey(name: EarningsBalanceView.reservedEurKey_) String get reservedEur;/// withdrawableEur
@JsonKey(name: EarningsBalanceView.withdrawableEurKey_) String get withdrawableEur;
/// Create a copy of EarningsBalanceView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EarningsBalanceViewCopyWith<EarningsBalanceView> get copyWith => _$EarningsBalanceViewCopyWithImpl<EarningsBalanceView>(this as EarningsBalanceView, _$identity);

  /// Serializes this EarningsBalanceView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EarningsBalanceView&&(identical(other.pendingEur, pendingEur) || other.pendingEur == pendingEur)&&(identical(other.availableEur, availableEur) || other.availableEur == availableEur)&&(identical(other.heldEur, heldEur) || other.heldEur == heldEur)&&(identical(other.reservedEur, reservedEur) || other.reservedEur == reservedEur)&&(identical(other.withdrawableEur, withdrawableEur) || other.withdrawableEur == withdrawableEur));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pendingEur,availableEur,heldEur,reservedEur,withdrawableEur);

@override
String toString() {
  return 'EarningsBalanceView(pendingEur: $pendingEur, availableEur: $availableEur, heldEur: $heldEur, reservedEur: $reservedEur, withdrawableEur: $withdrawableEur)';
}


}

/// @nodoc
abstract mixin class $EarningsBalanceViewCopyWith<$Res>  {
  factory $EarningsBalanceViewCopyWith(EarningsBalanceView value, $Res Function(EarningsBalanceView) _then) = _$EarningsBalanceViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: EarningsBalanceView.pendingEurKey_) String pendingEur,@JsonKey(name: EarningsBalanceView.availableEurKey_) String availableEur,@JsonKey(name: EarningsBalanceView.heldEurKey_) String heldEur,@JsonKey(name: EarningsBalanceView.reservedEurKey_) String reservedEur,@JsonKey(name: EarningsBalanceView.withdrawableEurKey_) String withdrawableEur
});




}
/// @nodoc
class _$EarningsBalanceViewCopyWithImpl<$Res>
    implements $EarningsBalanceViewCopyWith<$Res> {
  _$EarningsBalanceViewCopyWithImpl(this._self, this._then);

  final EarningsBalanceView _self;
  final $Res Function(EarningsBalanceView) _then;

/// Create a copy of EarningsBalanceView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pendingEur = null,Object? availableEur = null,Object? heldEur = null,Object? reservedEur = null,Object? withdrawableEur = null,}) {
  return _then(_self.copyWith(
pendingEur: null == pendingEur ? _self.pendingEur : pendingEur // ignore: cast_nullable_to_non_nullable
as String,availableEur: null == availableEur ? _self.availableEur : availableEur // ignore: cast_nullable_to_non_nullable
as String,heldEur: null == heldEur ? _self.heldEur : heldEur // ignore: cast_nullable_to_non_nullable
as String,reservedEur: null == reservedEur ? _self.reservedEur : reservedEur // ignore: cast_nullable_to_non_nullable
as String,withdrawableEur: null == withdrawableEur ? _self.withdrawableEur : withdrawableEur // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [EarningsBalanceView].
extension EarningsBalanceViewPatterns on EarningsBalanceView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EarningsBalanceView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EarningsBalanceView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EarningsBalanceView value)  $default,){
final _that = this;
switch (_that) {
case _EarningsBalanceView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EarningsBalanceView value)?  $default,){
final _that = this;
switch (_that) {
case _EarningsBalanceView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: EarningsBalanceView.pendingEurKey_)  String pendingEur, @JsonKey(name: EarningsBalanceView.availableEurKey_)  String availableEur, @JsonKey(name: EarningsBalanceView.heldEurKey_)  String heldEur, @JsonKey(name: EarningsBalanceView.reservedEurKey_)  String reservedEur, @JsonKey(name: EarningsBalanceView.withdrawableEurKey_)  String withdrawableEur)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EarningsBalanceView() when $default != null:
return $default(_that.pendingEur,_that.availableEur,_that.heldEur,_that.reservedEur,_that.withdrawableEur);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: EarningsBalanceView.pendingEurKey_)  String pendingEur, @JsonKey(name: EarningsBalanceView.availableEurKey_)  String availableEur, @JsonKey(name: EarningsBalanceView.heldEurKey_)  String heldEur, @JsonKey(name: EarningsBalanceView.reservedEurKey_)  String reservedEur, @JsonKey(name: EarningsBalanceView.withdrawableEurKey_)  String withdrawableEur)  $default,) {final _that = this;
switch (_that) {
case _EarningsBalanceView():
return $default(_that.pendingEur,_that.availableEur,_that.heldEur,_that.reservedEur,_that.withdrawableEur);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: EarningsBalanceView.pendingEurKey_)  String pendingEur, @JsonKey(name: EarningsBalanceView.availableEurKey_)  String availableEur, @JsonKey(name: EarningsBalanceView.heldEurKey_)  String heldEur, @JsonKey(name: EarningsBalanceView.reservedEurKey_)  String reservedEur, @JsonKey(name: EarningsBalanceView.withdrawableEurKey_)  String withdrawableEur)?  $default,) {final _that = this;
switch (_that) {
case _EarningsBalanceView() when $default != null:
return $default(_that.pendingEur,_that.availableEur,_that.heldEur,_that.reservedEur,_that.withdrawableEur);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _EarningsBalanceView extends EarningsBalanceView {
  const _EarningsBalanceView({@JsonKey(name: EarningsBalanceView.pendingEurKey_) required this.pendingEur, @JsonKey(name: EarningsBalanceView.availableEurKey_) required this.availableEur, @JsonKey(name: EarningsBalanceView.heldEurKey_) required this.heldEur, @JsonKey(name: EarningsBalanceView.reservedEurKey_) required this.reservedEur, @JsonKey(name: EarningsBalanceView.withdrawableEurKey_) required this.withdrawableEur}): super._();
  factory _EarningsBalanceView.fromJson(Map<String, dynamic> json) => _$EarningsBalanceViewFromJson(json);

/// pendingEur
@override@JsonKey(name: EarningsBalanceView.pendingEurKey_) final  String pendingEur;
/// availableEur
@override@JsonKey(name: EarningsBalanceView.availableEurKey_) final  String availableEur;
/// heldEur
@override@JsonKey(name: EarningsBalanceView.heldEurKey_) final  String heldEur;
/// reservedEur
@override@JsonKey(name: EarningsBalanceView.reservedEurKey_) final  String reservedEur;
/// withdrawableEur
@override@JsonKey(name: EarningsBalanceView.withdrawableEurKey_) final  String withdrawableEur;

/// Create a copy of EarningsBalanceView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EarningsBalanceViewCopyWith<_EarningsBalanceView> get copyWith => __$EarningsBalanceViewCopyWithImpl<_EarningsBalanceView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EarningsBalanceViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EarningsBalanceView&&(identical(other.pendingEur, pendingEur) || other.pendingEur == pendingEur)&&(identical(other.availableEur, availableEur) || other.availableEur == availableEur)&&(identical(other.heldEur, heldEur) || other.heldEur == heldEur)&&(identical(other.reservedEur, reservedEur) || other.reservedEur == reservedEur)&&(identical(other.withdrawableEur, withdrawableEur) || other.withdrawableEur == withdrawableEur));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pendingEur,availableEur,heldEur,reservedEur,withdrawableEur);

@override
String toString() {
  return 'EarningsBalanceView(pendingEur: $pendingEur, availableEur: $availableEur, heldEur: $heldEur, reservedEur: $reservedEur, withdrawableEur: $withdrawableEur)';
}


}

/// @nodoc
abstract mixin class _$EarningsBalanceViewCopyWith<$Res> implements $EarningsBalanceViewCopyWith<$Res> {
  factory _$EarningsBalanceViewCopyWith(_EarningsBalanceView value, $Res Function(_EarningsBalanceView) _then) = __$EarningsBalanceViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: EarningsBalanceView.pendingEurKey_) String pendingEur,@JsonKey(name: EarningsBalanceView.availableEurKey_) String availableEur,@JsonKey(name: EarningsBalanceView.heldEurKey_) String heldEur,@JsonKey(name: EarningsBalanceView.reservedEurKey_) String reservedEur,@JsonKey(name: EarningsBalanceView.withdrawableEurKey_) String withdrawableEur
});




}
/// @nodoc
class __$EarningsBalanceViewCopyWithImpl<$Res>
    implements _$EarningsBalanceViewCopyWith<$Res> {
  __$EarningsBalanceViewCopyWithImpl(this._self, this._then);

  final _EarningsBalanceView _self;
  final $Res Function(_EarningsBalanceView) _then;

/// Create a copy of EarningsBalanceView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pendingEur = null,Object? availableEur = null,Object? heldEur = null,Object? reservedEur = null,Object? withdrawableEur = null,}) {
  return _then(_EarningsBalanceView(
pendingEur: null == pendingEur ? _self.pendingEur : pendingEur // ignore: cast_nullable_to_non_nullable
as String,availableEur: null == availableEur ? _self.availableEur : availableEur // ignore: cast_nullable_to_non_nullable
as String,heldEur: null == heldEur ? _self.heldEur : heldEur // ignore: cast_nullable_to_non_nullable
as String,reservedEur: null == reservedEur ? _self.reservedEur : reservedEur // ignore: cast_nullable_to_non_nullable
as String,withdrawableEur: null == withdrawableEur ? _self.withdrawableEur : withdrawableEur // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
