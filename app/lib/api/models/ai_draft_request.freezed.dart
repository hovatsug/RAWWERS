// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_draft_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AIDraftRequest {

/// context
@JsonKey(name: AIDraftRequest.contextKey_) String? get context;
/// Create a copy of AIDraftRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AIDraftRequestCopyWith<AIDraftRequest> get copyWith => _$AIDraftRequestCopyWithImpl<AIDraftRequest>(this as AIDraftRequest, _$identity);

  /// Serializes this AIDraftRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AIDraftRequest&&(identical(other.context, context) || other.context == context));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,context);

@override
String toString() {
  return 'AIDraftRequest(context: $context)';
}


}

/// @nodoc
abstract mixin class $AIDraftRequestCopyWith<$Res>  {
  factory $AIDraftRequestCopyWith(AIDraftRequest value, $Res Function(AIDraftRequest) _then) = _$AIDraftRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: AIDraftRequest.contextKey_) String? context
});




}
/// @nodoc
class _$AIDraftRequestCopyWithImpl<$Res>
    implements $AIDraftRequestCopyWith<$Res> {
  _$AIDraftRequestCopyWithImpl(this._self, this._then);

  final AIDraftRequest _self;
  final $Res Function(AIDraftRequest) _then;

/// Create a copy of AIDraftRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? context = freezed,}) {
  return _then(_self.copyWith(
context: freezed == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AIDraftRequest].
extension AIDraftRequestPatterns on AIDraftRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AIDraftRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AIDraftRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AIDraftRequest value)  $default,){
final _that = this;
switch (_that) {
case _AIDraftRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AIDraftRequest value)?  $default,){
final _that = this;
switch (_that) {
case _AIDraftRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: AIDraftRequest.contextKey_)  String? context)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AIDraftRequest() when $default != null:
return $default(_that.context);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: AIDraftRequest.contextKey_)  String? context)  $default,) {final _that = this;
switch (_that) {
case _AIDraftRequest():
return $default(_that.context);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: AIDraftRequest.contextKey_)  String? context)?  $default,) {final _that = this;
switch (_that) {
case _AIDraftRequest() when $default != null:
return $default(_that.context);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _AIDraftRequest extends AIDraftRequest {
  const _AIDraftRequest({@JsonKey(name: AIDraftRequest.contextKey_) this.context}): super._();
  factory _AIDraftRequest.fromJson(Map<String, dynamic> json) => _$AIDraftRequestFromJson(json);

/// context
@override@JsonKey(name: AIDraftRequest.contextKey_) final  String? context;

/// Create a copy of AIDraftRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AIDraftRequestCopyWith<_AIDraftRequest> get copyWith => __$AIDraftRequestCopyWithImpl<_AIDraftRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AIDraftRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AIDraftRequest&&(identical(other.context, context) || other.context == context));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,context);

@override
String toString() {
  return 'AIDraftRequest(context: $context)';
}


}

/// @nodoc
abstract mixin class _$AIDraftRequestCopyWith<$Res> implements $AIDraftRequestCopyWith<$Res> {
  factory _$AIDraftRequestCopyWith(_AIDraftRequest value, $Res Function(_AIDraftRequest) _then) = __$AIDraftRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: AIDraftRequest.contextKey_) String? context
});




}
/// @nodoc
class __$AIDraftRequestCopyWithImpl<$Res>
    implements _$AIDraftRequestCopyWith<$Res> {
  __$AIDraftRequestCopyWithImpl(this._self, this._then);

  final _AIDraftRequest _self;
  final $Res Function(_AIDraftRequest) _then;

/// Create a copy of AIDraftRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? context = freezed,}) {
  return _then(_AIDraftRequest(
context: freezed == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
