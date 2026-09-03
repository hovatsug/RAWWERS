// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_match_card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClientMatchCard {

/// proUserId
@JsonKey(name: ClientMatchCard.proUserIdKey_) String get proUserId;/// rank
@JsonKey(name: ClientMatchCard.rankKey_) int get rank;/// score
@JsonKey(name: ClientMatchCard.scoreKey_) String get score;/// card
@JsonKey(name: ClientMatchCard.cardKey_) ClientDiscoverCard get card;/// scoreBreakdown
@JsonKey(name: ClientMatchCard.scoreBreakdownKey_) Map<String, dynamic>? get scoreBreakdown;
/// Create a copy of ClientMatchCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientMatchCardCopyWith<ClientMatchCard> get copyWith => _$ClientMatchCardCopyWithImpl<ClientMatchCard>(this as ClientMatchCard, _$identity);

  /// Serializes this ClientMatchCard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientMatchCard&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.score, score) || other.score == score)&&(identical(other.card, card) || other.card == card)&&const DeepCollectionEquality().equals(other.scoreBreakdown, scoreBreakdown));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,proUserId,rank,score,card,const DeepCollectionEquality().hash(scoreBreakdown));

@override
String toString() {
  return 'ClientMatchCard(proUserId: $proUserId, rank: $rank, score: $score, card: $card, scoreBreakdown: $scoreBreakdown)';
}


}

/// @nodoc
abstract mixin class $ClientMatchCardCopyWith<$Res>  {
  factory $ClientMatchCardCopyWith(ClientMatchCard value, $Res Function(ClientMatchCard) _then) = _$ClientMatchCardCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ClientMatchCard.proUserIdKey_) String proUserId,@JsonKey(name: ClientMatchCard.rankKey_) int rank,@JsonKey(name: ClientMatchCard.scoreKey_) String score,@JsonKey(name: ClientMatchCard.cardKey_) ClientDiscoverCard card,@JsonKey(name: ClientMatchCard.scoreBreakdownKey_) Map<String, dynamic>? scoreBreakdown
});


$ClientDiscoverCardCopyWith<$Res> get card;

}
/// @nodoc
class _$ClientMatchCardCopyWithImpl<$Res>
    implements $ClientMatchCardCopyWith<$Res> {
  _$ClientMatchCardCopyWithImpl(this._self, this._then);

  final ClientMatchCard _self;
  final $Res Function(ClientMatchCard) _then;

/// Create a copy of ClientMatchCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? proUserId = null,Object? rank = null,Object? score = null,Object? card = null,Object? scoreBreakdown = freezed,}) {
  return _then(_self.copyWith(
proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as String,card: null == card ? _self.card : card // ignore: cast_nullable_to_non_nullable
as ClientDiscoverCard,scoreBreakdown: freezed == scoreBreakdown ? _self.scoreBreakdown : scoreBreakdown // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}
/// Create a copy of ClientMatchCard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClientDiscoverCardCopyWith<$Res> get card {
  
  return $ClientDiscoverCardCopyWith<$Res>(_self.card, (value) {
    return _then(_self.copyWith(card: value));
  });
}
}


/// Adds pattern-matching-related methods to [ClientMatchCard].
extension ClientMatchCardPatterns on ClientMatchCard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientMatchCard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientMatchCard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientMatchCard value)  $default,){
final _that = this;
switch (_that) {
case _ClientMatchCard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientMatchCard value)?  $default,){
final _that = this;
switch (_that) {
case _ClientMatchCard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ClientMatchCard.proUserIdKey_)  String proUserId, @JsonKey(name: ClientMatchCard.rankKey_)  int rank, @JsonKey(name: ClientMatchCard.scoreKey_)  String score, @JsonKey(name: ClientMatchCard.cardKey_)  ClientDiscoverCard card, @JsonKey(name: ClientMatchCard.scoreBreakdownKey_)  Map<String, dynamic>? scoreBreakdown)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientMatchCard() when $default != null:
return $default(_that.proUserId,_that.rank,_that.score,_that.card,_that.scoreBreakdown);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ClientMatchCard.proUserIdKey_)  String proUserId, @JsonKey(name: ClientMatchCard.rankKey_)  int rank, @JsonKey(name: ClientMatchCard.scoreKey_)  String score, @JsonKey(name: ClientMatchCard.cardKey_)  ClientDiscoverCard card, @JsonKey(name: ClientMatchCard.scoreBreakdownKey_)  Map<String, dynamic>? scoreBreakdown)  $default,) {final _that = this;
switch (_that) {
case _ClientMatchCard():
return $default(_that.proUserId,_that.rank,_that.score,_that.card,_that.scoreBreakdown);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ClientMatchCard.proUserIdKey_)  String proUserId, @JsonKey(name: ClientMatchCard.rankKey_)  int rank, @JsonKey(name: ClientMatchCard.scoreKey_)  String score, @JsonKey(name: ClientMatchCard.cardKey_)  ClientDiscoverCard card, @JsonKey(name: ClientMatchCard.scoreBreakdownKey_)  Map<String, dynamic>? scoreBreakdown)?  $default,) {final _that = this;
switch (_that) {
case _ClientMatchCard() when $default != null:
return $default(_that.proUserId,_that.rank,_that.score,_that.card,_that.scoreBreakdown);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ClientMatchCard extends ClientMatchCard {
  const _ClientMatchCard({@JsonKey(name: ClientMatchCard.proUserIdKey_) required this.proUserId, @JsonKey(name: ClientMatchCard.rankKey_) required this.rank, @JsonKey(name: ClientMatchCard.scoreKey_) required this.score, @JsonKey(name: ClientMatchCard.cardKey_) required this.card, @JsonKey(name: ClientMatchCard.scoreBreakdownKey_) final  Map<String, dynamic>? scoreBreakdown}): _scoreBreakdown = scoreBreakdown,super._();
  factory _ClientMatchCard.fromJson(Map<String, dynamic> json) => _$ClientMatchCardFromJson(json);

/// proUserId
@override@JsonKey(name: ClientMatchCard.proUserIdKey_) final  String proUserId;
/// rank
@override@JsonKey(name: ClientMatchCard.rankKey_) final  int rank;
/// score
@override@JsonKey(name: ClientMatchCard.scoreKey_) final  String score;
/// card
@override@JsonKey(name: ClientMatchCard.cardKey_) final  ClientDiscoverCard card;
/// scoreBreakdown
 final  Map<String, dynamic>? _scoreBreakdown;
/// scoreBreakdown
@override@JsonKey(name: ClientMatchCard.scoreBreakdownKey_) Map<String, dynamic>? get scoreBreakdown {
  final value = _scoreBreakdown;
  if (value == null) return null;
  if (_scoreBreakdown is EqualUnmodifiableMapView) return _scoreBreakdown;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of ClientMatchCard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientMatchCardCopyWith<_ClientMatchCard> get copyWith => __$ClientMatchCardCopyWithImpl<_ClientMatchCard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientMatchCardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientMatchCard&&(identical(other.proUserId, proUserId) || other.proUserId == proUserId)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.score, score) || other.score == score)&&(identical(other.card, card) || other.card == card)&&const DeepCollectionEquality().equals(other._scoreBreakdown, _scoreBreakdown));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,proUserId,rank,score,card,const DeepCollectionEquality().hash(_scoreBreakdown));

@override
String toString() {
  return 'ClientMatchCard(proUserId: $proUserId, rank: $rank, score: $score, card: $card, scoreBreakdown: $scoreBreakdown)';
}


}

/// @nodoc
abstract mixin class _$ClientMatchCardCopyWith<$Res> implements $ClientMatchCardCopyWith<$Res> {
  factory _$ClientMatchCardCopyWith(_ClientMatchCard value, $Res Function(_ClientMatchCard) _then) = __$ClientMatchCardCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ClientMatchCard.proUserIdKey_) String proUserId,@JsonKey(name: ClientMatchCard.rankKey_) int rank,@JsonKey(name: ClientMatchCard.scoreKey_) String score,@JsonKey(name: ClientMatchCard.cardKey_) ClientDiscoverCard card,@JsonKey(name: ClientMatchCard.scoreBreakdownKey_) Map<String, dynamic>? scoreBreakdown
});


@override $ClientDiscoverCardCopyWith<$Res> get card;

}
/// @nodoc
class __$ClientMatchCardCopyWithImpl<$Res>
    implements _$ClientMatchCardCopyWith<$Res> {
  __$ClientMatchCardCopyWithImpl(this._self, this._then);

  final _ClientMatchCard _self;
  final $Res Function(_ClientMatchCard) _then;

/// Create a copy of ClientMatchCard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? proUserId = null,Object? rank = null,Object? score = null,Object? card = null,Object? scoreBreakdown = freezed,}) {
  return _then(_ClientMatchCard(
proUserId: null == proUserId ? _self.proUserId : proUserId // ignore: cast_nullable_to_non_nullable
as String,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as String,card: null == card ? _self.card : card // ignore: cast_nullable_to_non_nullable
as ClientDiscoverCard,scoreBreakdown: freezed == scoreBreakdown ? _self._scoreBreakdown : scoreBreakdown // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

/// Create a copy of ClientMatchCard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClientDiscoverCardCopyWith<$Res> get card {
  
  return $ClientDiscoverCardCopyWith<$Res>(_self.card, (value) {
    return _then(_self.copyWith(card: value));
  });
}
}

// dart format on
