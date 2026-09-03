// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'call_summary_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CallSummaryResponse {

/// id
@JsonKey(name: CallSummaryResponse.idKey_) String get id;/// summary
@JsonKey(name: CallSummaryResponse.summaryKey_) String get summary;/// metadata
@JsonKey(name: CallSummaryResponse.metadataKey_) Map<String, dynamic> get metadata;
/// Create a copy of CallSummaryResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CallSummaryResponseCopyWith<CallSummaryResponse> get copyWith => _$CallSummaryResponseCopyWithImpl<CallSummaryResponse>(this as CallSummaryResponse, _$identity);

  /// Serializes this CallSummaryResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CallSummaryResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,summary,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'CallSummaryResponse(id: $id, summary: $summary, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $CallSummaryResponseCopyWith<$Res>  {
  factory $CallSummaryResponseCopyWith(CallSummaryResponse value, $Res Function(CallSummaryResponse) _then) = _$CallSummaryResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: CallSummaryResponse.idKey_) String id,@JsonKey(name: CallSummaryResponse.summaryKey_) String summary,@JsonKey(name: CallSummaryResponse.metadataKey_) Map<String, dynamic> metadata
});




}
/// @nodoc
class _$CallSummaryResponseCopyWithImpl<$Res>
    implements $CallSummaryResponseCopyWith<$Res> {
  _$CallSummaryResponseCopyWithImpl(this._self, this._then);

  final CallSummaryResponse _self;
  final $Res Function(CallSummaryResponse) _then;

/// Create a copy of CallSummaryResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? summary = null,Object? metadata = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [CallSummaryResponse].
extension CallSummaryResponsePatterns on CallSummaryResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CallSummaryResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CallSummaryResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CallSummaryResponse value)  $default,){
final _that = this;
switch (_that) {
case _CallSummaryResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CallSummaryResponse value)?  $default,){
final _that = this;
switch (_that) {
case _CallSummaryResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: CallSummaryResponse.idKey_)  String id, @JsonKey(name: CallSummaryResponse.summaryKey_)  String summary, @JsonKey(name: CallSummaryResponse.metadataKey_)  Map<String, dynamic> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CallSummaryResponse() when $default != null:
return $default(_that.id,_that.summary,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: CallSummaryResponse.idKey_)  String id, @JsonKey(name: CallSummaryResponse.summaryKey_)  String summary, @JsonKey(name: CallSummaryResponse.metadataKey_)  Map<String, dynamic> metadata)  $default,) {final _that = this;
switch (_that) {
case _CallSummaryResponse():
return $default(_that.id,_that.summary,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: CallSummaryResponse.idKey_)  String id, @JsonKey(name: CallSummaryResponse.summaryKey_)  String summary, @JsonKey(name: CallSummaryResponse.metadataKey_)  Map<String, dynamic> metadata)?  $default,) {final _that = this;
switch (_that) {
case _CallSummaryResponse() when $default != null:
return $default(_that.id,_that.summary,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _CallSummaryResponse extends CallSummaryResponse {
  const _CallSummaryResponse({@JsonKey(name: CallSummaryResponse.idKey_) required this.id, @JsonKey(name: CallSummaryResponse.summaryKey_) required this.summary, @JsonKey(name: CallSummaryResponse.metadataKey_) required final  Map<String, dynamic> metadata}): _metadata = metadata,super._();
  factory _CallSummaryResponse.fromJson(Map<String, dynamic> json) => _$CallSummaryResponseFromJson(json);

/// id
@override@JsonKey(name: CallSummaryResponse.idKey_) final  String id;
/// summary
@override@JsonKey(name: CallSummaryResponse.summaryKey_) final  String summary;
/// metadata
 final  Map<String, dynamic> _metadata;
/// metadata
@override@JsonKey(name: CallSummaryResponse.metadataKey_) Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}


/// Create a copy of CallSummaryResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CallSummaryResponseCopyWith<_CallSummaryResponse> get copyWith => __$CallSummaryResponseCopyWithImpl<_CallSummaryResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CallSummaryResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CallSummaryResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,summary,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'CallSummaryResponse(id: $id, summary: $summary, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$CallSummaryResponseCopyWith<$Res> implements $CallSummaryResponseCopyWith<$Res> {
  factory _$CallSummaryResponseCopyWith(_CallSummaryResponse value, $Res Function(_CallSummaryResponse) _then) = __$CallSummaryResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: CallSummaryResponse.idKey_) String id,@JsonKey(name: CallSummaryResponse.summaryKey_) String summary,@JsonKey(name: CallSummaryResponse.metadataKey_) Map<String, dynamic> metadata
});




}
/// @nodoc
class __$CallSummaryResponseCopyWithImpl<$Res>
    implements _$CallSummaryResponseCopyWith<$Res> {
  __$CallSummaryResponseCopyWithImpl(this._self, this._then);

  final _CallSummaryResponse _self;
  final $Res Function(_CallSummaryResponse) _then;

/// Create a copy of CallSummaryResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? summary = null,Object? metadata = null,}) {
  return _then(_CallSummaryResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
