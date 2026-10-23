// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'my_findings_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MyFindingsResponse {

/// strikes
@JsonKey(name: MyFindingsResponse.strikesKey_) int get strikes;/// pause
@JsonKey(name: MyFindingsResponse.pauseKey_) BookingPauseView? get pause;/// items
@JsonKey(name: MyFindingsResponse.itemsKey_) List<FindingView> get items;
/// Create a copy of MyFindingsResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MyFindingsResponseCopyWith<MyFindingsResponse> get copyWith => _$MyFindingsResponseCopyWithImpl<MyFindingsResponse>(this as MyFindingsResponse, _$identity);

  /// Serializes this MyFindingsResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MyFindingsResponse&&(identical(other.strikes, strikes) || other.strikes == strikes)&&(identical(other.pause, pause) || other.pause == pause)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,strikes,pause,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'MyFindingsResponse(strikes: $strikes, pause: $pause, items: $items)';
}


}

/// @nodoc
abstract mixin class $MyFindingsResponseCopyWith<$Res>  {
  factory $MyFindingsResponseCopyWith(MyFindingsResponse value, $Res Function(MyFindingsResponse) _then) = _$MyFindingsResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: MyFindingsResponse.strikesKey_) int strikes,@JsonKey(name: MyFindingsResponse.pauseKey_) BookingPauseView? pause,@JsonKey(name: MyFindingsResponse.itemsKey_) List<FindingView> items
});


$BookingPauseViewCopyWith<$Res>? get pause;

}
/// @nodoc
class _$MyFindingsResponseCopyWithImpl<$Res>
    implements $MyFindingsResponseCopyWith<$Res> {
  _$MyFindingsResponseCopyWithImpl(this._self, this._then);

  final MyFindingsResponse _self;
  final $Res Function(MyFindingsResponse) _then;

/// Create a copy of MyFindingsResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? strikes = null,Object? pause = freezed,Object? items = null,}) {
  return _then(_self.copyWith(
strikes: null == strikes ? _self.strikes : strikes // ignore: cast_nullable_to_non_nullable
as int,pause: freezed == pause ? _self.pause : pause // ignore: cast_nullable_to_non_nullable
as BookingPauseView?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<FindingView>,
  ));
}
/// Create a copy of MyFindingsResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BookingPauseViewCopyWith<$Res>? get pause {
    if (_self.pause == null) {
    return null;
  }

  return $BookingPauseViewCopyWith<$Res>(_self.pause!, (value) {
    return _then(_self.copyWith(pause: value));
  });
}
}


/// Adds pattern-matching-related methods to [MyFindingsResponse].
extension MyFindingsResponsePatterns on MyFindingsResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MyFindingsResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MyFindingsResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MyFindingsResponse value)  $default,){
final _that = this;
switch (_that) {
case _MyFindingsResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MyFindingsResponse value)?  $default,){
final _that = this;
switch (_that) {
case _MyFindingsResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: MyFindingsResponse.strikesKey_)  int strikes, @JsonKey(name: MyFindingsResponse.pauseKey_)  BookingPauseView? pause, @JsonKey(name: MyFindingsResponse.itemsKey_)  List<FindingView> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MyFindingsResponse() when $default != null:
return $default(_that.strikes,_that.pause,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: MyFindingsResponse.strikesKey_)  int strikes, @JsonKey(name: MyFindingsResponse.pauseKey_)  BookingPauseView? pause, @JsonKey(name: MyFindingsResponse.itemsKey_)  List<FindingView> items)  $default,) {final _that = this;
switch (_that) {
case _MyFindingsResponse():
return $default(_that.strikes,_that.pause,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: MyFindingsResponse.strikesKey_)  int strikes, @JsonKey(name: MyFindingsResponse.pauseKey_)  BookingPauseView? pause, @JsonKey(name: MyFindingsResponse.itemsKey_)  List<FindingView> items)?  $default,) {final _that = this;
switch (_that) {
case _MyFindingsResponse() when $default != null:
return $default(_that.strikes,_that.pause,_that.items);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _MyFindingsResponse extends MyFindingsResponse {
  const _MyFindingsResponse({@JsonKey(name: MyFindingsResponse.strikesKey_) required this.strikes, @JsonKey(name: MyFindingsResponse.pauseKey_) this.pause, @JsonKey(name: MyFindingsResponse.itemsKey_) required final  List<FindingView> items}): _items = items,super._();
  factory _MyFindingsResponse.fromJson(Map<String, dynamic> json) => _$MyFindingsResponseFromJson(json);

/// strikes
@override@JsonKey(name: MyFindingsResponse.strikesKey_) final  int strikes;
/// pause
@override@JsonKey(name: MyFindingsResponse.pauseKey_) final  BookingPauseView? pause;
/// items
 final  List<FindingView> _items;
/// items
@override@JsonKey(name: MyFindingsResponse.itemsKey_) List<FindingView> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of MyFindingsResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MyFindingsResponseCopyWith<_MyFindingsResponse> get copyWith => __$MyFindingsResponseCopyWithImpl<_MyFindingsResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MyFindingsResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MyFindingsResponse&&(identical(other.strikes, strikes) || other.strikes == strikes)&&(identical(other.pause, pause) || other.pause == pause)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,strikes,pause,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'MyFindingsResponse(strikes: $strikes, pause: $pause, items: $items)';
}


}

/// @nodoc
abstract mixin class _$MyFindingsResponseCopyWith<$Res> implements $MyFindingsResponseCopyWith<$Res> {
  factory _$MyFindingsResponseCopyWith(_MyFindingsResponse value, $Res Function(_MyFindingsResponse) _then) = __$MyFindingsResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: MyFindingsResponse.strikesKey_) int strikes,@JsonKey(name: MyFindingsResponse.pauseKey_) BookingPauseView? pause,@JsonKey(name: MyFindingsResponse.itemsKey_) List<FindingView> items
});


@override $BookingPauseViewCopyWith<$Res>? get pause;

}
/// @nodoc
class __$MyFindingsResponseCopyWithImpl<$Res>
    implements _$MyFindingsResponseCopyWith<$Res> {
  __$MyFindingsResponseCopyWithImpl(this._self, this._then);

  final _MyFindingsResponse _self;
  final $Res Function(_MyFindingsResponse) _then;

/// Create a copy of MyFindingsResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? strikes = null,Object? pause = freezed,Object? items = null,}) {
  return _then(_MyFindingsResponse(
strikes: null == strikes ? _self.strikes : strikes // ignore: cast_nullable_to_non_nullable
as int,pause: freezed == pause ? _self.pause : pause // ignore: cast_nullable_to_non_nullable
as BookingPauseView?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<FindingView>,
  ));
}

/// Create a copy of MyFindingsResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BookingPauseViewCopyWith<$Res>? get pause {
    if (_self.pause == null) {
    return null;
  }

  return $BookingPauseViewCopyWith<$Res>(_self.pause!, (value) {
    return _then(_self.copyWith(pause: value));
  });
}
}

// dart format on
