// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MatchRequest {

/// city
@JsonKey(name: MatchRequest.cityKey_) String? get city;/// styles
@JsonKey(name: MatchRequest.stylesKey_) List<String>? get styles;/// budget
@JsonKey(name: MatchRequest.budgetKey_) dynamic? get budget;/// dateRange
@JsonKey(name: MatchRequest.dateRangeKey_) Map<String, dynamic>? get dateRange;/// purpose
@JsonKey(name: MatchRequest.purposeKey_) String? get purpose;/// limit
@JsonKey(name: MatchRequest.limitKey_) int get limit;
/// Create a copy of MatchRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MatchRequestCopyWith<MatchRequest> get copyWith => _$MatchRequestCopyWithImpl<MatchRequest>(this as MatchRequest, _$identity);

  /// Serializes this MatchRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MatchRequest&&(identical(other.city, city) || other.city == city)&&const DeepCollectionEquality().equals(other.styles, styles)&&const DeepCollectionEquality().equals(other.budget, budget)&&const DeepCollectionEquality().equals(other.dateRange, dateRange)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,city,const DeepCollectionEquality().hash(styles),const DeepCollectionEquality().hash(budget),const DeepCollectionEquality().hash(dateRange),purpose,limit);

@override
String toString() {
  return 'MatchRequest(city: $city, styles: $styles, budget: $budget, dateRange: $dateRange, purpose: $purpose, limit: $limit)';
}


}

/// @nodoc
abstract mixin class $MatchRequestCopyWith<$Res>  {
  factory $MatchRequestCopyWith(MatchRequest value, $Res Function(MatchRequest) _then) = _$MatchRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: MatchRequest.cityKey_) String? city,@JsonKey(name: MatchRequest.stylesKey_) List<String>? styles,@JsonKey(name: MatchRequest.budgetKey_) dynamic? budget,@JsonKey(name: MatchRequest.dateRangeKey_) Map<String, dynamic>? dateRange,@JsonKey(name: MatchRequest.purposeKey_) String? purpose,@JsonKey(name: MatchRequest.limitKey_) int limit
});




}
/// @nodoc
class _$MatchRequestCopyWithImpl<$Res>
    implements $MatchRequestCopyWith<$Res> {
  _$MatchRequestCopyWithImpl(this._self, this._then);

  final MatchRequest _self;
  final $Res Function(MatchRequest) _then;

/// Create a copy of MatchRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? city = freezed,Object? styles = freezed,Object? budget = freezed,Object? dateRange = freezed,Object? purpose = freezed,Object? limit = null,}) {
  return _then(_self.copyWith(
city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,styles: freezed == styles ? _self.styles : styles // ignore: cast_nullable_to_non_nullable
as List<String>?,budget: freezed == budget ? _self.budget : budget // ignore: cast_nullable_to_non_nullable
as dynamic?,dateRange: freezed == dateRange ? _self.dateRange : dateRange // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,purpose: freezed == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String?,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MatchRequest].
extension MatchRequestPatterns on MatchRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MatchRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MatchRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MatchRequest value)  $default,){
final _that = this;
switch (_that) {
case _MatchRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MatchRequest value)?  $default,){
final _that = this;
switch (_that) {
case _MatchRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: MatchRequest.cityKey_)  String? city, @JsonKey(name: MatchRequest.stylesKey_)  List<String>? styles, @JsonKey(name: MatchRequest.budgetKey_)  dynamic? budget, @JsonKey(name: MatchRequest.dateRangeKey_)  Map<String, dynamic>? dateRange, @JsonKey(name: MatchRequest.purposeKey_)  String? purpose, @JsonKey(name: MatchRequest.limitKey_)  int limit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MatchRequest() when $default != null:
return $default(_that.city,_that.styles,_that.budget,_that.dateRange,_that.purpose,_that.limit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: MatchRequest.cityKey_)  String? city, @JsonKey(name: MatchRequest.stylesKey_)  List<String>? styles, @JsonKey(name: MatchRequest.budgetKey_)  dynamic? budget, @JsonKey(name: MatchRequest.dateRangeKey_)  Map<String, dynamic>? dateRange, @JsonKey(name: MatchRequest.purposeKey_)  String? purpose, @JsonKey(name: MatchRequest.limitKey_)  int limit)  $default,) {final _that = this;
switch (_that) {
case _MatchRequest():
return $default(_that.city,_that.styles,_that.budget,_that.dateRange,_that.purpose,_that.limit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: MatchRequest.cityKey_)  String? city, @JsonKey(name: MatchRequest.stylesKey_)  List<String>? styles, @JsonKey(name: MatchRequest.budgetKey_)  dynamic? budget, @JsonKey(name: MatchRequest.dateRangeKey_)  Map<String, dynamic>? dateRange, @JsonKey(name: MatchRequest.purposeKey_)  String? purpose, @JsonKey(name: MatchRequest.limitKey_)  int limit)?  $default,) {final _that = this;
switch (_that) {
case _MatchRequest() when $default != null:
return $default(_that.city,_that.styles,_that.budget,_that.dateRange,_that.purpose,_that.limit);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _MatchRequest extends MatchRequest {
  const _MatchRequest({@JsonKey(name: MatchRequest.cityKey_) this.city, @JsonKey(name: MatchRequest.stylesKey_) final  List<String>? styles, @JsonKey(name: MatchRequest.budgetKey_) this.budget, @JsonKey(name: MatchRequest.dateRangeKey_) final  Map<String, dynamic>? dateRange, @JsonKey(name: MatchRequest.purposeKey_) this.purpose, @JsonKey(name: MatchRequest.limitKey_) this.limit = 10}): _styles = styles,_dateRange = dateRange,super._();
  factory _MatchRequest.fromJson(Map<String, dynamic> json) => _$MatchRequestFromJson(json);

/// city
@override@JsonKey(name: MatchRequest.cityKey_) final  String? city;
/// styles
 final  List<String>? _styles;
/// styles
@override@JsonKey(name: MatchRequest.stylesKey_) List<String>? get styles {
  final value = _styles;
  if (value == null) return null;
  if (_styles is EqualUnmodifiableListView) return _styles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// budget
@override@JsonKey(name: MatchRequest.budgetKey_) final  dynamic? budget;
/// dateRange
 final  Map<String, dynamic>? _dateRange;
/// dateRange
@override@JsonKey(name: MatchRequest.dateRangeKey_) Map<String, dynamic>? get dateRange {
  final value = _dateRange;
  if (value == null) return null;
  if (_dateRange is EqualUnmodifiableMapView) return _dateRange;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// purpose
@override@JsonKey(name: MatchRequest.purposeKey_) final  String? purpose;
/// limit
@override@JsonKey(name: MatchRequest.limitKey_) final  int limit;

/// Create a copy of MatchRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MatchRequestCopyWith<_MatchRequest> get copyWith => __$MatchRequestCopyWithImpl<_MatchRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MatchRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MatchRequest&&(identical(other.city, city) || other.city == city)&&const DeepCollectionEquality().equals(other._styles, _styles)&&const DeepCollectionEquality().equals(other.budget, budget)&&const DeepCollectionEquality().equals(other._dateRange, _dateRange)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,city,const DeepCollectionEquality().hash(_styles),const DeepCollectionEquality().hash(budget),const DeepCollectionEquality().hash(_dateRange),purpose,limit);

@override
String toString() {
  return 'MatchRequest(city: $city, styles: $styles, budget: $budget, dateRange: $dateRange, purpose: $purpose, limit: $limit)';
}


}

/// @nodoc
abstract mixin class _$MatchRequestCopyWith<$Res> implements $MatchRequestCopyWith<$Res> {
  factory _$MatchRequestCopyWith(_MatchRequest value, $Res Function(_MatchRequest) _then) = __$MatchRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: MatchRequest.cityKey_) String? city,@JsonKey(name: MatchRequest.stylesKey_) List<String>? styles,@JsonKey(name: MatchRequest.budgetKey_) dynamic? budget,@JsonKey(name: MatchRequest.dateRangeKey_) Map<String, dynamic>? dateRange,@JsonKey(name: MatchRequest.purposeKey_) String? purpose,@JsonKey(name: MatchRequest.limitKey_) int limit
});




}
/// @nodoc
class __$MatchRequestCopyWithImpl<$Res>
    implements _$MatchRequestCopyWith<$Res> {
  __$MatchRequestCopyWithImpl(this._self, this._then);

  final _MatchRequest _self;
  final $Res Function(_MatchRequest) _then;

/// Create a copy of MatchRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? city = freezed,Object? styles = freezed,Object? budget = freezed,Object? dateRange = freezed,Object? purpose = freezed,Object? limit = null,}) {
  return _then(_MatchRequest(
city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,styles: freezed == styles ? _self._styles : styles // ignore: cast_nullable_to_non_nullable
as List<String>?,budget: freezed == budget ? _self.budget : budget // ignore: cast_nullable_to_non_nullable
as dynamic?,dateRange: freezed == dateRange ? _self._dateRange : dateRange // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,purpose: freezed == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String?,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
