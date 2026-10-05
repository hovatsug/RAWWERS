// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lighting_declare_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LightingDeclareRequest {

/// make
@JsonKey(name: LightingDeclareRequest.makeKey_) String? get make;/// model
@JsonKey(name: LightingDeclareRequest.modelKey_) String get model;/// notes
@JsonKey(name: LightingDeclareRequest.notesKey_) String? get notes;
/// Create a copy of LightingDeclareRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LightingDeclareRequestCopyWith<LightingDeclareRequest> get copyWith => _$LightingDeclareRequestCopyWithImpl<LightingDeclareRequest>(this as LightingDeclareRequest, _$identity);

  /// Serializes this LightingDeclareRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LightingDeclareRequest&&(identical(other.make, make) || other.make == make)&&(identical(other.model, model) || other.model == model)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,make,model,notes);

@override
String toString() {
  return 'LightingDeclareRequest(make: $make, model: $model, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $LightingDeclareRequestCopyWith<$Res>  {
  factory $LightingDeclareRequestCopyWith(LightingDeclareRequest value, $Res Function(LightingDeclareRequest) _then) = _$LightingDeclareRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: LightingDeclareRequest.makeKey_) String? make,@JsonKey(name: LightingDeclareRequest.modelKey_) String model,@JsonKey(name: LightingDeclareRequest.notesKey_) String? notes
});




}
/// @nodoc
class _$LightingDeclareRequestCopyWithImpl<$Res>
    implements $LightingDeclareRequestCopyWith<$Res> {
  _$LightingDeclareRequestCopyWithImpl(this._self, this._then);

  final LightingDeclareRequest _self;
  final $Res Function(LightingDeclareRequest) _then;

/// Create a copy of LightingDeclareRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? make = freezed,Object? model = null,Object? notes = freezed,}) {
  return _then(_self.copyWith(
make: freezed == make ? _self.make : make // ignore: cast_nullable_to_non_nullable
as String?,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LightingDeclareRequest].
extension LightingDeclareRequestPatterns on LightingDeclareRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LightingDeclareRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LightingDeclareRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LightingDeclareRequest value)  $default,){
final _that = this;
switch (_that) {
case _LightingDeclareRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LightingDeclareRequest value)?  $default,){
final _that = this;
switch (_that) {
case _LightingDeclareRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: LightingDeclareRequest.makeKey_)  String? make, @JsonKey(name: LightingDeclareRequest.modelKey_)  String model, @JsonKey(name: LightingDeclareRequest.notesKey_)  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LightingDeclareRequest() when $default != null:
return $default(_that.make,_that.model,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: LightingDeclareRequest.makeKey_)  String? make, @JsonKey(name: LightingDeclareRequest.modelKey_)  String model, @JsonKey(name: LightingDeclareRequest.notesKey_)  String? notes)  $default,) {final _that = this;
switch (_that) {
case _LightingDeclareRequest():
return $default(_that.make,_that.model,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: LightingDeclareRequest.makeKey_)  String? make, @JsonKey(name: LightingDeclareRequest.modelKey_)  String model, @JsonKey(name: LightingDeclareRequest.notesKey_)  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _LightingDeclareRequest() when $default != null:
return $default(_that.make,_that.model,_that.notes);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _LightingDeclareRequest extends LightingDeclareRequest {
  const _LightingDeclareRequest({@JsonKey(name: LightingDeclareRequest.makeKey_) this.make, @JsonKey(name: LightingDeclareRequest.modelKey_) required this.model, @JsonKey(name: LightingDeclareRequest.notesKey_) this.notes}): super._();
  factory _LightingDeclareRequest.fromJson(Map<String, dynamic> json) => _$LightingDeclareRequestFromJson(json);

/// make
@override@JsonKey(name: LightingDeclareRequest.makeKey_) final  String? make;
/// model
@override@JsonKey(name: LightingDeclareRequest.modelKey_) final  String model;
/// notes
@override@JsonKey(name: LightingDeclareRequest.notesKey_) final  String? notes;

/// Create a copy of LightingDeclareRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LightingDeclareRequestCopyWith<_LightingDeclareRequest> get copyWith => __$LightingDeclareRequestCopyWithImpl<_LightingDeclareRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LightingDeclareRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LightingDeclareRequest&&(identical(other.make, make) || other.make == make)&&(identical(other.model, model) || other.model == model)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,make,model,notes);

@override
String toString() {
  return 'LightingDeclareRequest(make: $make, model: $model, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$LightingDeclareRequestCopyWith<$Res> implements $LightingDeclareRequestCopyWith<$Res> {
  factory _$LightingDeclareRequestCopyWith(_LightingDeclareRequest value, $Res Function(_LightingDeclareRequest) _then) = __$LightingDeclareRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: LightingDeclareRequest.makeKey_) String? make,@JsonKey(name: LightingDeclareRequest.modelKey_) String model,@JsonKey(name: LightingDeclareRequest.notesKey_) String? notes
});




}
/// @nodoc
class __$LightingDeclareRequestCopyWithImpl<$Res>
    implements _$LightingDeclareRequestCopyWith<$Res> {
  __$LightingDeclareRequestCopyWithImpl(this._self, this._then);

  final _LightingDeclareRequest _self;
  final $Res Function(_LightingDeclareRequest) _then;

/// Create a copy of LightingDeclareRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? make = freezed,Object? model = null,Object? notes = freezed,}) {
  return _then(_LightingDeclareRequest(
make: freezed == make ? _self.make : make // ignore: cast_nullable_to_non_nullable
as String?,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
