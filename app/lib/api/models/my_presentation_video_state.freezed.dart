// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'my_presentation_video_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MyPresentationVideoState {

/// available
@JsonKey(name: MyPresentationVideoState.availableKey_) bool get available;/// message
@JsonKey(name: MyPresentationVideoState.messageKey_) String? get message;/// maxSeconds
@JsonKey(name: MyPresentationVideoState.maxSecondsKey_) int get maxSeconds;/// maxBytes
@JsonKey(name: MyPresentationVideoState.maxBytesKey_) int get maxBytes;/// shown
@JsonKey(name: MyPresentationVideoState.shownKey_) MyPresentationVideo? get shown;/// pending
@JsonKey(name: MyPresentationVideoState.pendingKey_) MyPresentationVideo? get pending;
/// Create a copy of MyPresentationVideoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MyPresentationVideoStateCopyWith<MyPresentationVideoState> get copyWith => _$MyPresentationVideoStateCopyWithImpl<MyPresentationVideoState>(this as MyPresentationVideoState, _$identity);

  /// Serializes this MyPresentationVideoState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MyPresentationVideoState&&(identical(other.available, available) || other.available == available)&&(identical(other.message, message) || other.message == message)&&(identical(other.maxSeconds, maxSeconds) || other.maxSeconds == maxSeconds)&&(identical(other.maxBytes, maxBytes) || other.maxBytes == maxBytes)&&(identical(other.shown, shown) || other.shown == shown)&&(identical(other.pending, pending) || other.pending == pending));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,available,message,maxSeconds,maxBytes,shown,pending);

@override
String toString() {
  return 'MyPresentationVideoState(available: $available, message: $message, maxSeconds: $maxSeconds, maxBytes: $maxBytes, shown: $shown, pending: $pending)';
}


}

/// @nodoc
abstract mixin class $MyPresentationVideoStateCopyWith<$Res>  {
  factory $MyPresentationVideoStateCopyWith(MyPresentationVideoState value, $Res Function(MyPresentationVideoState) _then) = _$MyPresentationVideoStateCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: MyPresentationVideoState.availableKey_) bool available,@JsonKey(name: MyPresentationVideoState.messageKey_) String? message,@JsonKey(name: MyPresentationVideoState.maxSecondsKey_) int maxSeconds,@JsonKey(name: MyPresentationVideoState.maxBytesKey_) int maxBytes,@JsonKey(name: MyPresentationVideoState.shownKey_) MyPresentationVideo? shown,@JsonKey(name: MyPresentationVideoState.pendingKey_) MyPresentationVideo? pending
});


$MyPresentationVideoCopyWith<$Res>? get shown;$MyPresentationVideoCopyWith<$Res>? get pending;

}
/// @nodoc
class _$MyPresentationVideoStateCopyWithImpl<$Res>
    implements $MyPresentationVideoStateCopyWith<$Res> {
  _$MyPresentationVideoStateCopyWithImpl(this._self, this._then);

  final MyPresentationVideoState _self;
  final $Res Function(MyPresentationVideoState) _then;

/// Create a copy of MyPresentationVideoState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? available = null,Object? message = freezed,Object? maxSeconds = null,Object? maxBytes = null,Object? shown = freezed,Object? pending = freezed,}) {
  return _then(_self.copyWith(
available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,maxSeconds: null == maxSeconds ? _self.maxSeconds : maxSeconds // ignore: cast_nullable_to_non_nullable
as int,maxBytes: null == maxBytes ? _self.maxBytes : maxBytes // ignore: cast_nullable_to_non_nullable
as int,shown: freezed == shown ? _self.shown : shown // ignore: cast_nullable_to_non_nullable
as MyPresentationVideo?,pending: freezed == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as MyPresentationVideo?,
  ));
}
/// Create a copy of MyPresentationVideoState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MyPresentationVideoCopyWith<$Res>? get shown {
    if (_self.shown == null) {
    return null;
  }

  return $MyPresentationVideoCopyWith<$Res>(_self.shown!, (value) {
    return _then(_self.copyWith(shown: value));
  });
}/// Create a copy of MyPresentationVideoState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MyPresentationVideoCopyWith<$Res>? get pending {
    if (_self.pending == null) {
    return null;
  }

  return $MyPresentationVideoCopyWith<$Res>(_self.pending!, (value) {
    return _then(_self.copyWith(pending: value));
  });
}
}


/// Adds pattern-matching-related methods to [MyPresentationVideoState].
extension MyPresentationVideoStatePatterns on MyPresentationVideoState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MyPresentationVideoState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MyPresentationVideoState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MyPresentationVideoState value)  $default,){
final _that = this;
switch (_that) {
case _MyPresentationVideoState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MyPresentationVideoState value)?  $default,){
final _that = this;
switch (_that) {
case _MyPresentationVideoState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: MyPresentationVideoState.availableKey_)  bool available, @JsonKey(name: MyPresentationVideoState.messageKey_)  String? message, @JsonKey(name: MyPresentationVideoState.maxSecondsKey_)  int maxSeconds, @JsonKey(name: MyPresentationVideoState.maxBytesKey_)  int maxBytes, @JsonKey(name: MyPresentationVideoState.shownKey_)  MyPresentationVideo? shown, @JsonKey(name: MyPresentationVideoState.pendingKey_)  MyPresentationVideo? pending)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MyPresentationVideoState() when $default != null:
return $default(_that.available,_that.message,_that.maxSeconds,_that.maxBytes,_that.shown,_that.pending);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: MyPresentationVideoState.availableKey_)  bool available, @JsonKey(name: MyPresentationVideoState.messageKey_)  String? message, @JsonKey(name: MyPresentationVideoState.maxSecondsKey_)  int maxSeconds, @JsonKey(name: MyPresentationVideoState.maxBytesKey_)  int maxBytes, @JsonKey(name: MyPresentationVideoState.shownKey_)  MyPresentationVideo? shown, @JsonKey(name: MyPresentationVideoState.pendingKey_)  MyPresentationVideo? pending)  $default,) {final _that = this;
switch (_that) {
case _MyPresentationVideoState():
return $default(_that.available,_that.message,_that.maxSeconds,_that.maxBytes,_that.shown,_that.pending);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: MyPresentationVideoState.availableKey_)  bool available, @JsonKey(name: MyPresentationVideoState.messageKey_)  String? message, @JsonKey(name: MyPresentationVideoState.maxSecondsKey_)  int maxSeconds, @JsonKey(name: MyPresentationVideoState.maxBytesKey_)  int maxBytes, @JsonKey(name: MyPresentationVideoState.shownKey_)  MyPresentationVideo? shown, @JsonKey(name: MyPresentationVideoState.pendingKey_)  MyPresentationVideo? pending)?  $default,) {final _that = this;
switch (_that) {
case _MyPresentationVideoState() when $default != null:
return $default(_that.available,_that.message,_that.maxSeconds,_that.maxBytes,_that.shown,_that.pending);case _:
  return null;

}
}

}

/// @nodoc

@jsonSerializable
class _MyPresentationVideoState extends MyPresentationVideoState {
  const _MyPresentationVideoState({@JsonKey(name: MyPresentationVideoState.availableKey_) required this.available, @JsonKey(name: MyPresentationVideoState.messageKey_) this.message, @JsonKey(name: MyPresentationVideoState.maxSecondsKey_) required this.maxSeconds, @JsonKey(name: MyPresentationVideoState.maxBytesKey_) required this.maxBytes, @JsonKey(name: MyPresentationVideoState.shownKey_) this.shown, @JsonKey(name: MyPresentationVideoState.pendingKey_) this.pending}): super._();
  factory _MyPresentationVideoState.fromJson(Map<String, dynamic> json) => _$MyPresentationVideoStateFromJson(json);

/// available
@override@JsonKey(name: MyPresentationVideoState.availableKey_) final  bool available;
/// message
@override@JsonKey(name: MyPresentationVideoState.messageKey_) final  String? message;
/// maxSeconds
@override@JsonKey(name: MyPresentationVideoState.maxSecondsKey_) final  int maxSeconds;
/// maxBytes
@override@JsonKey(name: MyPresentationVideoState.maxBytesKey_) final  int maxBytes;
/// shown
@override@JsonKey(name: MyPresentationVideoState.shownKey_) final  MyPresentationVideo? shown;
/// pending
@override@JsonKey(name: MyPresentationVideoState.pendingKey_) final  MyPresentationVideo? pending;

/// Create a copy of MyPresentationVideoState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MyPresentationVideoStateCopyWith<_MyPresentationVideoState> get copyWith => __$MyPresentationVideoStateCopyWithImpl<_MyPresentationVideoState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MyPresentationVideoStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MyPresentationVideoState&&(identical(other.available, available) || other.available == available)&&(identical(other.message, message) || other.message == message)&&(identical(other.maxSeconds, maxSeconds) || other.maxSeconds == maxSeconds)&&(identical(other.maxBytes, maxBytes) || other.maxBytes == maxBytes)&&(identical(other.shown, shown) || other.shown == shown)&&(identical(other.pending, pending) || other.pending == pending));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,available,message,maxSeconds,maxBytes,shown,pending);

@override
String toString() {
  return 'MyPresentationVideoState(available: $available, message: $message, maxSeconds: $maxSeconds, maxBytes: $maxBytes, shown: $shown, pending: $pending)';
}


}

/// @nodoc
abstract mixin class _$MyPresentationVideoStateCopyWith<$Res> implements $MyPresentationVideoStateCopyWith<$Res> {
  factory _$MyPresentationVideoStateCopyWith(_MyPresentationVideoState value, $Res Function(_MyPresentationVideoState) _then) = __$MyPresentationVideoStateCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: MyPresentationVideoState.availableKey_) bool available,@JsonKey(name: MyPresentationVideoState.messageKey_) String? message,@JsonKey(name: MyPresentationVideoState.maxSecondsKey_) int maxSeconds,@JsonKey(name: MyPresentationVideoState.maxBytesKey_) int maxBytes,@JsonKey(name: MyPresentationVideoState.shownKey_) MyPresentationVideo? shown,@JsonKey(name: MyPresentationVideoState.pendingKey_) MyPresentationVideo? pending
});


@override $MyPresentationVideoCopyWith<$Res>? get shown;@override $MyPresentationVideoCopyWith<$Res>? get pending;

}
/// @nodoc
class __$MyPresentationVideoStateCopyWithImpl<$Res>
    implements _$MyPresentationVideoStateCopyWith<$Res> {
  __$MyPresentationVideoStateCopyWithImpl(this._self, this._then);

  final _MyPresentationVideoState _self;
  final $Res Function(_MyPresentationVideoState) _then;

/// Create a copy of MyPresentationVideoState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? available = null,Object? message = freezed,Object? maxSeconds = null,Object? maxBytes = null,Object? shown = freezed,Object? pending = freezed,}) {
  return _then(_MyPresentationVideoState(
available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,maxSeconds: null == maxSeconds ? _self.maxSeconds : maxSeconds // ignore: cast_nullable_to_non_nullable
as int,maxBytes: null == maxBytes ? _self.maxBytes : maxBytes // ignore: cast_nullable_to_non_nullable
as int,shown: freezed == shown ? _self.shown : shown // ignore: cast_nullable_to_non_nullable
as MyPresentationVideo?,pending: freezed == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as MyPresentationVideo?,
  ));
}

/// Create a copy of MyPresentationVideoState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MyPresentationVideoCopyWith<$Res>? get shown {
    if (_self.shown == null) {
    return null;
  }

  return $MyPresentationVideoCopyWith<$Res>(_self.shown!, (value) {
    return _then(_self.copyWith(shown: value));
  });
}/// Create a copy of MyPresentationVideoState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MyPresentationVideoCopyWith<$Res>? get pending {
    if (_self.pending == null) {
    return null;
  }

  return $MyPresentationVideoCopyWith<$Res>(_self.pending!, (value) {
    return _then(_self.copyWith(pending: value));
  });
}
}

// dart format on
