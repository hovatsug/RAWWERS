// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_home_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClientHomeResponse {

/// rows
@JsonKey(name: ClientHomeResponse.rowsKey_) List<ClientHomeRow>? get rows;/// guestLimited
@JsonKey(name: ClientHomeResponse.guestLimitedKey_) bool get guestLimited;/// niche
@JsonKey(name: ClientHomeResponse.nicheKey_) ClientHomeNiche? get niche;
/// Create a copy of ClientHomeResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientHomeResponseCopyWith<ClientHomeResponse> get copyWith => _$ClientHomeResponseCopyWithImpl<ClientHomeResponse>(this as ClientHomeResponse, _$identity);

  /// Serializes this ClientHomeResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientHomeResponse&&const DeepCollectionEquality().equals(other.rows, rows)&&(identical(other.guestLimited, guestLimited) || other.guestLimited == guestLimited)&&(identical(other.niche, niche) || other.niche == niche));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(rows),guestLimited,niche);

@override
String toString() {
  return 'ClientHomeResponse(rows: $rows, guestLimited: $guestLimited, niche: $niche)';
}


}

/// @nodoc
abstract mixin class $ClientHomeResponseCopyWith<$Res>  {
  factory $ClientHomeResponseCopyWith(ClientHomeResponse value, $Res Function(ClientHomeResponse) _then) = _$ClientHomeResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: ClientHomeResponse.rowsKey_) List<ClientHomeRow>? rows,@JsonKey(name: ClientHomeResponse.guestLimitedKey_) bool guestLimited,@JsonKey(name: ClientHomeResponse.nicheKey_) ClientHomeNiche? niche
});


$ClientHomeNicheCopyWith<$Res>? get niche;

}
/// @nodoc
class _$ClientHomeResponseCopyWithImpl<$Res>
    implements $ClientHomeResponseCopyWith<$Res> {
  _$ClientHomeResponseCopyWithImpl(this._self, this._then);

  final ClientHomeResponse _self;
  final $Res Function(ClientHomeResponse) _then;

/// Create a copy of ClientHomeResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rows = freezed,Object? guestLimited = null,Object? niche = freezed,}) {
  return _then(_self.copyWith(
rows: freezed == rows ? _self.rows : rows // ignore: cast_nullable_to_non_nullable
as List<ClientHomeRow>?,guestLimited: null == guestLimited ? _self.guestLimited : guestLimited // ignore: cast_nullable_to_non_nullable
as bool,niche: freezed == niche ? _self.niche : niche // ignore: cast_nullable_to_non_nullable
as ClientHomeNiche?,
  ));
}
/// Create a copy of ClientHomeResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClientHomeNicheCopyWith<$Res>? get niche {
    if (_self.niche == null) {
    return null;
  }

  return $ClientHomeNicheCopyWith<$Res>(_self.niche!, (value) {
    return _then(_self.copyWith(niche: value));
  });
}
}


/// Adds pattern-matching-related methods to [ClientHomeResponse].
extension ClientHomeResponsePatterns on ClientHomeResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientHomeResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientHomeResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientHomeResponse value)  $default,){
final _that = this;
switch (_that) {
case _ClientHomeResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientHomeResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ClientHomeResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: ClientHomeResponse.rowsKey_)  List<ClientHomeRow>? rows, @JsonKey(name: ClientHomeResponse.guestLimitedKey_)  bool guestLimited, @JsonKey(name: ClientHomeResponse.nicheKey_)  ClientHomeNiche? niche)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientHomeResponse() when $default != null:
return $default(_that.rows,_that.guestLimited,_that.niche);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: ClientHomeResponse.rowsKey_)  List<ClientHomeRow>? rows, @JsonKey(name: ClientHomeResponse.guestLimitedKey_)  bool guestLimited, @JsonKey(name: ClientHomeResponse.nicheKey_)  ClientHomeNiche? niche)  $default,) {final _that = this;
switch (_that) {
case _ClientHomeResponse():
return $default(_that.rows,_that.guestLimited,_that.niche);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: ClientHomeResponse.rowsKey_)  List<ClientHomeRow>? rows, @JsonKey(name: ClientHomeResponse.guestLimitedKey_)  bool guestLimited, @JsonKey(name: ClientHomeResponse.nicheKey_)  ClientHomeNiche? niche)?  $default,) {final _that = this;
switch (_that) {
case _ClientHomeResponse() when $default != null:
return $default(_that.rows,_that.guestLimited,_that.niche);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _ClientHomeResponse extends ClientHomeResponse {
  const _ClientHomeResponse({@JsonKey(name: ClientHomeResponse.rowsKey_) final  List<ClientHomeRow>? rows, @JsonKey(name: ClientHomeResponse.guestLimitedKey_) this.guestLimited = false, @JsonKey(name: ClientHomeResponse.nicheKey_) this.niche}): _rows = rows,super._();
  factory _ClientHomeResponse.fromJson(Map<String, dynamic> json) => _$ClientHomeResponseFromJson(json);

/// rows
 final  List<ClientHomeRow>? _rows;
/// rows
@override@JsonKey(name: ClientHomeResponse.rowsKey_) List<ClientHomeRow>? get rows {
  final value = _rows;
  if (value == null) return null;
  if (_rows is EqualUnmodifiableListView) return _rows;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// guestLimited
@override@JsonKey(name: ClientHomeResponse.guestLimitedKey_) final  bool guestLimited;
/// niche
@override@JsonKey(name: ClientHomeResponse.nicheKey_) final  ClientHomeNiche? niche;

/// Create a copy of ClientHomeResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientHomeResponseCopyWith<_ClientHomeResponse> get copyWith => __$ClientHomeResponseCopyWithImpl<_ClientHomeResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientHomeResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientHomeResponse&&const DeepCollectionEquality().equals(other._rows, _rows)&&(identical(other.guestLimited, guestLimited) || other.guestLimited == guestLimited)&&(identical(other.niche, niche) || other.niche == niche));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_rows),guestLimited,niche);

@override
String toString() {
  return 'ClientHomeResponse(rows: $rows, guestLimited: $guestLimited, niche: $niche)';
}


}

/// @nodoc
abstract mixin class _$ClientHomeResponseCopyWith<$Res> implements $ClientHomeResponseCopyWith<$Res> {
  factory _$ClientHomeResponseCopyWith(_ClientHomeResponse value, $Res Function(_ClientHomeResponse) _then) = __$ClientHomeResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: ClientHomeResponse.rowsKey_) List<ClientHomeRow>? rows,@JsonKey(name: ClientHomeResponse.guestLimitedKey_) bool guestLimited,@JsonKey(name: ClientHomeResponse.nicheKey_) ClientHomeNiche? niche
});


@override $ClientHomeNicheCopyWith<$Res>? get niche;

}
/// @nodoc
class __$ClientHomeResponseCopyWithImpl<$Res>
    implements _$ClientHomeResponseCopyWith<$Res> {
  __$ClientHomeResponseCopyWithImpl(this._self, this._then);

  final _ClientHomeResponse _self;
  final $Res Function(_ClientHomeResponse) _then;

/// Create a copy of ClientHomeResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rows = freezed,Object? guestLimited = null,Object? niche = freezed,}) {
  return _then(_ClientHomeResponse(
rows: freezed == rows ? _self._rows : rows // ignore: cast_nullable_to_non_nullable
as List<ClientHomeRow>?,guestLimited: null == guestLimited ? _self.guestLimited : guestLimited // ignore: cast_nullable_to_non_nullable
as bool,niche: freezed == niche ? _self.niche : niche // ignore: cast_nullable_to_non_nullable
as ClientHomeNiche?,
  ));
}

/// Create a copy of ClientHomeResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClientHomeNicheCopyWith<$Res>? get niche {
    if (_self.niche == null) {
    return null;
  }

  return $ClientHomeNicheCopyWith<$Res>(_self.niche!, (value) {
    return _then(_self.copyWith(niche: value));
  });
}
}

// dart format on
