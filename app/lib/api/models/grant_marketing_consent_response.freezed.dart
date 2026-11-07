// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'grant_marketing_consent_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GrantMarketingConsentResponse {

/// items
@JsonKey(name: GrantMarketingConsentResponse.itemsKey_) List<MarketingConsentView> get items;/// credit
@JsonKey(name: GrantMarketingConsentResponse.creditKey_) int get credit;/// creditEur
@JsonKey(name: GrantMarketingConsentResponse.creditEurKey_) String get creditEur;
/// Create a copy of GrantMarketingConsentResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GrantMarketingConsentResponseCopyWith<GrantMarketingConsentResponse> get copyWith => _$GrantMarketingConsentResponseCopyWithImpl<GrantMarketingConsentResponse>(this as GrantMarketingConsentResponse, _$identity);

  /// Serializes this GrantMarketingConsentResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GrantMarketingConsentResponse&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.credit, credit) || other.credit == credit)&&(identical(other.creditEur, creditEur) || other.creditEur == creditEur));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),credit,creditEur);

@override
String toString() {
  return 'GrantMarketingConsentResponse(items: $items, credit: $credit, creditEur: $creditEur)';
}


}

/// @nodoc
abstract mixin class $GrantMarketingConsentResponseCopyWith<$Res>  {
  factory $GrantMarketingConsentResponseCopyWith(GrantMarketingConsentResponse value, $Res Function(GrantMarketingConsentResponse) _then) = _$GrantMarketingConsentResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: GrantMarketingConsentResponse.itemsKey_) List<MarketingConsentView> items,@JsonKey(name: GrantMarketingConsentResponse.creditKey_) int credit,@JsonKey(name: GrantMarketingConsentResponse.creditEurKey_) String creditEur
});




}
/// @nodoc
class _$GrantMarketingConsentResponseCopyWithImpl<$Res>
    implements $GrantMarketingConsentResponseCopyWith<$Res> {
  _$GrantMarketingConsentResponseCopyWithImpl(this._self, this._then);

  final GrantMarketingConsentResponse _self;
  final $Res Function(GrantMarketingConsentResponse) _then;

/// Create a copy of GrantMarketingConsentResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? credit = null,Object? creditEur = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<MarketingConsentView>,credit: null == credit ? _self.credit : credit // ignore: cast_nullable_to_non_nullable
as int,creditEur: null == creditEur ? _self.creditEur : creditEur // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GrantMarketingConsentResponse].
extension GrantMarketingConsentResponsePatterns on GrantMarketingConsentResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GrantMarketingConsentResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GrantMarketingConsentResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GrantMarketingConsentResponse value)  $default,){
final _that = this;
switch (_that) {
case _GrantMarketingConsentResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GrantMarketingConsentResponse value)?  $default,){
final _that = this;
switch (_that) {
case _GrantMarketingConsentResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: GrantMarketingConsentResponse.itemsKey_)  List<MarketingConsentView> items, @JsonKey(name: GrantMarketingConsentResponse.creditKey_)  int credit, @JsonKey(name: GrantMarketingConsentResponse.creditEurKey_)  String creditEur)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GrantMarketingConsentResponse() when $default != null:
return $default(_that.items,_that.credit,_that.creditEur);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: GrantMarketingConsentResponse.itemsKey_)  List<MarketingConsentView> items, @JsonKey(name: GrantMarketingConsentResponse.creditKey_)  int credit, @JsonKey(name: GrantMarketingConsentResponse.creditEurKey_)  String creditEur)  $default,) {final _that = this;
switch (_that) {
case _GrantMarketingConsentResponse():
return $default(_that.items,_that.credit,_that.creditEur);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: GrantMarketingConsentResponse.itemsKey_)  List<MarketingConsentView> items, @JsonKey(name: GrantMarketingConsentResponse.creditKey_)  int credit, @JsonKey(name: GrantMarketingConsentResponse.creditEurKey_)  String creditEur)?  $default,) {final _that = this;
switch (_that) {
case _GrantMarketingConsentResponse() when $default != null:
return $default(_that.items,_that.credit,_that.creditEur);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _GrantMarketingConsentResponse extends GrantMarketingConsentResponse {
  const _GrantMarketingConsentResponse({@JsonKey(name: GrantMarketingConsentResponse.itemsKey_) required final  List<MarketingConsentView> items, @JsonKey(name: GrantMarketingConsentResponse.creditKey_) required this.credit, @JsonKey(name: GrantMarketingConsentResponse.creditEurKey_) this.creditEur = '0.00'}): _items = items,super._();
  factory _GrantMarketingConsentResponse.fromJson(Map<String, dynamic> json) => _$GrantMarketingConsentResponseFromJson(json);

/// items
 final  List<MarketingConsentView> _items;
/// items
@override@JsonKey(name: GrantMarketingConsentResponse.itemsKey_) List<MarketingConsentView> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

/// credit
@override@JsonKey(name: GrantMarketingConsentResponse.creditKey_) final  int credit;
/// creditEur
@override@JsonKey(name: GrantMarketingConsentResponse.creditEurKey_) final  String creditEur;

/// Create a copy of GrantMarketingConsentResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GrantMarketingConsentResponseCopyWith<_GrantMarketingConsentResponse> get copyWith => __$GrantMarketingConsentResponseCopyWithImpl<_GrantMarketingConsentResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GrantMarketingConsentResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GrantMarketingConsentResponse&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.credit, credit) || other.credit == credit)&&(identical(other.creditEur, creditEur) || other.creditEur == creditEur));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),credit,creditEur);

@override
String toString() {
  return 'GrantMarketingConsentResponse(items: $items, credit: $credit, creditEur: $creditEur)';
}


}

/// @nodoc
abstract mixin class _$GrantMarketingConsentResponseCopyWith<$Res> implements $GrantMarketingConsentResponseCopyWith<$Res> {
  factory _$GrantMarketingConsentResponseCopyWith(_GrantMarketingConsentResponse value, $Res Function(_GrantMarketingConsentResponse) _then) = __$GrantMarketingConsentResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: GrantMarketingConsentResponse.itemsKey_) List<MarketingConsentView> items,@JsonKey(name: GrantMarketingConsentResponse.creditKey_) int credit,@JsonKey(name: GrantMarketingConsentResponse.creditEurKey_) String creditEur
});




}
/// @nodoc
class __$GrantMarketingConsentResponseCopyWithImpl<$Res>
    implements _$GrantMarketingConsentResponseCopyWith<$Res> {
  __$GrantMarketingConsentResponseCopyWithImpl(this._self, this._then);

  final _GrantMarketingConsentResponse _self;
  final $Res Function(_GrantMarketingConsentResponse) _then;

/// Create a copy of GrantMarketingConsentResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? credit = null,Object? creditEur = null,}) {
  return _then(_GrantMarketingConsentResponse(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<MarketingConsentView>,credit: null == credit ? _self.credit : credit // ignore: cast_nullable_to_non_nullable
as int,creditEur: null == creditEur ? _self.creditEur : creditEur // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
