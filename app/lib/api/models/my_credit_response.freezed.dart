// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'my_credit_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MyCreditResponse {

/// balanceEur
@JsonKey(name: MyCreditResponse.balanceEurKey_) String get balanceEur;/// maxDiscountPercent
@JsonKey(name: MyCreditResponse.maxDiscountPercentKey_) int get maxDiscountPercent;/// items
@JsonKey(name: MyCreditResponse.itemsKey_) List<CreditHistoryItem> get items;
/// Create a copy of MyCreditResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MyCreditResponseCopyWith<MyCreditResponse> get copyWith => _$MyCreditResponseCopyWithImpl<MyCreditResponse>(this as MyCreditResponse, _$identity);

  /// Serializes this MyCreditResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MyCreditResponse&&(identical(other.balanceEur, balanceEur) || other.balanceEur == balanceEur)&&(identical(other.maxDiscountPercent, maxDiscountPercent) || other.maxDiscountPercent == maxDiscountPercent)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,balanceEur,maxDiscountPercent,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'MyCreditResponse(balanceEur: $balanceEur, maxDiscountPercent: $maxDiscountPercent, items: $items)';
}


}

/// @nodoc
abstract mixin class $MyCreditResponseCopyWith<$Res>  {
  factory $MyCreditResponseCopyWith(MyCreditResponse value, $Res Function(MyCreditResponse) _then) = _$MyCreditResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: MyCreditResponse.balanceEurKey_) String balanceEur,@JsonKey(name: MyCreditResponse.maxDiscountPercentKey_) int maxDiscountPercent,@JsonKey(name: MyCreditResponse.itemsKey_) List<CreditHistoryItem> items
});




}
/// @nodoc
class _$MyCreditResponseCopyWithImpl<$Res>
    implements $MyCreditResponseCopyWith<$Res> {
  _$MyCreditResponseCopyWithImpl(this._self, this._then);

  final MyCreditResponse _self;
  final $Res Function(MyCreditResponse) _then;

/// Create a copy of MyCreditResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? balanceEur = null,Object? maxDiscountPercent = null,Object? items = null,}) {
  return _then(_self.copyWith(
balanceEur: null == balanceEur ? _self.balanceEur : balanceEur // ignore: cast_nullable_to_non_nullable
as String,maxDiscountPercent: null == maxDiscountPercent ? _self.maxDiscountPercent : maxDiscountPercent // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<CreditHistoryItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [MyCreditResponse].
extension MyCreditResponsePatterns on MyCreditResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MyCreditResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MyCreditResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MyCreditResponse value)  $default,){
final _that = this;
switch (_that) {
case _MyCreditResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MyCreditResponse value)?  $default,){
final _that = this;
switch (_that) {
case _MyCreditResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: MyCreditResponse.balanceEurKey_)  String balanceEur, @JsonKey(name: MyCreditResponse.maxDiscountPercentKey_)  int maxDiscountPercent, @JsonKey(name: MyCreditResponse.itemsKey_)  List<CreditHistoryItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MyCreditResponse() when $default != null:
return $default(_that.balanceEur,_that.maxDiscountPercent,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: MyCreditResponse.balanceEurKey_)  String balanceEur, @JsonKey(name: MyCreditResponse.maxDiscountPercentKey_)  int maxDiscountPercent, @JsonKey(name: MyCreditResponse.itemsKey_)  List<CreditHistoryItem> items)  $default,) {final _that = this;
switch (_that) {
case _MyCreditResponse():
return $default(_that.balanceEur,_that.maxDiscountPercent,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: MyCreditResponse.balanceEurKey_)  String balanceEur, @JsonKey(name: MyCreditResponse.maxDiscountPercentKey_)  int maxDiscountPercent, @JsonKey(name: MyCreditResponse.itemsKey_)  List<CreditHistoryItem> items)?  $default,) {final _that = this;
switch (_that) {
case _MyCreditResponse() when $default != null:
return $default(_that.balanceEur,_that.maxDiscountPercent,_that.items);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _MyCreditResponse extends MyCreditResponse {
  const _MyCreditResponse({@JsonKey(name: MyCreditResponse.balanceEurKey_) required this.balanceEur, @JsonKey(name: MyCreditResponse.maxDiscountPercentKey_) required this.maxDiscountPercent, @JsonKey(name: MyCreditResponse.itemsKey_) required final  List<CreditHistoryItem> items}): _items = items,super._();
  factory _MyCreditResponse.fromJson(Map<String, dynamic> json) => _$MyCreditResponseFromJson(json);

/// balanceEur
@override@JsonKey(name: MyCreditResponse.balanceEurKey_) final  String balanceEur;
/// maxDiscountPercent
@override@JsonKey(name: MyCreditResponse.maxDiscountPercentKey_) final  int maxDiscountPercent;
/// items
 final  List<CreditHistoryItem> _items;
/// items
@override@JsonKey(name: MyCreditResponse.itemsKey_) List<CreditHistoryItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of MyCreditResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MyCreditResponseCopyWith<_MyCreditResponse> get copyWith => __$MyCreditResponseCopyWithImpl<_MyCreditResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MyCreditResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MyCreditResponse&&(identical(other.balanceEur, balanceEur) || other.balanceEur == balanceEur)&&(identical(other.maxDiscountPercent, maxDiscountPercent) || other.maxDiscountPercent == maxDiscountPercent)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,balanceEur,maxDiscountPercent,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'MyCreditResponse(balanceEur: $balanceEur, maxDiscountPercent: $maxDiscountPercent, items: $items)';
}


}

/// @nodoc
abstract mixin class _$MyCreditResponseCopyWith<$Res> implements $MyCreditResponseCopyWith<$Res> {
  factory _$MyCreditResponseCopyWith(_MyCreditResponse value, $Res Function(_MyCreditResponse) _then) = __$MyCreditResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: MyCreditResponse.balanceEurKey_) String balanceEur,@JsonKey(name: MyCreditResponse.maxDiscountPercentKey_) int maxDiscountPercent,@JsonKey(name: MyCreditResponse.itemsKey_) List<CreditHistoryItem> items
});




}
/// @nodoc
class __$MyCreditResponseCopyWithImpl<$Res>
    implements _$MyCreditResponseCopyWith<$Res> {
  __$MyCreditResponseCopyWithImpl(this._self, this._then);

  final _MyCreditResponse _self;
  final $Res Function(_MyCreditResponse) _then;

/// Create a copy of MyCreditResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? balanceEur = null,Object? maxDiscountPercent = null,Object? items = null,}) {
  return _then(_MyCreditResponse(
balanceEur: null == balanceEur ? _self.balanceEur : balanceEur // ignore: cast_nullable_to_non_nullable
as String,maxDiscountPercent: null == maxDiscountPercent ? _self.maxDiscountPercent : maxDiscountPercent // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CreditHistoryItem>,
  ));
}


}

// dart format on
