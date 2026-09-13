// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'zip_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ZipEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ZipEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ZipEvent()';
}


}

/// @nodoc
class $ZipEventCopyWith<$Res>  {
$ZipEventCopyWith(ZipEvent _, $Res Function(ZipEvent) __);
}


/// Adds pattern-matching-related methods to [ZipEvent].
extension ZipEventPatterns on ZipEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ZipStarted value)?  started,TResult Function( ZipCompleted value)?  completed,TResult Function( ZipNavigationHandled value)?  navigationHandled,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ZipStarted() when started != null:
return started(_that);case ZipCompleted() when completed != null:
return completed(_that);case ZipNavigationHandled() when navigationHandled != null:
return navigationHandled(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ZipStarted value)  started,required TResult Function( ZipCompleted value)  completed,required TResult Function( ZipNavigationHandled value)  navigationHandled,}){
final _that = this;
switch (_that) {
case ZipStarted():
return started(_that);case ZipCompleted():
return completed(_that);case ZipNavigationHandled():
return navigationHandled(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ZipStarted value)?  started,TResult? Function( ZipCompleted value)?  completed,TResult? Function( ZipNavigationHandled value)?  navigationHandled,}){
final _that = this;
switch (_that) {
case ZipStarted() when started != null:
return started(_that);case ZipCompleted() when completed != null:
return completed(_that);case ZipNavigationHandled() when navigationHandled != null:
return navigationHandled(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( DateTime? date)?  started,TResult Function( int points,  int timeSeconds)?  completed,TResult Function()?  navigationHandled,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ZipStarted() when started != null:
return started(_that.date);case ZipCompleted() when completed != null:
return completed(_that.points,_that.timeSeconds);case ZipNavigationHandled() when navigationHandled != null:
return navigationHandled();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( DateTime? date)  started,required TResult Function( int points,  int timeSeconds)  completed,required TResult Function()  navigationHandled,}) {final _that = this;
switch (_that) {
case ZipStarted():
return started(_that.date);case ZipCompleted():
return completed(_that.points,_that.timeSeconds);case ZipNavigationHandled():
return navigationHandled();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( DateTime? date)?  started,TResult? Function( int points,  int timeSeconds)?  completed,TResult? Function()?  navigationHandled,}) {final _that = this;
switch (_that) {
case ZipStarted() when started != null:
return started(_that.date);case ZipCompleted() when completed != null:
return completed(_that.points,_that.timeSeconds);case ZipNavigationHandled() when navigationHandled != null:
return navigationHandled();case _:
  return null;

}
}

}

/// @nodoc


class ZipStarted implements ZipEvent {
  const ZipStarted({this.date});
  

 final  DateTime? date;

/// Create a copy of ZipEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ZipStartedCopyWith<ZipStarted> get copyWith => _$ZipStartedCopyWithImpl<ZipStarted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ZipStarted&&(identical(other.date, date) || other.date == date));
}


@override
int get hashCode => Object.hash(runtimeType,date);

@override
String toString() {
  return 'ZipEvent.started(date: $date)';
}


}

/// @nodoc
abstract mixin class $ZipStartedCopyWith<$Res> implements $ZipEventCopyWith<$Res> {
  factory $ZipStartedCopyWith(ZipStarted value, $Res Function(ZipStarted) _then) = _$ZipStartedCopyWithImpl;
@useResult
$Res call({
 DateTime? date
});




}
/// @nodoc
class _$ZipStartedCopyWithImpl<$Res>
    implements $ZipStartedCopyWith<$Res> {
  _$ZipStartedCopyWithImpl(this._self, this._then);

  final ZipStarted _self;
  final $Res Function(ZipStarted) _then;

/// Create a copy of ZipEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? date = freezed,}) {
  return _then(ZipStarted(
date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc


class ZipCompleted implements ZipEvent {
  const ZipCompleted({required this.points, required this.timeSeconds});
  

 final  int points;
 final  int timeSeconds;

/// Create a copy of ZipEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ZipCompletedCopyWith<ZipCompleted> get copyWith => _$ZipCompletedCopyWithImpl<ZipCompleted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ZipCompleted&&(identical(other.points, points) || other.points == points)&&(identical(other.timeSeconds, timeSeconds) || other.timeSeconds == timeSeconds));
}


@override
int get hashCode => Object.hash(runtimeType,points,timeSeconds);

@override
String toString() {
  return 'ZipEvent.completed(points: $points, timeSeconds: $timeSeconds)';
}


}

/// @nodoc
abstract mixin class $ZipCompletedCopyWith<$Res> implements $ZipEventCopyWith<$Res> {
  factory $ZipCompletedCopyWith(ZipCompleted value, $Res Function(ZipCompleted) _then) = _$ZipCompletedCopyWithImpl;
@useResult
$Res call({
 int points, int timeSeconds
});




}
/// @nodoc
class _$ZipCompletedCopyWithImpl<$Res>
    implements $ZipCompletedCopyWith<$Res> {
  _$ZipCompletedCopyWithImpl(this._self, this._then);

  final ZipCompleted _self;
  final $Res Function(ZipCompleted) _then;

/// Create a copy of ZipEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? points = null,Object? timeSeconds = null,}) {
  return _then(ZipCompleted(
points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,timeSeconds: null == timeSeconds ? _self.timeSeconds : timeSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class ZipNavigationHandled implements ZipEvent {
  const ZipNavigationHandled();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ZipNavigationHandled);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ZipEvent.navigationHandled()';
}


}




// dart format on
