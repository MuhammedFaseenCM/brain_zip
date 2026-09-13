// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'word_match_play_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WordMatchPlayEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WordMatchPlayEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'WordMatchPlayEvent()';
}


}

/// @nodoc
class $WordMatchPlayEventCopyWith<$Res>  {
$WordMatchPlayEventCopyWith(WordMatchPlayEvent _, $Res Function(WordMatchPlayEvent) __);
}


/// Adds pattern-matching-related methods to [WordMatchPlayEvent].
extension WordMatchPlayEventPatterns on WordMatchPlayEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( WordMatchPlayStarted value)?  started,TResult Function( WordMatchPlayTick value)?  tick,TResult Function( WordMatchPlayProgressChanged value)?  progressChanged,TResult Function( WordMatchPlayWon value)?  won,required TResult orElse(),}){
final _that = this;
switch (_that) {
case WordMatchPlayStarted() when started != null:
return started(_that);case WordMatchPlayTick() when tick != null:
return tick(_that);case WordMatchPlayProgressChanged() when progressChanged != null:
return progressChanged(_that);case WordMatchPlayWon() when won != null:
return won(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( WordMatchPlayStarted value)  started,required TResult Function( WordMatchPlayTick value)  tick,required TResult Function( WordMatchPlayProgressChanged value)  progressChanged,required TResult Function( WordMatchPlayWon value)  won,}){
final _that = this;
switch (_that) {
case WordMatchPlayStarted():
return started(_that);case WordMatchPlayTick():
return tick(_that);case WordMatchPlayProgressChanged():
return progressChanged(_that);case WordMatchPlayWon():
return won(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( WordMatchPlayStarted value)?  started,TResult? Function( WordMatchPlayTick value)?  tick,TResult? Function( WordMatchPlayProgressChanged value)?  progressChanged,TResult? Function( WordMatchPlayWon value)?  won,}){
final _that = this;
switch (_that) {
case WordMatchPlayStarted() when started != null:
return started(_that);case WordMatchPlayTick() when tick != null:
return tick(_that);case WordMatchPlayProgressChanged() when progressChanged != null:
return progressChanged(_that);case WordMatchPlayWon() when won != null:
return won(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String deckId)?  started,TResult Function()?  tick,TResult Function( int matched,  int total)?  progressChanged,TResult Function( int points,  int elapsedSeconds)?  won,required TResult orElse(),}) {final _that = this;
switch (_that) {
case WordMatchPlayStarted() when started != null:
return started(_that.deckId);case WordMatchPlayTick() when tick != null:
return tick();case WordMatchPlayProgressChanged() when progressChanged != null:
return progressChanged(_that.matched,_that.total);case WordMatchPlayWon() when won != null:
return won(_that.points,_that.elapsedSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String deckId)  started,required TResult Function()  tick,required TResult Function( int matched,  int total)  progressChanged,required TResult Function( int points,  int elapsedSeconds)  won,}) {final _that = this;
switch (_that) {
case WordMatchPlayStarted():
return started(_that.deckId);case WordMatchPlayTick():
return tick();case WordMatchPlayProgressChanged():
return progressChanged(_that.matched,_that.total);case WordMatchPlayWon():
return won(_that.points,_that.elapsedSeconds);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String deckId)?  started,TResult? Function()?  tick,TResult? Function( int matched,  int total)?  progressChanged,TResult? Function( int points,  int elapsedSeconds)?  won,}) {final _that = this;
switch (_that) {
case WordMatchPlayStarted() when started != null:
return started(_that.deckId);case WordMatchPlayTick() when tick != null:
return tick();case WordMatchPlayProgressChanged() when progressChanged != null:
return progressChanged(_that.matched,_that.total);case WordMatchPlayWon() when won != null:
return won(_that.points,_that.elapsedSeconds);case _:
  return null;

}
}

}

/// @nodoc


class WordMatchPlayStarted implements WordMatchPlayEvent {
  const WordMatchPlayStarted({required this.deckId});
  

 final  String deckId;

/// Create a copy of WordMatchPlayEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WordMatchPlayStartedCopyWith<WordMatchPlayStarted> get copyWith => _$WordMatchPlayStartedCopyWithImpl<WordMatchPlayStarted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WordMatchPlayStarted&&(identical(other.deckId, deckId) || other.deckId == deckId));
}


@override
int get hashCode => Object.hash(runtimeType,deckId);

@override
String toString() {
  return 'WordMatchPlayEvent.started(deckId: $deckId)';
}


}

/// @nodoc
abstract mixin class $WordMatchPlayStartedCopyWith<$Res> implements $WordMatchPlayEventCopyWith<$Res> {
  factory $WordMatchPlayStartedCopyWith(WordMatchPlayStarted value, $Res Function(WordMatchPlayStarted) _then) = _$WordMatchPlayStartedCopyWithImpl;
@useResult
$Res call({
 String deckId
});




}
/// @nodoc
class _$WordMatchPlayStartedCopyWithImpl<$Res>
    implements $WordMatchPlayStartedCopyWith<$Res> {
  _$WordMatchPlayStartedCopyWithImpl(this._self, this._then);

  final WordMatchPlayStarted _self;
  final $Res Function(WordMatchPlayStarted) _then;

/// Create a copy of WordMatchPlayEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? deckId = null,}) {
  return _then(WordMatchPlayStarted(
deckId: null == deckId ? _self.deckId : deckId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class WordMatchPlayTick implements WordMatchPlayEvent {
  const WordMatchPlayTick();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WordMatchPlayTick);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'WordMatchPlayEvent.tick()';
}


}




/// @nodoc


class WordMatchPlayProgressChanged implements WordMatchPlayEvent {
  const WordMatchPlayProgressChanged({required this.matched, required this.total});
  

 final  int matched;
 final  int total;

/// Create a copy of WordMatchPlayEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WordMatchPlayProgressChangedCopyWith<WordMatchPlayProgressChanged> get copyWith => _$WordMatchPlayProgressChangedCopyWithImpl<WordMatchPlayProgressChanged>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WordMatchPlayProgressChanged&&(identical(other.matched, matched) || other.matched == matched)&&(identical(other.total, total) || other.total == total));
}


@override
int get hashCode => Object.hash(runtimeType,matched,total);

@override
String toString() {
  return 'WordMatchPlayEvent.progressChanged(matched: $matched, total: $total)';
}


}

/// @nodoc
abstract mixin class $WordMatchPlayProgressChangedCopyWith<$Res> implements $WordMatchPlayEventCopyWith<$Res> {
  factory $WordMatchPlayProgressChangedCopyWith(WordMatchPlayProgressChanged value, $Res Function(WordMatchPlayProgressChanged) _then) = _$WordMatchPlayProgressChangedCopyWithImpl;
@useResult
$Res call({
 int matched, int total
});




}
/// @nodoc
class _$WordMatchPlayProgressChangedCopyWithImpl<$Res>
    implements $WordMatchPlayProgressChangedCopyWith<$Res> {
  _$WordMatchPlayProgressChangedCopyWithImpl(this._self, this._then);

  final WordMatchPlayProgressChanged _self;
  final $Res Function(WordMatchPlayProgressChanged) _then;

/// Create a copy of WordMatchPlayEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? matched = null,Object? total = null,}) {
  return _then(WordMatchPlayProgressChanged(
matched: null == matched ? _self.matched : matched // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class WordMatchPlayWon implements WordMatchPlayEvent {
  const WordMatchPlayWon({required this.points, required this.elapsedSeconds});
  

 final  int points;
 final  int elapsedSeconds;

/// Create a copy of WordMatchPlayEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WordMatchPlayWonCopyWith<WordMatchPlayWon> get copyWith => _$WordMatchPlayWonCopyWithImpl<WordMatchPlayWon>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WordMatchPlayWon&&(identical(other.points, points) || other.points == points)&&(identical(other.elapsedSeconds, elapsedSeconds) || other.elapsedSeconds == elapsedSeconds));
}


@override
int get hashCode => Object.hash(runtimeType,points,elapsedSeconds);

@override
String toString() {
  return 'WordMatchPlayEvent.won(points: $points, elapsedSeconds: $elapsedSeconds)';
}


}

/// @nodoc
abstract mixin class $WordMatchPlayWonCopyWith<$Res> implements $WordMatchPlayEventCopyWith<$Res> {
  factory $WordMatchPlayWonCopyWith(WordMatchPlayWon value, $Res Function(WordMatchPlayWon) _then) = _$WordMatchPlayWonCopyWithImpl;
@useResult
$Res call({
 int points, int elapsedSeconds
});




}
/// @nodoc
class _$WordMatchPlayWonCopyWithImpl<$Res>
    implements $WordMatchPlayWonCopyWith<$Res> {
  _$WordMatchPlayWonCopyWithImpl(this._self, this._then);

  final WordMatchPlayWon _self;
  final $Res Function(WordMatchPlayWon) _then;

/// Create a copy of WordMatchPlayEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? points = null,Object? elapsedSeconds = null,}) {
  return _then(WordMatchPlayWon(
points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,elapsedSeconds: null == elapsedSeconds ? _self.elapsedSeconds : elapsedSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
