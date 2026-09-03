// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dispute_create_v1_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DisputeCreateV1Request {

/// gigId
@JsonKey(name: DisputeCreateV1Request.gigIdKey_) String? get gigId;/// extraPurchaseId
@JsonKey(name: DisputeCreateV1Request.extraPurchaseIdKey_) String? get extraPurchaseId;/// category
@JsonKey(name: DisputeCreateV1Request.categoryKey_) DisputeCategory get category;/// reason
@JsonKey(name: DisputeCreateV1Request.reasonKey_) String? get reason;/// summary
@JsonKey(name: DisputeCreateV1Request.summaryKey_) String? get summary;/// requestedRefundAmount
@JsonKey(name: DisputeCreateV1Request.requestedRefundAmountKey_) dynamic? get requestedRefundAmount;/// currency
@JsonKey(name: DisputeCreateV1Request.currencyKey_) String get currency;
/// Create a copy of DisputeCreateV1Request
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DisputeCreateV1RequestCopyWith<DisputeCreateV1Request> get copyWith => _$DisputeCreateV1RequestCopyWithImpl<DisputeCreateV1Request>(this as DisputeCreateV1Request, _$identity);

  /// Serializes this DisputeCreateV1Request to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DisputeCreateV1Request&&(identical(other.gigId, gigId) || other.gigId == gigId)&&(identical(other.extraPurchaseId, extraPurchaseId) || other.extraPurchaseId == extraPurchaseId)&&(identical(other.category, category) || other.category == category)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other.requestedRefundAmount, requestedRefundAmount)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,gigId,extraPurchaseId,category,reason,summary,const DeepCollectionEquality().hash(requestedRefundAmount),currency);

@override
String toString() {
  return 'DisputeCreateV1Request(gigId: $gigId, extraPurchaseId: $extraPurchaseId, category: $category, reason: $reason, summary: $summary, requestedRefundAmount: $requestedRefundAmount, currency: $currency)';
}


}

/// @nodoc
abstract mixin class $DisputeCreateV1RequestCopyWith<$Res>  {
  factory $DisputeCreateV1RequestCopyWith(DisputeCreateV1Request value, $Res Function(DisputeCreateV1Request) _then) = _$DisputeCreateV1RequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: DisputeCreateV1Request.gigIdKey_) String? gigId,@JsonKey(name: DisputeCreateV1Request.extraPurchaseIdKey_) String? extraPurchaseId,@JsonKey(name: DisputeCreateV1Request.categoryKey_) DisputeCategory category,@JsonKey(name: DisputeCreateV1Request.reasonKey_) String? reason,@JsonKey(name: DisputeCreateV1Request.summaryKey_) String? summary,@JsonKey(name: DisputeCreateV1Request.requestedRefundAmountKey_) dynamic? requestedRefundAmount,@JsonKey(name: DisputeCreateV1Request.currencyKey_) String currency
});




}
/// @nodoc
class _$DisputeCreateV1RequestCopyWithImpl<$Res>
    implements $DisputeCreateV1RequestCopyWith<$Res> {
  _$DisputeCreateV1RequestCopyWithImpl(this._self, this._then);

  final DisputeCreateV1Request _self;
  final $Res Function(DisputeCreateV1Request) _then;

/// Create a copy of DisputeCreateV1Request
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? gigId = freezed,Object? extraPurchaseId = freezed,Object? category = null,Object? reason = freezed,Object? summary = freezed,Object? requestedRefundAmount = freezed,Object? currency = null,}) {
  return _then(_self.copyWith(
gigId: freezed == gigId ? _self.gigId : gigId // ignore: cast_nullable_to_non_nullable
as String?,extraPurchaseId: freezed == extraPurchaseId ? _self.extraPurchaseId : extraPurchaseId // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as DisputeCategory,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,requestedRefundAmount: freezed == requestedRefundAmount ? _self.requestedRefundAmount : requestedRefundAmount // ignore: cast_nullable_to_non_nullable
as dynamic?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DisputeCreateV1Request].
extension DisputeCreateV1RequestPatterns on DisputeCreateV1Request {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DisputeCreateV1Request value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DisputeCreateV1Request() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DisputeCreateV1Request value)  $default,){
final _that = this;
switch (_that) {
case _DisputeCreateV1Request():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DisputeCreateV1Request value)?  $default,){
final _that = this;
switch (_that) {
case _DisputeCreateV1Request() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: DisputeCreateV1Request.gigIdKey_)  String? gigId, @JsonKey(name: DisputeCreateV1Request.extraPurchaseIdKey_)  String? extraPurchaseId, @JsonKey(name: DisputeCreateV1Request.categoryKey_)  DisputeCategory category, @JsonKey(name: DisputeCreateV1Request.reasonKey_)  String? reason, @JsonKey(name: DisputeCreateV1Request.summaryKey_)  String? summary, @JsonKey(name: DisputeCreateV1Request.requestedRefundAmountKey_)  dynamic? requestedRefundAmount, @JsonKey(name: DisputeCreateV1Request.currencyKey_)  String currency)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DisputeCreateV1Request() when $default != null:
return $default(_that.gigId,_that.extraPurchaseId,_that.category,_that.reason,_that.summary,_that.requestedRefundAmount,_that.currency);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: DisputeCreateV1Request.gigIdKey_)  String? gigId, @JsonKey(name: DisputeCreateV1Request.extraPurchaseIdKey_)  String? extraPurchaseId, @JsonKey(name: DisputeCreateV1Request.categoryKey_)  DisputeCategory category, @JsonKey(name: DisputeCreateV1Request.reasonKey_)  String? reason, @JsonKey(name: DisputeCreateV1Request.summaryKey_)  String? summary, @JsonKey(name: DisputeCreateV1Request.requestedRefundAmountKey_)  dynamic? requestedRefundAmount, @JsonKey(name: DisputeCreateV1Request.currencyKey_)  String currency)  $default,) {final _that = this;
switch (_that) {
case _DisputeCreateV1Request():
return $default(_that.gigId,_that.extraPurchaseId,_that.category,_that.reason,_that.summary,_that.requestedRefundAmount,_that.currency);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: DisputeCreateV1Request.gigIdKey_)  String? gigId, @JsonKey(name: DisputeCreateV1Request.extraPurchaseIdKey_)  String? extraPurchaseId, @JsonKey(name: DisputeCreateV1Request.categoryKey_)  DisputeCategory category, @JsonKey(name: DisputeCreateV1Request.reasonKey_)  String? reason, @JsonKey(name: DisputeCreateV1Request.summaryKey_)  String? summary, @JsonKey(name: DisputeCreateV1Request.requestedRefundAmountKey_)  dynamic? requestedRefundAmount, @JsonKey(name: DisputeCreateV1Request.currencyKey_)  String currency)?  $default,) {final _that = this;
switch (_that) {
case _DisputeCreateV1Request() when $default != null:
return $default(_that.gigId,_that.extraPurchaseId,_that.category,_that.reason,_that.summary,_that.requestedRefundAmount,_that.currency);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _DisputeCreateV1Request extends DisputeCreateV1Request {
  const _DisputeCreateV1Request({@JsonKey(name: DisputeCreateV1Request.gigIdKey_) this.gigId, @JsonKey(name: DisputeCreateV1Request.extraPurchaseIdKey_) this.extraPurchaseId, @JsonKey(name: DisputeCreateV1Request.categoryKey_) required this.category, @JsonKey(name: DisputeCreateV1Request.reasonKey_) this.reason, @JsonKey(name: DisputeCreateV1Request.summaryKey_) this.summary, @JsonKey(name: DisputeCreateV1Request.requestedRefundAmountKey_) this.requestedRefundAmount, @JsonKey(name: DisputeCreateV1Request.currencyKey_) this.currency = 'EUR'}): super._();
  factory _DisputeCreateV1Request.fromJson(Map<String, dynamic> json) => _$DisputeCreateV1RequestFromJson(json);

/// gigId
@override@JsonKey(name: DisputeCreateV1Request.gigIdKey_) final  String? gigId;
/// extraPurchaseId
@override@JsonKey(name: DisputeCreateV1Request.extraPurchaseIdKey_) final  String? extraPurchaseId;
/// category
@override@JsonKey(name: DisputeCreateV1Request.categoryKey_) final  DisputeCategory category;
/// reason
@override@JsonKey(name: DisputeCreateV1Request.reasonKey_) final  String? reason;
/// summary
@override@JsonKey(name: DisputeCreateV1Request.summaryKey_) final  String? summary;
/// requestedRefundAmount
@override@JsonKey(name: DisputeCreateV1Request.requestedRefundAmountKey_) final  dynamic? requestedRefundAmount;
/// currency
@override@JsonKey(name: DisputeCreateV1Request.currencyKey_) final  String currency;

/// Create a copy of DisputeCreateV1Request
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DisputeCreateV1RequestCopyWith<_DisputeCreateV1Request> get copyWith => __$DisputeCreateV1RequestCopyWithImpl<_DisputeCreateV1Request>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DisputeCreateV1RequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DisputeCreateV1Request&&(identical(other.gigId, gigId) || other.gigId == gigId)&&(identical(other.extraPurchaseId, extraPurchaseId) || other.extraPurchaseId == extraPurchaseId)&&(identical(other.category, category) || other.category == category)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other.requestedRefundAmount, requestedRefundAmount)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,gigId,extraPurchaseId,category,reason,summary,const DeepCollectionEquality().hash(requestedRefundAmount),currency);

@override
String toString() {
  return 'DisputeCreateV1Request(gigId: $gigId, extraPurchaseId: $extraPurchaseId, category: $category, reason: $reason, summary: $summary, requestedRefundAmount: $requestedRefundAmount, currency: $currency)';
}


}

/// @nodoc
abstract mixin class _$DisputeCreateV1RequestCopyWith<$Res> implements $DisputeCreateV1RequestCopyWith<$Res> {
  factory _$DisputeCreateV1RequestCopyWith(_DisputeCreateV1Request value, $Res Function(_DisputeCreateV1Request) _then) = __$DisputeCreateV1RequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: DisputeCreateV1Request.gigIdKey_) String? gigId,@JsonKey(name: DisputeCreateV1Request.extraPurchaseIdKey_) String? extraPurchaseId,@JsonKey(name: DisputeCreateV1Request.categoryKey_) DisputeCategory category,@JsonKey(name: DisputeCreateV1Request.reasonKey_) String? reason,@JsonKey(name: DisputeCreateV1Request.summaryKey_) String? summary,@JsonKey(name: DisputeCreateV1Request.requestedRefundAmountKey_) dynamic? requestedRefundAmount,@JsonKey(name: DisputeCreateV1Request.currencyKey_) String currency
});




}
/// @nodoc
class __$DisputeCreateV1RequestCopyWithImpl<$Res>
    implements _$DisputeCreateV1RequestCopyWith<$Res> {
  __$DisputeCreateV1RequestCopyWithImpl(this._self, this._then);

  final _DisputeCreateV1Request _self;
  final $Res Function(_DisputeCreateV1Request) _then;

/// Create a copy of DisputeCreateV1Request
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? gigId = freezed,Object? extraPurchaseId = freezed,Object? category = null,Object? reason = freezed,Object? summary = freezed,Object? requestedRefundAmount = freezed,Object? currency = null,}) {
  return _then(_DisputeCreateV1Request(
gigId: freezed == gigId ? _self.gigId : gigId // ignore: cast_nullable_to_non_nullable
as String?,extraPurchaseId: freezed == extraPurchaseId ? _self.extraPurchaseId : extraPurchaseId // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as DisputeCategory,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,requestedRefundAmount: freezed == requestedRefundAmount ? _self.requestedRefundAmount : requestedRefundAmount // ignore: cast_nullable_to_non_nullable
as dynamic?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
