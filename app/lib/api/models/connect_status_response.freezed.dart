// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'connect_status_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConnectStatusResponse {

/// stripeAccountId
@JsonKey(name: ConnectStatusResponse.stripeAccountIdKey_) String? get stripeAccountId;/// accountStatus
@JsonKey(name: ConnectStatusResponse.accountStatusKey_) String get accountStatus;/// chargesEnabled
@JsonKey(name: ConnectStatusResponse.chargesEnabledKey_) bool get chargesEnabled;/// payoutsEnabled
@JsonKey(name: ConnectStatusResponse.payoutsEnabledKey_) bool get payoutsEnabled;/// detailsSubmitted
@JsonKey(name: ConnectStatusResponse.detailsSubmittedKey_) bool get detailsSubmitted;/// currentlyDue
@JsonKey(name: ConnectStatusResponse.currentlyDueKey_) List<String>? get currentlyDue;/// pastDue
@JsonKey(name: ConnectStatusResponse.pastDueKey_) List<String>? get pastDue;/// disabledReason
@JsonKey(name: ConnectStatusResponse.disabledReasonKey_) String? get disabledReason;
/// Create a copy of ConnectStatusResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConnectStatusResponseCopyWith<ConnectStatusResponse> get copyWith => _$ConnectStatusResponseCopyWithImpl<ConnectStatusResponse>(this as ConnectStatusResponse, _$identity);

  /// Serializes this ConnectStatusResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConnectStatusResponse&&(identical(other.stripeAccountId, stripeAccountId) || other.stripeAccountId == stripeAccountId)&&(identical(other.accountStatus, accountStatus) || other.accountStatus == accountStatus)&&(identical(other.chargesEnabled, chargesEnabled) || other.chargesEnabled == chargesEnabled)&&(identical(other.payoutsEnabled, payoutsEnabled) || other.payoutsEnabled == payoutsEnabled)&&(identical(other.detailsSubmitted, detailsSubmitted) || other.detailsSubmitted == detailsSubmitted)&&const DeepCollectionEquality().equals(other.currentlyDue, currentlyDue)&&const DeepCollectionEquality().equals(other.pastDue, pastDue)&&(identical(other.disabledReason, disabledReason) || other.disabledReason == disabledReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,stripeAccountId,accountStatus,chargesEnabled,payoutsEnabled,detailsSubmitted,const DeepCollectionEquality().hash(currentlyDue),const DeepCollectionEquality().hash(pastDue),disabledReason);

@override
String toString() {
  return 'ConnectStatusResponse(stripeAccountId: $stripeAccountId, accountStatus: $accountStatus, chargesEnabled: $chargesEnabled, payoutsEnabled: $payoutsEnabled, detailsSubmitted: $detailsSubmitted, currentlyDue: $currentlyDue, pastDue: $pastDue, disabledReason: $disabledReason)';
}


}

/// @nodoc
abstract mixin class $ConnectStatusResponseCopyWith<$Res>  {
  factory $ConnectStatusResponseCopyWith(ConnectStatusResponse value, $Res Function(ConnectStatusResponse) _then) = _$ConnectStatusResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ConnectStatusResponse.stripeAccountIdKey_) String? stripeAccountId,@JsonKey(name: ConnectStatusResponse.accountStatusKey_) String accountStatus,@JsonKey(name: ConnectStatusResponse.chargesEnabledKey_) bool chargesEnabled,@JsonKey(name: ConnectStatusResponse.payoutsEnabledKey_) bool payoutsEnabled,@JsonKey(name: ConnectStatusResponse.detailsSubmittedKey_) bool detailsSubmitted,@JsonKey(name: ConnectStatusResponse.currentlyDueKey_) List<String>? currentlyDue,@JsonKey(name: ConnectStatusResponse.pastDueKey_) List<String>? pastDue,@JsonKey(name: ConnectStatusResponse.disabledReasonKey_) String? disabledReason
});




}
/// @nodoc
class _$ConnectStatusResponseCopyWithImpl<$Res>
    implements $ConnectStatusResponseCopyWith<$Res> {
  _$ConnectStatusResponseCopyWithImpl(this._self, this._then);

  final ConnectStatusResponse _self;
  final $Res Function(ConnectStatusResponse) _then;

/// Create a copy of ConnectStatusResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stripeAccountId = freezed,Object? accountStatus = null,Object? chargesEnabled = null,Object? payoutsEnabled = null,Object? detailsSubmitted = null,Object? currentlyDue = freezed,Object? pastDue = freezed,Object? disabledReason = freezed,}) {
  return _then(_self.copyWith(
stripeAccountId: freezed == stripeAccountId ? _self.stripeAccountId : stripeAccountId // ignore: cast_nullable_to_non_nullable
as String?,accountStatus: null == accountStatus ? _self.accountStatus : accountStatus // ignore: cast_nullable_to_non_nullable
as String,chargesEnabled: null == chargesEnabled ? _self.chargesEnabled : chargesEnabled // ignore: cast_nullable_to_non_nullable
as bool,payoutsEnabled: null == payoutsEnabled ? _self.payoutsEnabled : payoutsEnabled // ignore: cast_nullable_to_non_nullable
as bool,detailsSubmitted: null == detailsSubmitted ? _self.detailsSubmitted : detailsSubmitted // ignore: cast_nullable_to_non_nullable
as bool,currentlyDue: freezed == currentlyDue ? _self.currentlyDue : currentlyDue // ignore: cast_nullable_to_non_nullable
as List<String>?,pastDue: freezed == pastDue ? _self.pastDue : pastDue // ignore: cast_nullable_to_non_nullable
as List<String>?,disabledReason: freezed == disabledReason ? _self.disabledReason : disabledReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ConnectStatusResponse].
extension ConnectStatusResponsePatterns on ConnectStatusResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConnectStatusResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConnectStatusResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConnectStatusResponse value)  $default,){
final _that = this;
switch (_that) {
case _ConnectStatusResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConnectStatusResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ConnectStatusResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ConnectStatusResponse.stripeAccountIdKey_)  String? stripeAccountId, @JsonKey(name: ConnectStatusResponse.accountStatusKey_)  String accountStatus, @JsonKey(name: ConnectStatusResponse.chargesEnabledKey_)  bool chargesEnabled, @JsonKey(name: ConnectStatusResponse.payoutsEnabledKey_)  bool payoutsEnabled, @JsonKey(name: ConnectStatusResponse.detailsSubmittedKey_)  bool detailsSubmitted, @JsonKey(name: ConnectStatusResponse.currentlyDueKey_)  List<String>? currentlyDue, @JsonKey(name: ConnectStatusResponse.pastDueKey_)  List<String>? pastDue, @JsonKey(name: ConnectStatusResponse.disabledReasonKey_)  String? disabledReason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConnectStatusResponse() when $default != null:
return $default(_that.stripeAccountId,_that.accountStatus,_that.chargesEnabled,_that.payoutsEnabled,_that.detailsSubmitted,_that.currentlyDue,_that.pastDue,_that.disabledReason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ConnectStatusResponse.stripeAccountIdKey_)  String? stripeAccountId, @JsonKey(name: ConnectStatusResponse.accountStatusKey_)  String accountStatus, @JsonKey(name: ConnectStatusResponse.chargesEnabledKey_)  bool chargesEnabled, @JsonKey(name: ConnectStatusResponse.payoutsEnabledKey_)  bool payoutsEnabled, @JsonKey(name: ConnectStatusResponse.detailsSubmittedKey_)  bool detailsSubmitted, @JsonKey(name: ConnectStatusResponse.currentlyDueKey_)  List<String>? currentlyDue, @JsonKey(name: ConnectStatusResponse.pastDueKey_)  List<String>? pastDue, @JsonKey(name: ConnectStatusResponse.disabledReasonKey_)  String? disabledReason)  $default,) {final _that = this;
switch (_that) {
case _ConnectStatusResponse():
return $default(_that.stripeAccountId,_that.accountStatus,_that.chargesEnabled,_that.payoutsEnabled,_that.detailsSubmitted,_that.currentlyDue,_that.pastDue,_that.disabledReason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ConnectStatusResponse.stripeAccountIdKey_)  String? stripeAccountId, @JsonKey(name: ConnectStatusResponse.accountStatusKey_)  String accountStatus, @JsonKey(name: ConnectStatusResponse.chargesEnabledKey_)  bool chargesEnabled, @JsonKey(name: ConnectStatusResponse.payoutsEnabledKey_)  bool payoutsEnabled, @JsonKey(name: ConnectStatusResponse.detailsSubmittedKey_)  bool detailsSubmitted, @JsonKey(name: ConnectStatusResponse.currentlyDueKey_)  List<String>? currentlyDue, @JsonKey(name: ConnectStatusResponse.pastDueKey_)  List<String>? pastDue, @JsonKey(name: ConnectStatusResponse.disabledReasonKey_)  String? disabledReason)?  $default,) {final _that = this;
switch (_that) {
case _ConnectStatusResponse() when $default != null:
return $default(_that.stripeAccountId,_that.accountStatus,_that.chargesEnabled,_that.payoutsEnabled,_that.detailsSubmitted,_that.currentlyDue,_that.pastDue,_that.disabledReason);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ConnectStatusResponse extends ConnectStatusResponse {
  const _ConnectStatusResponse({@JsonKey(name: ConnectStatusResponse.stripeAccountIdKey_) this.stripeAccountId, @JsonKey(name: ConnectStatusResponse.accountStatusKey_) required this.accountStatus, @JsonKey(name: ConnectStatusResponse.chargesEnabledKey_) this.chargesEnabled = false, @JsonKey(name: ConnectStatusResponse.payoutsEnabledKey_) this.payoutsEnabled = false, @JsonKey(name: ConnectStatusResponse.detailsSubmittedKey_) this.detailsSubmitted = false, @JsonKey(name: ConnectStatusResponse.currentlyDueKey_) final  List<String>? currentlyDue, @JsonKey(name: ConnectStatusResponse.pastDueKey_) final  List<String>? pastDue, @JsonKey(name: ConnectStatusResponse.disabledReasonKey_) this.disabledReason}): _currentlyDue = currentlyDue,_pastDue = pastDue,super._();
  factory _ConnectStatusResponse.fromJson(Map<String, dynamic> json) => _$ConnectStatusResponseFromJson(json);

/// stripeAccountId
@override@JsonKey(name: ConnectStatusResponse.stripeAccountIdKey_) final  String? stripeAccountId;
/// accountStatus
@override@JsonKey(name: ConnectStatusResponse.accountStatusKey_) final  String accountStatus;
/// chargesEnabled
@override@JsonKey(name: ConnectStatusResponse.chargesEnabledKey_) final  bool chargesEnabled;
/// payoutsEnabled
@override@JsonKey(name: ConnectStatusResponse.payoutsEnabledKey_) final  bool payoutsEnabled;
/// detailsSubmitted
@override@JsonKey(name: ConnectStatusResponse.detailsSubmittedKey_) final  bool detailsSubmitted;
/// currentlyDue
 final  List<String>? _currentlyDue;
/// currentlyDue
@override@JsonKey(name: ConnectStatusResponse.currentlyDueKey_) List<String>? get currentlyDue {
  final value = _currentlyDue;
  if (value == null) return null;
  if (_currentlyDue is EqualUnmodifiableListView) return _currentlyDue;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// pastDue
 final  List<String>? _pastDue;
/// pastDue
@override@JsonKey(name: ConnectStatusResponse.pastDueKey_) List<String>? get pastDue {
  final value = _pastDue;
  if (value == null) return null;
  if (_pastDue is EqualUnmodifiableListView) return _pastDue;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// disabledReason
@override@JsonKey(name: ConnectStatusResponse.disabledReasonKey_) final  String? disabledReason;

/// Create a copy of ConnectStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConnectStatusResponseCopyWith<_ConnectStatusResponse> get copyWith => __$ConnectStatusResponseCopyWithImpl<_ConnectStatusResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConnectStatusResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConnectStatusResponse&&(identical(other.stripeAccountId, stripeAccountId) || other.stripeAccountId == stripeAccountId)&&(identical(other.accountStatus, accountStatus) || other.accountStatus == accountStatus)&&(identical(other.chargesEnabled, chargesEnabled) || other.chargesEnabled == chargesEnabled)&&(identical(other.payoutsEnabled, payoutsEnabled) || other.payoutsEnabled == payoutsEnabled)&&(identical(other.detailsSubmitted, detailsSubmitted) || other.detailsSubmitted == detailsSubmitted)&&const DeepCollectionEquality().equals(other._currentlyDue, _currentlyDue)&&const DeepCollectionEquality().equals(other._pastDue, _pastDue)&&(identical(other.disabledReason, disabledReason) || other.disabledReason == disabledReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,stripeAccountId,accountStatus,chargesEnabled,payoutsEnabled,detailsSubmitted,const DeepCollectionEquality().hash(_currentlyDue),const DeepCollectionEquality().hash(_pastDue),disabledReason);

@override
String toString() {
  return 'ConnectStatusResponse(stripeAccountId: $stripeAccountId, accountStatus: $accountStatus, chargesEnabled: $chargesEnabled, payoutsEnabled: $payoutsEnabled, detailsSubmitted: $detailsSubmitted, currentlyDue: $currentlyDue, pastDue: $pastDue, disabledReason: $disabledReason)';
}


}

/// @nodoc
abstract mixin class _$ConnectStatusResponseCopyWith<$Res> implements $ConnectStatusResponseCopyWith<$Res> {
  factory _$ConnectStatusResponseCopyWith(_ConnectStatusResponse value, $Res Function(_ConnectStatusResponse) _then) = __$ConnectStatusResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ConnectStatusResponse.stripeAccountIdKey_) String? stripeAccountId,@JsonKey(name: ConnectStatusResponse.accountStatusKey_) String accountStatus,@JsonKey(name: ConnectStatusResponse.chargesEnabledKey_) bool chargesEnabled,@JsonKey(name: ConnectStatusResponse.payoutsEnabledKey_) bool payoutsEnabled,@JsonKey(name: ConnectStatusResponse.detailsSubmittedKey_) bool detailsSubmitted,@JsonKey(name: ConnectStatusResponse.currentlyDueKey_) List<String>? currentlyDue,@JsonKey(name: ConnectStatusResponse.pastDueKey_) List<String>? pastDue,@JsonKey(name: ConnectStatusResponse.disabledReasonKey_) String? disabledReason
});




}
/// @nodoc
class __$ConnectStatusResponseCopyWithImpl<$Res>
    implements _$ConnectStatusResponseCopyWith<$Res> {
  __$ConnectStatusResponseCopyWithImpl(this._self, this._then);

  final _ConnectStatusResponse _self;
  final $Res Function(_ConnectStatusResponse) _then;

/// Create a copy of ConnectStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stripeAccountId = freezed,Object? accountStatus = null,Object? chargesEnabled = null,Object? payoutsEnabled = null,Object? detailsSubmitted = null,Object? currentlyDue = freezed,Object? pastDue = freezed,Object? disabledReason = freezed,}) {
  return _then(_ConnectStatusResponse(
stripeAccountId: freezed == stripeAccountId ? _self.stripeAccountId : stripeAccountId // ignore: cast_nullable_to_non_nullable
as String?,accountStatus: null == accountStatus ? _self.accountStatus : accountStatus // ignore: cast_nullable_to_non_nullable
as String,chargesEnabled: null == chargesEnabled ? _self.chargesEnabled : chargesEnabled // ignore: cast_nullable_to_non_nullable
as bool,payoutsEnabled: null == payoutsEnabled ? _self.payoutsEnabled : payoutsEnabled // ignore: cast_nullable_to_non_nullable
as bool,detailsSubmitted: null == detailsSubmitted ? _self.detailsSubmitted : detailsSubmitted // ignore: cast_nullable_to_non_nullable
as bool,currentlyDue: freezed == currentlyDue ? _self._currentlyDue : currentlyDue // ignore: cast_nullable_to_non_nullable
as List<String>?,pastDue: freezed == pastDue ? _self._pastDue : pastDue // ignore: cast_nullable_to_non_nullable
as List<String>?,disabledReason: freezed == disabledReason ? _self.disabledReason : disabledReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
