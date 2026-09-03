// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pro_activate_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProActivateResponse {

/// isAcceptingBookings
@JsonKey(name: ProActivateResponse.isAcceptingBookingsKey_) bool get isAcceptingBookings;/// completenessScore
@JsonKey(name: ProActivateResponse.completenessScoreKey_) int get completenessScore;/// kycStatus
@JsonKey(name: ProActivateResponse.kycStatusKey_) String get kycStatus;
/// Create a copy of ProActivateResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProActivateResponseCopyWith<ProActivateResponse> get copyWith => _$ProActivateResponseCopyWithImpl<ProActivateResponse>(this as ProActivateResponse, _$identity);

  /// Serializes this ProActivateResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProActivateResponse&&(identical(other.isAcceptingBookings, isAcceptingBookings) || other.isAcceptingBookings == isAcceptingBookings)&&(identical(other.completenessScore, completenessScore) || other.completenessScore == completenessScore)&&(identical(other.kycStatus, kycStatus) || other.kycStatus == kycStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isAcceptingBookings,completenessScore,kycStatus);

@override
String toString() {
  return 'ProActivateResponse(isAcceptingBookings: $isAcceptingBookings, completenessScore: $completenessScore, kycStatus: $kycStatus)';
}


}

/// @nodoc
abstract mixin class $ProActivateResponseCopyWith<$Res>  {
  factory $ProActivateResponseCopyWith(ProActivateResponse value, $Res Function(ProActivateResponse) _then) = _$ProActivateResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ProActivateResponse.isAcceptingBookingsKey_) bool isAcceptingBookings,@JsonKey(name: ProActivateResponse.completenessScoreKey_) int completenessScore,@JsonKey(name: ProActivateResponse.kycStatusKey_) String kycStatus
});




}
/// @nodoc
class _$ProActivateResponseCopyWithImpl<$Res>
    implements $ProActivateResponseCopyWith<$Res> {
  _$ProActivateResponseCopyWithImpl(this._self, this._then);

  final ProActivateResponse _self;
  final $Res Function(ProActivateResponse) _then;

/// Create a copy of ProActivateResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isAcceptingBookings = null,Object? completenessScore = null,Object? kycStatus = null,}) {
  return _then(_self.copyWith(
isAcceptingBookings: null == isAcceptingBookings ? _self.isAcceptingBookings : isAcceptingBookings // ignore: cast_nullable_to_non_nullable
as bool,completenessScore: null == completenessScore ? _self.completenessScore : completenessScore // ignore: cast_nullable_to_non_nullable
as int,kycStatus: null == kycStatus ? _self.kycStatus : kycStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ProActivateResponse].
extension ProActivateResponsePatterns on ProActivateResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProActivateResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProActivateResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProActivateResponse value)  $default,){
final _that = this;
switch (_that) {
case _ProActivateResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProActivateResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ProActivateResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ProActivateResponse.isAcceptingBookingsKey_)  bool isAcceptingBookings, @JsonKey(name: ProActivateResponse.completenessScoreKey_)  int completenessScore, @JsonKey(name: ProActivateResponse.kycStatusKey_)  String kycStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProActivateResponse() when $default != null:
return $default(_that.isAcceptingBookings,_that.completenessScore,_that.kycStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ProActivateResponse.isAcceptingBookingsKey_)  bool isAcceptingBookings, @JsonKey(name: ProActivateResponse.completenessScoreKey_)  int completenessScore, @JsonKey(name: ProActivateResponse.kycStatusKey_)  String kycStatus)  $default,) {final _that = this;
switch (_that) {
case _ProActivateResponse():
return $default(_that.isAcceptingBookings,_that.completenessScore,_that.kycStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ProActivateResponse.isAcceptingBookingsKey_)  bool isAcceptingBookings, @JsonKey(name: ProActivateResponse.completenessScoreKey_)  int completenessScore, @JsonKey(name: ProActivateResponse.kycStatusKey_)  String kycStatus)?  $default,) {final _that = this;
switch (_that) {
case _ProActivateResponse() when $default != null:
return $default(_that.isAcceptingBookings,_that.completenessScore,_that.kycStatus);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ProActivateResponse extends ProActivateResponse {
  const _ProActivateResponse({@JsonKey(name: ProActivateResponse.isAcceptingBookingsKey_) required this.isAcceptingBookings, @JsonKey(name: ProActivateResponse.completenessScoreKey_) required this.completenessScore, @JsonKey(name: ProActivateResponse.kycStatusKey_) required this.kycStatus}): super._();
  factory _ProActivateResponse.fromJson(Map<String, dynamic> json) => _$ProActivateResponseFromJson(json);

/// isAcceptingBookings
@override@JsonKey(name: ProActivateResponse.isAcceptingBookingsKey_) final  bool isAcceptingBookings;
/// completenessScore
@override@JsonKey(name: ProActivateResponse.completenessScoreKey_) final  int completenessScore;
/// kycStatus
@override@JsonKey(name: ProActivateResponse.kycStatusKey_) final  String kycStatus;

/// Create a copy of ProActivateResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProActivateResponseCopyWith<_ProActivateResponse> get copyWith => __$ProActivateResponseCopyWithImpl<_ProActivateResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProActivateResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProActivateResponse&&(identical(other.isAcceptingBookings, isAcceptingBookings) || other.isAcceptingBookings == isAcceptingBookings)&&(identical(other.completenessScore, completenessScore) || other.completenessScore == completenessScore)&&(identical(other.kycStatus, kycStatus) || other.kycStatus == kycStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isAcceptingBookings,completenessScore,kycStatus);

@override
String toString() {
  return 'ProActivateResponse(isAcceptingBookings: $isAcceptingBookings, completenessScore: $completenessScore, kycStatus: $kycStatus)';
}


}

/// @nodoc
abstract mixin class _$ProActivateResponseCopyWith<$Res> implements $ProActivateResponseCopyWith<$Res> {
  factory _$ProActivateResponseCopyWith(_ProActivateResponse value, $Res Function(_ProActivateResponse) _then) = __$ProActivateResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ProActivateResponse.isAcceptingBookingsKey_) bool isAcceptingBookings,@JsonKey(name: ProActivateResponse.completenessScoreKey_) int completenessScore,@JsonKey(name: ProActivateResponse.kycStatusKey_) String kycStatus
});




}
/// @nodoc
class __$ProActivateResponseCopyWithImpl<$Res>
    implements _$ProActivateResponseCopyWith<$Res> {
  __$ProActivateResponseCopyWithImpl(this._self, this._then);

  final _ProActivateResponse _self;
  final $Res Function(_ProActivateResponse) _then;

/// Create a copy of ProActivateResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isAcceptingBookings = null,Object? completenessScore = null,Object? kycStatus = null,}) {
  return _then(_ProActivateResponse(
isAcceptingBookings: null == isAcceptingBookings ? _self.isAcceptingBookings : isAcceptingBookings // ignore: cast_nullable_to_non_nullable
as bool,completenessScore: null == completenessScore ? _self.completenessScore : completenessScore // ignore: cast_nullable_to_non_nullable
as int,kycStatus: null == kycStatus ? _self.kycStatus : kycStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
