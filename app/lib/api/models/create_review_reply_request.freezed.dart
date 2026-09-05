// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_review_reply_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateReviewReplyRequest {

/// text
@JsonKey(name: CreateReviewReplyRequest.textKey_) String get text;
/// Create a copy of CreateReviewReplyRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateReviewReplyRequestCopyWith<CreateReviewReplyRequest> get copyWith => _$CreateReviewReplyRequestCopyWithImpl<CreateReviewReplyRequest>(this as CreateReviewReplyRequest, _$identity);

  /// Serializes this CreateReviewReplyRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateReviewReplyRequest&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text);

@override
String toString() {
  return 'CreateReviewReplyRequest(text: $text)';
}


}

/// @nodoc
abstract mixin class $CreateReviewReplyRequestCopyWith<$Res>  {
  factory $CreateReviewReplyRequestCopyWith(CreateReviewReplyRequest value, $Res Function(CreateReviewReplyRequest) _then) = _$CreateReviewReplyRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: CreateReviewReplyRequest.textKey_) String text
});




}
/// @nodoc
class _$CreateReviewReplyRequestCopyWithImpl<$Res>
    implements $CreateReviewReplyRequestCopyWith<$Res> {
  _$CreateReviewReplyRequestCopyWithImpl(this._self, this._then);

  final CreateReviewReplyRequest _self;
  final $Res Function(CreateReviewReplyRequest) _then;

/// Create a copy of CreateReviewReplyRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,}) {
  return _then(_self.copyWith(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateReviewReplyRequest].
extension CreateReviewReplyRequestPatterns on CreateReviewReplyRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateReviewReplyRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateReviewReplyRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateReviewReplyRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateReviewReplyRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateReviewReplyRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateReviewReplyRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: CreateReviewReplyRequest.textKey_)  String text)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateReviewReplyRequest() when $default != null:
return $default(_that.text);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: CreateReviewReplyRequest.textKey_)  String text)  $default,) {final _that = this;
switch (_that) {
case _CreateReviewReplyRequest():
return $default(_that.text);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: CreateReviewReplyRequest.textKey_)  String text)?  $default,) {final _that = this;
switch (_that) {
case _CreateReviewReplyRequest() when $default != null:
return $default(_that.text);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _CreateReviewReplyRequest extends CreateReviewReplyRequest {
  const _CreateReviewReplyRequest({@JsonKey(name: CreateReviewReplyRequest.textKey_) required this.text}): super._();
  factory _CreateReviewReplyRequest.fromJson(Map<String, dynamic> json) => _$CreateReviewReplyRequestFromJson(json);

/// text
@override@JsonKey(name: CreateReviewReplyRequest.textKey_) final  String text;

/// Create a copy of CreateReviewReplyRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateReviewReplyRequestCopyWith<_CreateReviewReplyRequest> get copyWith => __$CreateReviewReplyRequestCopyWithImpl<_CreateReviewReplyRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateReviewReplyRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateReviewReplyRequest&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text);

@override
String toString() {
  return 'CreateReviewReplyRequest(text: $text)';
}


}

/// @nodoc
abstract mixin class _$CreateReviewReplyRequestCopyWith<$Res> implements $CreateReviewReplyRequestCopyWith<$Res> {
  factory _$CreateReviewReplyRequestCopyWith(_CreateReviewReplyRequest value, $Res Function(_CreateReviewReplyRequest) _then) = __$CreateReviewReplyRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: CreateReviewReplyRequest.textKey_) String text
});




}
/// @nodoc
class __$CreateReviewReplyRequestCopyWithImpl<$Res>
    implements _$CreateReviewReplyRequestCopyWith<$Res> {
  __$CreateReviewReplyRequestCopyWithImpl(this._self, this._then);

  final _CreateReviewReplyRequest _self;
  final $Res Function(_CreateReviewReplyRequest) _then;

/// Create a copy of CreateReviewReplyRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,}) {
  return _then(_CreateReviewReplyRequest(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
