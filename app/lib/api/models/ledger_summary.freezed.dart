// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ledger_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LedgerSummary {

/// totalInflow
@JsonKey(name: LedgerSummary.totalInflowKey_) String get totalInflow;/// totalOutflow
@JsonKey(name: LedgerSummary.totalOutflowKey_) String get totalOutflow;/// net
@JsonKey(name: LedgerSummary.netKey_) String get net;
/// Create a copy of LedgerSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LedgerSummaryCopyWith<LedgerSummary> get copyWith => _$LedgerSummaryCopyWithImpl<LedgerSummary>(this as LedgerSummary, _$identity);

  /// Serializes this LedgerSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LedgerSummary&&(identical(other.totalInflow, totalInflow) || other.totalInflow == totalInflow)&&(identical(other.totalOutflow, totalOutflow) || other.totalOutflow == totalOutflow)&&(identical(other.net, net) || other.net == net));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalInflow,totalOutflow,net);

@override
String toString() {
  return 'LedgerSummary(totalInflow: $totalInflow, totalOutflow: $totalOutflow, net: $net)';
}


}

/// @nodoc
abstract mixin class $LedgerSummaryCopyWith<$Res>  {
  factory $LedgerSummaryCopyWith(LedgerSummary value, $Res Function(LedgerSummary) _then) = _$LedgerSummaryCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: LedgerSummary.totalInflowKey_) String totalInflow,@JsonKey(name: LedgerSummary.totalOutflowKey_) String totalOutflow,@JsonKey(name: LedgerSummary.netKey_) String net
});




}
/// @nodoc
class _$LedgerSummaryCopyWithImpl<$Res>
    implements $LedgerSummaryCopyWith<$Res> {
  _$LedgerSummaryCopyWithImpl(this._self, this._then);

  final LedgerSummary _self;
  final $Res Function(LedgerSummary) _then;

/// Create a copy of LedgerSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalInflow = null,Object? totalOutflow = null,Object? net = null,}) {
  return _then(_self.copyWith(
totalInflow: null == totalInflow ? _self.totalInflow : totalInflow // ignore: cast_nullable_to_non_nullable
as String,totalOutflow: null == totalOutflow ? _self.totalOutflow : totalOutflow // ignore: cast_nullable_to_non_nullable
as String,net: null == net ? _self.net : net // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LedgerSummary].
extension LedgerSummaryPatterns on LedgerSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LedgerSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LedgerSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LedgerSummary value)  $default,){
final _that = this;
switch (_that) {
case _LedgerSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LedgerSummary value)?  $default,){
final _that = this;
switch (_that) {
case _LedgerSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: LedgerSummary.totalInflowKey_)  String totalInflow, @JsonKey(name: LedgerSummary.totalOutflowKey_)  String totalOutflow, @JsonKey(name: LedgerSummary.netKey_)  String net)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LedgerSummary() when $default != null:
return $default(_that.totalInflow,_that.totalOutflow,_that.net);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: LedgerSummary.totalInflowKey_)  String totalInflow, @JsonKey(name: LedgerSummary.totalOutflowKey_)  String totalOutflow, @JsonKey(name: LedgerSummary.netKey_)  String net)  $default,) {final _that = this;
switch (_that) {
case _LedgerSummary():
return $default(_that.totalInflow,_that.totalOutflow,_that.net);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: LedgerSummary.totalInflowKey_)  String totalInflow, @JsonKey(name: LedgerSummary.totalOutflowKey_)  String totalOutflow, @JsonKey(name: LedgerSummary.netKey_)  String net)?  $default,) {final _that = this;
switch (_that) {
case _LedgerSummary() when $default != null:
return $default(_that.totalInflow,_that.totalOutflow,_that.net);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _LedgerSummary extends LedgerSummary {
  const _LedgerSummary({@JsonKey(name: LedgerSummary.totalInflowKey_) required this.totalInflow, @JsonKey(name: LedgerSummary.totalOutflowKey_) required this.totalOutflow, @JsonKey(name: LedgerSummary.netKey_) required this.net}): super._();
  factory _LedgerSummary.fromJson(Map<String, dynamic> json) => _$LedgerSummaryFromJson(json);

/// totalInflow
@override@JsonKey(name: LedgerSummary.totalInflowKey_) final  String totalInflow;
/// totalOutflow
@override@JsonKey(name: LedgerSummary.totalOutflowKey_) final  String totalOutflow;
/// net
@override@JsonKey(name: LedgerSummary.netKey_) final  String net;

/// Create a copy of LedgerSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LedgerSummaryCopyWith<_LedgerSummary> get copyWith => __$LedgerSummaryCopyWithImpl<_LedgerSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LedgerSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LedgerSummary&&(identical(other.totalInflow, totalInflow) || other.totalInflow == totalInflow)&&(identical(other.totalOutflow, totalOutflow) || other.totalOutflow == totalOutflow)&&(identical(other.net, net) || other.net == net));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalInflow,totalOutflow,net);

@override
String toString() {
  return 'LedgerSummary(totalInflow: $totalInflow, totalOutflow: $totalOutflow, net: $net)';
}


}

/// @nodoc
abstract mixin class _$LedgerSummaryCopyWith<$Res> implements $LedgerSummaryCopyWith<$Res> {
  factory _$LedgerSummaryCopyWith(_LedgerSummary value, $Res Function(_LedgerSummary) _then) = __$LedgerSummaryCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: LedgerSummary.totalInflowKey_) String totalInflow,@JsonKey(name: LedgerSummary.totalOutflowKey_) String totalOutflow,@JsonKey(name: LedgerSummary.netKey_) String net
});




}
/// @nodoc
class __$LedgerSummaryCopyWithImpl<$Res>
    implements _$LedgerSummaryCopyWith<$Res> {
  __$LedgerSummaryCopyWithImpl(this._self, this._then);

  final _LedgerSummary _self;
  final $Res Function(_LedgerSummary) _then;

/// Create a copy of LedgerSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalInflow = null,Object? totalOutflow = null,Object? net = null,}) {
  return _then(_LedgerSummary(
totalInflow: null == totalInflow ? _self.totalInflow : totalInflow // ignore: cast_nullable_to_non_nullable
as String,totalOutflow: null == totalOutflow ? _self.totalOutflow : totalOutflow // ignore: cast_nullable_to_non_nullable
as String,net: null == net ? _self.net : net // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
