// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pro_raww_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProRawwView {

/// shelfOpen
@JsonKey(name: ProRawwView.shelfOpenKey_) bool get shelfOpen;/// spendable
@JsonKey(name: ProRawwView.spendableKey_) int get spendable;/// pending
@JsonKey(name: ProRawwView.pendingKey_) int get pending;/// rawwEurValue
@JsonKey(name: ProRawwView.rawwEurValueKey_) String get rawwEurValue;/// pendingBookings
@JsonKey(name: ProRawwView.pendingBookingsKey_) List<RawwPendingBooking> get pendingBookings;/// expiresAt
@JsonKey(name: ProRawwView.expiresAtKey_) DateTime? get expiresAt;/// expiryWarning
@JsonKey(name: ProRawwView.expiryWarningKey_) bool get expiryWarning;/// inactivityMonths
@JsonKey(name: ProRawwView.inactivityMonthsKey_) int get inactivityMonths;
/// Create a copy of ProRawwView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProRawwViewCopyWith<ProRawwView> get copyWith => _$ProRawwViewCopyWithImpl<ProRawwView>(this as ProRawwView, _$identity);

  /// Serializes this ProRawwView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProRawwView&&(identical(other.shelfOpen, shelfOpen) || other.shelfOpen == shelfOpen)&&(identical(other.spendable, spendable) || other.spendable == spendable)&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.rawwEurValue, rawwEurValue) || other.rawwEurValue == rawwEurValue)&&const DeepCollectionEquality().equals(other.pendingBookings, pendingBookings)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.expiryWarning, expiryWarning) || other.expiryWarning == expiryWarning)&&(identical(other.inactivityMonths, inactivityMonths) || other.inactivityMonths == inactivityMonths));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,shelfOpen,spendable,pending,rawwEurValue,const DeepCollectionEquality().hash(pendingBookings),expiresAt,expiryWarning,inactivityMonths);

@override
String toString() {
  return 'ProRawwView(shelfOpen: $shelfOpen, spendable: $spendable, pending: $pending, rawwEurValue: $rawwEurValue, pendingBookings: $pendingBookings, expiresAt: $expiresAt, expiryWarning: $expiryWarning, inactivityMonths: $inactivityMonths)';
}


}

/// @nodoc
abstract mixin class $ProRawwViewCopyWith<$Res>  {
  factory $ProRawwViewCopyWith(ProRawwView value, $Res Function(ProRawwView) _then) = _$ProRawwViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ProRawwView.shelfOpenKey_) bool shelfOpen,@JsonKey(name: ProRawwView.spendableKey_) int spendable,@JsonKey(name: ProRawwView.pendingKey_) int pending,@JsonKey(name: ProRawwView.rawwEurValueKey_) String rawwEurValue,@JsonKey(name: ProRawwView.pendingBookingsKey_) List<RawwPendingBooking> pendingBookings,@JsonKey(name: ProRawwView.expiresAtKey_) DateTime? expiresAt,@JsonKey(name: ProRawwView.expiryWarningKey_) bool expiryWarning,@JsonKey(name: ProRawwView.inactivityMonthsKey_) int inactivityMonths
});




}
/// @nodoc
class _$ProRawwViewCopyWithImpl<$Res>
    implements $ProRawwViewCopyWith<$Res> {
  _$ProRawwViewCopyWithImpl(this._self, this._then);

  final ProRawwView _self;
  final $Res Function(ProRawwView) _then;

/// Create a copy of ProRawwView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? shelfOpen = null,Object? spendable = null,Object? pending = null,Object? rawwEurValue = null,Object? pendingBookings = null,Object? expiresAt = freezed,Object? expiryWarning = null,Object? inactivityMonths = null,}) {
  return _then(_self.copyWith(
shelfOpen: null == shelfOpen ? _self.shelfOpen : shelfOpen // ignore: cast_nullable_to_non_nullable
as bool,spendable: null == spendable ? _self.spendable : spendable // ignore: cast_nullable_to_non_nullable
as int,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as int,rawwEurValue: null == rawwEurValue ? _self.rawwEurValue : rawwEurValue // ignore: cast_nullable_to_non_nullable
as String,pendingBookings: null == pendingBookings ? _self.pendingBookings : pendingBookings // ignore: cast_nullable_to_non_nullable
as List<RawwPendingBooking>,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiryWarning: null == expiryWarning ? _self.expiryWarning : expiryWarning // ignore: cast_nullable_to_non_nullable
as bool,inactivityMonths: null == inactivityMonths ? _self.inactivityMonths : inactivityMonths // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ProRawwView].
extension ProRawwViewPatterns on ProRawwView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProRawwView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProRawwView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProRawwView value)  $default,){
final _that = this;
switch (_that) {
case _ProRawwView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProRawwView value)?  $default,){
final _that = this;
switch (_that) {
case _ProRawwView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ProRawwView.shelfOpenKey_)  bool shelfOpen, @JsonKey(name: ProRawwView.spendableKey_)  int spendable, @JsonKey(name: ProRawwView.pendingKey_)  int pending, @JsonKey(name: ProRawwView.rawwEurValueKey_)  String rawwEurValue, @JsonKey(name: ProRawwView.pendingBookingsKey_)  List<RawwPendingBooking> pendingBookings, @JsonKey(name: ProRawwView.expiresAtKey_)  DateTime? expiresAt, @JsonKey(name: ProRawwView.expiryWarningKey_)  bool expiryWarning, @JsonKey(name: ProRawwView.inactivityMonthsKey_)  int inactivityMonths)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProRawwView() when $default != null:
return $default(_that.shelfOpen,_that.spendable,_that.pending,_that.rawwEurValue,_that.pendingBookings,_that.expiresAt,_that.expiryWarning,_that.inactivityMonths);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ProRawwView.shelfOpenKey_)  bool shelfOpen, @JsonKey(name: ProRawwView.spendableKey_)  int spendable, @JsonKey(name: ProRawwView.pendingKey_)  int pending, @JsonKey(name: ProRawwView.rawwEurValueKey_)  String rawwEurValue, @JsonKey(name: ProRawwView.pendingBookingsKey_)  List<RawwPendingBooking> pendingBookings, @JsonKey(name: ProRawwView.expiresAtKey_)  DateTime? expiresAt, @JsonKey(name: ProRawwView.expiryWarningKey_)  bool expiryWarning, @JsonKey(name: ProRawwView.inactivityMonthsKey_)  int inactivityMonths)  $default,) {final _that = this;
switch (_that) {
case _ProRawwView():
return $default(_that.shelfOpen,_that.spendable,_that.pending,_that.rawwEurValue,_that.pendingBookings,_that.expiresAt,_that.expiryWarning,_that.inactivityMonths);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ProRawwView.shelfOpenKey_)  bool shelfOpen, @JsonKey(name: ProRawwView.spendableKey_)  int spendable, @JsonKey(name: ProRawwView.pendingKey_)  int pending, @JsonKey(name: ProRawwView.rawwEurValueKey_)  String rawwEurValue, @JsonKey(name: ProRawwView.pendingBookingsKey_)  List<RawwPendingBooking> pendingBookings, @JsonKey(name: ProRawwView.expiresAtKey_)  DateTime? expiresAt, @JsonKey(name: ProRawwView.expiryWarningKey_)  bool expiryWarning, @JsonKey(name: ProRawwView.inactivityMonthsKey_)  int inactivityMonths)?  $default,) {final _that = this;
switch (_that) {
case _ProRawwView() when $default != null:
return $default(_that.shelfOpen,_that.spendable,_that.pending,_that.rawwEurValue,_that.pendingBookings,_that.expiresAt,_that.expiryWarning,_that.inactivityMonths);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ProRawwView extends ProRawwView {
  const _ProRawwView({@JsonKey(name: ProRawwView.shelfOpenKey_) required this.shelfOpen, @JsonKey(name: ProRawwView.spendableKey_) required this.spendable, @JsonKey(name: ProRawwView.pendingKey_) required this.pending, @JsonKey(name: ProRawwView.rawwEurValueKey_) required this.rawwEurValue, @JsonKey(name: ProRawwView.pendingBookingsKey_) required final  List<RawwPendingBooking> pendingBookings, @JsonKey(name: ProRawwView.expiresAtKey_) this.expiresAt, @JsonKey(name: ProRawwView.expiryWarningKey_) required this.expiryWarning, @JsonKey(name: ProRawwView.inactivityMonthsKey_) required this.inactivityMonths}): _pendingBookings = pendingBookings,super._();
  factory _ProRawwView.fromJson(Map<String, dynamic> json) => _$ProRawwViewFromJson(json);

/// shelfOpen
@override@JsonKey(name: ProRawwView.shelfOpenKey_) final  bool shelfOpen;
/// spendable
@override@JsonKey(name: ProRawwView.spendableKey_) final  int spendable;
/// pending
@override@JsonKey(name: ProRawwView.pendingKey_) final  int pending;
/// rawwEurValue
@override@JsonKey(name: ProRawwView.rawwEurValueKey_) final  String rawwEurValue;
/// pendingBookings
 final  List<RawwPendingBooking> _pendingBookings;
/// pendingBookings
@override@JsonKey(name: ProRawwView.pendingBookingsKey_) List<RawwPendingBooking> get pendingBookings {
  if (_pendingBookings is EqualUnmodifiableListView) return _pendingBookings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pendingBookings);
}

/// expiresAt
@override@JsonKey(name: ProRawwView.expiresAtKey_) final  DateTime? expiresAt;
/// expiryWarning
@override@JsonKey(name: ProRawwView.expiryWarningKey_) final  bool expiryWarning;
/// inactivityMonths
@override@JsonKey(name: ProRawwView.inactivityMonthsKey_) final  int inactivityMonths;

/// Create a copy of ProRawwView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProRawwViewCopyWith<_ProRawwView> get copyWith => __$ProRawwViewCopyWithImpl<_ProRawwView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProRawwViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProRawwView&&(identical(other.shelfOpen, shelfOpen) || other.shelfOpen == shelfOpen)&&(identical(other.spendable, spendable) || other.spendable == spendable)&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.rawwEurValue, rawwEurValue) || other.rawwEurValue == rawwEurValue)&&const DeepCollectionEquality().equals(other._pendingBookings, _pendingBookings)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.expiryWarning, expiryWarning) || other.expiryWarning == expiryWarning)&&(identical(other.inactivityMonths, inactivityMonths) || other.inactivityMonths == inactivityMonths));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,shelfOpen,spendable,pending,rawwEurValue,const DeepCollectionEquality().hash(_pendingBookings),expiresAt,expiryWarning,inactivityMonths);

@override
String toString() {
  return 'ProRawwView(shelfOpen: $shelfOpen, spendable: $spendable, pending: $pending, rawwEurValue: $rawwEurValue, pendingBookings: $pendingBookings, expiresAt: $expiresAt, expiryWarning: $expiryWarning, inactivityMonths: $inactivityMonths)';
}


}

/// @nodoc
abstract mixin class _$ProRawwViewCopyWith<$Res> implements $ProRawwViewCopyWith<$Res> {
  factory _$ProRawwViewCopyWith(_ProRawwView value, $Res Function(_ProRawwView) _then) = __$ProRawwViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ProRawwView.shelfOpenKey_) bool shelfOpen,@JsonKey(name: ProRawwView.spendableKey_) int spendable,@JsonKey(name: ProRawwView.pendingKey_) int pending,@JsonKey(name: ProRawwView.rawwEurValueKey_) String rawwEurValue,@JsonKey(name: ProRawwView.pendingBookingsKey_) List<RawwPendingBooking> pendingBookings,@JsonKey(name: ProRawwView.expiresAtKey_) DateTime? expiresAt,@JsonKey(name: ProRawwView.expiryWarningKey_) bool expiryWarning,@JsonKey(name: ProRawwView.inactivityMonthsKey_) int inactivityMonths
});




}
/// @nodoc
class __$ProRawwViewCopyWithImpl<$Res>
    implements _$ProRawwViewCopyWith<$Res> {
  __$ProRawwViewCopyWithImpl(this._self, this._then);

  final _ProRawwView _self;
  final $Res Function(_ProRawwView) _then;

/// Create a copy of ProRawwView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? shelfOpen = null,Object? spendable = null,Object? pending = null,Object? rawwEurValue = null,Object? pendingBookings = null,Object? expiresAt = freezed,Object? expiryWarning = null,Object? inactivityMonths = null,}) {
  return _then(_ProRawwView(
shelfOpen: null == shelfOpen ? _self.shelfOpen : shelfOpen // ignore: cast_nullable_to_non_nullable
as bool,spendable: null == spendable ? _self.spendable : spendable // ignore: cast_nullable_to_non_nullable
as int,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as int,rawwEurValue: null == rawwEurValue ? _self.rawwEurValue : rawwEurValue // ignore: cast_nullable_to_non_nullable
as String,pendingBookings: null == pendingBookings ? _self._pendingBookings : pendingBookings // ignore: cast_nullable_to_non_nullable
as List<RawwPendingBooking>,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiryWarning: null == expiryWarning ? _self.expiryWarning : expiryWarning // ignore: cast_nullable_to_non_nullable
as bool,inactivityMonths: null == inactivityMonths ? _self.inactivityMonths : inactivityMonths // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
