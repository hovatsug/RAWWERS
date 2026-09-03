// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_gig_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateGigRequest {

/// proUserId
@JsonKey(name: CreateGigRequest.proUserIdKey_) String get proUserId;/// nicheId
@JsonKey(name: CreateGigRequest.nicheIdKey_) String? get nicheId;/// amountTotal
@JsonKey(name: CreateGigRequest.amountTotalKey_) dynamic get amountTotal;/// currency
@JsonKey(name: CreateGigRequest.currencyKey_) String get currency;/// locationText
@JsonKey(name: CreateGigRequest.locationTextKey_) String? get locationText;/// scheduledStart
@JsonKey(name: CreateGigRequest.scheduledStartKey_) DateTime? get scheduledStart;/// scheduledEnd
@JsonKey(name: CreateGigRequest.scheduledEndKey_) DateTime? get scheduledEnd;
/// Create a copy of CreateGigRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateGigRequestCopyWith<CreateGigRequest> get copyWith => _$CreateGigRequestCopyWithImpl<CreateGigRequest>(this as CreateGigRequest, _$identity);

  /// Serializes this CreateGigRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateGigRequest&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.nicheId, nicheId) || other.nicheId == nicheId)&&const DeepCollectionEquality().equals(other.amountTotal, amountTotal)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.locationText, locationText) || other.locationText == locationText)&&(identical(other.scheduledStart, scheduledStart) || other.scheduledStart == scheduledStart)&&(identical(other.scheduledEnd, scheduledEnd) || other.scheduledEnd == scheduledEnd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,proUserId,nicheId,const DeepCollectionEquality().hash(amountTotal),currency,locationText,scheduledStart,scheduledEnd);

@override
String toString() {
  return 'CreateGigRequest(proUserId: $proUserId, nicheId: $nicheId, amountTotal: $amountTotal, currency: $currency, locationText: $locationText, scheduledStart: $scheduledStart, scheduledEnd: $scheduledEnd)';
}


}

/// @nodoc
abstract mixin class $CreateGigRequestCopyWith<$Res>  {
  factory $CreateGigRequestCopyWith(CreateGigRequest value, $Res Function(CreateGigRequest) _then) = _$CreateGigRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: CreateGigRequest.proUserIdKey_) String proUserId,@JsonKey(name: CreateGigRequest.nicheIdKey_) String? nicheId,@JsonKey(name: CreateGigRequest.amountTotalKey_) dynamic amountTotal,@JsonKey(name: CreateGigRequest.currencyKey_) String currency,@JsonKey(name: CreateGigRequest.locationTextKey_) String? locationText,@JsonKey(name: CreateGigRequest.scheduledStartKey_) DateTime? scheduledStart,@JsonKey(name: CreateGigRequest.scheduledEndKey_) DateTime? scheduledEnd
});




}
/// @nodoc
class _$CreateGigRequestCopyWithImpl<$Res>
    implements $CreateGigRequestCopyWith<$Res> {
  _$CreateGigRequestCopyWithImpl(this._self, this._then);

  final CreateGigRequest _self;
  final $Res Function(CreateGigRequest) _then;

/// Create a copy of CreateGigRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? proUserId = null,Object? nicheId = freezed,Object? amountTotal = freezed,Object? currency = null,Object? locationText = freezed,Object? scheduledStart = freezed,Object? scheduledEnd = freezed,}) {
  return _then(_self.copyWith(
proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,nicheId: freezed == nicheId ? _self.nicheId : nicheId // ignore: cast_nullable_to_non_nullable
as String?,amountTotal: freezed == amountTotal ? _self.amountTotal : amountTotal // ignore: cast_nullable_to_non_nullable
as dynamic,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,locationText: freezed == locationText ? _self.locationText : locationText // ignore: cast_nullable_to_non_nullable
as String?,scheduledStart: freezed == scheduledStart ? _self.scheduledStart : scheduledStart // ignore: cast_nullable_to_non_nullable
as DateTime?,scheduledEnd: freezed == scheduledEnd ? _self.scheduledEnd : scheduledEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateGigRequest].
extension CreateGigRequestPatterns on CreateGigRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateGigRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateGigRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateGigRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateGigRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateGigRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateGigRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: CreateGigRequest.proUserIdKey_)  String proUserId, @JsonKey(name: CreateGigRequest.nicheIdKey_)  String? nicheId, @JsonKey(name: CreateGigRequest.amountTotalKey_)  dynamic amountTotal, @JsonKey(name: CreateGigRequest.currencyKey_)  String currency, @JsonKey(name: CreateGigRequest.locationTextKey_)  String? locationText, @JsonKey(name: CreateGigRequest.scheduledStartKey_)  DateTime? scheduledStart, @JsonKey(name: CreateGigRequest.scheduledEndKey_)  DateTime? scheduledEnd)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateGigRequest() when $default != null:
return $default(_that.proUserId,_that.nicheId,_that.amountTotal,_that.currency,_that.locationText,_that.scheduledStart,_that.scheduledEnd);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: CreateGigRequest.proUserIdKey_)  String proUserId, @JsonKey(name: CreateGigRequest.nicheIdKey_)  String? nicheId, @JsonKey(name: CreateGigRequest.amountTotalKey_)  dynamic amountTotal, @JsonKey(name: CreateGigRequest.currencyKey_)  String currency, @JsonKey(name: CreateGigRequest.locationTextKey_)  String? locationText, @JsonKey(name: CreateGigRequest.scheduledStartKey_)  DateTime? scheduledStart, @JsonKey(name: CreateGigRequest.scheduledEndKey_)  DateTime? scheduledEnd)  $default,) {final _that = this;
switch (_that) {
case _CreateGigRequest():
return $default(_that.proUserId,_that.nicheId,_that.amountTotal,_that.currency,_that.locationText,_that.scheduledStart,_that.scheduledEnd);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: CreateGigRequest.proUserIdKey_)  String proUserId, @JsonKey(name: CreateGigRequest.nicheIdKey_)  String? nicheId, @JsonKey(name: CreateGigRequest.amountTotalKey_)  dynamic amountTotal, @JsonKey(name: CreateGigRequest.currencyKey_)  String currency, @JsonKey(name: CreateGigRequest.locationTextKey_)  String? locationText, @JsonKey(name: CreateGigRequest.scheduledStartKey_)  DateTime? scheduledStart, @JsonKey(name: CreateGigRequest.scheduledEndKey_)  DateTime? scheduledEnd)?  $default,) {final _that = this;
switch (_that) {
case _CreateGigRequest() when $default != null:
return $default(_that.proUserId,_that.nicheId,_that.amountTotal,_that.currency,_that.locationText,_that.scheduledStart,_that.scheduledEnd);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _CreateGigRequest extends CreateGigRequest {
  const _CreateGigRequest({@JsonKey(name: CreateGigRequest.proUserIdKey_) required this.proUserId, @JsonKey(name: CreateGigRequest.nicheIdKey_) this.nicheId, @JsonKey(name: CreateGigRequest.amountTotalKey_) required this.amountTotal, @JsonKey(name: CreateGigRequest.currencyKey_) this.currency = 'EUR', @JsonKey(name: CreateGigRequest.locationTextKey_) this.locationText, @JsonKey(name: CreateGigRequest.scheduledStartKey_) this.scheduledStart, @JsonKey(name: CreateGigRequest.scheduledEndKey_) this.scheduledEnd}): super._();
  factory _CreateGigRequest.fromJson(Map<String, dynamic> json) => _$CreateGigRequestFromJson(json);

/// proUserId
@override@JsonKey(name: CreateGigRequest.proUserIdKey_) final  String proUserId;
/// nicheId
@override@JsonKey(name: CreateGigRequest.nicheIdKey_) final  String? nicheId;
/// amountTotal
@override@JsonKey(name: CreateGigRequest.amountTotalKey_) final  dynamic amountTotal;
/// currency
@override@JsonKey(name: CreateGigRequest.currencyKey_) final  String currency;
/// locationText
@override@JsonKey(name: CreateGigRequest.locationTextKey_) final  String? locationText;
/// scheduledStart
@override@JsonKey(name: CreateGigRequest.scheduledStartKey_) final  DateTime? scheduledStart;
/// scheduledEnd
@override@JsonKey(name: CreateGigRequest.scheduledEndKey_) final  DateTime? scheduledEnd;

/// Create a copy of CreateGigRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateGigRequestCopyWith<_CreateGigRequest> get copyWith => __$CreateGigRequestCopyWithImpl<_CreateGigRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateGigRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateGigRequest&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.nicheId, nicheId) || other.nicheId == nicheId)&&const DeepCollectionEquality().equals(other.amountTotal, amountTotal)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.locationText, locationText) || other.locationText == locationText)&&(identical(other.scheduledStart, scheduledStart) || other.scheduledStart == scheduledStart)&&(identical(other.scheduledEnd, scheduledEnd) || other.scheduledEnd == scheduledEnd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,proUserId,nicheId,const DeepCollectionEquality().hash(amountTotal),currency,locationText,scheduledStart,scheduledEnd);

@override
String toString() {
  return 'CreateGigRequest(proUserId: $proUserId, nicheId: $nicheId, amountTotal: $amountTotal, currency: $currency, locationText: $locationText, scheduledStart: $scheduledStart, scheduledEnd: $scheduledEnd)';
}


}

/// @nodoc
abstract mixin class _$CreateGigRequestCopyWith<$Res> implements $CreateGigRequestCopyWith<$Res> {
  factory _$CreateGigRequestCopyWith(_CreateGigRequest value, $Res Function(_CreateGigRequest) _then) = __$CreateGigRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: CreateGigRequest.proUserIdKey_) String proUserId,@JsonKey(name: CreateGigRequest.nicheIdKey_) String? nicheId,@JsonKey(name: CreateGigRequest.amountTotalKey_) dynamic amountTotal,@JsonKey(name: CreateGigRequest.currencyKey_) String currency,@JsonKey(name: CreateGigRequest.locationTextKey_) String? locationText,@JsonKey(name: CreateGigRequest.scheduledStartKey_) DateTime? scheduledStart,@JsonKey(name: CreateGigRequest.scheduledEndKey_) DateTime? scheduledEnd
});




}
/// @nodoc
class __$CreateGigRequestCopyWithImpl<$Res>
    implements _$CreateGigRequestCopyWith<$Res> {
  __$CreateGigRequestCopyWithImpl(this._self, this._then);

  final _CreateGigRequest _self;
  final $Res Function(_CreateGigRequest) _then;

/// Create a copy of CreateGigRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? proUserId = null,Object? nicheId = freezed,Object? amountTotal = freezed,Object? currency = null,Object? locationText = freezed,Object? scheduledStart = freezed,Object? scheduledEnd = freezed,}) {
  return _then(_CreateGigRequest(
proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,nicheId: freezed == nicheId ? _self.nicheId : nicheId // ignore: cast_nullable_to_non_nullable
as String?,amountTotal: freezed == amountTotal ? _self.amountTotal : amountTotal // ignore: cast_nullable_to_non_nullable
as dynamic,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,locationText: freezed == locationText ? _self.locationText : locationText // ignore: cast_nullable_to_non_nullable
as String?,scheduledStart: freezed == scheduledStart ? _self.scheduledStart : scheduledStart // ignore: cast_nullable_to_non_nullable
as DateTime?,scheduledEnd: freezed == scheduledEnd ? _self.scheduledEnd : scheduledEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
