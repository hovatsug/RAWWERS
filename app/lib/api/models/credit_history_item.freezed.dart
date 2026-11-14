// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credit_history_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreditHistoryItem {

/// id
@JsonKey(name: CreditHistoryItem.idKey_) String get id;/// createdAt
@JsonKey(name: CreditHistoryItem.createdAtKey_) DateTime get createdAt;/// kind
@JsonKey(name: CreditHistoryItem.kindKey_) String get kind;/// amount
@JsonKey(name: CreditHistoryItem.amountKey_) String get amount;/// currency
@JsonKey(name: CreditHistoryItem.currencyKey_) String get currency;/// photographerFirstName
@JsonKey(name: CreditHistoryItem.photographerFirstNameKey_) String? get photographerFirstName;
/// Create a copy of CreditHistoryItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreditHistoryItemCopyWith<CreditHistoryItem> get copyWith => _$CreditHistoryItemCopyWithImpl<CreditHistoryItem>(this as CreditHistoryItem, _$identity);

  /// Serializes this CreditHistoryItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreditHistoryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.photographerFirstName, photographerFirstName) || other.photographerFirstName == photographerFirstName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,kind,amount,currency,photographerFirstName);

@override
String toString() {
  return 'CreditHistoryItem(id: $id, createdAt: $createdAt, kind: $kind, amount: $amount, currency: $currency, photographerFirstName: $photographerFirstName)';
}


}

/// @nodoc
abstract mixin class $CreditHistoryItemCopyWith<$Res>  {
  factory $CreditHistoryItemCopyWith(CreditHistoryItem value, $Res Function(CreditHistoryItem) _then) = _$CreditHistoryItemCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: CreditHistoryItem.idKey_) String id,@JsonKey(name: CreditHistoryItem.createdAtKey_) DateTime createdAt,@JsonKey(name: CreditHistoryItem.kindKey_) String kind,@JsonKey(name: CreditHistoryItem.amountKey_) String amount,@JsonKey(name: CreditHistoryItem.currencyKey_) String currency,@JsonKey(name: CreditHistoryItem.photographerFirstNameKey_) String? photographerFirstName
});




}
/// @nodoc
class _$CreditHistoryItemCopyWithImpl<$Res>
    implements $CreditHistoryItemCopyWith<$Res> {
  _$CreditHistoryItemCopyWithImpl(this._self, this._then);

  final CreditHistoryItem _self;
  final $Res Function(CreditHistoryItem) _then;

/// Create a copy of CreditHistoryItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? createdAt = null,Object? kind = null,Object? amount = null,Object? currency = null,Object? photographerFirstName = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,photographerFirstName: freezed == photographerFirstName ? _self.photographerFirstName : photographerFirstName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreditHistoryItem].
extension CreditHistoryItemPatterns on CreditHistoryItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreditHistoryItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreditHistoryItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreditHistoryItem value)  $default,){
final _that = this;
switch (_that) {
case _CreditHistoryItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreditHistoryItem value)?  $default,){
final _that = this;
switch (_that) {
case _CreditHistoryItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: CreditHistoryItem.idKey_)  String id, @JsonKey(name: CreditHistoryItem.createdAtKey_)  DateTime createdAt, @JsonKey(name: CreditHistoryItem.kindKey_)  String kind, @JsonKey(name: CreditHistoryItem.amountKey_)  String amount, @JsonKey(name: CreditHistoryItem.currencyKey_)  String currency, @JsonKey(name: CreditHistoryItem.photographerFirstNameKey_)  String? photographerFirstName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreditHistoryItem() when $default != null:
return $default(_that.id,_that.createdAt,_that.kind,_that.amount,_that.currency,_that.photographerFirstName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: CreditHistoryItem.idKey_)  String id, @JsonKey(name: CreditHistoryItem.createdAtKey_)  DateTime createdAt, @JsonKey(name: CreditHistoryItem.kindKey_)  String kind, @JsonKey(name: CreditHistoryItem.amountKey_)  String amount, @JsonKey(name: CreditHistoryItem.currencyKey_)  String currency, @JsonKey(name: CreditHistoryItem.photographerFirstNameKey_)  String? photographerFirstName)  $default,) {final _that = this;
switch (_that) {
case _CreditHistoryItem():
return $default(_that.id,_that.createdAt,_that.kind,_that.amount,_that.currency,_that.photographerFirstName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: CreditHistoryItem.idKey_)  String id, @JsonKey(name: CreditHistoryItem.createdAtKey_)  DateTime createdAt, @JsonKey(name: CreditHistoryItem.kindKey_)  String kind, @JsonKey(name: CreditHistoryItem.amountKey_)  String amount, @JsonKey(name: CreditHistoryItem.currencyKey_)  String currency, @JsonKey(name: CreditHistoryItem.photographerFirstNameKey_)  String? photographerFirstName)?  $default,) {final _that = this;
switch (_that) {
case _CreditHistoryItem() when $default != null:
return $default(_that.id,_that.createdAt,_that.kind,_that.amount,_that.currency,_that.photographerFirstName);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _CreditHistoryItem extends CreditHistoryItem {
  const _CreditHistoryItem({@JsonKey(name: CreditHistoryItem.idKey_) required this.id, @JsonKey(name: CreditHistoryItem.createdAtKey_) required this.createdAt, @JsonKey(name: CreditHistoryItem.kindKey_) required this.kind, @JsonKey(name: CreditHistoryItem.amountKey_) required this.amount, @JsonKey(name: CreditHistoryItem.currencyKey_) required this.currency, @JsonKey(name: CreditHistoryItem.photographerFirstNameKey_) this.photographerFirstName}): super._();
  factory _CreditHistoryItem.fromJson(Map<String, dynamic> json) => _$CreditHistoryItemFromJson(json);

/// id
@override@JsonKey(name: CreditHistoryItem.idKey_) final  String id;
/// createdAt
@override@JsonKey(name: CreditHistoryItem.createdAtKey_) final  DateTime createdAt;
/// kind
@override@JsonKey(name: CreditHistoryItem.kindKey_) final  String kind;
/// amount
@override@JsonKey(name: CreditHistoryItem.amountKey_) final  String amount;
/// currency
@override@JsonKey(name: CreditHistoryItem.currencyKey_) final  String currency;
/// photographerFirstName
@override@JsonKey(name: CreditHistoryItem.photographerFirstNameKey_) final  String? photographerFirstName;

/// Create a copy of CreditHistoryItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreditHistoryItemCopyWith<_CreditHistoryItem> get copyWith => __$CreditHistoryItemCopyWithImpl<_CreditHistoryItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreditHistoryItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreditHistoryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.photographerFirstName, photographerFirstName) || other.photographerFirstName == photographerFirstName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,kind,amount,currency,photographerFirstName);

@override
String toString() {
  return 'CreditHistoryItem(id: $id, createdAt: $createdAt, kind: $kind, amount: $amount, currency: $currency, photographerFirstName: $photographerFirstName)';
}


}

/// @nodoc
abstract mixin class _$CreditHistoryItemCopyWith<$Res> implements $CreditHistoryItemCopyWith<$Res> {
  factory _$CreditHistoryItemCopyWith(_CreditHistoryItem value, $Res Function(_CreditHistoryItem) _then) = __$CreditHistoryItemCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: CreditHistoryItem.idKey_) String id,@JsonKey(name: CreditHistoryItem.createdAtKey_) DateTime createdAt,@JsonKey(name: CreditHistoryItem.kindKey_) String kind,@JsonKey(name: CreditHistoryItem.amountKey_) String amount,@JsonKey(name: CreditHistoryItem.currencyKey_) String currency,@JsonKey(name: CreditHistoryItem.photographerFirstNameKey_) String? photographerFirstName
});




}
/// @nodoc
class __$CreditHistoryItemCopyWithImpl<$Res>
    implements _$CreditHistoryItemCopyWith<$Res> {
  __$CreditHistoryItemCopyWithImpl(this._self, this._then);

  final _CreditHistoryItem _self;
  final $Res Function(_CreditHistoryItem) _then;

/// Create a copy of CreditHistoryItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdAt = null,Object? kind = null,Object? amount = null,Object? currency = null,Object? photographerFirstName = freezed,}) {
  return _then(_CreditHistoryItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,photographerFirstName: freezed == photographerFirstName ? _self.photographerFirstName : photographerFirstName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
