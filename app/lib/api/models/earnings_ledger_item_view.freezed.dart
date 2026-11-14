// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'earnings_ledger_item_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EarningsLedgerItemView {

/// id
@JsonKey(name: EarningsLedgerItemView.idKey_) String get id;/// sourceType
@JsonKey(name: EarningsLedgerItemView.sourceTypeKey_) EarningsSourceType get sourceType;/// sourceId
@JsonKey(name: EarningsLedgerItemView.sourceIdKey_) String get sourceId;/// currency
@JsonKey(name: EarningsLedgerItemView.currencyKey_) String get currency;/// gross
@JsonKey(name: EarningsLedgerItemView.grossKey_) String get gross;/// platformFee
@JsonKey(name: EarningsLedgerItemView.platformFeeKey_) String get platformFee;/// net
@JsonKey(name: EarningsLedgerItemView.netKey_) String get net;/// status
@JsonKey(name: EarningsLedgerItemView.statusKey_) EarningsEntryStatus get status;/// availableAt
@JsonKey(name: EarningsLedgerItemView.availableAtKey_) DateTime get availableAt;/// reversedAt
@JsonKey(name: EarningsLedgerItemView.reversedAtKey_) DateTime? get reversedAt;/// meta
@JsonKey(name: EarningsLedgerItemView.metaKey_) Map<String, dynamic>? get meta;/// createdAt
@JsonKey(name: EarningsLedgerItemView.createdAtKey_) DateTime get createdAt;
/// Create a copy of EarningsLedgerItemView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EarningsLedgerItemViewCopyWith<EarningsLedgerItemView> get copyWith => _$EarningsLedgerItemViewCopyWithImpl<EarningsLedgerItemView>(this as EarningsLedgerItemView, _$identity);

  /// Serializes this EarningsLedgerItemView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EarningsLedgerItemView&&(identical(other.id, id) || other.id == id)&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.gross, gross) || other.gross == gross)&&(identical(other.platformFee, platformFee) || other.platformFee == platformFee)&&(identical(other.net, net) || other.net == net)&&(identical(other.status, status) || other.status == status)&&(identical(other.availableAt, availableAt) || other.availableAt == availableAt)&&(identical(other.reversedAt, reversedAt) || other.reversedAt == reversedAt)&&const DeepCollectionEquality().equals(other.meta, meta)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sourceType,sourceId,currency,gross,platformFee,net,status,availableAt,reversedAt,const DeepCollectionEquality().hash(meta),createdAt);

@override
String toString() {
  return 'EarningsLedgerItemView(id: $id, sourceType: $sourceType, sourceId: $sourceId, currency: $currency, gross: $gross, platformFee: $platformFee, net: $net, status: $status, availableAt: $availableAt, reversedAt: $reversedAt, meta: $meta, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $EarningsLedgerItemViewCopyWith<$Res>  {
  factory $EarningsLedgerItemViewCopyWith(EarningsLedgerItemView value, $Res Function(EarningsLedgerItemView) _then) = _$EarningsLedgerItemViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: EarningsLedgerItemView.idKey_) String id,@JsonKey(name: EarningsLedgerItemView.sourceTypeKey_) EarningsSourceType sourceType,@JsonKey(name: EarningsLedgerItemView.sourceIdKey_) String sourceId,@JsonKey(name: EarningsLedgerItemView.currencyKey_) String currency,@JsonKey(name: EarningsLedgerItemView.grossKey_) String gross,@JsonKey(name: EarningsLedgerItemView.platformFeeKey_) String platformFee,@JsonKey(name: EarningsLedgerItemView.netKey_) String net,@JsonKey(name: EarningsLedgerItemView.statusKey_) EarningsEntryStatus status,@JsonKey(name: EarningsLedgerItemView.availableAtKey_) DateTime availableAt,@JsonKey(name: EarningsLedgerItemView.reversedAtKey_) DateTime? reversedAt,@JsonKey(name: EarningsLedgerItemView.metaKey_) Map<String, dynamic>? meta,@JsonKey(name: EarningsLedgerItemView.createdAtKey_) DateTime createdAt
});




}
/// @nodoc
class _$EarningsLedgerItemViewCopyWithImpl<$Res>
    implements $EarningsLedgerItemViewCopyWith<$Res> {
  _$EarningsLedgerItemViewCopyWithImpl(this._self, this._then);

  final EarningsLedgerItemView _self;
  final $Res Function(EarningsLedgerItemView) _then;

/// Create a copy of EarningsLedgerItemView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sourceType = null,Object? sourceId = null,Object? currency = null,Object? gross = null,Object? platformFee = null,Object? net = null,Object? status = null,Object? availableAt = null,Object? reversedAt = freezed,Object? meta = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sourceType: null == sourceType ? _self.sourceType : sourceType // ignore: cast_nullable_to_non_nullable
as EarningsSourceType,sourceId: null == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,gross: null == gross ? _self.gross : gross // ignore: cast_nullable_to_non_nullable
as String,platformFee: null == platformFee ? _self.platformFee : platformFee // ignore: cast_nullable_to_non_nullable
as String,net: null == net ? _self.net : net // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EarningsEntryStatus,availableAt: null == availableAt ? _self.availableAt : availableAt // ignore: cast_nullable_to_non_nullable
as DateTime,reversedAt: freezed == reversedAt ? _self.reversedAt : reversedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,meta: freezed == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [EarningsLedgerItemView].
extension EarningsLedgerItemViewPatterns on EarningsLedgerItemView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EarningsLedgerItemView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EarningsLedgerItemView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EarningsLedgerItemView value)  $default,){
final _that = this;
switch (_that) {
case _EarningsLedgerItemView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EarningsLedgerItemView value)?  $default,){
final _that = this;
switch (_that) {
case _EarningsLedgerItemView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: EarningsLedgerItemView.idKey_)  String id, @JsonKey(name: EarningsLedgerItemView.sourceTypeKey_)  EarningsSourceType sourceType, @JsonKey(name: EarningsLedgerItemView.sourceIdKey_)  String sourceId, @JsonKey(name: EarningsLedgerItemView.currencyKey_)  String currency, @JsonKey(name: EarningsLedgerItemView.grossKey_)  String gross, @JsonKey(name: EarningsLedgerItemView.platformFeeKey_)  String platformFee, @JsonKey(name: EarningsLedgerItemView.netKey_)  String net, @JsonKey(name: EarningsLedgerItemView.statusKey_)  EarningsEntryStatus status, @JsonKey(name: EarningsLedgerItemView.availableAtKey_)  DateTime availableAt, @JsonKey(name: EarningsLedgerItemView.reversedAtKey_)  DateTime? reversedAt, @JsonKey(name: EarningsLedgerItemView.metaKey_)  Map<String, dynamic>? meta, @JsonKey(name: EarningsLedgerItemView.createdAtKey_)  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EarningsLedgerItemView() when $default != null:
return $default(_that.id,_that.sourceType,_that.sourceId,_that.currency,_that.gross,_that.platformFee,_that.net,_that.status,_that.availableAt,_that.reversedAt,_that.meta,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: EarningsLedgerItemView.idKey_)  String id, @JsonKey(name: EarningsLedgerItemView.sourceTypeKey_)  EarningsSourceType sourceType, @JsonKey(name: EarningsLedgerItemView.sourceIdKey_)  String sourceId, @JsonKey(name: EarningsLedgerItemView.currencyKey_)  String currency, @JsonKey(name: EarningsLedgerItemView.grossKey_)  String gross, @JsonKey(name: EarningsLedgerItemView.platformFeeKey_)  String platformFee, @JsonKey(name: EarningsLedgerItemView.netKey_)  String net, @JsonKey(name: EarningsLedgerItemView.statusKey_)  EarningsEntryStatus status, @JsonKey(name: EarningsLedgerItemView.availableAtKey_)  DateTime availableAt, @JsonKey(name: EarningsLedgerItemView.reversedAtKey_)  DateTime? reversedAt, @JsonKey(name: EarningsLedgerItemView.metaKey_)  Map<String, dynamic>? meta, @JsonKey(name: EarningsLedgerItemView.createdAtKey_)  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _EarningsLedgerItemView():
return $default(_that.id,_that.sourceType,_that.sourceId,_that.currency,_that.gross,_that.platformFee,_that.net,_that.status,_that.availableAt,_that.reversedAt,_that.meta,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: EarningsLedgerItemView.idKey_)  String id, @JsonKey(name: EarningsLedgerItemView.sourceTypeKey_)  EarningsSourceType sourceType, @JsonKey(name: EarningsLedgerItemView.sourceIdKey_)  String sourceId, @JsonKey(name: EarningsLedgerItemView.currencyKey_)  String currency, @JsonKey(name: EarningsLedgerItemView.grossKey_)  String gross, @JsonKey(name: EarningsLedgerItemView.platformFeeKey_)  String platformFee, @JsonKey(name: EarningsLedgerItemView.netKey_)  String net, @JsonKey(name: EarningsLedgerItemView.statusKey_)  EarningsEntryStatus status, @JsonKey(name: EarningsLedgerItemView.availableAtKey_)  DateTime availableAt, @JsonKey(name: EarningsLedgerItemView.reversedAtKey_)  DateTime? reversedAt, @JsonKey(name: EarningsLedgerItemView.metaKey_)  Map<String, dynamic>? meta, @JsonKey(name: EarningsLedgerItemView.createdAtKey_)  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _EarningsLedgerItemView() when $default != null:
return $default(_that.id,_that.sourceType,_that.sourceId,_that.currency,_that.gross,_that.platformFee,_that.net,_that.status,_that.availableAt,_that.reversedAt,_that.meta,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _EarningsLedgerItemView extends EarningsLedgerItemView {
  const _EarningsLedgerItemView({@JsonKey(name: EarningsLedgerItemView.idKey_) required this.id, @JsonKey(name: EarningsLedgerItemView.sourceTypeKey_) required this.sourceType, @JsonKey(name: EarningsLedgerItemView.sourceIdKey_) required this.sourceId, @JsonKey(name: EarningsLedgerItemView.currencyKey_) required this.currency, @JsonKey(name: EarningsLedgerItemView.grossKey_) required this.gross, @JsonKey(name: EarningsLedgerItemView.platformFeeKey_) required this.platformFee, @JsonKey(name: EarningsLedgerItemView.netKey_) required this.net, @JsonKey(name: EarningsLedgerItemView.statusKey_) required this.status, @JsonKey(name: EarningsLedgerItemView.availableAtKey_) required this.availableAt, @JsonKey(name: EarningsLedgerItemView.reversedAtKey_) this.reversedAt, @JsonKey(name: EarningsLedgerItemView.metaKey_) final  Map<String, dynamic>? meta, @JsonKey(name: EarningsLedgerItemView.createdAtKey_) required this.createdAt}): _meta = meta,super._();
  factory _EarningsLedgerItemView.fromJson(Map<String, dynamic> json) => _$EarningsLedgerItemViewFromJson(json);

/// id
@override@JsonKey(name: EarningsLedgerItemView.idKey_) final  String id;
/// sourceType
@override@JsonKey(name: EarningsLedgerItemView.sourceTypeKey_) final  EarningsSourceType sourceType;
/// sourceId
@override@JsonKey(name: EarningsLedgerItemView.sourceIdKey_) final  String sourceId;
/// currency
@override@JsonKey(name: EarningsLedgerItemView.currencyKey_) final  String currency;
/// gross
@override@JsonKey(name: EarningsLedgerItemView.grossKey_) final  String gross;
/// platformFee
@override@JsonKey(name: EarningsLedgerItemView.platformFeeKey_) final  String platformFee;
/// net
@override@JsonKey(name: EarningsLedgerItemView.netKey_) final  String net;
/// status
@override@JsonKey(name: EarningsLedgerItemView.statusKey_) final  EarningsEntryStatus status;
/// availableAt
@override@JsonKey(name: EarningsLedgerItemView.availableAtKey_) final  DateTime availableAt;
/// reversedAt
@override@JsonKey(name: EarningsLedgerItemView.reversedAtKey_) final  DateTime? reversedAt;
/// meta
 final  Map<String, dynamic>? _meta;
/// meta
@override@JsonKey(name: EarningsLedgerItemView.metaKey_) Map<String, dynamic>? get meta {
  final value = _meta;
  if (value == null) return null;
  if (_meta is EqualUnmodifiableMapView) return _meta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// createdAt
@override@JsonKey(name: EarningsLedgerItemView.createdAtKey_) final  DateTime createdAt;

/// Create a copy of EarningsLedgerItemView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EarningsLedgerItemViewCopyWith<_EarningsLedgerItemView> get copyWith => __$EarningsLedgerItemViewCopyWithImpl<_EarningsLedgerItemView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EarningsLedgerItemViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EarningsLedgerItemView&&(identical(other.id, id) || other.id == id)&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.gross, gross) || other.gross == gross)&&(identical(other.platformFee, platformFee) || other.platformFee == platformFee)&&(identical(other.net, net) || other.net == net)&&(identical(other.status, status) || other.status == status)&&(identical(other.availableAt, availableAt) || other.availableAt == availableAt)&&(identical(other.reversedAt, reversedAt) || other.reversedAt == reversedAt)&&const DeepCollectionEquality().equals(other._meta, _meta)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sourceType,sourceId,currency,gross,platformFee,net,status,availableAt,reversedAt,const DeepCollectionEquality().hash(_meta),createdAt);

@override
String toString() {
  return 'EarningsLedgerItemView(id: $id, sourceType: $sourceType, sourceId: $sourceId, currency: $currency, gross: $gross, platformFee: $platformFee, net: $net, status: $status, availableAt: $availableAt, reversedAt: $reversedAt, meta: $meta, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$EarningsLedgerItemViewCopyWith<$Res> implements $EarningsLedgerItemViewCopyWith<$Res> {
  factory _$EarningsLedgerItemViewCopyWith(_EarningsLedgerItemView value, $Res Function(_EarningsLedgerItemView) _then) = __$EarningsLedgerItemViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: EarningsLedgerItemView.idKey_) String id,@JsonKey(name: EarningsLedgerItemView.sourceTypeKey_) EarningsSourceType sourceType,@JsonKey(name: EarningsLedgerItemView.sourceIdKey_) String sourceId,@JsonKey(name: EarningsLedgerItemView.currencyKey_) String currency,@JsonKey(name: EarningsLedgerItemView.grossKey_) String gross,@JsonKey(name: EarningsLedgerItemView.platformFeeKey_) String platformFee,@JsonKey(name: EarningsLedgerItemView.netKey_) String net,@JsonKey(name: EarningsLedgerItemView.statusKey_) EarningsEntryStatus status,@JsonKey(name: EarningsLedgerItemView.availableAtKey_) DateTime availableAt,@JsonKey(name: EarningsLedgerItemView.reversedAtKey_) DateTime? reversedAt,@JsonKey(name: EarningsLedgerItemView.metaKey_) Map<String, dynamic>? meta,@JsonKey(name: EarningsLedgerItemView.createdAtKey_) DateTime createdAt
});




}
/// @nodoc
class __$EarningsLedgerItemViewCopyWithImpl<$Res>
    implements _$EarningsLedgerItemViewCopyWith<$Res> {
  __$EarningsLedgerItemViewCopyWithImpl(this._self, this._then);

  final _EarningsLedgerItemView _self;
  final $Res Function(_EarningsLedgerItemView) _then;

/// Create a copy of EarningsLedgerItemView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sourceType = null,Object? sourceId = null,Object? currency = null,Object? gross = null,Object? platformFee = null,Object? net = null,Object? status = null,Object? availableAt = null,Object? reversedAt = freezed,Object? meta = freezed,Object? createdAt = null,}) {
  return _then(_EarningsLedgerItemView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sourceType: null == sourceType ? _self.sourceType : sourceType // ignore: cast_nullable_to_non_nullable
as EarningsSourceType,sourceId: null == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,gross: null == gross ? _self.gross : gross // ignore: cast_nullable_to_non_nullable
as String,platformFee: null == platformFee ? _self.platformFee : platformFee // ignore: cast_nullable_to_non_nullable
as String,net: null == net ? _self.net : net // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EarningsEntryStatus,availableAt: null == availableAt ? _self.availableAt : availableAt // ignore: cast_nullable_to_non_nullable
as DateTime,reversedAt: freezed == reversedAt ? _self.reversedAt : reversedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,meta: freezed == meta ? _self._meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
