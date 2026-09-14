// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invoice_summary_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InvoiceSummaryView {

/// bookings
@JsonKey(name: InvoiceSummaryView.bookingsKey_) int get bookings;/// gross
@JsonKey(name: InvoiceSummaryView.grossKey_) String get gross;/// platformFees
@JsonKey(name: InvoiceSummaryView.platformFeesKey_) String get platformFees;/// proRaww
@JsonKey(name: InvoiceSummaryView.proRawwKey_) String get proRaww;/// clientRaww
@JsonKey(name: InvoiceSummaryView.clientRawwKey_) String get clientRaww;/// proCash
@JsonKey(name: InvoiceSummaryView.proCashKey_) String get proCash;/// averageGross
@JsonKey(name: InvoiceSummaryView.averageGrossKey_) String? get averageGross;/// reconstructed
@JsonKey(name: InvoiceSummaryView.reconstructedKey_) int get reconstructed;
/// Create a copy of InvoiceSummaryView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvoiceSummaryViewCopyWith<InvoiceSummaryView> get copyWith => _$InvoiceSummaryViewCopyWithImpl<InvoiceSummaryView>(this as InvoiceSummaryView, _$identity);

  /// Serializes this InvoiceSummaryView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvoiceSummaryView&&(identical(other.bookings, bookings) || other.bookings == bookings)&&(identical(other.gross, gross) || other.gross == gross)&&(identical(other.platformFees, platformFees) || other.platformFees == platformFees)&&(identical(other.proRaww, proRaww) || other.proRaww == proRaww)&&(identical(other.clientRaww, clientRaww) || other.clientRaww == clientRaww)&&(identical(other.proCash, proCash) || other.proCash == proCash)&&(identical(other.averageGross, averageGross) || other.averageGross == averageGross)&&(identical(other.reconstructed, reconstructed) || other.reconstructed == reconstructed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bookings,gross,platformFees,proRaww,clientRaww,proCash,averageGross,reconstructed);

@override
String toString() {
  return 'InvoiceSummaryView(bookings: $bookings, gross: $gross, platformFees: $platformFees, proRaww: $proRaww, clientRaww: $clientRaww, proCash: $proCash, averageGross: $averageGross, reconstructed: $reconstructed)';
}


}

/// @nodoc
abstract mixin class $InvoiceSummaryViewCopyWith<$Res>  {
  factory $InvoiceSummaryViewCopyWith(InvoiceSummaryView value, $Res Function(InvoiceSummaryView) _then) = _$InvoiceSummaryViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: InvoiceSummaryView.bookingsKey_) int bookings,@JsonKey(name: InvoiceSummaryView.grossKey_) String gross,@JsonKey(name: InvoiceSummaryView.platformFeesKey_) String platformFees,@JsonKey(name: InvoiceSummaryView.proRawwKey_) String proRaww,@JsonKey(name: InvoiceSummaryView.clientRawwKey_) String clientRaww,@JsonKey(name: InvoiceSummaryView.proCashKey_) String proCash,@JsonKey(name: InvoiceSummaryView.averageGrossKey_) String? averageGross,@JsonKey(name: InvoiceSummaryView.reconstructedKey_) int reconstructed
});




}
/// @nodoc
class _$InvoiceSummaryViewCopyWithImpl<$Res>
    implements $InvoiceSummaryViewCopyWith<$Res> {
  _$InvoiceSummaryViewCopyWithImpl(this._self, this._then);

  final InvoiceSummaryView _self;
  final $Res Function(InvoiceSummaryView) _then;

/// Create a copy of InvoiceSummaryView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bookings = null,Object? gross = null,Object? platformFees = null,Object? proRaww = null,Object? clientRaww = null,Object? proCash = null,Object? averageGross = freezed,Object? reconstructed = null,}) {
  return _then(_self.copyWith(
bookings: null == bookings ? _self.bookings : bookings // ignore: cast_nullable_to_non_nullable
as int,gross: null == gross ? _self.gross : gross // ignore: cast_nullable_to_non_nullable
as String,platformFees: null == platformFees ? _self.platformFees : platformFees // ignore: cast_nullable_to_non_nullable
as String,proRaww: null == proRaww ? _self.proRaww : proRaww // ignore: cast_nullable_to_non_nullable
as String,clientRaww: null == clientRaww ? _self.clientRaww : clientRaww // ignore: cast_nullable_to_non_nullable
as String,proCash: null == proCash ? _self.proCash : proCash // ignore: cast_nullable_to_non_nullable
as String,averageGross: freezed == averageGross ? _self.averageGross : averageGross // ignore: cast_nullable_to_non_nullable
as String?,reconstructed: null == reconstructed ? _self.reconstructed : reconstructed // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [InvoiceSummaryView].
extension InvoiceSummaryViewPatterns on InvoiceSummaryView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InvoiceSummaryView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InvoiceSummaryView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InvoiceSummaryView value)  $default,){
final _that = this;
switch (_that) {
case _InvoiceSummaryView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InvoiceSummaryView value)?  $default,){
final _that = this;
switch (_that) {
case _InvoiceSummaryView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: InvoiceSummaryView.bookingsKey_)  int bookings, @JsonKey(name: InvoiceSummaryView.grossKey_)  String gross, @JsonKey(name: InvoiceSummaryView.platformFeesKey_)  String platformFees, @JsonKey(name: InvoiceSummaryView.proRawwKey_)  String proRaww, @JsonKey(name: InvoiceSummaryView.clientRawwKey_)  String clientRaww, @JsonKey(name: InvoiceSummaryView.proCashKey_)  String proCash, @JsonKey(name: InvoiceSummaryView.averageGrossKey_)  String? averageGross, @JsonKey(name: InvoiceSummaryView.reconstructedKey_)  int reconstructed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InvoiceSummaryView() when $default != null:
return $default(_that.bookings,_that.gross,_that.platformFees,_that.proRaww,_that.clientRaww,_that.proCash,_that.averageGross,_that.reconstructed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: InvoiceSummaryView.bookingsKey_)  int bookings, @JsonKey(name: InvoiceSummaryView.grossKey_)  String gross, @JsonKey(name: InvoiceSummaryView.platformFeesKey_)  String platformFees, @JsonKey(name: InvoiceSummaryView.proRawwKey_)  String proRaww, @JsonKey(name: InvoiceSummaryView.clientRawwKey_)  String clientRaww, @JsonKey(name: InvoiceSummaryView.proCashKey_)  String proCash, @JsonKey(name: InvoiceSummaryView.averageGrossKey_)  String? averageGross, @JsonKey(name: InvoiceSummaryView.reconstructedKey_)  int reconstructed)  $default,) {final _that = this;
switch (_that) {
case _InvoiceSummaryView():
return $default(_that.bookings,_that.gross,_that.platformFees,_that.proRaww,_that.clientRaww,_that.proCash,_that.averageGross,_that.reconstructed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: InvoiceSummaryView.bookingsKey_)  int bookings, @JsonKey(name: InvoiceSummaryView.grossKey_)  String gross, @JsonKey(name: InvoiceSummaryView.platformFeesKey_)  String platformFees, @JsonKey(name: InvoiceSummaryView.proRawwKey_)  String proRaww, @JsonKey(name: InvoiceSummaryView.clientRawwKey_)  String clientRaww, @JsonKey(name: InvoiceSummaryView.proCashKey_)  String proCash, @JsonKey(name: InvoiceSummaryView.averageGrossKey_)  String? averageGross, @JsonKey(name: InvoiceSummaryView.reconstructedKey_)  int reconstructed)?  $default,) {final _that = this;
switch (_that) {
case _InvoiceSummaryView() when $default != null:
return $default(_that.bookings,_that.gross,_that.platformFees,_that.proRaww,_that.clientRaww,_that.proCash,_that.averageGross,_that.reconstructed);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _InvoiceSummaryView extends InvoiceSummaryView {
  const _InvoiceSummaryView({@JsonKey(name: InvoiceSummaryView.bookingsKey_) required this.bookings, @JsonKey(name: InvoiceSummaryView.grossKey_) required this.gross, @JsonKey(name: InvoiceSummaryView.platformFeesKey_) required this.platformFees, @JsonKey(name: InvoiceSummaryView.proRawwKey_) required this.proRaww, @JsonKey(name: InvoiceSummaryView.clientRawwKey_) required this.clientRaww, @JsonKey(name: InvoiceSummaryView.proCashKey_) required this.proCash, @JsonKey(name: InvoiceSummaryView.averageGrossKey_) this.averageGross, @JsonKey(name: InvoiceSummaryView.reconstructedKey_) this.reconstructed = 0}): super._();
  factory _InvoiceSummaryView.fromJson(Map<String, dynamic> json) => _$InvoiceSummaryViewFromJson(json);

/// bookings
@override@JsonKey(name: InvoiceSummaryView.bookingsKey_) final  int bookings;
/// gross
@override@JsonKey(name: InvoiceSummaryView.grossKey_) final  String gross;
/// platformFees
@override@JsonKey(name: InvoiceSummaryView.platformFeesKey_) final  String platformFees;
/// proRaww
@override@JsonKey(name: InvoiceSummaryView.proRawwKey_) final  String proRaww;
/// clientRaww
@override@JsonKey(name: InvoiceSummaryView.clientRawwKey_) final  String clientRaww;
/// proCash
@override@JsonKey(name: InvoiceSummaryView.proCashKey_) final  String proCash;
/// averageGross
@override@JsonKey(name: InvoiceSummaryView.averageGrossKey_) final  String? averageGross;
/// reconstructed
@override@JsonKey(name: InvoiceSummaryView.reconstructedKey_) final  int reconstructed;

/// Create a copy of InvoiceSummaryView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvoiceSummaryViewCopyWith<_InvoiceSummaryView> get copyWith => __$InvoiceSummaryViewCopyWithImpl<_InvoiceSummaryView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvoiceSummaryViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvoiceSummaryView&&(identical(other.bookings, bookings) || other.bookings == bookings)&&(identical(other.gross, gross) || other.gross == gross)&&(identical(other.platformFees, platformFees) || other.platformFees == platformFees)&&(identical(other.proRaww, proRaww) || other.proRaww == proRaww)&&(identical(other.clientRaww, clientRaww) || other.clientRaww == clientRaww)&&(identical(other.proCash, proCash) || other.proCash == proCash)&&(identical(other.averageGross, averageGross) || other.averageGross == averageGross)&&(identical(other.reconstructed, reconstructed) || other.reconstructed == reconstructed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bookings,gross,platformFees,proRaww,clientRaww,proCash,averageGross,reconstructed);

@override
String toString() {
  return 'InvoiceSummaryView(bookings: $bookings, gross: $gross, platformFees: $platformFees, proRaww: $proRaww, clientRaww: $clientRaww, proCash: $proCash, averageGross: $averageGross, reconstructed: $reconstructed)';
}


}

/// @nodoc
abstract mixin class _$InvoiceSummaryViewCopyWith<$Res> implements $InvoiceSummaryViewCopyWith<$Res> {
  factory _$InvoiceSummaryViewCopyWith(_InvoiceSummaryView value, $Res Function(_InvoiceSummaryView) _then) = __$InvoiceSummaryViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: InvoiceSummaryView.bookingsKey_) int bookings,@JsonKey(name: InvoiceSummaryView.grossKey_) String gross,@JsonKey(name: InvoiceSummaryView.platformFeesKey_) String platformFees,@JsonKey(name: InvoiceSummaryView.proRawwKey_) String proRaww,@JsonKey(name: InvoiceSummaryView.clientRawwKey_) String clientRaww,@JsonKey(name: InvoiceSummaryView.proCashKey_) String proCash,@JsonKey(name: InvoiceSummaryView.averageGrossKey_) String? averageGross,@JsonKey(name: InvoiceSummaryView.reconstructedKey_) int reconstructed
});




}
/// @nodoc
class __$InvoiceSummaryViewCopyWithImpl<$Res>
    implements _$InvoiceSummaryViewCopyWith<$Res> {
  __$InvoiceSummaryViewCopyWithImpl(this._self, this._then);

  final _InvoiceSummaryView _self;
  final $Res Function(_InvoiceSummaryView) _then;

/// Create a copy of InvoiceSummaryView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bookings = null,Object? gross = null,Object? platformFees = null,Object? proRaww = null,Object? clientRaww = null,Object? proCash = null,Object? averageGross = freezed,Object? reconstructed = null,}) {
  return _then(_InvoiceSummaryView(
bookings: null == bookings ? _self.bookings : bookings // ignore: cast_nullable_to_non_nullable
as int,gross: null == gross ? _self.gross : gross // ignore: cast_nullable_to_non_nullable
as String,platformFees: null == platformFees ? _self.platformFees : platformFees // ignore: cast_nullable_to_non_nullable
as String,proRaww: null == proRaww ? _self.proRaww : proRaww // ignore: cast_nullable_to_non_nullable
as String,clientRaww: null == clientRaww ? _self.clientRaww : clientRaww // ignore: cast_nullable_to_non_nullable
as String,proCash: null == proCash ? _self.proCash : proCash // ignore: cast_nullable_to_non_nullable
as String,averageGross: freezed == averageGross ? _self.averageGross : averageGross // ignore: cast_nullable_to_non_nullable
as String?,reconstructed: null == reconstructed ? _self.reconstructed : reconstructed // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
